import 'package:flutter/material.dart';

import '../repositories/admin_exceptions.dart';

class DataTableSimpleColumn {
  const DataTableSimpleColumn({
    required this.label,
    this.numeric = false,
    this.flex = 1,
  });

  final String label;
  final bool numeric;
  final int flex;
}

class DataTableSimple extends StatelessWidget {
  const DataTableSimple({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.emptyLabel = 'No data found.',
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.onPageChange,
    this.error,
    this.onRetry,
    this.onUseMock,
  });

  final List<DataTableSimpleColumn> columns;
  final List<List<Widget>> rows;
  final bool isLoading;
  final String emptyLabel;
  final int total;
  final int page;
  final int pageSize;
  final ValueChanged<int>? onPageChange;
  final Object? error;
  final VoidCallback? onRetry;
  final VoidCallback? onUseMock;

  bool get _hasError => error != null;
  bool get _isAdminMissing => error is AdminEndpointMissing;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _ErrorCard(
        error: error!,
        onRetry: onRetry,
        onUseMock: _isAdminMissing ? onUseMock : null,
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rows.isEmpty) {
      return _EmptyState(label: emptyLabel, onRetry: onRetry);
    }

    final theme = Theme.of(context);
    final totalPages = (total / pageSize).ceil().clamp(1, 1 << 31);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 600),
            child: Table(
              columnWidths: {
                for (var i = 0; i < columns.length; i++)
                  i: FlexColumnWidth(columns[i].flex.toDouble()),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  children: columns
                      .map(
                        (column) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Text(
                            column.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: column.numeric
                                ? TextAlign.end
                                : TextAlign.start,
                          ),
                        ),
                      )
                      .toList(),
                ),
                for (final row in rows)
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    children: [
                      for (var i = 0; i < columns.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: row.elementAt(i),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (onPageChange != null)
          _PaginationControls(
            page: page,
            totalPages: totalPages,
            onPageChange: onPageChange!,
          ),
      ],
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.page,
    required this.totalPages,
    required this.onPageChange,
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: page > 1 ? () => onPageChange(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('$page / $totalPages'),
        IconButton(
          onPressed: page < totalPages ? () => onPageChange(page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label, this.onRetry});

  final String label;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error, this.onRetry, this.onUseMock});

  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onUseMock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endpointMissing = error is AdminEndpointMissing;
    final description = endpointMissing
        ? 'Admin endpoint ${(error as AdminEndpointMissing).endpoint} is missing. Please ask backend to implement it or use mock data.'
        : error.toString();

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to load data',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (onRetry != null)
                  FilledButton(onPressed: onRetry, child: const Text('Retry')),
                if (endpointMissing && onUseMock != null)
                  OutlinedButton(
                    onPressed: onUseMock,
                    child: const Text('Use mock data'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
