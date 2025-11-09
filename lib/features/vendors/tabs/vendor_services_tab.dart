import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/vendor_detail_providers.dart';

class VendorServicesTab extends ConsumerStatefulWidget {
  const VendorServicesTab({required this.vendorId, super.key});

  final int vendorId;

  @override
  ConsumerState<VendorServicesTab> createState() => _VendorServicesTabState();
}

class _VendorServicesTabState extends ConsumerState<VendorServicesTab> {
  String? _statusFilter;
  String? _categoryFilter;
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(
      vendorServicesProvider(
        VendorServicesParams(
          vendorId: widget.vendorId,
          page: _currentPage,
          pageSize: 20,
          status: _statusFilter,
          category: _categoryFilter,
        ),
      ),
    );

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
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
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                    DropdownMenuItem(
                      value: 'pending_approval',
                      child: Text('Pending Approval'),
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
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    isDense: true,
                    hintText: 'Enter category',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _categoryFilter = value.isEmpty ? null : value;
                      _currentPage = 1;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Services list
        Expanded(
          child: servicesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Failed to load services: $error'),
                ],
              ),
            ),
            data: (pagination) {
              if (pagination.items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No services found'),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: pagination.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final service = pagination.items[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _StatusChip(service.status),
                                    if (service.isFeatured) ...[
                                      const SizedBox(width: 8),
                                      const Chip(
                                        label: Text('FEATURED'),
                                        backgroundColor: Colors.amber,
                                        labelStyle: TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _InfoTag(Icons.category, service.category),
                                    if (service.subcategory != null)
                                      _InfoTag(
                                        Icons.subdirectory_arrow_right,
                                        service.subcategory!,
                                      ),
                                    _InfoTag(
                                      Icons.attach_money,
                                      service.pricing.formattedPrice,
                                    ),
                                    if (service.viewsCount != null)
                                      _InfoTag(
                                        Icons.visibility,
                                        '${service.viewsCount} views',
                                      ),
                                    if (service.bookingsCount != null)
                                      _InfoTag(
                                        Icons.event_available,
                                        '${service.bookingsCount} bookings',
                                      ),
                                    if (service.rating != null)
                                      _InfoTag(
                                        Icons.star,
                                        '${service.rating?.toStringAsFixed(1)} rating',
                                      ),
                                  ],
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

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.grey;
        break;
      case 'pending_approval':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }
}
