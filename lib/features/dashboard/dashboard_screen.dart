import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/pagination.dart';
import '../../models/vendor.dart';
import '../vendors/vendors_list_screen.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/vendors_provider.dart';
import '../../routes.dart';
import '../shared/admin_sidebar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final vendorsState = ref.watch(vendorsProvider);

    final metrics = metricsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <String, num>{},
    );

    final fallbackVendors = vendorsState.data.valueOrNull;
    final cards = _buildCards(context, metrics, fallbackVendors);

    return AdminScaffold(
      currentRoute: AppRoute.dashboard,
      title: 'Dashboard',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardMetricsProvider);
          await ref.read(dashboardMetricsProvider.future);
          await ref.read(vendorsProvider.notifier).load();
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Wrap(spacing: 16, runSpacing: 16, children: cards),
            const SizedBox(height: 32),
            metricsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (_) => const SizedBox.shrink(),
              error: (error, _) => Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Unable to load analytics metrics. Showing fallback values. Error: $error',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCards(
    BuildContext context,
    Map<String, num> metrics,
    Pagination<Vendor>? fallbackVendors,
  ) {
    String formatNumber(num? value) {
      if (value == null) return '—';
      if (value >= 1000) {
        return value.toStringAsFixed(0);
      }
      return value.toString();
    }

    num? vendorsTotal =
        metrics['vendors_total'] ?? fallbackVendors?.total.toDouble();
    num? pendingVerification = metrics['vendors_pending_verification'];
    pendingVerification ??= fallbackVendors?.items
        .where((vendor) => vendor.isPending)
        .length
        .toDouble();

    final cards = [
      _DashboardCard(
        label: 'Registered Vendors',
        value: formatNumber(vendorsTotal),
        icon: Icons.store,
        onTap: () =>
            Navigator.pushReplacementNamed(context, AppRoute.vendors.path),
      ),
      _DashboardCard(
        label: 'Pending Verification',
        value: formatNumber(pendingVerification),
        icon: Icons.verified_outlined,
        onTap: () => Navigator.pushReplacementNamed(
          context,
          AppRoute.vendors.path,
          arguments: const VendorsListArgs(status: 'pending'),
        ),
      ),
      _DashboardCard(
        label: 'Active Subscriptions',
        value: formatNumber(metrics['active_subscriptions']),
        icon: Icons.credit_card,
        onTap: () => Navigator.pushReplacementNamed(
          context,
          AppRoute.subscriptions.path,
        ),
      ),
      _DashboardCard(
        label: 'Bookings Today',
        value: formatNumber(metrics['bookings_today']),
        icon: Icons.event_available,
        onTap: () =>
            Navigator.pushReplacementNamed(context, AppRoute.vendors.path),
      ),
      _DashboardCard(
        label: 'Revenue (30d)',
        value: metrics['revenue_30d_cents'] != null
            ? '₹${(metrics['revenue_30d_cents']! / 100).toStringAsFixed(0)}'
            : '—',
        icon: Icons.currency_rupee,
        onTap: () => Navigator.pushReplacementNamed(
          context,
          AppRoute.subscriptions.path,
        ),
      ),
      _DashboardCard(
        label: 'Payment Failures (7d)',
        value: formatNumber(metrics['payment_failures_7d']),
        icon: Icons.warning_amber_outlined,
        onTap: () => Navigator.pushReplacementNamed(
          context,
          AppRoute.subscriptions.path,
        ),
      ),
      _DashboardCard(
        label: 'Error Rate (5m)',
        value: metrics['error_rate_5m'] != null
            ? '${metrics['error_rate_5m']!.toStringAsFixed(2)}%'
            : '—',
        icon: Icons.error_outline,
        onTap: () =>
            Navigator.pushReplacementNamed(context, AppRoute.diagnostics.path),
      ),
    ];

    return cards;
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
