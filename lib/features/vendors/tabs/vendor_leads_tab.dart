import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/vendor_detail_providers.dart';

class VendorLeadsTab extends ConsumerStatefulWidget {
  const VendorLeadsTab({required this.vendorId, super.key});

  final int vendorId;

  @override
  ConsumerState<VendorLeadsTab> createState() => _VendorLeadsTabState();
}

class _VendorLeadsTabState extends ConsumerState<VendorLeadsTab> {
  String? _statusFilter;
  int _currentPage = 1;

  final _currencyFormat = NumberFormat.currency(symbol: '₹');

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(
      vendorLeadsProvider(
        VendorLeadsParams(
          vendorId: widget.vendorId,
          page: _currentPage,
          pageSize: 20,
          status: _statusFilter,
        ),
      ),
    );

    return Column(
      children: [
        // Filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: DropdownButtonFormField<String>(
            initialValue: _statusFilter,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'new', child: Text('New')),
              DropdownMenuItem(value: 'contacted', child: Text('Contacted')),
              DropdownMenuItem(value: 'converted', child: Text('Converted')),
              DropdownMenuItem(value: 'lost', child: Text('Lost')),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value;
                _currentPage = 1;
              });
            },
          ),
        ),

        // Content
        Expanded(
          child: leadsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Failed to load leads: $error'),
                ],
              ),
            ),
            data: (result) {
              final pagination = result.leads;
              final summary = result.summary;

              return Column(
                children: [
                  // Summary cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.purple[50],
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            'Total Leads',
                            '${summary.total}',
                            Icons.people,
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            'New',
                            '${summary.newLeads}',
                            Icons.fiber_new,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            'Converted',
                            '${summary.converted}',
                            Icons.done_all,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            'Conversion Rate',
                            '${(summary.conversionRate * 100).toStringAsFixed(1)}%',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Leads list
                  Expanded(
                    child: pagination.items.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No leads found'),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: pagination.items.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final lead = pagination.items[index];
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
                                              lead.customerName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _StatusChip(lead.status),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (lead.serviceRequested != null)
                                        _InfoRow(
                                          'Service',
                                          lead.serviceRequested!,
                                        ),
                                      if (lead.customerEmail != null)
                                        _InfoRow('Email', lead.customerEmail!),
                                      _InfoRow('Phone', lead.customerPhone),
                                      if (lead.eventDate != null)
                                        _InfoRow(
                                          'Event Date',
                                          DateFormat.yMMMd().format(
                                            lead.eventDate!,
                                          ),
                                        ),
                                      if (lead.budget != null)
                                        _InfoRow(
                                          'Budget',
                                          _currencyFormat.format(
                                            lead.budget!.toDouble() / 100,
                                          ),
                                        ),
                                      _InfoRow('Source', lead.source),
                                      _InfoRow(
                                        'Received',
                                        DateFormat.yMMMd().add_jm().format(
                                          lead.createdAt,
                                        ),
                                      ),
                                      if (lead.message.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            lead.message,
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
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
              textAlign: TextAlign.center,
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
      case 'new':
        color = Colors.blue;
        break;
      case 'contacted':
        color = Colors.purple;
        break;
      case 'converted':
        color = Colors.green;
        break;
      case 'lost':
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
            width: 100,
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
