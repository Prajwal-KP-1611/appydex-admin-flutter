import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/vendor_repo.dart';

import '../../core/utils/toast_service.dart';
import '../../models/vendor.dart';
import '../../providers/vendors_provider.dart';
import '../../routes.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/vendor_approval_dialogs.dart';
import '../../widgets/vendor_documents_dialog.dart';
import '../shared/admin_sidebar.dart';
import 'tabs/vendor_application_tab.dart';
import 'tabs/vendor_services_tab.dart';
import 'tabs/vendor_bookings_tab.dart';
import 'tabs/vendor_leads_tab.dart';
import 'tabs/vendor_revenue_tab.dart';
import 'tabs/vendor_payouts_tab.dart';
import 'tabs/vendor_analytics_tab.dart';
import 'tabs/vendor_documents_tab.dart';

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

    return AdminScaffold(
      currentRoute: AppRoute.vendors,
      title: 'Vendor detail',
      child: DefaultTabController(
        length: 8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: _VendorSummaryCard(
                  vendor: vendor,
                  onApprove: vendor.isVerified
                      ? null
                      : () async {
                          final notes = await showDialog<String>(
                            context: context,
                            builder: (context) => ApproveVendorDialog(
                              vendorName: vendor.companyName,
                            ),
                          );
                          if (notes == null) return;

                          try {
                            await notifier.verifyVendor(
                              vendor.id,
                              notes: notes,
                            );
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
                            builder: (context) => RejectVendorDialog(
                              vendorName: vendor.companyName,
                            ),
                          );
                          if (reason == null) return;

                          try {
                            await notifier.rejectVendor(
                              vendor.id,
                              reason: reason,
                            );
                            if (!context.mounted) return;
                            ToastService.showSuccess(
                              context,
                              'Vendor rejected',
                            );
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
                        vendorName: vendor.companyName,
                      ),
                    );
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
              ),
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(icon: Icon(Icons.app_registration), text: 'Application'),
                  Tab(icon: Icon(Icons.room_service), text: 'Services'),
                  Tab(icon: Icon(Icons.book_online), text: 'Bookings'),
                  Tab(icon: Icon(Icons.contact_page), text: 'Leads'),
                  Tab(icon: Icon(Icons.payments), text: 'Revenue'),
                  Tab(icon: Icon(Icons.account_balance), text: 'Payouts'),
                  Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
                  Tab(icon: Icon(Icons.folder), text: 'Documents'),
                ],
              ),
              SizedBox(
                height: 600,
                child: TabBarView(
                  children: [
                    VendorApplicationTab(vendorId: vendor.id),
                    VendorServicesTab(vendorId: vendor.id),
                    VendorBookingsTab(vendorId: vendor.id),
                    VendorLeadsTab(vendorId: vendor.id),
                    VendorRevenueTab(vendorId: vendor.id),
                    VendorPayoutsTab(vendorId: vendor.id),
                    VendorAnalyticsTab(vendorId: vendor.id),
                    VendorDocumentsTab(vendorId: vendor.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorSummaryCard extends StatelessWidget {
  const _VendorSummaryCard({
    required this.vendor,
    required this.onApprove,
    required this.onReject,
    required this.onViewDocuments,
    required this.onImpersonate,
  });

  final Vendor vendor;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback onViewDocuments;
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
                    vendor.companyName,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                StatusChip(
                  label: vendor.status.toUpperCase(),
                  color: _statusColor(theme, vendor.status),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vendor Information Section
            _buildInfoSection(context, 'Vendor Information', [
              if (vendor.contactEmail != null)
                _buildInfoRow(
                  Icons.email_outlined,
                  'Email',
                  vendor.contactEmail!,
                ),
              if (vendor.contactPhone != null)
                _buildInfoRow(
                  Icons.phone_outlined,
                  'Phone',
                  vendor.contactPhone!,
                ),
              _buildInfoRow(
                Icons.business_outlined,
                'Company Name',
                vendor.companyName,
              ),
              _buildInfoRow(Icons.tag, 'Slug', vendor.slug),
              if (vendor.businessType != null)
                _buildInfoRow(
                  Icons.category_outlined,
                  'Business Type',
                  vendor.businessType!,
                ),
            ]),

            const SizedBox(height: 16),

            // System Information
            _buildInfoSection(context, 'System Information', [
              _buildInfoRow(Icons.badge_outlined, 'Vendor ID', '#${vendor.id}'),
              _buildInfoRow(
                Icons.person_outline,
                'User ID',
                '#${vendor.userId}',
              ),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Created',
                MaterialLocalizations.of(
                  context,
                ).formatFullDate(vendor.createdAt),
              ),
              if (vendor.updatedAt != null)
                _buildInfoRow(
                  Icons.update_outlined,
                  'Updated',
                  MaterialLocalizations.of(
                    context,
                  ).formatFullDate(vendor.updatedAt!),
                ),
            ]),

            const SizedBox(height: 24),
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

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(ThemeData theme, String status) {
  switch (status) {
    case 'verified':
      return Colors.green;
    case 'rejected':
      return theme.colorScheme.error;
    case 'pending':
    default:
      return theme.colorScheme.secondary;
  }
}
