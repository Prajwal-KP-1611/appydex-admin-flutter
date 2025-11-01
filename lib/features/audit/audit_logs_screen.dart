import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audit_provider.dart';
import '../../routes.dart';
import '../../widgets/data_table_simple.dart';
import '../../widgets/filter_row.dart';
import '../../widgets/trace_snackbar.dart';
import '../shared/admin_sidebar.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(auditProvider.notifier);
    final state = ref.watch(auditProvider);

    final async = state.data;
    final data = async.valueOrNull;
    final events = data?.items ?? const [];
    final asyncError = async.maybeWhen<Object?>(
      error: (error, _) => error,
      orElse: () => null,
    );
    final Object? error = state.missingEndpoint ?? asyncError;

    return AdminScaffold(
      currentRoute: AppRoute.audit,
      title: 'Audit Logs',
      actions: [
        IconButton(
          onPressed: () => notifier.load(),
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: events.isEmpty
              ? null
              : () {
                  final csv = notifier.exportCsv();
                  Clipboard.setData(ClipboardData(text: csv));
                  ScaffoldMessenger.of(context).showSnackBar(
                    buildTraceSnackbar('Audit CSV copied to clipboard'),
                  );
                },
          icon: const Icon(Icons.download),
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
                  width: 200,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Action'),
                    onSubmitted: (value) => notifier.updateFilter(
                      state.filter.copyWith(
                        action: value.isEmpty ? null : value,
                        page: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Admin identifier',
                    ),
                    onSubmitted: (value) => notifier.updateFilter(
                      state.filter.copyWith(
                        adminIdentifier: value.isEmpty ? null : value,
                        page: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Subject type',
                    ),
                    onSubmitted: (value) => notifier.updateFilter(
                      state.filter.copyWith(
                        subjectType: value.isEmpty ? null : value,
                        page: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Subject ID'),
                    onSubmitted: (value) => notifier.updateFilter(
                      state.filter.copyWith(
                        subjectId: value.isEmpty ? null : value,
                        page: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataTableSimple(
                columns: const [
                  DataTableSimpleColumn(label: 'Time', flex: 2),
                  DataTableSimpleColumn(label: 'Admin', flex: 2),
                  DataTableSimpleColumn(label: 'Action', flex: 2),
                  DataTableSimpleColumn(label: 'Subject', flex: 2),
                  DataTableSimpleColumn(label: 'Payload', flex: 3),
                ],
                rows: events
                    .map(
                      (event) => [
                        Text(event.createdAt.toLocal().toString()),
                        Text(event.adminIdentifier),
                        Text(event.action),
                        Text('${event.subjectType} #${event.subjectId}'),
                        Text(event.payload?.toString() ?? '-'),
                      ],
                    )
                    .toList(),
                isLoading: async.isLoading,
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
}
