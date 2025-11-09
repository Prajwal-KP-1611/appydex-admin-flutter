import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/vendor_detail_providers.dart';

class VendorPayoutsTab extends ConsumerStatefulWidget {
  const VendorPayoutsTab({required this.vendorId, super.key});

  final int vendorId;

  @override
  ConsumerState<VendorPayoutsTab> createState() => _VendorPayoutsTabState();
}

class _VendorPayoutsTabState extends ConsumerState<VendorPayoutsTab> {
  int _currentPage = 1;
  static const int _pageSize = 20;

  VendorPayoutsParams get _params => VendorPayoutsParams(
    vendorId: widget.vendorId,
    page: _currentPage,
    pageSize: _pageSize,
  );

  @override
  Widget build(BuildContext context) {
    final payoutsAsync = ref.watch(vendorPayoutsProvider(_params));

    return Column(
      children: [
        Expanded(
          child: payoutsAsync.when(
            data: (pagination) {
              if (pagination.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No payouts yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Payout history will appear here once processed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
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
                    _buildSummaryCards(pagination),
                    const SizedBox(height: 24),
                    _buildPayoutsTable(pagination.items),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load payouts',
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
        // Pagination
        payoutsAsync.whenData((pagination) {
              if (pagination.totalPages <= 1) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${pagination.items.length} of ${pagination.total} payouts',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          'Page $_currentPage of ${pagination.totalPages}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        IconButton(
                          onPressed: _currentPage < pagination.totalPages
                              ? () => setState(() => _currentPage++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).value ??
            const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSummaryCards(pagination) {
    final payouts = pagination.items;
    final totalGross = payouts.fold<int>(0, (sum, p) => sum + p.grossAmount);
    final totalNet = payouts.fold<int>(0, (sum, p) => sum + p.netAmount);
    final processedCount = payouts.where((p) => p.status == 'processed').length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Gross',
            '₹${_formatAmount(totalGross.toDouble())}',
            Icons.account_balance_wallet,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Total Net',
            '₹${_formatAmount(totalNet.toDouble())}',
            Icons.payments,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Processed',
            '$processedCount',
            Icons.check_circle,
            Colors.teal,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Total Payouts',
            '${pagination.total}',
            Icons.receipt_long,
            Colors.purple,
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

  Widget _buildPayoutsTable(List payouts) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
          columns: const [
            DataColumn(label: Text('Payout Ref')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Gross Amount')),
            DataColumn(label: Text('Fees')),
            DataColumn(label: Text('Net Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('UTR Number')),
            DataColumn(label: Text('Processed At')),
          ],
          rows: payouts
              .map(
                (payout) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        payout.payoutReference,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    DataCell(
                      Text(DateFormat('MMM d, y').format(payout.createdAt)),
                    ),
                    DataCell(
                      Text('₹${_formatAmount(payout.grossAmount.toDouble())}'),
                    ),
                    DataCell(
                      Text(
                        '₹${_formatAmount((payout.grossAmount - payout.netAmount).toDouble())}',
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${_formatAmount(payout.netAmount.toDouble())}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(_buildStatusChip(payout.status)),
                    DataCell(
                      Text(
                        payout.utrNumber ?? '-',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    DataCell(
                      Text(
                        payout.processedAt != null
                            ? DateFormat(
                                'MMM d, HH:mm',
                              ).format(payout.processedAt!)
                            : '-',
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'processed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
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
