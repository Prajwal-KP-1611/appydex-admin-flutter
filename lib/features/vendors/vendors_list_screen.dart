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
import 'vendor_detail_screen.dart';

class VendorsListArgs {
  const VendorsListArgs({this.verified, this.status, this.planCode});

  final bool? verified;
  final String? status;
  final String? planCode;
}

class VendorsListScreen extends ConsumerStatefulWidget {
  const VendorsListScreen({super.key, this.initialArguments});

  final Object? initialArguments;

  @override
  ConsumerState<VendorsListScreen> createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends ConsumerState<VendorsListScreen> {
  late final TextEditingController _searchController;
  DateTimeRange? _createdRange;
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
          notifier.updateFilter(
            state.filter.copyWith(
              verified: args.verified,
              status: args.status,
              planCode: args.planCode,
            ),
          );
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterRow(
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search (name or email)',
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
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) => notifier.updateFilter(
                    state.filter.copyWith(status: value, page: 1),
                  ),
                ),
                DropdownButtonFormField<String?>(
                  initialValue: state.filter.verified == null
                      ? null
                      : (state.filter.verified! ? 'true' : 'false'),
                  decoration: const InputDecoration(labelText: 'Verified'),
                  items: const <DropdownMenuItem<String?>>[
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'true', child: Text('Verified')),
                    DropdownMenuItem(value: 'false', child: Text('Unverified')),
                  ],
                  onChanged: (value) => notifier.updateFilter(
                    state.filter.copyWith(
                      verified: value == null
                          ? null
                          : value == 'true'
                          ? true
                          : false,
                      page: 1,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Plan code'),
                    onSubmitted: (value) => notifier.updateFilter(
                      state.filter.copyWith(
                        planCode: value.isEmpty ? null : value,
                        page: 1,
                      ),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _createdRange,
                    );
                    if (!context.mounted) return;
                    setState(() => _createdRange = range);
                    notifier.updateFilter(
                      state.filter.copyWith(
                        createdAfter: range?.start,
                        createdBefore: range?.end,
                        page: 1,
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _createdRange == null
                        ? 'Created date'
                        : '${_createdRange!.start.toLocal().toShort()} - ${_createdRange!.end.toLocal().toShort()}',
                  ),
                ),
                if (state.missingEndpoint != null)
                  TextButton(
                    onPressed: () => _showBackendTodo(context),
                    child: const Text('View backend TODO'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value:
                      rows.isNotEmpty && state.selected.length == rows.length,
                  tristate: rows.isNotEmpty && state.selected.isNotEmpty,
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
                Text('Select all'),
                const Spacer(),
                FilledButton(
                  onPressed: state.selected.isEmpty
                      ? null
                      : () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Bulk verify',
                            message: 'Verify ${state.selected.length} vendors?',
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
                OutlinedButton(
                  onPressed: state.selected.isEmpty
                      ? null
                      : () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Bulk deactivate',
                            message:
                                'Deactivate ${state.selected.length} vendors?',
                            confirmLabel: 'Deactivate',
                            isDestructive: true,
                          );
                          if (confirmed != true) return;
                          await notifier.bulkDeactivate();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            buildTraceSnackbar(
                              'Vendors deactivated',
                              traceId: lastTraceId,
                            ),
                          );
                        },
                  child: const Text('Deactivate selected'),
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
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTableSimple(
                columns: const [
                  DataTableSimpleColumn(label: 'Select', flex: 1),
                  DataTableSimpleColumn(label: 'Vendor', flex: 3),
                  DataTableSimpleColumn(label: 'Owner', flex: 2),
                  DataTableSimpleColumn(label: 'Contact', flex: 2),
                  DataTableSimpleColumn(label: 'Plan', flex: 1),
                  DataTableSimpleColumn(label: 'Verified', flex: 1),
                  DataTableSimpleColumn(label: 'Onboarding', flex: 1),
                  DataTableSimpleColumn(label: 'Created At', flex: 2),
                  DataTableSimpleColumn(label: 'Actions', flex: 2),
                ],
                rows: rows
                    .map(
                      (vendor) => [
                        Checkbox(
                          value: state.selected.contains(vendor.id),
                          onChanged: (value) =>
                              notifier.toggleSelection(vendor.id),
                        ),
                        _VendorNameCell(vendor: vendor),
                        Text(vendor.ownerEmail),
                        Text(vendor.phone ?? '—'),
                        Text(vendor.planCode ?? '—'),
                        StatusChip(
                          label: vendor.isVerified ? 'Verified' : 'Pending',
                          color: vendor.isVerified
                              ? Colors.green
                              : theme.colorScheme.secondary,
                        ),
                        Text('${(vendor.onboardingScore * 100).round()}%'),
                        Text(vendor.createdAt.toLocal().toString()),
                        _VendorActions(
                          vendor: vendor,
                          onView: () => _openVendorDetail(context, vendor),
                          onVerify: vendor.isVerified
                              ? null
                              : () async {
                                  await notifier.verifyVendor(vendor.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    buildTraceSnackbar(
                                      'Vendor verified',
                                      traceId: lastTraceId,
                                    ),
                                  );
                                },
                          onToggleActive: () async {
                            await notifier.toggleActive(
                              vendor.id,
                              !vendor.isActive,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              buildTraceSnackbar(
                                vendor.isActive
                                    ? 'Vendor deactivated'
                                    : 'Vendor activated',
                                traceId: lastTraceId,
                              ),
                            );
                          },
                          onExport: () {
                            final csv = toCsv([
                              {
                                'id': vendor.id,
                                'name': vendor.name,
                                'owner_email': vendor.ownerEmail,
                                'phone': vendor.phone ?? '',
                                'plan_code': vendor.planCode ?? '',
                                'is_active': vendor.isActive,
                                'is_verified': vendor.isVerified,
                                'onboarding_score': vendor.onboardingScore,
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
      ),
    );
  }

  void _openVendorDetail(BuildContext context, Vendor vendor) {
    Navigator.of(context).pushNamed(
      AppRoute.vendorDetail.path,
      arguments: VendorDetailArgs(vendorId: vendor.id, initialVendor: vendor),
    );
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
        Text(vendor.name, style: Theme.of(context).textTheme.titleMedium),
        if (vendor.notes != null && vendor.notes!.isNotEmpty)
          Text(vendor.notes!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _VendorActions extends StatelessWidget {
  const _VendorActions({
    required this.vendor,
    required this.onView,
    required this.onToggleActive,
    required this.onExport,
    this.onVerify,
  });

  final Vendor vendor;
  final VoidCallback onView;
  final VoidCallback? onVerify;
  final VoidCallback onToggleActive;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        TextButton(onPressed: onView, child: const Text('Detail')),
        if (onVerify != null)
          TextButton(onPressed: onVerify, child: const Text('Verify')),
        TextButton(
          onPressed: onToggleActive,
          child: Text(vendor.isActive ? 'Deactivate' : 'Activate'),
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

extension _DateTimeExt on DateTime {
  String toShort() {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
