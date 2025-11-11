import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/feedback_models.dart';
import '../../routes.dart';
import '../shared/admin_sidebar.dart';
import 'feedback_providers.dart';

class FeedbackDetailScreen extends ConsumerStatefulWidget {
  const FeedbackDetailScreen({required this.feedbackId, super.key});

  final int feedbackId;

  @override
  ConsumerState<FeedbackDetailScreen> createState() =>
      _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends ConsumerState<FeedbackDetailScreen> {
  final _responseController = TextEditingController();
  final _responseFormKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _autoSetStatus;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(feedbackDetailProvider(widget.feedbackId));

    return AdminScaffold(
      currentRoute: AppRoute.feedbackDetail,
      title: 'Feedback Details',
      child: detailsAsync.when(
        data: (details) => _buildContent(context, details),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(feedbackDetailProvider(widget.feedbackId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FeedbackDetails details) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  details.feedback.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Feedback details
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeedbackCard(context, details.feedback),
                    const SizedBox(height: 16),
                    _buildCommentsCard(context, details.comments),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Right column - Admin actions
              Expanded(
                child: Column(
                  children: [
                    _buildActionsCard(context, details.feedback),
                    const SizedBox(height: 16),
                    _buildResponseCard(context, details.feedback),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, FeedbackItem feedback) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata row
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildCategoryChip(context, feedback.category),
                _buildStatusChip(context, feedback.status),
                if (feedback.priority != null)
                  _buildPriorityChip(context, feedback.priority!),
                Chip(
                  avatar: Icon(
                    feedback.isPublic ? Icons.public : Icons.lock_outline,
                    size: 16,
                  ),
                  label: Text(feedback.isPublic ? 'Public' : 'Private'),
                  backgroundColor: feedback.isPublic
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                ),
              ],
            ),
            const Divider(height: 32),

            // Description
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(feedback.description),
            const Divider(height: 32),

            // Submitter info
            Text(
              'Submitted By',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  child: Text(feedback.submitterName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.submitterName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${feedback.submitterType.label} • ${feedback.submitterId != null ? "ID: ${feedback.submitterId}" : "Unknown ID"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // Stats
            Row(
              children: [
                _buildStatBadge(
                  Icons.arrow_upward,
                  '${feedback.votesCount} votes',
                ),
                const SizedBox(width: 16),
                _buildStatBadge(
                  Icons.comment_outlined,
                  '${feedback.commentsCount} comments',
                ),
                const SizedBox(width: 16),
                _buildStatBadge(
                  Icons.schedule,
                  'Created ${DateFormat('MMM dd, yyyy').format(feedback.createdAt)}',
                ),
              ],
            ),

            // Admin response if exists
            if (feedback.adminResponse != null) ...[
              const Divider(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Admin Response',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (feedback.respondedAt != null)
                          Text(
                            DateFormat(
                              'MMM dd, yyyy HH:mm',
                            ).format(feedback.respondedAt!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(feedback.adminResponse!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsCard(
    BuildContext context,
    List<FeedbackComment> comments,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments (${comments.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (comments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No comments yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...comments.map((comment) => _buildCommentItem(context, comment)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, FeedbackComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: comment.isAdmin
            ? Colors.blue.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: comment.isAdmin
              ? Colors.blue.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: comment.isAdmin ? Colors.blue : Colors.grey,
                child: Text(
                  comment.commenterName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.commenterName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (comment.isAdmin) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${comment.commenterType} • ${DateFormat('MMM dd, yyyy HH:mm').format(comment.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment.content),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, FeedbackItem feedback) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Status dropdown
            DropdownButtonFormField<String>(
              value: feedback.status.value,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: FeedbackStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status.value,
                  child: Text(status.label),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null && value != feedback.status.value) {
                  await _updateStatus(feedback.id, value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Priority dropdown
            DropdownButtonFormField<String>(
              value: feedback.priority?.value,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...FeedbackPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority.value,
                    child: Text(priority.label),
                  );
                }),
              ],
              onChanged: (value) async {
                if (value != null && value != feedback.priority?.value) {
                  await _updatePriority(feedback.id, value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Visibility toggle
            SwitchListTile(
              title: const Text('Public Visibility'),
              subtitle: Text(
                feedback.isPublic
                    ? 'Visible on landing page'
                    : 'Hidden from public',
              ),
              value: feedback.isPublic,
              onChanged: (value) async {
                await _toggleVisibility(feedback.id, value);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard(BuildContext context, FeedbackItem feedback) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _responseFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Admin Response',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _responseController,
                decoration: const InputDecoration(
                  labelText: 'Response',
                  hintText: 'Write a public response to this feedback...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Response cannot be empty';
                  }
                  if (value.trim().length < 10) {
                    return 'Response must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Auto-set status dropdown
              DropdownButtonFormField<String>(
                value: _autoSetStatus,
                decoration: const InputDecoration(
                  labelText: 'Auto-set status (optional)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Keep current'),
                  ),
                  ...FeedbackStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status.value,
                      child: Text(status.label),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _autoSetStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          await _submitResponse(feedback.id);
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Response'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(int feedbackId, String status) async {
    try {
      final actions = ref.read(feedbackActionsProvider);
      await actions.updateStatus(feedbackId: feedbackId, status: status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  Future<void> _updatePriority(int feedbackId, String priority) async {
    try {
      final actions = ref.read(feedbackActionsProvider);
      await actions.setPriority(feedbackId: feedbackId, priority: priority);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Priority updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating priority: $e')));
      }
    }
  }

  Future<void> _toggleVisibility(int feedbackId, bool isPublic) async {
    try {
      final actions = ref.read(feedbackActionsProvider);
      await actions.toggleVisibility(
        feedbackId: feedbackId,
        isPublic: isPublic,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPublic ? 'Feedback is now public' : 'Feedback is now private',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating visibility: $e')),
        );
      }
    }
  }

  Future<void> _submitResponse(int feedbackId) async {
    if (!_responseFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final actions = ref.read(feedbackActionsProvider);
      await actions.addResponse(
        feedbackId: feedbackId,
        response: _responseController.text.trim(),
        autoSetStatus: _autoSetStatus,
      );

      _responseController.clear();
      setState(() {
        _autoSetStatus = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting response: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, FeedbackCategory category) {
    final colors = {
      FeedbackCategory.featureRequest: Colors.blue,
      FeedbackCategory.bugReport: Colors.red,
      FeedbackCategory.improvement: Colors.green,
      FeedbackCategory.uxFeedback: Colors.purple,
      FeedbackCategory.performance: Colors.orange,
      FeedbackCategory.general: Colors.grey,
    };

    return Chip(
      label: Text(
        category.label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: colors[category],
    );
  }

  Widget _buildStatusChip(BuildContext context, FeedbackStatus status) {
    final colors = {
      FeedbackStatus.pending: Colors.grey,
      FeedbackStatus.underReview: Colors.blue,
      FeedbackStatus.planned: Colors.cyan,
      FeedbackStatus.inProgress: Colors.orange,
      FeedbackStatus.completed: Colors.green,
      FeedbackStatus.declined: Colors.red,
    };

    return Chip(
      label: Text(
        status.label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: colors[status],
    );
  }

  Widget _buildPriorityChip(BuildContext context, FeedbackPriority priority) {
    final colors = {
      FeedbackPriority.low: Colors.blue,
      FeedbackPriority.medium: Colors.orange,
      FeedbackPriority.high: Colors.red,
      FeedbackPriority.critical: Colors.deepPurple,
    };

    return Chip(
      label: Text(
        priority.label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: colors[priority],
    );
  }
}
