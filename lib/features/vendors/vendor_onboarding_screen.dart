import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/vendor.dart';
import '../../providers/vendors_provider.dart';
import '../../routes.dart';
import '../shared/admin_sidebar.dart';
import '../shared/confirm_dialog.dart';
import '../../widgets/data_table_simple.dart';
import '../../widgets/filter_row.dart';
import '../../widgets/status_chip.dart';
import '../../core/export_util.dart';
import '../../widgets/trace_snackbar.dart';
import '../../widgets/vendor_approval_dialogs.dart';
import 'vendor_detail_screen.dart';

/// Screen for vendor onboarding queue
/// Shows vendors in pending, onboarding, and rejected states
class VendorOnboardingScreen extends ConsumerStatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  ConsumerState<VendorOnboardingScreen> createState() =>
      _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState
    extends ConsumerState<VendorOnboardingScreen> {
  late final TextEditingController _searchController;
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Set initial filter to show only onboarding statuses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(vendorsProvider.notifier);
      final currentState = ref.read(vendorsProvider);
      notifier.updateFilter(currentState.filter.copyWith(status: 'pending'));
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

    // Count vendors by status for stats
    final pendingCount = rows.where((v) => v.status == 'pending').length;
    final onboardingCount = rows.where((v) => v.status == 'onboarding').length;
    final rejectedCount = rows.where((v) => v.status == 'rejected').length;

    return AdminScaffold(
      currentRoute: AppRoute.vendorOnboarding,
      title: 'Vendor Onboarding',
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
                          title: 'Pending Review',
                          count: pendingCount,
                          color: Colors.orange,
                          icon: Icons.pending_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatusCard(
                          title: 'Onboarding',
                          count: onboardingCount,
                          color: Colors.blue,
                          icon: Icons.hourglass_empty,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatusCard(
                          title: 'Rejected',
                          count: rejectedCount,
                          color: Colors.red,
                          icon: Icons.cancel_outlined,
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
                            labelText: 'Search (company or email)',
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
                            value: 'pending',
                            child: Text('Pending Review'),
                          ),
                          DropdownMenuItem(
                            value: 'onboarding',
                            child: Text('Onboarding'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('Rejected'),
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
                            : () async {
                                final confirmed = await showConfirmDialog(
                                  context,
                                  title: 'Bulk Approve',
                                  message:
                                      'Approve ${state.selected.length} vendors?',
                                  confirmLabel: 'Approve',
                                );
                                if (confirmed != true) return;
                                await notifier.bulkVerify();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  buildTraceSnackbar(
                                    'Vendors approved',
                                    traceId: lastTraceId,
                                  ),
                                );
                              },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Approve Selected'),
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
                      DataTableSimpleColumn(label: 'Company', flex: 4),
                      DataTableSimpleColumn(label: 'Contact', flex: 3),
                      DataTableSimpleColumn(label: 'Business Type', flex: 2),
                      DataTableSimpleColumn(label: 'Status', flex: 2),
                      DataTableSimpleColumn(label: 'Submitted', flex: 2),
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
                          child: Text(vendor.businessType ?? '—'),
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
                          child: Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(vendor.createdAt),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _OnboardingActions(
                            vendor: vendor,
                            onView: () => _openVendorDetail(context, vendor),
                            onApprove: vendor.isPending
                                ? () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => ApproveVendorDialog(
                                        vendorName: vendor.companyName,
                                      ),
                                    );
                                    if (confirmed != true) return;
                                    await notifier.verifyVendor(vendor.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      buildTraceSnackbar(
                                        'Vendor approved',
                                        traceId: lastTraceId,
                                      ),
                                    );
                                  }
                                : null,
                            onReject: vendor.isPending
                                ? () async {
                                    final reason = await showDialog<String>(
                                      context: context,
                                      builder: (context) => RejectVendorDialog(
                                        vendorName: vendor.companyName,
                                      ),
                                    );
                                    if (reason == null) return;
                                    await notifier.rejectVendor(
                                      vendor.id,
                                      reason: reason,
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      buildTraceSnackbar(
                                        'Vendor rejected',
                                        traceId: lastTraceId,
                                      ),
                                    );
                                  }
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
                                  'business_type': vendor.businessType ?? '',
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
                    emptyLabel: 'No vendors in onboarding queue.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          vendor.companyName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          vendor.slug,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          'User #${vendor.userId}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({
    required this.vendor,
    required this.onView,
    required this.onExport,
    this.onApprove,
    this.onReject,
  });

  final Vendor vendor;
  final VoidCallback onView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        TextButton.icon(
          onPressed: onView,
          icon: const Icon(Icons.visibility_outlined, size: 16),
          label: const Text('View'),
        ),
        if (onApprove != null)
          ElevatedButton.icon(
            onPressed: onApprove,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        if (onReject != null)
          OutlinedButton.icon(
            onPressed: onReject,
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        IconButton(
          tooltip: 'Export vendor CSV',
          onPressed: onExport,
          icon: const Icon(Icons.download, size: 20),
        ),
      ],
    );
  }
}

class ApproveVendorDialog extends StatelessWidget {
  const ApproveVendorDialog({super.key, required this.vendorName});

  final String vendorName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve Vendor'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Approve $vendorName?'),
          const SizedBox(height: 16),
          const Text(
            'This will:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Grant vendor access to the platform'),
          const Text('• Allow them to create and manage services'),
          const Text('• Enable them to accept bookings'),
          const Text('• Send approval notification email'),
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
          child: const Text('Approve'),
        ),
      ],
    );
  }
}

Color _statusColor(ThemeData theme, String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'onboarding':
      return Colors.blue;
    case 'rejected':
      return theme.colorScheme.error;
    default:
      return theme.colorScheme.secondary;
  }
}
