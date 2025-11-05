import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils/toast_service.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../models/campaign.dart';
import '../../repositories/campaign_repo.dart';
import '../../routes.dart';
import 'credit_promo_days_dialog.dart';

/// Promo Ledger management screen
/// Track and manage promotional day credits for vendors
class PromoLedgerScreen extends ConsumerStatefulWidget {
  const PromoLedgerScreen({super.key});

  @override
  ConsumerState<PromoLedgerScreen> createState() => _PromoLedgerScreenState();
}

class _PromoLedgerScreenState extends ConsumerState<PromoLedgerScreen> {
  String? _campaignTypeFilter;

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(promoLedgerProvider);
    final statsAsync = ref.watch(campaignStatsProvider);

    return AdminScaffold(
      currentRoute: AppRoute.campaigns,
      title: 'Promo Days Ledger',
      actions: [
        FilledButton.icon(
          onPressed: () => _showCreditDialog(context, ref),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Credit Promo Days'),
        ),
        const SizedBox(width: 16),
      ],
      child: Column(
        children: [
          // Stats dashboard
          statsAsync.when(
            data: (stats) => _StatsDashboard(stats: stats),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(
                        value: null,
                        label: Text('All Types'),
                        icon: Icon(Icons.list, size: 16),
                      ),
                      ButtonSegment(
                        value: 'referral_bonus',
                        label: Text('Referral'),
                        icon: Icon(Icons.people, size: 16),
                      ),
                      ButtonSegment(
                        value: 'signup_bonus',
                        label: Text('Signup'),
                        icon: Icon(Icons.card_giftcard, size: 16),
                      ),
                      ButtonSegment(
                        value: 'admin_compensation',
                        label: Text('Admin'),
                        icon: Icon(Icons.admin_panel_settings, size: 16),
                      ),
                    ],
                    selected: {_campaignTypeFilter},
                    onSelectionChanged: (Set<String?> newSelection) {
                      setState(() => _campaignTypeFilter = newSelection.first);
                      ref
                          .read(promoLedgerProvider.notifier)
                          .filterByCampaignType(newSelection.first);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _campaignTypeFilter = null);
                    ref.read(promoLedgerProvider.notifier).clearFilters();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear Filters'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Ledger entries
          Expanded(
            child: ledgerAsync.when(
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
                    Text('Failed to load ledger: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(promoLedgerProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (pagination) {
                final entries = pagination.items;

                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _campaignTypeFilter != null
                              ? 'No entries for this campaign type'
                              : 'No promo day entries yet',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_campaignTypeFilter == null)
                          FilledButton.icon(
                            onPressed: () => _showCreditDialog(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Credit First Entry'),
                          ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ledger table
                      Card(
                        child: Column(
                          children: [
                            // Table header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'ID',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Vendor',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Days Credited',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Campaign Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Description',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Created',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
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
                            ...entries.map(
                              (entry) => _LedgerRow(
                                entry: entry,
                                onDelete: () =>
                                    _deleteEntry(context, ref, entry),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pagination info
                      if (pagination.total > pagination.items.length)
                        Text(
                          'Showing ${pagination.items.length} of ${pagination.total} entries',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      const SizedBox(height: 24),
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

  void _showCreditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const CreditPromoDaysDialog(),
    );
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    PromoLedgerEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete this promo day entry?\n\n'
          'Vendor: ${entry.vendorName ?? 'ID ${entry.vendorId}'}\n'
          'Days: ${entry.daysCredited}\n'
          'Type: ${entry.campaignType}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(promoLedgerProvider.notifier).deleteEntry(entry.id);
        if (context.mounted) {
          ToastService.showSuccess(context, 'Entry deleted successfully');
        }
      } catch (error) {
        if (context.mounted) {
          ToastService.showError(context, 'Failed to delete entry: $error');
        }
      }
    }
  }
}

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({required this.stats});

  final CampaignStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                'Campaign Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCard(
                title: 'Total Days Credited',
                value: stats.totalPromoDaysCredited.toString(),
                icon: Icons.event_available,
                color: Colors.purple,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Active Referral Codes',
                value: stats.activeReferralCodes.toString(),
                icon: Icons.qr_code,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Total Referrals',
                value: stats.referrals.total.toString(),
                icon: Icons.people,
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Credited Referrals',
                value: stats.referrals.credited.toString(),
                icon: Icons.check_circle,
                color: Colors.orange,
              ),
            ],
          ),
          if (stats.promoDaysByCampaign.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Days by Campaign Type',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: stats.promoDaysByCampaign.entries.map((entry) {
                return Chip(
                  label: Text(
                    '${_formatCampaignType(entry.key)}: ${entry.value} days',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.white,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCampaignType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
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

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry, required this.onDelete});

  final PromoLedgerEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '#${entry.id}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.vendorName ?? 'Vendor #${entry.vendorId}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  '${entry.daysCredited} days',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Chip(
              label: Text(
                _formatCampaignType(entry.campaignType),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getCampaignColor(entry.campaignType),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.description ?? '—',
              style: TextStyle(
                fontSize: 13,
                color: entry.description != null
                    ? Colors.grey.shade700
                    : Colors.grey.shade400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(entry.createdAt),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          SizedBox(
            width: 80,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete,
                size: 20,
                color: AppTheme.dangerRed,
              ),
              tooltip: 'Delete Entry',
            ),
          ),
        ],
      ),
    );
  }

  String _formatCampaignType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  Color _getCampaignColor(String type) {
    switch (type.toLowerCase()) {
      case 'referral_bonus':
        return Colors.blue.shade100;
      case 'signup_bonus':
        return Colors.green.shade100;
      case 'admin_compensation':
        return Colors.orange.shade100;
      default:
        return const Color(0xFFF3F4F6); // Light mode grey
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
