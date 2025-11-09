import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/users/user_detail_providers.dart';

/// Activity tab showing user's activity log
class UserActivityTab extends ConsumerWidget {
  const UserActivityTab({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(userActivityProvider(userId));

    return Column(
      children: [
        // Filters Bar - Coming Soon
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text('Activity Filters - Coming Soon'),
        ),

        // Activity List
        Expanded(
          child: activityAsync.when(
            data: (pagination) {
              if (pagination.items.isEmpty) {
                return const Center(child: Text('No activity yet'));
              }
              return ListView.builder(
                itemCount: pagination.items.length,
                itemBuilder: (context, index) {
                  final activity = pagination.items[index];
                  return ListTile(
                    leading: Text(activity.icon),
                    title: Text(activity.description),
                    subtitle: Text(
                      '${activity.timeAgo} • ${activity.ipAddress}',
                    ),
                    trailing: Text(activity.activityType.name),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),

        // Pagination - Coming Soon
        activityAsync.whenOrNull(
              data: (pagination) {
                if (pagination.totalPages > 1) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Page ${pagination.page}/${pagination.totalPages}',
                    ),
                  );
                }
                return null;
              },
            ) ??
            const SizedBox.shrink(),
      ],
    );
  }
}
