import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/vendor.dart';
import '../../providers/vendors_provider.dart';
import '../../routes.dart';
import '../shared/admin_sidebar.dart';
import '../../widgets/data_table_simple.dart';
import '../../widgets/filter_row.dart';
import '../../widgets/status_chip.dart';
import '../../core/export_util.dart';
import '../../widgets/trace_snackbar.dart';
import 'vendor_detail_screen.dart';

/// Screen for managing active (verified) vendors
/// Provides CRUD operations, service management, booking management
class VendorManagementScreen extends ConsumerStatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  ConsumerState<VendorManagementScreen> createState() =>
      _VendorManagementScreenState();
}

class _VendorManagementScreenState
    extends ConsumerState<VendorManagementScreen> {
  late final TextEditingController _searchController;
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Set initial filter to show only verified vendors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(vendorsProvider.notifier);
      final currentState = ref.read(vendorsProvider);
      notifier.updateFilter(currentState.filter.copyWith(status: 'verified'));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(vendorsProvider.notifier);
    final state = ref.watch(vendorsProvider);
    final lastTraceId = ref.watch(lastTraceIdProvider);

    final data = state.data.valueOrNull;
    final isLoading = state.data.isLoading;
    final asyncError = state.data.maybeWhen<Object?>(
      error: (error, _) => error,
      orElse: () => null,
    );
    final Object? error = state.missingEndpoint ?? asyncError;

    final rows = data?.items ?? const <Vendor>[];
    final theme = Theme.of(context);

    // Count vendors by status
    final verifiedCount = rows.where((v) => v.status == 'verified').length;
    final suspendedCount = rows.where((v) => v.status == 'suspended').length;

    return AdminScaffold(
      currentRoute: AppRoute.vendorManagement,
      title: 'Vendor Management',
      actions: [
        IconButton(
          tooltip: 'Reload',
          onPressed: () => notifier.load(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 900;
          return Padding(
            padding: EdgeInsets.fromLTRB(24, isNarrow ? 8 : 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Cards
                if (!isNarrow) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _StatusCard(
                          title: 'Active Vendors',
                          count: verifiedCount,
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatusCard(
                          title: 'Suspended',
                          count: suspendedCount,
                          color: Colors.orange,
                          icon: Icons.pause_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatusCard(
                          title: 'Total',
                          count: data?.total ?? 0,
                          color: Colors.blue,
                          icon: Icons.store,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Filters
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 900;
                    final filterChildren = <Widget>[
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search (company or slug)',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onSubmitted: (value) => notifier.updateFilter(
                            state.filter.copyWith(query: value, page: 1),
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String?>(
                        initialValue: state.filter.status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const <DropdownMenuItem<String?>>[
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(
                            value: 'verified',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'suspended',
                            child: Text('Suspended'),
                          ),
                        ],
                        onChanged: (value) => notifier.updateFilter(
                          state.filter.copyWith(status: value, page: 1),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<int>(
                          initialValue: _pageSize,
                          decoration: const InputDecoration(
                            labelText: 'Records per page',
                          ),
                          items: const [
                            DropdownMenuItem(value: 10, child: Text('10')),
                            DropdownMenuItem(value: 20, child: Text('20')),
                            DropdownMenuItem(value: 50, child: Text('50')),
                            DropdownMenuItem(value: 100, child: Text('100')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _pageSize = value);
                              notifier.updateFilter(
                                state.filter.copyWith(pageSize: value, page: 1),
                              );
                            }
                          },
                        ),
                      ),
                    ];

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpansionTile(
                            title: const Text('Filters'),
                            childrenPadding: EdgeInsets.zero,
                            children: [FilterRow(children: filterChildren)],
                          ),
                        ],
                      );
                    }

                    return FilterRow(children: filterChildren);
                  },
                ),
                const SizedBox(height: 16),

                // Bulk Actions
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 900;
                    if (isNarrow) {
                      return const SizedBox.shrink();
                    }

                    final actions = <Widget>[
                      FilledButton.icon(
                        onPressed: state.selected.isEmpty
                            ? null
                            : () => _bulkSuspend(context, notifier, state),
                        icon: const Icon(Icons.pause_circle_outline),
                        label: const Text('Suspend Selected'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: rows.isEmpty
                            ? null
                            : () {
                                final csv = notifier.exportCurrentCsv();
                                Clipboard.setData(ClipboardData(text: csv));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  buildTraceSnackbar('CSV copied to clipboard'),
                                );
                              },
                        icon: const Icon(Icons.download),
                        label: const Text('Export CSV'),
                      ),
                    ];

                    return Row(
                      children: [
                        Checkbox(
                          value:
                              rows.isNotEmpty &&
                              state.selected.length == rows.length,
                          tristate:
                              rows.isNotEmpty && state.selected.isNotEmpty,
                          onChanged: rows.isEmpty
                              ? null
                              : (value) {
                                  if (value == true) {
                                    notifier.selectAll(rows);
                                  } else {
                                    notifier.clearSelection();
                                  }
                                },
                        ),
                        const SizedBox(width: 8),
                        const Text('Select all'),
                        const Spacer(),
                        ...actions,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Data Table
                Expanded(
                  child: DataTableSimple(
                    columns: const [
                      DataTableSimpleColumn(label: 'Select', flex: 1),
                      DataTableSimpleColumn(label: 'SL No.', flex: 1),
                      DataTableSimpleColumn(label: 'Company', flex: 3),
                      DataTableSimpleColumn(label: 'Contact', flex: 3),
                      DataTableSimpleColumn(label: 'Status', flex: 2),
                      DataTableSimpleColumn(label: 'Services', flex: 2),
                      DataTableSimpleColumn(label: 'Verified', flex: 2),
                      DataTableSimpleColumn(label: 'Actions', flex: 3),
                    ],
                    rows: rows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final vendor = entry.value;
                      // Calculate actual serial number based on pagination
                      final serialNumber =
                          (state.filter.page - 1) * _pageSize + index + 1;
                      return [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Checkbox(
                            value: state.selected.contains(vendor.id),
                            onChanged: (value) =>
                                notifier.toggleSelection(vendor.id),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$serialNumber',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _VendorNameCell(vendor: vendor),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Builder(
                            builder: (_) {
                              final contacts = [
                                if (vendor.contactEmail != null)
                                  vendor.contactEmail!,
                                if (vendor.contactPhone != null)
                                  vendor.contactPhone!,
                              ].where((value) => value.isNotEmpty).toList();
                              return Text(
                                contacts.isEmpty ? '—' : contacts.join('\n'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: StatusChip(
                            label: vendor.status.toUpperCase(),
                            color: _statusColor(theme, vendor.status),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => _viewServices(context, vendor),
                            child: const Text('View Services'),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            vendor.updatedAt != null
                                ? MaterialLocalizations.of(
                                    context,
                                  ).formatMediumDate(vendor.updatedAt!)
                                : MaterialLocalizations.of(
                                    context,
                                  ).formatMediumDate(vendor.createdAt),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _ManagementActions(
                            vendor: vendor,
                            onView: () => _openVendorDetail(context, vendor),
                            onViewServices: () =>
                                _viewServices(context, vendor),
                            onViewBookings: () =>
                                _viewBookings(context, vendor),
                            onSuspend: vendor.status == 'verified'
                                ? () => _confirmSuspendVendor(
                                    context,
                                    notifier,
                                    vendor,
                                    lastTraceId,
                                  )
                                : null,
                            onReactivate: vendor.status == 'suspended'
                                ? () => _confirmReactivateVendor(
                                    context,
                                    notifier,
                                    vendor,
                                    lastTraceId,
                                  )
                                : null,
                            onExport: () {
                              final csv = toCsv([
                                {
                                  'id': vendor.id,
                                  'company_name': vendor.companyName,
                                  'slug': vendor.slug,
                                  'status': vendor.status,
                                  'contact_email': vendor.contactEmail ?? '',
                                  'contact_phone': vendor.contactPhone ?? '',
                                  'created_at': vendor.createdAt
                                      .toIso8601String(),
                                },
                              ]);
                              Clipboard.setData(ClipboardData(text: csv));
                              ScaffoldMessenger.of(context).showSnackBar(
                                buildTraceSnackbar('Vendor CSV copied'),
                              );
                            },
                          ),
                        ),
                      ];
                    }).toList(),
                    isLoading: isLoading,
                    emptyLabel: 'No active vendors found.',
                    total: data?.total ?? 0,
                    page: state.filter.page,
                    pageSize: state.filter.pageSize,
                    onPageChange: notifier.setPage,
                    error: error,
                    onRetry: notifier.load,
                    onUseMock: state.missingEndpoint != null
                        ? notifier.useMockData
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openVendorDetail(BuildContext context, Vendor vendor) {
    Navigator.of(context).pushNamed(
      AppRoute.vendorDetail.path,
      arguments: VendorDetailArgs(vendorId: vendor.id, initialVendor: vendor),
    );
  }

  void _viewServices(BuildContext context, Vendor vendor) {
    // TODO: Navigate to vendor services screen when implemented
    // For now, show a dialog with backend requirement
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${vendor.companyName} - Services'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Backend API needed:'),
            const SizedBox(height: 8),
            const Text('GET /api/v1/admin/vendors/{id}/services'),
            const SizedBox(height: 16),
            Text('See: VENDOR_MANAGEMENT_BACKEND_REQUIREMENTS.md'),
            const SizedBox(height: 16),
            const Text('Features:'),
            const Text('• View all vendor services'),
            const Text('• Activate/Deactivate services'),
            const Text('• Edit service details'),
            const Text('• Manage pricing'),
          ],
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

  void _viewBookings(BuildContext context, Vendor vendor) {
    // TODO: Navigate to vendor bookings screen when implemented
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${vendor.companyName} - Bookings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Backend API needed:'),
            const SizedBox(height: 8),
            const Text('GET /api/v1/admin/vendors/{id}/bookings'),
            const Text(
              'POST /api/v1/admin/vendors/{id}/bookings/{booking_id}/cancel',
            ),
            const SizedBox(height: 16),
            Text('See: VENDOR_MANAGEMENT_BACKEND_REQUIREMENTS.md'),
            const SizedBox(height: 16),
            const Text('Features:'),
            const Text('• View all vendor bookings'),
            const Text('• Cancel bookings (with refund)'),
            const Text('• View booking details'),
            const Text('• Export booking data'),
          ],
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

  Future<void> _bulkSuspend(
    BuildContext context,
    VendorsNotifier notifier,
    VendorsState state,
  ) async {
    final reasonController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Suspend ${state.selected.length} Vendors'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will suspend all selected vendors.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for suspension *',
                  hintText: 'Enter reason (minimum 10 characters)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Reason must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (days)',
                  hintText: 'Leave empty for indefinite',
                  border: OutlineInputBorder(),
                  suffixText: 'days',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Suspend All'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // TODO: Implement bulk suspend when backend API is ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bulk suspend: Backend API needed - See VENDOR_MANAGEMENT_BACKEND_REQUIREMENTS.md',
        ),
        backgroundColor: Colors.orange,
      ),
    );

    reasonController.dispose();
    durationController.dispose();
  }

  Future<void> _confirmSuspendVendor(
    BuildContext context,
    VendorsNotifier notifier,
    Vendor vendor,
    String? lastTraceId,
  ) async {
    final reasonController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suspend ${vendor.companyName}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Suspending this vendor will:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Block new bookings'),
              const Text('• Hide services from customers'),
              const Text('• Restrict dashboard access'),
              const Text('• Preserve existing bookings'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for suspension *',
                  hintText: 'Enter reason (minimum 10 characters)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Reason must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (days)',
                  hintText: 'Leave empty for indefinite',
                  border: OutlineInputBorder(),
                  suffixText: 'days',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final days = int.tryParse(value);
                    if (days == null || days < 1) {
                      return 'Must be a positive number';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Suspend Vendor'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final reason = reasonController.text.trim();
      final durationText = durationController.text.trim();
      final durationDays = durationText.isNotEmpty
          ? int.tryParse(durationText)
          : null;

      await notifier.suspendVendor(
        vendor.id,
        reason: reason,
        durationDays: durationDays,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        buildTraceSnackbar(
          'Vendor suspended successfully',
          traceId: lastTraceId,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to suspend vendor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      reasonController.dispose();
      durationController.dispose();
    }
  }

  Future<void> _confirmReactivateVendor(
    BuildContext context,
    VendorsNotifier notifier,
    Vendor vendor,
    String? lastTraceId,
  ) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reactivate ${vendor.companyName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reactivating this vendor will restore:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Ability to accept new bookings'),
            const Text('• Service listings visibility'),
            const Text('• Full dashboard access'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any notes about reactivation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reactivate Vendor'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final notes = notesController.text.trim();
      await notifier.reactivateVendor(
        vendor.id,
        notes: notes.isNotEmpty ? notes : null,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        buildTraceSnackbar(
          'Vendor reactivated successfully',
          traceId: lastTraceId,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reactivate vendor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      notesController.dispose();
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String title;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorNameCell extends StatelessWidget {
  const _VendorNameCell({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          vendor.companyName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Text(
          '(${vendor.slug})',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _ManagementActions extends StatelessWidget {
  const _ManagementActions({
    required this.vendor,
    required this.onView,
    required this.onViewServices,
    required this.onViewBookings,
    required this.onExport,
    this.onSuspend,
    this.onReactivate,
  });

  final Vendor vendor;
  final VoidCallback onView;
  final VoidCallback onViewServices;
  final VoidCallback onViewBookings;
  final VoidCallback? onSuspend;
  final VoidCallback? onReactivate;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        TextButton(onPressed: onView, child: const Text('Details')),
        if (onSuspend != null)
          TextButton(
            onPressed: onSuspend,
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Suspend'),
          ),
        if (onReactivate != null)
          TextButton(
            onPressed: onReactivate,
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Reactivate'),
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'services':
                onViewServices();
                break;
              case 'bookings':
                onViewBookings();
                break;
              case 'export':
                onExport();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'services',
              child: Row(
                children: [
                  Icon(Icons.category_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Services'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'bookings',
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Bookings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 18),
                  SizedBox(width: 8),
                  Text('Export CSV'),
                ],
              ),
            ),
          ],
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.more_vert, size: 20),
          ),
        ),
      ],
    );
  }
}

Color _statusColor(ThemeData theme, String status) {
  switch (status) {
    case 'verified':
      return Colors.green;
    case 'suspended':
      return Colors.orange;
    default:
      return theme.colorScheme.secondary;
  }
}
