import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/vendor_analytics.dart';
import '../../../providers/vendor_detail_providers.dart';

class VendorAnalyticsTab extends ConsumerStatefulWidget {
  const VendorAnalyticsTab({required this.vendorId, super.key});

  final int vendorId;

  @override
  ConsumerState<VendorAnalyticsTab> createState() => _VendorAnalyticsTabState();
}

class _VendorAnalyticsTabState extends ConsumerState<VendorAnalyticsTab> {
  DateTime? _fromDate;
  DateTime? _toDate;

  VendorAnalyticsParams get _params => VendorAnalyticsParams(
    vendorId: widget.vendorId,
    fromDate: _fromDate,
    toDate: _toDate,
  );

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(vendorAnalyticsProvider(_params));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Filter
          Row(
            children: [
              Expanded(child: _buildDateRangePicker(context)),
              const SizedBox(width: 16),
              if (_fromDate != null || _toDate != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _fromDate = null;
                      _toDate = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Analytics Data
          analyticsAsync.when(
            data: (analytics) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodInfo(analytics.period),
                const SizedBox(height: 24),
                _buildPerformanceMetrics(analytics.performance),
                const SizedBox(height: 24),
                _buildRevenueMetrics(analytics.revenue),
                const SizedBox(height: 24),
                _buildCustomerMetrics(analytics.customer),
                const SizedBox(height: 24),
                _buildServiceMetrics(analytics.service),
              ],
            ),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load analytics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    final startStr = _fromDate != null
        ? DateFormat('MMM d, y').format(_fromDate!)
        : 'Start date';
    final endStr = _toDate != null
        ? DateFormat('MMM d, y').format(_toDate!)
        : 'End date';

    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: _fromDate != null && _toDate != null
              ? DateTimeRange(start: _fromDate!, end: _toDate!)
              : null,
        );
        if (picked != null) {
          setState(() {
            _fromDate = picked.start;
            _toDate = picked.end;
          });
        }
      },
      icon: const Icon(Icons.date_range, size: 20),
      label: Text('$startStr - $endStr'),
    );
  }

  Widget _buildPeriodInfo(AnalyticsPeriod period) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              period.startDate != null && period.endDate != null
                  ? 'Analytics Period: ${DateFormat('MMM d, y').format(period.startDate!)} - ${DateFormat('MMM d, y').format(period.endDate!)}'
                  : 'Analytics Period: All Time',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(PerformanceMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Metrics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Completion Rate',
                '${metrics.completionRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.green,
                subtitle: 'Bookings completed successfully',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Average Rating',
                '${metrics.averageRating.toStringAsFixed(1)}/5',
                Icons.star,
                Colors.amber,
                subtitle: 'Based on ${metrics.totalReviews ?? 0} reviews',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Response Time',
                metrics.responseTimeAvgMinutes != null
                    ? '${(metrics.responseTimeAvgMinutes! / 60).toStringAsFixed(1)}h'
                    : '-',
                Icons.access_time,
                Colors.blue,
                subtitle: 'Average lead response',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Acceptance Rate',
                metrics.acceptanceRate != null
                    ? '${metrics.acceptanceRate!.toStringAsFixed(1)}%'
                    : '-',
                Icons.check,
                Colors.teal,
                subtitle: 'Leads accepted',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueMetrics(RevenueMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue Metrics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Revenue',
                '₹${_formatAmount(metrics.totalRevenue.toDouble())}',
                Icons.payments,
                Colors.green,
                subtitle: 'Period earnings',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Revenue Growth',
                metrics.growthPct != null
                    ? '${metrics.growthPct!.toStringAsFixed(1)}%'
                    : '-',
                metrics.growthPct != null && metrics.growthPct! >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                metrics.growthPct != null && metrics.growthPct! >= 0
                    ? Colors.green
                    : Colors.red,
                subtitle: 'vs previous period',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Avg Booking Value',
                metrics.averageBookingValue != null
                    ? '₹${_formatAmount(metrics.averageBookingValue!.toDouble())}'
                    : '-',
                Icons.receipt,
                Colors.blue,
                subtitle: 'Per booking',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Bookings',
                '${metrics.totalRevenue}',
                Icons.shopping_bag,
                Colors.purple,
                subtitle: 'In this period',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerMetrics(CustomerMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Metrics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Unique Customers',
                '${metrics.uniqueCustomers}',
                Icons.people,
                Colors.indigo,
                subtitle: 'Total customers',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Repeat Customers',
                metrics.repeatCustomers != null
                    ? '${metrics.repeatCustomers}'
                    : '-',
                Icons.repeat,
                Colors.green,
                subtitle: 'Returning customers',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Repeat Rate',
                metrics.repeatRate != null
                    ? '${metrics.repeatRate!.toStringAsFixed(1)}%'
                    : '-',
                Icons.percent,
                Colors.teal,
                subtitle: 'Customer retention',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Customer Loyalty',
                metrics.repeatRate != null && metrics.repeatRate! > 50
                    ? 'High'
                    : metrics.repeatRate != null && metrics.repeatRate! > 25
                    ? 'Medium'
                    : 'Low',
                Icons.favorite,
                metrics.repeatRate != null && metrics.repeatRate! > 50
                    ? Colors.green
                    : Colors.orange,
                subtitle: 'Based on repeat rate',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceMetrics(ServiceMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Metrics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Active Services',
                '${metrics.activeServices}',
                Icons.room_service,
                Colors.blue,
                subtitle: 'Currently listed',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Views',
                metrics.totalViews != null ? '${metrics.totalViews}' : '-',
                Icons.visibility,
                Colors.purple,
                subtitle: 'Service impressions',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Conversion Rate',
                metrics.conversionRate != null
                    ? '${metrics.conversionRate!.toStringAsFixed(1)}%'
                    : '-',
                Icons.trending_up,
                Colors.green,
                subtitle: 'Views to bookings',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Avg Views per Service',
                metrics.totalViews != null && metrics.activeServices > 0
                    ? '${(metrics.totalViews! / metrics.activeServices).toStringAsFixed(0)}'
                    : '-',
                Icons.bar_chart,
                Colors.orange,
                subtitle: 'Per service',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
