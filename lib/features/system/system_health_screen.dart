import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/admin_sidebar.dart';
import '../../models/system_health.dart';
import '../../repositories/system_repo.dart';
import '../../routes.dart';

/// System Health and Reports Screen
/// Displays ephemeral data statistics and system monitoring info
class SystemHealthScreen extends ConsumerWidget {
  const SystemHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(ephemeralStatsProvider);

    return AdminScaffold(
      currentRoute: AppRoute.reports,
      title: 'System Health & Reports',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'System Health Monitoring',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor ephemeral data lifecycle and cleanup processes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Stats cards
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load system stats: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(ephemeralStatsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (stats) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Idempotency Keys',
                          subtitle: '30-day retention',
                          total: stats.idempotencyKeys.total,
                          recent: stats.idempotencyKeys.last7Days,
                          icon: Icons.key,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Webhook Events',
                          subtitle: '90-day retention',
                          total: stats.webhookEvents.total,
                          recent: stats.webhookEvents.last7Days,
                          icon: Icons.webhook,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRefreshTokenCard(
                          context,
                          stats: stats.refreshTokens,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Cleanup trigger
                  _buildCleanupSection(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int total,
    required int recent,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total: $total',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Last 7 days: $recent',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshTokenCard(
    BuildContext context, {
    required RefreshTokenStats stats,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_clock, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refresh Tokens',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '14-day retention',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ${stats.total}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Active: ${stats.active}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Expired: ${stats.expired}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanupSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manual Cleanup',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Trigger manual cleanup of expired ephemeral data. This typically runs automatically via scheduled tasks.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _triggerCleanup(context, ref),
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Trigger Cleanup'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerCleanup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trigger Manual Cleanup'),
        content: const Text(
          'This will trigger a manual cleanup of expired ephemeral data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Trigger'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final repo = ref.read(systemRepositoryProvider);
      await repo.triggerCleanup();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cleanup triggered successfully')),
        );
      }

      // Refresh stats
      ref.invalidate(ephemeralStatsProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to trigger cleanup: $error')),
        );
      }
    }
  }
}
