import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../models/vendor_revenue.dart';
import '../../../providers/vendor_detail_providers.dart';

class VendorRevenueTab extends ConsumerStatefulWidget {
  const VendorRevenueTab({required this.vendorId, super.key});

  final int vendorId;

  @override
  ConsumerState<VendorRevenueTab> createState() => _VendorRevenueTabState();
}

class _VendorRevenueTabState extends ConsumerState<VendorRevenueTab> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _groupBy = 'day';

  VendorRevenueParams get _params => VendorRevenueParams(
    vendorId: widget.vendorId,
    fromDate: _fromDate,
    toDate: _toDate,
    groupBy: _groupBy,
  );

  @override
  Widget build(BuildContext context) {
    final revenueAsync = ref.watch(vendorRevenueProvider(_params));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters Row
          Row(
            children: [
              Expanded(child: _buildDateRangePicker(context)),
              const SizedBox(width: 16),
              _buildGroupBySelector(),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue Data
          revenueAsync.when(
            data: (revenue) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(revenue.summary),
                const SizedBox(height: 32),
                _buildRevenueChart(revenue.timeSeries),
                const SizedBox(height: 32),
                _buildCommissionBreakdown(revenue.commissionBreakdown),
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
                      'Failed to load revenue data',
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

  Widget _buildGroupBySelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'day', label: Text('Day')),
        ButtonSegment(value: 'week', label: Text('Week')),
        ButtonSegment(value: 'month', label: Text('Month')),
      ],
      selected: {_groupBy},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _groupBy = newSelection.first;
        });
      },
    );
  }

  Widget _buildSummaryCards(RevenueSummary summary) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 200,
          child: _buildSummaryCard(
            'Total Revenue',
            '₹${_formatAmount(summary.totalRevenue)}',
            Icons.receipt_long,
            Colors.blue,
          ),
        ),
        SizedBox(
          width: 200,
          child: _buildSummaryCard(
            'Bookings',
            summary.bookingCount.toString(),
            Icons.bookmark,
            Colors.purple,
          ),
        ),
        SizedBox(
          width: 200,
          child: _buildSummaryCard(
            'Commission',
            '₹${_formatAmount(summary.commission)}',
            Icons.account_balance,
            Colors.orange,
          ),
        ),
        SizedBox(
          width: 200,
          child: _buildSummaryCard(
            'Net Payout',
            '₹${_formatAmount(summary.netPayout)}',
            Icons.payments,
            Colors.green,
          ),
        ),
        SizedBox(
          width: 200,
          child: _buildSummaryCard(
            'Avg Booking',
            '₹${_formatAmount(summary.averageBookingValue)}',
            Icons.trending_up,
            Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<RevenueTimeSeries> timeSeries) {
    if (timeSeries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Text(
              'No revenue data available for the selected period',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Over Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < timeSeries.length) {
                            final dateTime = timeSeries[value.toInt()].dateTime;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('MMM d').format(dateTime),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${_formatAmount(value)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // Revenue Line
                    LineChartBarData(
                      spots: timeSeries
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.revenue.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                    // Commission Line
                    LineChartBarData(
                      spots: timeSeries
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.commission.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Revenue', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('Commission', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCommissionBreakdown(CommissionBreakdown breakdown) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commission Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow(
              'Platform Commission Rate',
              '${(breakdown.platformCommissionRate * 100).toStringAsFixed(1)}%',
              '',
            ),
            _buildBreakdownRow(
              'Platform Commission',
              '',
              '₹${_formatAmount(breakdown.platformCommission)}',
            ),
            const Divider(height: 32),
            _buildBreakdownRow(
              'Vendor Earnings',
              '',
              '₹${_formatAmount(breakdown.vendorEarnings)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String rate,
    String amount, {
    bool isBold = false,
  }) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          if (rate.isNotEmpty) ...[
            Text(rate, style: style?.copyWith(color: Colors.grey[600])),
            const SizedBox(width: 24),
          ],
          SizedBox(
            width: 120,
            child: Text(amount, style: style, textAlign: TextAlign.right),
          ),
        ],
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
