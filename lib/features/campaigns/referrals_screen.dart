import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/pagination.dart';
import '../../core/theme.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../models/campaign.dart';
import '../../repositories/campaign_repo.dart';
import '../../routes.dart';

/// Referrals management screen
/// Track referrals and referral codes
class ReferralsScreen extends ConsumerStatefulWidget {
  const ReferralsScreen({super.key});

  @override
  ConsumerState<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends ConsumerState<ReferralsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AppRoute.campaigns,
      title: 'Referrals',
      actions: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Referrals', icon: Icon(Icons.people, size: 20)),
            Tab(text: 'Referral Codes', icon: Icon(Icons.qr_code, size: 20)),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
        ),
        const SizedBox(width: 16),
      ],
      child: TabBarView(
        controller: _tabController,
        children: const [_ReferralsTab(), _ReferralCodesTab()],
      ),
    );
  }
}

/// Provider for referrals state
final referralsProvider =
    StateNotifierProvider<ReferralsNotifier, AsyncValue<Pagination<Referral>>>((
      ref,
    ) {
      final repository = ref.watch(campaignRepositoryProvider);
      return ReferralsNotifier(repository);
    });

class ReferralsNotifier
    extends StateNotifier<AsyncValue<Pagination<Referral>>> {
  ReferralsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final CampaignRepository _repository;

  String? _statusFilter;
  int _skip = 0;
  static const int _limit = 100;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.listReferrals(
        skip: _skip,
        limit: _limit,
        status: _statusFilter,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByStatus(String? status) {
    _statusFilter = status;
    _skip = 0;
    load();
  }

  void clearFilters() {
    _statusFilter = null;
    _skip = 0;
    load();
  }
}

/// Provider for referral codes state
final referralCodesProvider =
    StateNotifierProvider<
      ReferralCodesNotifier,
      AsyncValue<Pagination<ReferralCode>>
    >((ref) {
      final repository = ref.watch(campaignRepositoryProvider);
      return ReferralCodesNotifier(repository);
    });

class ReferralCodesNotifier
    extends StateNotifier<AsyncValue<Pagination<ReferralCode>>> {
  ReferralCodesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final CampaignRepository _repository;

  bool? _activeFilter;
  int _skip = 0;
  static const int _limit = 100;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.listReferralCodes(
        skip: _skip,
        limit: _limit,
        isActive: _activeFilter,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByActive(bool? isActive) {
    _activeFilter = isActive;
    _skip = 0;
    load();
  }

  void clearFilters() {
    _activeFilter = null;
    _skip = 0;
    load();
  }
}

class _ReferralsTab extends ConsumerStatefulWidget {
  const _ReferralsTab();

  @override
  ConsumerState<_ReferralsTab> createState() => _ReferralsTabState();
}

class _ReferralsTabState extends ConsumerState<_ReferralsTab> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final referralsAsync = ref.watch(referralsProvider);
    final statsAsync = ref.watch(campaignStatsProvider);

    return Column(
      children: [
        // Stats
        statsAsync.when(
          data: (stats) => Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200, width: 2),
            ),
            child: Row(
              children: [
                _StatCard(
                  title: 'Total Referrals',
                  value: stats.referrals.total.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Pending',
                  value: stats.referrals.pending.toString(),
                  icon: Icons.hourglass_empty,
                  color: Colors.orange,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Credited',
                  value: stats.referrals.credited.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ],
            ),
          ),
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
                      label: Text('All'),
                      icon: Icon(Icons.list, size: 16),
                    ),
                    ButtonSegment(
                      value: 'pending',
                      label: Text('Pending'),
                      icon: Icon(Icons.hourglass_empty, size: 16),
                    ),
                    ButtonSegment(
                      value: 'credited',
                      label: Text('Credited'),
                      icon: Icon(Icons.check_circle, size: 16),
                    ),
                    ButtonSegment(
                      value: 'expired',
                      label: Text('Expired'),
                      icon: Icon(Icons.cancel, size: 16),
                    ),
                  ],
                  selected: {_statusFilter},
                  onSelectionChanged: (Set<String?> newSelection) {
                    setState(() => _statusFilter = newSelection.first);
                    ref
                        .read(referralsProvider.notifier)
                        .filterByStatus(newSelection.first);
                  },
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _statusFilter = null);
                  ref.read(referralsProvider.notifier).clearFilters();
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

        // Referrals list
        Expanded(
          child: referralsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load referrals: $error'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => ref.refresh(referralsProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (pagination) {
              final referrals = pagination.items;

              if (referrals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusFilter != null
                            ? 'No ${_statusFilter} referrals found'
                            : 'No referrals yet',
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Referrals table
                    Card(
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
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
                                    'Referrer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Referred Vendor',
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
                                    'Created',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Credited',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table rows
                          ...referrals.map(
                            (referral) => _ReferralRow(referral: referral),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pagination info
                    if (pagination.total > pagination.items.length)
                      Text(
                        'Showing ${pagination.items.length} of ${pagination.total} referrals',
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
    );
  }
}

class _ReferralCodesTab extends ConsumerStatefulWidget {
  const _ReferralCodesTab();

  @override
  ConsumerState<_ReferralCodesTab> createState() => _ReferralCodesTabState();
}

class _ReferralCodesTabState extends ConsumerState<_ReferralCodesTab> {
  bool? _activeFilter;

  @override
  Widget build(BuildContext context) {
    final codesAsync = ref.watch(referralCodesProvider);

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<bool?>(
                  segments: const [
                    ButtonSegment(
                      value: null,
                      label: Text('All Codes'),
                      icon: Icon(Icons.list, size: 16),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Active'),
                      icon: Icon(Icons.check_circle, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Inactive'),
                      icon: Icon(Icons.cancel, size: 16),
                    ),
                  ],
                  selected: {_activeFilter},
                  onSelectionChanged: (Set<bool?> newSelection) {
                    setState(() => _activeFilter = newSelection.first);
                    ref
                        .read(referralCodesProvider.notifier)
                        .filterByActive(newSelection.first);
                  },
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _activeFilter = null);
                  ref.read(referralCodesProvider.notifier).clearFilters();
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

        // Codes list
        Expanded(
          child: codesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load referral codes: $error'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => ref.refresh(referralCodesProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (pagination) {
              final codes = pagination.items;

              if (codes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No referral codes found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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
                    // Codes table
                    Card(
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
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
                                    'User',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Referral Code',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Usage Count',
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
                                    'Created',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table rows
                          ...codes.map((code) => _ReferralCodeRow(code: code)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pagination info
                    if (pagination.total > pagination.items.length)
                      Text(
                        'Showing ${pagination.items.length} of ${pagination.total} codes',
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
    );
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

class _ReferralRow extends StatelessWidget {
  const _ReferralRow({required this.referral});

  final Referral referral;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '#${referral.id}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              referral.referrerName ?? 'User #${referral.referrerId}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              referral.referredName ?? 'Vendor #${referral.referredId}',
            ),
          ),
          Expanded(child: _StatusChip(status: referral.status)),
          Expanded(
            child: Text(
              _formatDate(referral.createdAt),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              referral.creditedAt != null
                  ? _formatDate(referral.creditedAt!)
                  : '—',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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

class _ReferralCodeRow extends StatelessWidget {
  const _ReferralCodeRow({required this.code});

  final ReferralCode code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '#${code.id}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              code.userName ?? 'User #${code.userId}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    code.code,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  code.usageCount.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Chip(
              label: Text(
                code.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: code.isActive
                  ? Colors.green.shade100
                  : Colors.grey.shade200,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(code.createdAt),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
      case 'credited':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'expired':
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
