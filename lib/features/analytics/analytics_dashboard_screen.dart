import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/shared/admin_sidebar.dart';
import '../../providers/analytics_dashboard_provider.dart';
import '../../widgets/export_button.dart';
import '../../routes.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsDashboardProvider);

    return AdminScaffold(
      currentRoute: AppRoute.analytics,
      title: 'Analytics',
      actions: [
        ExportButton(
          label: 'Export (CSV)',
          endpoint: '/admin/analytics/export',
          exportData: {
            'start_date': state.start.toIso8601String(),
            'end_date': state.end.toIso8601String(),
            'format': 'csv',
          },
          variant: ExportButtonVariant.outlined,
        ),
        const SizedBox(width: 8),
      ],
      child: RefreshIndicator(
        onRefresh: () async => ref.read(analyticsDashboardProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _FiltersBar(state: state),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )),
            if (state.error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Failed to load analytics: ${state.error}'),
                ),
              ),
            if (!state.isLoading) ...[
              Row(
                children: [
                  Expanded(child: _TopSearchesCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _CtrCard()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FiltersBar extends ConsumerWidget {
  const _FiltersBar({required this.state});
  final AnalyticsDashboardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(analyticsDashboardProvider.notifier);

    return Row(
      children: [
        SegmentedButton<Duration>(
          segments: const [
            ButtonSegment(value: Duration(days: 7), label: Text('Last 7d')),
            ButtonSegment(value: Duration(days: 30), label: Text('Last 30d')),
          ],
          selected: {state.end.difference(state.start)},
          onSelectionChanged: (s) => notifier.setRange(s.first),
        ),
        const SizedBox(width: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'day', label: Text('Daily')),
            ButtonSegment(value: 'week', label: Text('Weekly')),
          ],
          selected: {state.granularity},
          onSelectionChanged: (s) => notifier.setGranularity(s.first),
        ),
      ],
    );
  }
}

class _TopSearchesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsDashboardProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Searches', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (state.topSearches.isEmpty)
              const Text('No data available'),
            for (final item in state.topSearches)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(item.query, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 12),
                    Text(item.count.toString()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CtrCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsDashboardProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CTR Over Time', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (state.ctrSeries.isEmpty)
              const Text('No data available'),
            // Simple textual series placeholder (no chart lib)
            for (final point in state.ctrSeries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('${point.date.toLocal().toIso8601String().substring(0, 10)}')),
                    Text('${point.ctr.toStringAsFixed(2)}%'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
