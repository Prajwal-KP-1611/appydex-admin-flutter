import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../models/review.dart';
import '../../repositories/reviews_repo.dart';
import '../../routes.dart';
import '../../core/permissions.dart';

/// Reviews moderation screen
/// Allows admins to approve, hide, remove, and restore reviews
class ReviewsListScreen extends ConsumerStatefulWidget {
  const ReviewsListScreen({super.key});

  @override
  ConsumerState<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends ConsumerState<ReviewsListScreen> {
  String? _statusFilter;
  bool? _flaggedFilter;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewsProvider);

    return AdminScaffold(
      currentRoute: AppRoute.reviews,
      title: 'Reviews Moderation',
      child: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Status filter
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String?>(
                        segments: const [
                          ButtonSegment(
                            value: null,
                            label: Text('All'),
                            icon: Icon(Icons.list, size: 16),
                          ),
                          ButtonSegment(
                            value: 'pending',
                            label: Text('Pending'),
                            icon: Icon(Icons.hourglass_empty, size: 16),
                          ),
                          ButtonSegment(
                            value: 'approved',
                            label: Text('Approved'),
                            icon: Icon(Icons.check_circle, size: 16),
                          ),
                          ButtonSegment(
                            value: 'hidden',
                            label: Text('Hidden'),
                            icon: Icon(Icons.visibility_off, size: 16),
                          ),
                          ButtonSegment(
                            value: 'removed',
                            label: Text('Removed'),
                            icon: Icon(Icons.delete_forever, size: 16),
                          ),
                        ],
                        selected: {_statusFilter},
                        onSelectionChanged: (Set<String?> newSelection) {
                          setState(() => _statusFilter = newSelection.first);
                          ref
                              .read(reviewsProvider.notifier)
                              .filterByStatus(newSelection.first);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Flagged filter + refresh
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Flagged Only'),
                      selected: _flaggedFilter == true,
                      onSelected: (selected) {
                        setState(() => _flaggedFilter = selected ? true : null);
                        ref
                            .read(reviewsProvider.notifier)
                            .filterByFlagged(_flaggedFilter);
                      },
                      avatar: const Icon(Icons.flag, size: 16),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/reviews/flags'),
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Flags Queue'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _statusFilter = null;
                          _flaggedFilter = null;
                        });
                        ref.read(reviewsProvider.notifier).clearFilters();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Clear Filters'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Reviews list
          Expanded(
            child: reviewsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Failed to load reviews: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(reviewsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (pagination) {
                final reviews = pagination.items;

                if (reviews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusFilter != null || _flaggedFilter != null
                              ? 'No matching reviews found'
                              : 'No reviews yet',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      Row(
                        children: [
                          _StatCard(
                            title: 'Total Reviews',
                            value: pagination.total.toString(),
                            icon: Icons.rate_review,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Pending',
                            value: reviews.where((r) => r.isPending).length.toString(),
                            icon: Icons.hourglass_empty,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Flagged',
                            value: reviews.where((r) => r.isFlagged).length.toString(),
                            icon: Icons.flag,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Reviews cards
                      ...reviews.map(
                        (review) => _ReviewCard(
                          review: review,
                          onAction: () => ref.read(reviewsProvider.notifier).load(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pagination info
                      if (pagination.total > pagination.items.length)
                        Text(
                          'Showing ${pagination.items.length} of ${pagination.total} reviews',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
}

class _ReviewCard extends ConsumerStatefulWidget {
  const _ReviewCard({required this.review, required this.onAction});

  final Review review;
  final VoidCallback onAction;

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final hasUpdatePermission = can(ref, Permissions.reviewsUpdate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Rating stars
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: 20,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${review.rating}/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Status chip
                _StatusChip(status: review.status),
                if (review.isFlagged) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text(
                      'FLAGGED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    avatar: const Icon(Icons.flag, size: 14),
                    backgroundColor: AppTheme.dangerRed.withOpacity(0.1),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Review comment
            Text(
              review.comment,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),

            // Metadata
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _MetaItem(
                  icon: Icons.store,
                  label: 'Vendor',
                  value: review.vendorName ?? 'ID: ${review.vendorId}',
                ),
                _MetaItem(
                  icon: Icons.person,
                  label: 'User',
                  value: review.userName ?? 'ID: ${review.userId}',
                ),
                _MetaItem(
                  icon: Icons.calendar_today,
                  label: 'Created',
                  value: _formatDate(review.createdAt),
                ),
                if (review.isFlagged)
                  _MetaItem(
                    icon: Icons.report,
                    label: 'Flag Reason',
                    value: review.flagReason!,
                    color: AppTheme.dangerRed,
                  ),
              ],
            ),

            if (review.adminNotes != null && review.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Admin Notes: ${review.adminNotes}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Action buttons
            Row(
              children: [
                if (hasUpdatePermission && (review.isPending || review.isHidden)) ...[
                  FilledButton.icon(
                    onPressed: _isProcessing ? null : () => _approveReview(),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (hasUpdatePermission && (review.isApproved || review.isPending)) ...[
                  OutlinedButton.icon(
                    onPressed: _isProcessing ? null : () => _hideReview(),
                    icon: const Icon(Icons.visibility_off, size: 18),
                    label: const Text('Hide'),
                  ),
                  const SizedBox(width: 12),
                ],
                if (hasUpdatePermission && review.isHidden) ...[
                  OutlinedButton.icon(
                    onPressed: _isProcessing ? null : () => _restoreReview(),
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Restore'),
                  ),
                  const SizedBox(width: 12),
                ],
                if (hasUpdatePermission && !review.isRemoved) ...[
                  OutlinedButton.icon(
                    onPressed: _isProcessing ? null : () => _removeReview(),
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dangerRed,
                    ),
                  ),
                ],
                if (_isProcessing) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveReview() async {
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(reviewsRepositoryProvider);
      await repo.approve(widget.review.id);
      
      if (mounted) {
        widget.onAction();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review approved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: $error'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _hideReview() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _ReasonDialog(
        title: 'Hide Review',
        prompt: 'Why are you hiding this review?',
      ),
    );

    if (reason == null || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(reviewsRepositoryProvider);
      await repo.hide(widget.review.id, reason: reason);
      
      if (mounted) {
        widget.onAction();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review hidden'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to hide: $error'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _restoreReview() async {
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(reviewsRepositoryProvider);
      await repo.restore(widget.review.id);
      
      if (mounted) {
        widget.onAction();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review restored'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore: $error'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _removeReview() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _ReasonDialog(
        title: 'Remove Review Permanently',
        prompt: 'This action cannot be undone. Why are you removing this review?',
        isDanger: true,
      ),
    );

    if (reason == null || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(reviewsRepositoryProvider);
      await repo.remove(widget.review.id, reason: reason);
      
      if (mounted) {
        widget.onAction();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review removed permanently'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $error'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'hidden':
        color = Colors.orange;
        icon = Icons.visibility_off;
        break;
      case 'removed':
        color = AppTheme.dangerRed;
        icon = Icons.delete_forever;
        break;
      case 'pending':
      default:
        color = Colors.grey;
        icon = Icons.hourglass_empty;
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

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: color ?? Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.prompt,
    this.isDanger = false,
  });

  final String title;
  final String prompt;
  final bool isDanger;

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
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.prompt,
              style: TextStyle(
                color: widget.isDanger ? AppTheme.dangerRed : Colors.grey,
                fontWeight: widget.isDanger ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'e.g., Spam, Inappropriate content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              Navigator.pop(context, text);
            }
          },
          style: widget.isDanger
              ? FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed)
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
