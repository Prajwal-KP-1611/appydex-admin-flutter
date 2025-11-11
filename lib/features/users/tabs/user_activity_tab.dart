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

    return activityAsync.when(
      data: (pagination) {
        if (pagination.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No activity yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            // Activity List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pagination.items.length,
                itemBuilder: (context, index) {
                  final activity = pagination.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(activity.icon)),
                      title: Text(activity.description),
                      subtitle: Text(
                        '${activity.timeAgo} • ${activity.ipAddress}',
                      ),
                      trailing: Chip(
                        label: Text(activity.activityType.name),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Pagination
            if (pagination.totalPages > 1)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Page ${pagination.page}/${pagination.totalPages}'),
              ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Activity log not available',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Backend endpoint not implemented',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
