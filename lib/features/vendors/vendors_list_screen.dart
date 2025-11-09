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

class VendorsListArgs {
  const VendorsListArgs({this.status});

  final String? status;
}

class VendorsListScreen extends ConsumerStatefulWidget {
  const VendorsListScreen({super.key, this.initialArguments});

  final Object? initialArguments;

  @override
  ConsumerState<VendorsListScreen> createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends ConsumerState<VendorsListScreen> {
  late final TextEditingController _searchController;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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

    if (!_initialised) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = widget.initialArguments;
        if (args is VendorsListArgs) {
          notifier.updateFilter(state.filter.copyWith(status: args.status));
        }
      });
      _initialised = true;
    }

    final data = state.data.valueOrNull;
    final isLoading = state.data.isLoading;
    final asyncError = state.data.maybeWhen<Object?>(
      error: (error, _) => error,
      orElse: () => null,
    );
    final Object? error = state.missingEndpoint ?? asyncError;

    final rows = data?.items ?? const <Vendor>[];
    final theme = Theme.of(context);

    return AdminScaffold(
      currentRoute: AppRoute.vendors,
      title: 'Vendors',
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
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'onboarding',
                            child: Text('Onboarding'),
                          ),
                          DropdownMenuItem(
                            value: 'verified',
                            child: Text('Verified'),
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
                          if (state.missingEndpoint != null)
                            TextButton(
                              onPressed: () => _showBackendTodo(context),
                              child: const Text('View backend TODO'),
                            ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FilterRow(children: filterChildren),
                        if (state.missingEndpoint != null)
                          TextButton(
                            onPressed: () => _showBackendTodo(context),
                            child: const Text('View backend TODO'),
                          ),
                      ],
                    );
                  },
                ),
                // Quick action for narrow screens to keep a visible 'Verify' button
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 900;
                    if (!isNarrow || rows.isEmpty || !rows.first.isPending) {
                      return const SizedBox.shrink();
                    }
                    return Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          await notifier.verifyVendor(rows.first.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            buildTraceSnackbar(
                              'Vendor verified',
                              traceId: lastTraceId,
                            ),
                          );
                        },
                        child: const Text('Verify'),
                      ),
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 900;
                    return SizedBox(height: isNarrow ? 0 : 16);
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 900;
                    if (isNarrow) {
                      // Hide bulk action bar on narrow screens to keep row actions visible
                      return const SizedBox.shrink();
                    }
                    final actions = <Widget>[
                      FilledButton(
                        onPressed: state.selected.isEmpty
                            ? null
                            : () async {
                                final confirmed = await showConfirmDialog(
                                  context,
                                  title: 'Bulk verify',
                                  message:
                                      'Verify ${state.selected.length} vendors?',
                                  confirmLabel: 'Verify',
                                );
                                if (confirmed != true) return;
                                await notifier.bulkVerify();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  buildTraceSnackbar(
                                    'Vendors verified',
                                    traceId: lastTraceId,
                                  ),
                                );
                              },
                        child: const Text('Verify selected'),
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
                Expanded(
                  child: DataTableSimple(
                    columns: const [
                      DataTableSimpleColumn(label: 'Select', flex: 1),
                      DataTableSimpleColumn(label: 'Company', flex: 4),
                      DataTableSimpleColumn(label: 'Slug', flex: 2),
                      DataTableSimpleColumn(label: 'Contact', flex: 3),
                      DataTableSimpleColumn(label: 'Status', flex: 3),
                      DataTableSimpleColumn(label: 'Created', flex: 2),
                      DataTableSimpleColumn(label: 'Actions', flex: 3),
                    ],
                    rows: rows
                        .map(
                          (vendor) => [
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
                              child: _VendorNameCell(vendor: vendor),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(vendor.slug),
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
                                    contacts.isEmpty
                                        ? '—'
                                        : contacts.join('\n'),
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
                              child: Text(
                                MaterialLocalizations.of(
                                  context,
                                ).formatMediumDate(vendor.createdAt),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _VendorActions(
                                vendor: vendor,
                                onView: () =>
                                    _openVendorDetail(context, vendor),
                                onVerify: vendor.isPending
                                    ? () async {
                                        await notifier.verifyVendor(vendor.id);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          buildTraceSnackbar(
                                            'Vendor verified',
                                            traceId: lastTraceId,
                                          ),
                                        );
                                      }
                                    : null,
                                onReject: vendor.isPending
                                    ? () async {
                                        final reason = await showDialog<String>(
                                          context: context,
                                          builder: (context) =>
                                              RejectVendorDialog(
                                                vendorName: vendor.companyName,
                                              ),
                                        );
                                        if (reason == null) return;
                                        await notifier.rejectVendor(
                                          vendor.id,
                                          reason: reason,
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          buildTraceSnackbar(
                                            'Vendor rejected',
                                            traceId: lastTraceId,
                                          ),
                                        );
                                      }
                                    : null,
                                onSuspend: vendor.status == 'verified'
                                    ? () => _confirmSuspendVendor(
                                        context,
                                        notifier,
                                        vendor,
                                      )
                                    : null,
                                onReactivate: vendor.status == 'suspended'
                                    ? () => _confirmReactivateVendor(
                                        context,
                                        notifier,
                                        vendor,
                                      )
                                    : null,
                                onExport: () {
                                  final csv = toCsv([
                                    {
                                      'id': vendor.id,
                                      'company_name': vendor.companyName,
                                      'slug': vendor.slug,
                                      'status': vendor.status,
                                      'contact_email':
                                          vendor.contactEmail ?? '',
                                      'contact_phone':
                                          vendor.contactPhone ?? '',
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
                          ],
                        )
                        .toList(),
                    isLoading: isLoading,
                    emptyLabel: 'No vendors found for current filters.',
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

  Future<void> _confirmSuspendVendor(
    BuildContext context,
    VendorsNotifier notifier,
    Vendor vendor,
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
      final lastTraceId = ref.read(lastTraceIdProvider);
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
      final lastTraceId = ref.read(lastTraceIdProvider);
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

  void _showBackendTodo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Backend TODO'),
          content: Text(
            'Admin endpoints are missing. Please refer to BACKEND_TODO.md in the project root for the required API specifications.',
          ),
        );
      },
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'User #${vendor.userId}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (vendor.businessType != null)
          Text(
            vendor.businessType!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

class _VendorActions extends StatelessWidget {
  const _VendorActions({
    required this.vendor,
    required this.onView,
    required this.onExport,
    this.onVerify,
    this.onReject,
    this.onSuspend,
    this.onReactivate,
  });

  final Vendor vendor;
  final VoidCallback onView;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;
  final VoidCallback? onSuspend;
  final VoidCallback? onReactivate;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        TextButton(onPressed: onView, child: const Text('Detail')),
        if (onVerify != null)
          TextButton(onPressed: onVerify, child: const Text('Verify')),
        if (onReject != null)
          TextButton(onPressed: onReject, child: const Text('Reject')),
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
        IconButton(
          tooltip: 'Export vendor CSV',
          onPressed: onExport,
          icon: const Icon(Icons.download),
        ),
      ],
    );
  }
}

Color _statusColor(ThemeData theme, String status) {
  switch (status) {
    case 'verified':
      return Colors.green;
    case 'rejected':
      return theme.colorScheme.error;
    case 'suspended':
      return Colors.orange;
    case 'onboarding':
      return Colors.blue; // Blue for onboarding status
    case 'pending':
    default:
      return theme.colorScheme.secondary;
  }
}
