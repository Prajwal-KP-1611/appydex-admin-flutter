import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../models/service_type_request.dart';
import '../../repositories/service_type_request_repo.dart';
import '../../routes.dart';
import 'request_review_dialogs.dart';

/// Service Type Requests management screen
/// Handle vendor requests for new service categories with SLA monitoring
class ServiceTypeRequestsListScreen extends ConsumerStatefulWidget {
  const ServiceTypeRequestsListScreen({super.key});

  @override
  ConsumerState<ServiceTypeRequestsListScreen> createState() =>
      _ServiceTypeRequestsListScreenState();
}

class _ServiceTypeRequestsListScreenState
    extends ConsumerState<ServiceTypeRequestsListScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(serviceTypeRequestsProvider);
    final statsAsync = _fetchStats();

    return AdminScaffold(
      currentRoute: AppRoute.services,
      title: 'Service Type Requests',
      actions: [
        SegmentedButton<String?>(
          segments: const [
            ButtonSegment(
              value: null,
              label: Text('All'),
              icon: Icon(Icons.list, size: 16),
            ),
            ButtonSegment(
              value: 'pending',
              label: Text('Pending'),
              icon: Icon(Icons.hourglass_empty, size: 16),
            ),
            ButtonSegment(
              value: 'approved',
              label: Text('Approved'),
              icon: Icon(Icons.check_circle, size: 16),
            ),
            ButtonSegment(
              value: 'rejected',
              label: Text('Rejected'),
              icon: Icon(Icons.cancel, size: 16),
            ),
          ],
          selected: {_statusFilter},
          onSelectionChanged: (Set<String?> newSelection) {
            setState(() => _statusFilter = newSelection.first);
            ref
                .read(serviceTypeRequestsProvider.notifier)
                .filterByStatus(newSelection.first);
          },
        ),
        const SizedBox(width: 16),
      ],
      child: Column(
        children: [
          // SLA Dashboard
          FutureBuilder<ServiceTypeRequestStats>(
            future: statsAsync,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _SLADashboard(stats: snapshot.data!);
              }
              return const SizedBox.shrink();
            },
          ),

          // Requests list
          Expanded(
            child: requestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Failed to load requests: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(serviceTypeRequestsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (pagination) {
                final requests = pagination.items;

                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusFilter != null
                              ? 'No $_statusFilter requests found'
                              : 'No service type requests yet',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Requests table
                      Card(
                        child: Column(
                          children: [
                            // Table header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Requested Service Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Vendor',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Submitted',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      'Actions',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Table rows
                            ...requests.map(
                              (request) => _RequestRow(
                                request: request,
                                onApprove: () =>
                                    _showApproveDialog(context, ref, request),
                                onReject: () =>
                                    _showRejectDialog(context, ref, request),
                                onViewDetails: () =>
                                    _showDetailsDialog(context, request),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pagination info
                      if (pagination.total > pagination.items.length)
                        Text(
                          'Showing ${pagination.items.length} of ${pagination.total} requests',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<ServiceTypeRequestStats> _fetchStats() async {
    final repo = ref.read(serviceTypeRequestRepositoryProvider);
    return repo.getStats();
  }

  void _showApproveDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceTypeRequest request,
  ) {
    showDialog(
      context: context,
      builder: (context) => ApproveRequestDialog(request: request),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceTypeRequest request,
  ) {
    showDialog(
      context: context,
      builder: (context) => RejectRequestDialog(request: request),
    );
  }

  void _showDetailsDialog(BuildContext context, ServiceTypeRequest request) {
    showDialog(
      context: context,
      builder: (context) => _RequestDetailsDialog(request: request),
    );
  }
}

class _SLADashboard extends StatelessWidget {
  const _SLADashboard({required this.stats});

  final ServiceTypeRequestStats stats;

  @override
  Widget build(BuildContext context) {
    final hasViolations = stats.hasSlaViolations;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasViolations ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasViolations ? Colors.red.shade200 : Colors.blue.shade200,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasViolations ? Icons.warning : Icons.analytics,
                color: hasViolations
                    ? AppTheme.dangerRed
                    : Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'SLA Monitoring Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: hasViolations
                      ? AppTheme.dangerRed
                      : Colors.blue.shade900,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text(
                  '48-hour SLA Compliance: ${stats.complianceRateDisplay}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                backgroundColor: _getComplianceColor(stats.slaComplianceRate),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCard(
                title: 'Total Pending',
                value: stats.pendingTotal.toString(),
                icon: Icons.pending,
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Under 24h',
                value: stats.pendingUnder24h.toString(),
                icon: Icons.schedule,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: '24-48h',
                value: stats.pending24To48h.toString(),
                icon: Icons.watch_later,
                color: Colors.amber,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Over 48h (SLA Violation)',
                value: stats.pendingOver48h.toString(),
                icon: Icons.alarm,
                color: AppTheme.dangerRed,
              ),
            ],
          ),
          if (hasViolations) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.error,
                        color: AppTheme.dangerRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Overdue Requests (${stats.overdueRequests.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.dangerRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...stats.overdueRequests
                      .take(3)
                      .map(
                        (overdue) => Padding(
                          padding: const EdgeInsets.only(left: 28, top: 4),
                          child: Text(
                            '• ${overdue.requestedName} (${overdue.ageHours.toStringAsFixed(1)}h old)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ),
                  if (stats.overdueRequests.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(left: 28, top: 4),
                      child: Text(
                        '... and ${stats.overdueRequests.length - 3} more',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getComplianceColor(double rate) {
    if (rate >= 95) return Colors.green.shade100;
    if (rate >= 80) return Colors.amber.shade100;
    return Colors.red.shade100;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.onApprove,
    required this.onReject,
    required this.onViewDetails,
  });

  final ServiceTypeRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final ageHours = DateTime.now().difference(request.createdAt).inHours;
    final isOverdue = ageHours > 48 && request.isPending;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        color: isOverdue ? Colors.red.shade50 : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isOverdue)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.alarm,
                          color: AppTheme.dangerRed,
                          size: 16,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        request.requestedName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                if (request.requestedDescription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    request.requestedDescription!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Text(
              request.vendorName ?? 'Vendor #${request.vendorId}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(child: _StatusChip(status: request.status)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(request.createdAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                Text(
                  '${ageHours}h ago',
                  style: TextStyle(
                    fontSize: 11,
                    color: isOverdue
                        ? AppTheme.dangerRed
                        : Colors.grey.shade500,
                    fontWeight: isOverdue ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onViewDetails,
                  icon: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: 'View Details',
                ),
                if (request.isPending) ...[
                  IconButton(
                    onPressed: onApprove,
                    icon: const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Colors.green,
                    ),
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(
                      Icons.cancel,
                      size: 20,
                      color: AppTheme.dangerRed,
                    ),
                    tooltip: 'Reject',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = AppTheme.dangerRed;
        icon = Icons.cancel;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.zero,
    );
  }
}

class _RequestDetailsDialog extends StatelessWidget {
  const _RequestDetailsDialog({required this.request});

  final ServiceTypeRequest request;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Details'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Request ID', '#${request.id}'),
              _DetailRow(
                'Vendor',
                request.vendorName ?? 'ID: ${request.vendorId}',
              ),
              _DetailRow('Requested Name', request.requestedName),
              if (request.requestedDescription != null)
                _DetailRow('Description', request.requestedDescription!),
              if (request.justification != null)
                _DetailRow('Justification', request.justification!),
              _DetailRow('Status', request.status.toUpperCase()),
              _DetailRow('Submitted', request.createdAt.toString()),
              if (request.reviewedAt != null)
                _DetailRow('Reviewed', request.reviewedAt.toString()),
              if (request.reviewNotes != null)
                _DetailRow('Review Notes', request.reviewNotes!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
