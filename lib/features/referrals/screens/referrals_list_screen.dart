/// Referrals tracking screen with filters and statistics
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/error_mapper.dart';
import '../../../models/referral.dart';
import '../../../providers/referrals_provider.dart';
import '../../../widgets/loading_indicator.dart';

class ReferralsListScreen extends ConsumerStatefulWidget {
  const ReferralsListScreen({super.key});

  @override
  ConsumerState<ReferralsListScreen> createState() =>
      _ReferralsListScreenState();
}

class _ReferralsListScreenState extends ConsumerState<ReferralsListScreen> {
  final _searchController = TextEditingController();
  ReferralStatus? _selectedStatus;
  String? _selectedTier;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final search = _searchController.text;

    // Backend requires min 2 chars when searching
    // Skip update if 1 char to avoid unnecessary API calls
    if (search.isNotEmpty && search.length < 2) {
      return;
    }

    ref.read(referralsSearchProvider.notifier).updateSearchTerm(search);
  }

  void _applyFilters() {
    ref.read(referralsFiltersProvider.notifier).state = ReferralsFilters(
      page: 1,
      status: _selectedStatus,
      tier: _selectedTier,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedTier = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
    ref.read(referralsFiltersProvider.notifier).state =
        const ReferralsFilters();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(referralsFiltersProvider);
    final referralsAsync = ref.watch(referralsListProvider(filters));
    final statsAsync = ref.watch(referralsStatsProvider);
    final canView = ref.watch(canViewReferralsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Referrals Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(referralsListProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: !canView
          ? const Center(
              child: Text('You do not have permission to view referrals.'),
            )
          : Column(
              children: [
                // Statistics cards
                statsAsync.when(
                  data: (stats) => _buildStatsCards(stats),
                  loading: () => const SizedBox(height: 100),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Top referrers section
                _buildTopReferrers(),

                // Filters
                _buildFiltersBar(),

                // Referrals list
                Expanded(
                  child: referralsAsync.when(
                    data: (response) => _buildReferralsList(response),
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, stack) => _buildErrorView(error),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCards(ReferralsStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  stats.total.toString(),
                  Colors.blue,
                  Icons.people,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  stats.pending.toString(),
                  Colors.orange,
                  Icons.pending,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  stats.completed.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Rate',
                  '${stats.completionRate.toStringAsFixed(1)}%',
                  Colors.purple,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Rewards',
                  '\$${stats.totalRewards.toStringAsFixed(2)}',
                  Colors.teal,
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Avg Reward',
                  '\$${stats.averageReward.toStringAsFixed(2)}',
                  Colors.indigo,
                  Icons.calculate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Active Tiers',
                  stats.activeTiers.toString(),
                  Colors.pink,
                  Icons.stars,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container()), // Spacer
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopReferrers() {
    final topReferrersAsync = ref.watch(topReferrersProvider(5));

    return topReferrersAsync.when(
      data: (referrers) {
        if (referrers.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Top Referrers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ...referrers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final referrer = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _getRankColor(index),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  referrer.vendorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  referrer.vendorEmail,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${referrer.referralCount} referrals',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${referrer.totalRewards.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.brown[300]!;
      default:
        return Colors.blue[300]!;
    }
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search referrals... (min 2 chars)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
              ),
              maxLength: 64,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<ReferralStatus?>(
            value: _selectedStatus,
            hint: const Text('All Status'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Status')),
              ...ReferralStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value);
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          DropdownButton<String?>(
            value: _selectedTier,
            hint: const Text('All Tiers'),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Tiers')),
              DropdownMenuItem(value: 'bronze', child: Text('Bronze')),
              DropdownMenuItem(value: 'silver', child: Text('Silver')),
              DropdownMenuItem(value: 'gold', child: Text('Gold')),
              DropdownMenuItem(value: 'platinum', child: Text('Platinum')),
            ],
            onChanged: (value) {
              setState(() => _selectedTier = value);
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              _startDate != null && _endDate != null
                  ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                  : 'Date Range',
            ),
          ),
          if (_selectedStatus != null ||
              _selectedTier != null ||
              _startDate != null ||
              _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Clear Filters',
            ),
        ],
      ),
    );
  }

  Widget _buildReferralsList(response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No referrals found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear filters'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: response.data.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final referral = response.data[index];
              return _buildReferralCard(referral);
            },
          ),
        ),
        _buildPaginationControls(response),
      ],
    );
  }

  Widget _buildReferralCard(ReferralListItem referral) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Referral #${referral.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildStatusBadge(referral.status),
                    if (referral.tier != null) ...[
                      const SizedBox(width: 8),
                      _buildTierBadge(referral.tier!),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (referral.referrerVendor != null) ...[
              Row(
                children: [
                  const Icon(Icons.store, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Referrer: ${referral.referrerVendor!.name}'),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (referral.referred != null) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Referred: ${referral.referred!.name}'),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                const Icon(Icons.category, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Type: ${referral.referredType}'),
              ],
            ),
            if (referral.bonusAmount != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Bonus: \$${referral.bonusAmount!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (referral.milestoneAwarded) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const Text(
                      'Milestone',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Created ${DateFormat('MMM d, y').format(referral.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReferralStatus status) {
    final color = Color(int.parse(status.colorHex.replaceFirst('#', '0xFF')));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTierBadge(String tier) {
    final color = _getTierColor(tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            tier.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return Colors.brown;
      case 'silver':
        return Colors.grey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.cyan;
      default:
        return Colors.blue;
    }
  }

  Widget _buildPaginationControls(response) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${response.data.length} of ${response.meta.totalItems} referrals',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: response.hasPrevPage
                    ? () {
                        ref
                            .read(referralsFiltersProvider.notifier)
                            .update(
                              (state) =>
                                  state.copyWith(page: response.prevPage),
                            );
                      }
                    : null,
              ),
              Text(
                'Page ${response.meta.page} of ${response.meta.totalPages}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: response.hasNextPage
                    ? () {
                        ref
                            .read(referralsFiltersProvider.notifier)
                            .update(
                              (state) =>
                                  state.copyWith(page: response.nextPage),
                            );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    final errorMessage = ErrorMapper.mapErrorToMessage(error);
    final isRetryable = ErrorMapper.isRetryable(error);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            ErrorMapper.getErrorTitle(error),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          if (isRetryable)
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(referralsListProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
