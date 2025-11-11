import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/feedback_models.dart';
import '../../routes.dart';
import '../shared/admin_sidebar.dart';
import 'feedback_providers.dart';

class FeedbackListScreen extends ConsumerWidget {
  const FeedbackListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminScaffold(
      currentRoute: AppRoute.feedback,
      title: 'Feedback Management',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats banner
          _buildStatsBanner(context, ref),
          const SizedBox(height: 16),

          // Filters
          _buildFilters(context, ref),
          const SizedBox(height: 16),

          // Feedback table
          Expanded(child: _buildFeedbackTable(context, ref)),
        ],
      ),
    );
  }

  Widget _buildStatsBanner(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(feedbackStatsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statsAsync.when(
          data: (stats) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Total Feedback',
                stats.total.toString(),
                Icons.feedback_outlined,
              ),
              _buildStatItem(
                context,
                'Pending Review',
                stats.pendingReview.toString(),
                Icons.pending_actions_outlined,
                color: Colors.orange,
              ),
              _buildStatItem(
                context,
                'Response Rate',
                '${stats.responseRate.toStringAsFixed(1)}%',
                Icons.rate_review_outlined,
                color: Colors.green,
              ),
              _buildStatItem(
                context,
                'Avg Response Time',
                stats.avgResponseTimeHours != null
                    ? '${stats.avgResponseTimeHours!.toStringAsFixed(1)}h'
                    : 'N/A',
                Icons.schedule_outlined,
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading stats: $error'),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color ?? Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Category filter
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: ref.watch(feedbackCategoryFilterProvider),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...FeedbackCategory.values.map(
                    (cat) => DropdownMenuItem(
                      value: cat.value,
                      child: Text(cat.label),
                    ),
                  ),
                ],
                onChanged: (value) {
                  ref.read(feedbackCategoryFilterProvider.notifier).state =
                      value;
                  ref.read(feedbackPageProvider.notifier).state = 1;
                },
              ),
            ),

            // Status filter
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: ref.watch(feedbackStatusFilterProvider),
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...FeedbackStatus.values.map(
                    (status) => DropdownMenuItem(
                      value: status.value,
                      child: Text(status.label),
                    ),
                  ),
                ],
                onChanged: (value) {
                  ref.read(feedbackStatusFilterProvider.notifier).state = value;
                  ref.read(feedbackPageProvider.notifier).state = 1;
                },
              ),
            ),

            // Priority filter
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: ref.watch(feedbackPriorityFilterProvider),
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...FeedbackPriority.values.map(
                    (priority) => DropdownMenuItem(
                      value: priority.value,
                      child: Text(priority.label),
                    ),
                  ),
                ],
                onChanged: (value) {
                  ref.read(feedbackPriorityFilterProvider.notifier).state =
                      value;
                  ref.read(feedbackPageProvider.notifier).state = 1;
                },
              ),
            ),

            // Submitter type filter
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: ref.watch(feedbackSubmitterTypeFilterProvider),
                decoration: const InputDecoration(
                  labelText: 'Submitter Type',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
                ],
                onChanged: (value) {
                  ref.read(feedbackSubmitterTypeFilterProvider.notifier).state =
                      value;
                  ref.read(feedbackPageProvider.notifier).state = 1;
                },
              ),
            ),

            // Clear filters button
            ElevatedButton.icon(
              onPressed: () {
                ref.read(feedbackCategoryFilterProvider.notifier).state = null;
                ref.read(feedbackStatusFilterProvider.notifier).state = null;
                ref.read(feedbackPriorityFilterProvider.notifier).state = null;
                ref.read(feedbackSubmitterTypeFilterProvider.notifier).state =
                    null;
                ref.read(feedbackHasResponseFilterProvider.notifier).state =
                    null;
                ref.read(feedbackPageProvider.notifier).state = 1;
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTable(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(feedbackListProvider);

    return feedbackAsync.when(
      data: (response) {
        if (response.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No feedback found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Priority')),
                        DataColumn(label: Text('Submitter')),
                        DataColumn(label: Text('Votes')),
                        DataColumn(label: Text('Comments')),
                        DataColumn(label: Text('Visibility')),
                        DataColumn(label: Text('Created')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: response.items.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text('#${item.id}')),
                            DataCell(
                              SizedBox(
                                width: 300,
                                child: Text(
                                  item.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              _buildCategoryChip(context, item.category),
                            ),
                            DataCell(_buildStatusChip(context, item.status)),
                            DataCell(
                              item.priority != null
                                  ? _buildPriorityChip(context, item.priority!)
                                  : const Text('—'),
                            ),
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.submitterName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    item.submitterType.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_upward,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(item.votesCount.toString()),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  const Icon(
                                    Icons.comment_outlined,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(item.commentsCount.toString()),
                                ],
                              ),
                            ),
                            DataCell(
                              Icon(
                                item.isPublic
                                    ? Icons.public
                                    : Icons.lock_outline,
                                size: 20,
                                color: item.isPublic
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(item.createdAt),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                tooltip: 'View Details',
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoute.feedbackDetail.path,
                                    arguments: item.id,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            // Pagination
            _buildPagination(context, ref, response.pagination),
          ],
        );
      },
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
              onPressed: () => ref.refresh(feedbackListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(
    BuildContext context,
    WidgetRef ref,
    PaginationInfo pagination,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${((pagination.page - 1) * pagination.pageSize) + 1} - '
              '${(pagination.page * pagination.pageSize).clamp(0, pagination.total)} '
              'of ${pagination.total}',
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: pagination.page > 1
                      ? () {
                          ref.read(feedbackPageProvider.notifier).state =
                              pagination.page - 1;
                        }
                      : null,
                ),
                Text('Page ${pagination.page} of ${pagination.totalPages}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: pagination.page < pagination.totalPages
                      ? () {
                          ref.read(feedbackPageProvider.notifier).state =
                              pagination.page + 1;
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
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
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
