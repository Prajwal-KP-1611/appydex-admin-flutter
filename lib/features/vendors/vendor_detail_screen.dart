import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/audit_repo.dart';
import '../../repositories/admin_exceptions.dart';
import '../../providers/mock_admin_fallback.dart';
import '../../repositories/vendor_repo.dart';

import '../../core/api_client.dart';
import '../../core/utils/toast_service.dart';
import '../../models/audit_event.dart';
import '../../models/vendor.dart';
import '../../providers/vendors_provider.dart';
import '../../routes.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/trace_snackbar.dart';
import '../../widgets/vendor_approval_dialogs.dart';
import '../../widgets/vendor_documents_dialog.dart';
import '../shared/admin_sidebar.dart';
import '../shared/confirm_dialog.dart';
import 'vendor_verification_widget.dart';

class VendorDetailArgs {
  const VendorDetailArgs({required this.vendorId, this.initialVendor});

  final int vendorId;
  final Vendor? initialVendor;
}

final vendorDetailProvider = FutureProvider.family<Vendor, int>((
  ref,
  id,
) async {
  final repo = ref.read(vendorRepositoryProvider);
  return repo.get(id);
});

final vendorServicesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, int>((ref, vendorId) async {
      final client = ref.read(apiClientProvider);
      try {
        final response = await client.dio.get<List<dynamic>>(
          '/vendors/$vendorId/services',
          options: Options(
            extra: const {'skipAuth': true, 'skipErrorWrapping': true},
          ),
        );
        return _normalizeList(response.data);
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) return const [];
        rethrow;
      }
    });

final vendorAvailabilityProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, int>((ref, vendorId) async {
      final client = ref.read(apiClientProvider);
      try {
        final response = await client.dio.get<List<dynamic>>(
          '/availability/vendors/$vendorId',
          options: Options(extra: const {'skipErrorWrapping': true}),
        );
        return _normalizeList(response.data);
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) return const [];
        rethrow;
      }
    });

final vendorBookingsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, int>((ref, vendorId) async {
      final client = ref.read(apiClientProvider);
      try {
        final response = await client.dio.get<Map<String, dynamic>>(
          '/bookings',
          queryParameters: {'vendor_id': vendorId},
          options: Options(extra: const {'skipErrorWrapping': true}),
        );
        final list = response.data?['items'] as List<dynamic>?;
        return _normalizeList(list);
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) return const [];
        rethrow;
      }
    });

final vendorLeadsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, int>((ref, vendorId) async {
      final client = ref.read(apiClientProvider);
      try {
        final response = await client.dio.get<Map<String, dynamic>>(
          '/leads',
          queryParameters: {'vendor_id': vendorId},
          options: Options(extra: const {'skipErrorWrapping': true}),
        );
        final list = response.data?['items'] as List<dynamic>?;
        return _normalizeList(list);
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) return const [];
        rethrow;
      }
    });

final vendorReviewsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, int>((ref, vendorId) async {
      final client = ref.read(apiClientProvider);
      try {
        final response = await client.dio.get<List<dynamic>>(
          '/vendors/$vendorId/reviews',
          options: Options(extra: const {'skipErrorWrapping': true}),
        );
        return _normalizeList(response.data);
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) return const [];
        rethrow;
      }
    });

final vendorAuditProvider = FutureProvider.family<List<AuditEvent>, int>((
  ref,
  vendorId,
) async {
  final repo = ref.read(auditRepositoryProvider);
  try {
    final page = await repo.list(
      subjectType: 'vendor',
      subjectId: '$vendorId',
      pageSize: 50,
    );
    return page.items;
  } on AdminEndpointMissing {
    final mock = ref.read(mockAdminFallbackProvider);
    return mock.auditLog(pageSize: 20).items;
  }
});

class VendorDetailScreen extends ConsumerWidget {
  const VendorDetailScreen({super.key, this.args});

  final VendorDetailArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorId = args?.vendorId ?? 0;
    final detailAsync = ref.watch(vendorDetailProvider(vendorId));

    return detailAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => AdminScaffold(
        currentRoute: AppRoute.vendors,
        title: 'Vendor detail',
        child: Center(child: Text('Failed to load vendor: $error')),
      ),
      data: (vendor) => _VendorDetailView(vendor: vendor),
    );
  }
}

class _VendorDetailView extends ConsumerStatefulWidget {
  const _VendorDetailView({required this.vendor});

  final Vendor vendor;

  @override
  ConsumerState<_VendorDetailView> createState() => _VendorDetailViewState();
}

class _VendorDetailViewState extends ConsumerState<_VendorDetailView> {
  bool _impersonationModalShown = false;

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final notifier = ref.read(vendorsProvider.notifier);
    final lastTraceId = ref.watch(lastTraceIdProvider);

    return AdminScaffold(
      currentRoute: AppRoute.vendors,
      title: 'Vendor detail',
      child: DefaultTabController(
        length: 5,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _VendorSummaryCard(
              vendor: vendor,
              onApprove: vendor.isVerified
                  ? null
                  : () async {
                      final notes = await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            ApproveVendorDialog(vendorName: vendor.name),
                      );
                      if (notes == null) return;

                      try {
                        await ref
                            .read(vendorsProvider.notifier)
                            .verifyVendor(vendor.id, notes: notes);
                        if (!context.mounted) return;
                        ToastService.showSuccess(
                          context,
                          'Vendor approved successfully',
                        );
                        ref.invalidate(vendorDetailProvider(vendor.id));
                        ref.invalidate(vendorsProvider);
                      } catch (error) {
                        if (!context.mounted) return;
                        ToastService.showError(
                          context,
                          'Failed to approve vendor: $error',
                        );
                      }
                    },
              onReject: vendor.isVerified
                  ? null
                  : () async {
                      final reason = await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            RejectVendorDialog(vendorName: vendor.name),
                      );
                      if (reason == null) return;

                      try {
                        await ref
                            .read(vendorRepositoryProvider)
                            .reject(vendor.id, reason: reason);
                        if (!context.mounted) return;
                        ToastService.showSuccess(context, 'Vendor rejected');
                        ref.invalidate(vendorDetailProvider(vendor.id));
                        ref.invalidate(vendorsProvider);
                      } catch (error) {
                        if (!context.mounted) return;
                        ToastService.showError(
                          context,
                          'Failed to reject vendor: $error',
                        );
                      }
                    },
              onViewDocuments: () {
                showDialog(
                  context: context,
                  builder: (context) => VendorDocumentsDialog(
                    vendorId: vendor.id,
                    vendorName: vendor.name,
                  ),
                );
              },
              onVerify: vendor.isVerified
                  ? null
                  : () async {
                      final result = await showVendorVerificationDialog(
                        context,
                        vendor: vendor,
                      );
                      if (result == null) return;
                      if (result.approved) {
                        await notifier.verifyVendor(
                          vendor.id,
                          notes: result.notes,
                        );
                        if (!context.mounted) return;
                        _showSnack(context, 'Vendor verified', lastTraceId);
                        ref.invalidate(vendorDetailProvider(vendor.id));
                        ref.invalidate(vendorsProvider);
                      } else {
                        if (!context.mounted) return;
                        _showSnack(
                          context,
                          'Verification pending more info',
                          lastTraceId,
                        );
                      }
                    },
              onToggleActive: () async {
                final confirm = await showConfirmDialog(
                  context,
                  title: vendor.isActive
                      ? 'Deactivate vendor'
                      : 'Activate vendor',
                  message: vendor.isActive
                      ? 'Deactivate ${vendor.name}?'
                      : 'Activate ${vendor.name}?',
                  confirmLabel: vendor.isActive ? 'Deactivate' : 'Activate',
                  isDestructive: vendor.isActive,
                );
                if (confirm != true) return;
                await notifier.toggleActive(vendor.id, !vendor.isActive);
                if (!context.mounted) return;
                _showSnack(
                  context,
                  vendor.isActive ? 'Vendor deactivated' : 'Vendor activated',
                  lastTraceId,
                );
                ref.invalidate(vendorDetailProvider(vendor.id));
                ref.invalidate(vendorsProvider);
              },
              onImpersonate: () {
                if (_impersonationModalShown) return;
                _impersonationModalShown = true;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Impersonation'),
                    content: const Text(
                      'Admin impersonation is not yet implemented. Please coordinate with the backend team to issue temporary vendor tokens.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ).whenComplete(() => _impersonationModalShown = false);
              },
            ),
            const SizedBox(height: 24),
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Services'),
                Tab(text: 'Availability'),
                Tab(text: 'Bookings'),
                Tab(text: 'Leads'),
                Tab(text: 'Reviews'),
              ],
            ),
            SizedBox(
              height: 320,
              child: TabBarView(
                children: [
                  _VendorListTab(provider: vendorServicesProvider(vendor.id)),
                  _VendorListTab(
                    provider: vendorAvailabilityProvider(vendor.id),
                  ),
                  _VendorListTab(provider: vendorBookingsProvider(vendor.id)),
                  _VendorListTab(provider: vendorLeadsProvider(vendor.id)),
                  _VendorListTab(provider: vendorReviewsProvider(vendor.id)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent audit events',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _AuditTimeline(vendorId: vendor.id),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message, String? traceId) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(buildTraceSnackbar(message, traceId: traceId));
  }
}

class _VendorSummaryCard extends StatelessWidget {
  const _VendorSummaryCard({
    required this.vendor,
    required this.onVerify,
    required this.onApprove,
    required this.onReject,
    required this.onViewDocuments,
    required this.onToggleActive,
    required this.onImpersonate,
  });

  final Vendor vendor;
  final VoidCallback? onVerify;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback onViewDocuments;
  final VoidCallback onToggleActive;
  final VoidCallback onImpersonate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vendor.name,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                StatusChip(
                  label: vendor.isActive ? 'Active' : 'Inactive',
                  color: vendor.isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                StatusChip(
                  label: vendor.isVerified ? 'Verified' : 'Pending',
                  color: vendor.isVerified
                      ? Colors.green
                      : theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _InfoChip('Owner', vendor.ownerEmail),
                if (vendor.phone != null) _InfoChip('Phone', vendor.phone!),
                if (vendor.planCode != null)
                  _InfoChip('Plan', vendor.planCode!),
                _InfoChip(
                  'Onboarding',
                  '${(vendor.onboardingScore * 100).round()}%',
                ),
                _InfoChip('Created', vendor.createdAt.toLocal().toString()),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // New Approve/Reject buttons (modern workflow)
                if (onApprove != null)
                  FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Verify'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                if (onReject != null)
                  FilledButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  ),

                // View Documents button
                OutlinedButton.icon(
                  onPressed: onViewDocuments,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Documents'),
                ),

                // Legacy verify button (kept for compatibility)
                if (onVerify != null && onApprove == null)
                  FilledButton.icon(
                    onPressed: onVerify,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Verify'),
                  ),

                OutlinedButton.icon(
                  onPressed: onToggleActive,
                  icon: Icon(vendor.isActive ? Icons.pause : Icons.play_arrow),
                  label: Text(vendor.isActive ? 'Deactivate' : 'Activate'),
                ),
                TextButton.icon(
                  onPressed: onImpersonate,
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Impersonate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _VendorListTab extends ConsumerWidget {
  const _VendorListTab({required this.provider});

  final AutoDisposeFutureProvider<List<Map<String, dynamic>>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(provider);
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Failed to load: $error')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No records'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(
                item['name']?.toString() ??
                    item['title']?.toString() ??
                    'Record ${index + 1}',
              ),
              subtitle: Text(
                item.entries
                    .map((entry) => '${entry.key}: ${entry.value}')
                    .join(', '),
              ),
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: items.length,
        );
      },
    );
  }
}

class _AuditTimeline extends ConsumerWidget {
  const _AuditTimeline({required this.vendorId});

  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(vendorAuditProvider(vendorId));
    return values.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Unable to load audit: $error'),
      data: (items) {
        if (items.isEmpty) {
          return const Text('No audit events recorded yet.');
        }
        return Column(
          children: [
            for (final event in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: Text(event.action),
                subtitle: Text(
                  'By ${event.adminIdentifier} on ${event.createdAt.toLocal()}\nPayload: ${event.payload}',
                ),
              ),
          ],
        );
      },
    );
  }
}

List<Map<String, dynamic>> _normalizeList(List<dynamic>? data) {
  if (data == null) return const [];
  return data
      .map(
        (item) =>
            item is Map<String, dynamic> ? item : {'value': item.toString()},
      )
      .toList();
}
