import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/subscription.dart';
import '../../providers/subscriptions_provider.dart';
import '../../routes.dart';
import '../../widgets/data_table_simple.dart';
import '../../widgets/filter_row.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/trace_snackbar.dart';
import '../shared/admin_sidebar.dart';

class SubscriptionsAdminScreen extends ConsumerWidget {
  const SubscriptionsAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(subscriptionsProvider.notifier);
    final state = ref.watch(subscriptionsProvider);
    final lastTrace = ref.watch(lastTraceIdProvider);
    final data = state.data.valueOrNull;
    final rows = data?.items ?? const <Subscription>[];

    final asyncError = state.data.maybeWhen<Object?>(
      error: (error, _) => error,
      orElse: () => null,
    );
    final Object? error = state.missingEndpoint ?? asyncError;

    return AdminScaffold(
      currentRoute: AppRoute.subscriptions,
      title: 'Subscriptions',
      actions: [
        IconButton(
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
                  width: 160,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Vendor ID'),
                    onSubmitted: (value) => notifier.updateFilter(
                      state.filter.copyWith(
                        vendorId: value.isEmpty ? null : int.tryParse(value),
                        page: 1,
                      ),
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
                DropdownButtonFormField<String?>(
                  initialValue: state.filter.status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const <DropdownMenuItem<String?>>[
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'canceled',
                      child: Text('Canceled'),
                    ),
                  ],
                  onChanged: (value) => notifier.updateFilter(
                    state.filter.copyWith(status: value, page: 1),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                  DataTableSimpleColumn(label: 'ID', flex: 1),
                  DataTableSimpleColumn(label: 'Vendor', flex: 2),
                  DataTableSimpleColumn(label: 'Plan', flex: 2),
                  DataTableSimpleColumn(label: 'Status', flex: 1),
                  DataTableSimpleColumn(label: 'Dates', flex: 2),
                  DataTableSimpleColumn(label: 'Paid months', flex: 1),
                  DataTableSimpleColumn(label: 'Actions', flex: 2),
                ],
                rows: rows
                    .map(
                      (subscription) => [
                        Text('#${subscription.id}'),
                        Text(subscription.vendorId.toString()),
                        Text(subscription.planCode),
                        StatusChip(
                          label: subscription.status,
                          color: subscription.status == 'active'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        Text(
                          '${subscription.startAt?.toLocal() ?? '-'} \n→ ${subscription.endAt?.toLocal() ?? '-'}',
                        ),
                        Text('${subscription.paidMonths}'),
                        TextButton(
                          onPressed: () async {
                            final controller = TextEditingController(text: '3');
                            final result = await showDialog<int>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Activate subscription #${subscription.id}',
                                ),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Paid months',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(
                                      context,
                                      int.tryParse(controller.text),
                                    ),
                                    child: const Text('Activate'),
                                  ),
                                ],
                              ),
                            );
                            if (result == null) return;
                            await notifier.activate(
                              subscription.id,
                              paidMonths: result,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              buildTraceSnackbar(
                                'Subscription activated',
                                traceId: lastTrace,
                              ),
                            );
                          },
                          child: const Text('Activate'),
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

  void _showBackendTodo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Backend TODO'),
        content: Text(
          'Admin subscriptions endpoints are missing. See BACKEND_TODO.md for API contracts.',
        ),
      ),
    );
  }
}
