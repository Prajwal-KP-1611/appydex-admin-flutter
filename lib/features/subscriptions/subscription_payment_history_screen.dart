import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/subscription_payment.dart';
import '../../providers/subscription_payments_provider.dart';
import '../../repositories/subscription_payment_repo.dart';
import '../../routes.dart';
import '../../widgets/data_table_simple.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/trace_snackbar.dart';
import '../shared/admin_sidebar.dart';

/// Vendor Subscription Payment History Screen
/// Displays payment history with date filtering and pagination
class SubscriptionPaymentHistoryScreen extends ConsumerStatefulWidget {
  const SubscriptionPaymentHistoryScreen({super.key});

  @override
  ConsumerState<SubscriptionPaymentHistoryScreen> createState() =>
      _SubscriptionPaymentHistoryScreenState();
}

class _SubscriptionPaymentHistoryScreenState
    extends ConsumerState<SubscriptionPaymentHistoryScreen> {
  final TextEditingController _vendorIdController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedMonth;

  @override
  void dispose() {
    _vendorIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionPaymentsProvider);
    final notifier = ref.read(subscriptionPaymentsProvider.notifier);
    final data = state.data.valueOrNull;
    final payments = data?.items ?? const <SubscriptionPayment>[];
    final summary = state.summary?.valueOrNull;

    final asyncError = state.data.maybeWhen<Object?>(
      error: (error, _) => error,
      orElse: () => null,
    );
    final Object? error = state.missingEndpoint ?? asyncError;

    return AdminScaffold(
      currentRoute: AppRoute.subscriptions,
      title: 'Subscription Payment History',
      actions: [
        IconButton(
          onPressed: () {
            notifier.load();
            notifier.loadSummary();
          },
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Stats
            if (summary != null) _SummaryCards(summary: summary),
            const SizedBox(height: 24),

            // Filters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        // Vendor ID Filter
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _vendorIdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Vendor ID',
                              prefixIcon: Icon(Icons.store, size: 20),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (value) {
                              notifier.updateFilter(
                                state.filter.copyWith(
                                  vendorId: value.isEmpty
                                      ? null
                                      : int.tryParse(value),
                                  page: 1,
                                  clearVendorId: value.isEmpty,
                                ),
                              );
                            },
                          ),
                        ),

                        // Status Filter
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<String?>(
                            initialValue: state.filter.status,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(Icons.filter_list, size: 20),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text('All Statuses'),
                              ),
                              DropdownMenuItem(
                                value: 'succeeded',
                                child: Text('Succeeded'),
                              ),
                              DropdownMenuItem(
                                value: 'failed',
                                child: Text('Failed'),
                              ),
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending'),
                              ),
                              DropdownMenuItem(
                                value: 'refunded',
                                child: Text('Refunded'),
                              ),
                            ],
                            onChanged: (value) {
                              notifier.updateFilter(
                                state.filter.copyWith(
                                  status: value,
                                  page: 1,
                                  clearStatus: value == null,
                                ),
                              );
                            },
                          ),
                        ),

                        // Monthly Filter
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<String?>(
                            initialValue: _selectedMonth,
                            decoration: const InputDecoration(
                              labelText: 'Month',
                              prefixIcon: Icon(Icons.calendar_month, size: 20),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _buildMonthItems(),
                            onChanged: (value) {
                              setState(() => _selectedMonth = value);
                              if (value == null) {
                                notifier.setDateRange(null, null);
                              } else {
                                final parts = value.split('-');
                                final year = int.parse(parts[0]);
                                final month = int.parse(parts[1]);
                                notifier.setMonthYear(year, month);
                              }
                            },
                          ),
                        ),

                        // Start Date
                        SizedBox(
                          width: 180,
                          child: InkWell(
                            onTap: () => _selectStartDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              child: Text(
                                _startDate != null
                                    ? DateFormat(
                                        'MMM d, yyyy',
                                      ).format(_startDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  color: _startDate != null
                                      ? null
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // End Date
                        SizedBox(
                          width: 180,
                          child: InkWell(
                            onTap: () => _selectEndDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              child: Text(
                                _endDate != null
                                    ? DateFormat(
                                        'MMM d, yyyy',
                                      ).format(_endDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  color: _endDate != null ? null : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Apply Date Range Button
                        if (_startDate != null || _endDate != null)
                          FilledButton.icon(
                            onPressed: () {
                              setState(() => _selectedMonth = null);
                              notifier.setDateRange(_startDate, _endDate);
                            },
                            icon: const Icon(Icons.check, size: 20),
                            label: const Text('Apply'),
                          ),

                        // Clear Filters Button
                        OutlinedButton.icon(
                          onPressed: () {
                            _vendorIdController.clear();
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _selectedMonth = null;
                            });
                            notifier.clearFilters();
                          },
                          icon: const Icon(Icons.clear, size: 20),
                          label: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Export Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (state.missingEndpoint != null)
                  TextButton.icon(
                    onPressed: () => _showBackendTicket(context),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Backend Ticket'),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: payments.isEmpty
                      ? null
                      : () {
                          final csv = notifier.exportCurrentCsv();
                          Clipboard.setData(ClipboardData(text: csv));
                          ScaffoldMessenger.of(context).showSnackBar(
                            buildTraceSnackbar('CSV copied to clipboard'),
                          );
                        },
                  icon: const Icon(Icons.download, size: 20),
                  label: const Text('Export CSV'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payments Table
            Expanded(
              child: DataTableSimple(
                columns: const [
                  DataTableSimpleColumn(label: 'Payment ID', flex: 2),
                  DataTableSimpleColumn(label: 'Date', flex: 2),
                  DataTableSimpleColumn(label: 'Vendor', flex: 2),
                  DataTableSimpleColumn(label: 'Plan', flex: 2),
                  DataTableSimpleColumn(label: 'Amount', flex: 1),
                  DataTableSimpleColumn(label: 'Payment Method', flex: 2),
                  DataTableSimpleColumn(label: 'Status', flex: 1),
                  DataTableSimpleColumn(label: 'Actions', flex: 1),
                ],
                rows: payments
                    .map(
                      (payment) => [
                        SelectableText(
                          payment.id,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMM d, yyyy\nhh:mm a',
                          ).format(payment.createdAt.toLocal()),
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          payment.vendorName ?? 'Vendor #${payment.vendorId}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          payment.planName ?? 'Plan #${payment.planId}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          payment.amountDisplay,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          payment.cardDisplay,
                          style: const TextStyle(fontSize: 13),
                        ),
                        StatusChip(
                          label: payment.status.toUpperCase(),
                          color: _getStatusColor(payment.status),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _showDetailsDialog(context, payment),
                              icon: const Icon(Icons.info_outline, size: 20),
                              tooltip: 'View Details',
                            ),
                            if (payment.invoiceUrl != null)
                              IconButton(
                                onPressed: () =>
                                    _downloadInvoice(context, payment.id),
                                icon: const Icon(Icons.receipt_long, size: 20),
                                tooltip: 'Download Invoice',
                              ),
                          ],
                        ),
                      ],
                    )
                    .toList(),
                isLoading: state.data.isLoading,
                total: data?.total ?? 0,
                page: state.filter.page,
                pageSize: state.filter.pageSize,
                onPageChange: notifier.setPage,
                error: error,
                onRetry: notifier.load,
                onUseMock: state.missingEndpoint != null
                    ? notifier.useMock
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String?>> _buildMonthItems() {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem(value: null, child: Text('All Time')),
    ];

    final now = DateTime.now();
    for (var i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final label = DateFormat('MMMM yyyy').format(date);
      items.add(DropdownMenuItem(value: key, child: Text(label)));
    }

    return items;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Colors.green;
      case 'failed':
        return AppTheme.dangerRed;
      case 'refunded':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.blue;
    }
  }

  Future<void> _downloadInvoice(BuildContext context, String paymentId) async {
    try {
      final repo = ref.read(subscriptionPaymentRepositoryProvider);
      final url = await repo.getInvoiceUrl(paymentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SelectableText('Invoice URL: $url'),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
              },
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get invoice: $error'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  void _showDetailsDialog(BuildContext context, SubscriptionPayment payment) {
    showDialog(
      context: context,
      builder: (context) => _PaymentDetailsDialog(payment: payment),
    );
  }

  void _showBackendTicket(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backend Endpoint Required'),
        content: const SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'The subscription payment history endpoints are not yet implemented in the backend.',
                ),
                SizedBox(height: 16),
                Text(
                  'Required Endpoints:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• GET /api/v1/admin/subscriptions/payments'),
                Text('• GET /api/v1/admin/subscriptions/payments/:id'),
                Text('• GET /api/v1/admin/subscriptions/payments/summary'),
                Text('• GET /api/v1/admin/subscriptions/payments/:id/invoice'),
                SizedBox(height: 16),
                Text(
                  'See ticket for full API specification:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                SelectableText(
                  'docs/tickets/TICKET_VENDOR_SUBSCRIPTION_PAYMENT_HISTORY.md',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final SubscriptionPaymentSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          title: 'Total Payments',
          value: summary.totalPayments.toString(),
          icon: Icons.payment,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: 'Succeeded',
          value: summary.succeededCount.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: 'Failed',
          value: summary.failedCount.toString(),
          icon: Icons.error,
          color: AppTheme.dangerRed,
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: 'Total Revenue',
          value: summary.totalAmountDisplay,
          icon: Icons.attach_money,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentDetailsDialog extends StatelessWidget {
  const _PaymentDetailsDialog({required this.payment});

  final SubscriptionPayment payment;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.payment, size: 28),
          SizedBox(width: 12),
          Text('Payment Details'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Payment ID', payment.id),
              _DetailRow('Subscription ID', '#${payment.subscriptionId}'),
              _DetailRow(
                'Vendor',
                payment.vendorName ?? 'ID: ${payment.vendorId}',
              ),
              _DetailRow('Plan', payment.planName ?? 'ID: ${payment.planId}'),
              _DetailRow('Amount', payment.amountDisplay),
              _DetailRow('Currency', payment.currency.toUpperCase()),
              _DetailRow('Status', payment.status.toUpperCase()),
              _DetailRow('Payment Method', payment.cardDisplay),
              if (payment.description != null)
                _DetailRow('Description', payment.description!),
              _DetailRow(
                'Created',
                DateFormat(
                  'MMM d, yyyy hh:mm a',
                ).format(payment.createdAt.toLocal()),
              ),
              if (payment.succeededAt != null)
                _DetailRow(
                  'Succeeded',
                  DateFormat(
                    'MMM d, yyyy hh:mm a',
                  ).format(payment.succeededAt!.toLocal()),
                ),
              if (payment.failedAt != null)
                _DetailRow(
                  'Failed',
                  DateFormat(
                    'MMM d, yyyy hh:mm a',
                  ).format(payment.failedAt!.toLocal()),
                ),
              if (payment.refundedAt != null)
                _DetailRow(
                  'Refunded',
                  DateFormat(
                    'MMM d, yyyy hh:mm a',
                  ).format(payment.refundedAt!.toLocal()),
                ),
              if (payment.invoiceId != null)
                _DetailRow('Invoice ID', payment.invoiceId!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
