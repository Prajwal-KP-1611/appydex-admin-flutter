import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../models/payment_intent.dart';
import '../../repositories/payment_repo.dart';
import '../../routes.dart';

/// Payments list screen
/// Read-only view of payment intents
class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);

    return AdminScaffold(
      currentRoute: AppRoute.payments,
      title: 'Payment Intents',
      child: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(
                        value: null,
                        label: Text('All'),
                        icon: Icon(Icons.list, size: 16),
                      ),
                      ButtonSegment(
                        value: 'succeeded',
                        label: Text('Succeeded'),
                        icon: Icon(Icons.check_circle, size: 16),
                      ),
                      ButtonSegment(
                        value: 'pending',
                        label: Text('Pending'),
                        icon: Icon(Icons.hourglass_empty, size: 16),
                      ),
                      ButtonSegment(
                        value: 'failed',
                        label: Text('Failed'),
                        icon: Icon(Icons.error, size: 16),
                      ),
                      ButtonSegment(
                        value: 'cancelled',
                        label: Text('Cancelled'),
                        icon: Icon(Icons.cancel, size: 16),
                      ),
                    ],
                    selected: {_statusFilter},
                    onSelectionChanged: (Set<String?> newSelection) {
                      setState(() => _statusFilter = newSelection.first);
                      ref
                          .read(paymentsProvider.notifier)
                          .filterByStatus(newSelection.first);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _statusFilter = null);
                    ref.read(paymentsProvider.notifier).clearFilters();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear Filters'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Payments list
          Expanded(
            child: paymentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Failed to load payments: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(paymentsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (pagination) {
                final payments = pagination.items;

                if (payments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.payment_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusFilter != null
                              ? 'No $_statusFilter payments found'
                              : 'No payment intents yet',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
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
                      // Stats cards
                      Row(
                        children: [
                          _StatCard(
                            title: 'Total Payments',
                            value: pagination.total.toString(),
                            icon: Icons.payment,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Succeeded',
                            value: payments
                                .where((p) => p.isSucceeded)
                                .length
                                .toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Pending',
                            value: payments
                                .where((p) => p.isPending)
                                .length
                                .toString(),
                            icon: Icons.hourglass_empty,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Total Amount',
                            value: _formatTotalAmount(payments),
                            icon: Icons.attach_money,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Payments table
                      Card(
                        child: Column(
                          children: [
                            // Table header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Payment ID',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Vendor',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Description',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Created',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Actions',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Table rows
                            ...payments.map(
                              (payment) => _PaymentRow(
                                payment: payment,
                                onViewDetails: () =>
                                    _showDetailsDialog(context, payment),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pagination info
                      if (pagination.total > pagination.items.length)
                        Text(
                          'Showing ${pagination.items.length} of ${pagination.total} payments',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTotalAmount(List<PaymentIntent> payments) {
    final total = payments
        .where((p) => p.isSucceeded)
        .fold<int>(0, (sum, p) => sum + p.amountCents);
    return '\$${(total / 100).toStringAsFixed(2)}';
  }

  void _showDetailsDialog(BuildContext context, PaymentIntent payment) {
    showDialog(
      context: context,
      builder: (context) => _PaymentDetailsDialog(payment: payment),
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
                      fontSize: 24,
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

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.onViewDetails});

  final PaymentIntent payment;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              payment.id,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              payment.vendorName ?? 'Vendor #${payment.vendorId}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              payment.amountDisplay,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              payment.description ?? '—',
              style: TextStyle(
                fontSize: 13,
                color: payment.description != null
                    ? Colors.grey.shade700
                    : Colors.grey.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: _StatusChip(status: payment.status)),
          Expanded(
            child: Text(
              _formatDate(payment.createdAt),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          SizedBox(
            width: 80,
            child: IconButton(
              onPressed: onViewDetails,
              icon: Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              tooltip: 'View Details',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'succeeded':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'failed':
        color = AppTheme.dangerRed;
        icon = Icons.error;
        break;
      case 'cancelled':
        color = Colors.grey;
        icon = Icons.cancel;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.zero,
    );
  }
}

class _PaymentDetailsDialog extends StatelessWidget {
  const _PaymentDetailsDialog({required this.payment});

  final PaymentIntent payment;

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
              _DetailRow(
                'Vendor',
                payment.vendorName ?? 'ID: ${payment.vendorId}',
              ),
              _DetailRow('Amount', payment.amountDisplay),
              _DetailRow('Currency', payment.currency),
              _DetailRow('Status', payment.status.toUpperCase()),
              if (payment.description != null)
                _DetailRow('Description', payment.description!),
              _DetailRow('Created', _formatDateTime(payment.createdAt)),
              if (payment.succeededAt != null)
                _DetailRow('Succeeded', _formatDateTime(payment.succeededAt!)),
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

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
