import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/permissions.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../routes.dart';
import '../../repositories/reviews_repo.dart';
import '../../models/review.dart';
import '../../core/theme.dart';

/// Vendor Flags Queue Screen
/// Shows flagged reviews and lets admins resolve (approve/hide/remove)
class VendorFlagsQueueScreen extends ConsumerStatefulWidget {
  const VendorFlagsQueueScreen({super.key});

  @override
  ConsumerState<VendorFlagsQueueScreen> createState() =>
      _VendorFlagsQueueScreenState();
}

class _VendorFlagsQueueScreenState
    extends ConsumerState<VendorFlagsQueueScreen> {
  bool _isLoading = true;
  Object? _error;
  List<Review> _flagged = [];
  bool _showResolved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(reviewsRepositoryProvider);
      final page = await repo.list(
        flagged: true,
        limit: 200,
        status: _showResolved ? null : 'pending',
      );
      setState(() {
        _flagged = page.items.where((r) => r.isFlagged).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check for either reviews:update OR reviews.moderate (backend uses dots)
    final hasUpdate =
        can(ref, Permissions.reviewsUpdate) || can(ref, 'reviews.moderate');

    return AdminScaffold(
      currentRoute: AppRoute.reviews,
      title: 'Vendor Flags Queue',
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                FilterChip(
                  label: const Text('Include Resolved'),
                  selected: _showResolved,
                  onSelected: (v) {
                    setState(() => _showResolved = v);
                    _load();
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasUpdate)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'You lack permissions to update reviews',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              )
            else if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Failed to load flagged reviews',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('$_error'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_flagged.isEmpty)
              const Center(child: Text('No flagged reviews'))
            else ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _flagged
                    .map((r) => _FlaggedReviewCard(review: r, onAction: _load))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlaggedReviewCard extends ConsumerStatefulWidget {
  const _FlaggedReviewCard({required this.review, required this.onAction});
  final Review review;
  final VoidCallback onAction;
  @override
  ConsumerState<_FlaggedReviewCard> createState() => _FlaggedReviewCardState();
}

class _FlaggedReviewCardState extends ConsumerState<_FlaggedReviewCard> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    return SizedBox(
      width: 340,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag, color: AppTheme.dangerRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Review #${r.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _StatusChip(status: r.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(r.comment, maxLines: 4, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(
                'Flag: ${r.flagReason}',
                style: TextStyle(color: AppTheme.dangerRed, fontSize: 12),
              ),
              const Divider(height: 20),
              if (_busy) const LinearProgressIndicator(minHeight: 4),
              if (!_busy)
                Row(
                  children: [
                    if (r.isPending || r.isHidden)
                      IconButton(
                        tooltip: 'Approve',
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onPressed: () => _action(
                          () =>
                              ref.read(reviewsRepositoryProvider).approve(r.id),
                        ),
                      ),
                    if (r.isApproved || r.isPending)
                      IconButton(
                        tooltip: 'Hide',
                        icon: const Icon(Icons.visibility_off),
                        onPressed: () => _dialogReason(
                          'Hide reason',
                          (reason) => ref
                              .read(reviewsRepositoryProvider)
                              .hide(r.id, reason: reason),
                        ),
                      ),
                    if (r.isHidden)
                      IconButton(
                        tooltip: 'Restore',
                        icon: const Icon(Icons.restore, color: Colors.blue),
                        onPressed: () => _action(
                          () =>
                              ref.read(reviewsRepositoryProvider).restore(r.id),
                        ),
                      ),
                    if (!r.isRemoved)
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        onPressed: () => _dialogReason(
                          'Removal reason',
                          (reason) => ref
                              .read(reviewsRepositoryProvider)
                              .remove(r.id, reason: reason),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _action(Future<dynamic> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
      widget.onAction();
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _dialogReason(
    String title,
    Future<dynamic> Function(String reason) fn,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) =>
          _ReasonDialog(title: title, prompt: 'Provide a reason'),
    );
    if (reason == null || reason.isEmpty) return;
    await _action(() => fn(reason));
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action failed: $e'),
        backgroundColor: AppTheme.dangerRed,
      ),
    );
  }
}

// Reuse existing status chip from reviews_list_screen via a minimal copy (could refactor later)
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'hidden':
        color = Colors.grey;
        icon = Icons.visibility_off;
        break;
      case 'removed':
        color = AppTheme.dangerRed;
        icon = Icons.delete_forever;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
    }
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.zero,
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.title, required this.prompt});
  final String title;
  final String prompt;
  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.prompt,
          border: const OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
