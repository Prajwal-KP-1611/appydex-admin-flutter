import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/vendor_detail_providers.dart';

class VendorBookingsTab extends ConsumerStatefulWidget {
  const VendorBookingsTab({required this.vendorId, super.key});

  final int vendorId;

  @override
  ConsumerState<VendorBookingsTab> createState() => _VendorBookingsTabState();
}

class _VendorBookingsTabState extends ConsumerState<VendorBookingsTab> {
  String? _statusFilter;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sort = 'created_at';
  int _currentPage = 1;

  final _currencyFormat = NumberFormat.currency(symbol: '₹');

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(
      vendorBookingsProvider(
        VendorBookingsParams(
          vendorId: widget.vendorId,
          page: _currentPage,
          pageSize: 20,
          status: _statusFilter,
          fromDate: _fromDate,
          toDate: _toDate,
          sort: _sort,
        ),
      ),
    );

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _statusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(
                          value: 'confirmed',
                          child: Text('Confirmed'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _sort,
                      decoration: const InputDecoration(
                        labelText: 'Sort By',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'created_at',
                          child: Text('Date Created'),
                        ),
                        DropdownMenuItem(
                          value: 'event_date',
                          child: Text('Event Date'),
                        ),
                        DropdownMenuItem(
                          value: 'amount',
                          child: Text('Amount'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sort = value ?? 'created_at';
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _fromDate == null
                            ? 'From Date'
                            : DateFormat.yMMMd().format(_fromDate!),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _fromDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _fromDate = date;
                            _currentPage = 1;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _toDate == null
                            ? 'To Date'
                            : DateFormat.yMMMd().format(_toDate!),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _toDate ?? DateTime.now(),
                          firstDate:
                              _fromDate ??
                              DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _toDate = date;
                            _currentPage = 1;
                          });
                        }
                      },
                    ),
                  ),
                  if (_fromDate != null || _toDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear dates',
                      onPressed: () {
                        setState(() {
                          _fromDate = null;
                          _toDate = null;
                          _currentPage = 1;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: bookingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Failed to load bookings: $error'),
                ],
              ),
            ),
            data: (result) {
              final pagination = result.bookings;
              final summary = result.summary;

              return Column(
                children: [
                  // Summary cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[50],
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            'Total Bookings',
                            '${summary.totalBookings}',
                            Icons.event,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            'Total Revenue',
                            _currencyFormat.format(summary.totalRevenue),
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            'Commission',
                            _currencyFormat.format(summary.totalCommission),
                            Icons.account_balance,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bookings list
                  Expanded(
                    child: pagination.items.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No bookings found'),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: pagination.items.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final booking = pagination.items[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Booking #${booking.bookingReference}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _StatusChip(booking.status),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (booking.serviceName != null)
                                        _InfoRow(
                                          'Service',
                                          booking.serviceName!,
                                        ),
                                      _InfoRow(
                                        'Customer',
                                        booking.customerName,
                                      ),
                                      _InfoRow(
                                        'Booking Date',
                                        DateFormat.yMMMd().format(
                                          booking.bookingDate,
                                        ),
                                      ),
                                      _InfoRow(
                                        'Amount',
                                        _currencyFormat.format(
                                          booking.amount / 100,
                                        ),
                                      ),
                                      if (booking.commission != null)
                                        _InfoRow(
                                          'Commission',
                                          _currencyFormat.format(
                                            booking.commission! / 100,
                                          ),
                                        ),
                                      if (booking.vendorPayout != null)
                                        _InfoRow(
                                          'Vendor Payout',
                                          _currencyFormat.format(
                                            booking.vendorPayout! / 100,
                                          ),
                                        ),
                                      _InfoRow(
                                        'Payment',
                                        booking.paymentStatus,
                                      ),
                                      if (booking.createdAt != null)
                                        _InfoRow(
                                          'Created',
                                          DateFormat.yMMMd().add_jm().format(
                                            booking.createdAt!,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Pagination
                  if (pagination.totalPages > 1)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Page $_currentPage of ${pagination.totalPages}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < pagination.totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
