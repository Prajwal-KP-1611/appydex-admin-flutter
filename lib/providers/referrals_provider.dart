/// Referrals providers for state management
/// Uses Riverpod for dependency injection and state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../core/paginated_response.dart';
import '../core/permissions.dart';
import '../models/referral.dart';
import '../repositories/referrals_repository.dart';

// ============================================================================
// Repository Provider
// ============================================================================

final referralsRepositoryProvider = Provider<ReferralsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReferralsRepository(apiClient);
});

// ============================================================================
// List Referrals Provider
// ============================================================================

/// Provider for listing referrals with filters
///
/// Usage:
/// ```dart
/// final referralsAsync = ref.watch(referralsListProvider(filters));
/// referralsAsync.when(
///   data: (response) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final referralsListProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<ReferralListItem>, ReferralsFilters?>((
      ref,
      filters,
    ) async {
      final repository = ref.watch(referralsRepositoryProvider);
      return repository.listReferrals(filters);
    });

// ============================================================================
// Vendor Referrals Provider
// ============================================================================

/// Provider for fetching vendor-specific referral statistics
///
/// Usage:
/// ```dart
/// final statsAsync = ref.watch(vendorReferralsProvider(vendorId));
/// statsAsync.when(
///   data: (stats) => VendorStatsWidget(stats),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final vendorReferralsProvider = FutureProvider.autoDispose
    .family<VendorReferralStats, int>((ref, vendorId) async {
      final repository = ref.watch(referralsRepositoryProvider);
      return repository.getVendorReferrals(vendorId);
    });

// ============================================================================
// Referrals Filters State Provider
// ============================================================================

/// State provider for managing referral filters
///
/// Usage:
/// ```dart
/// // Read filters
/// final filters = ref.watch(referralsFiltersProvider);
///
/// // Update filters
/// ref.read(referralsFiltersProvider.notifier).state = ReferralsFilters(
///   status: ReferralStatus.completed,
///   page: 1,
/// );
///
/// // Update specific filter
/// ref.read(referralsFiltersProvider.notifier).update((state) =>
///   state.copyWith(tier: 'gold'),
/// );
/// ```
final referralsFiltersProvider = StateProvider.autoDispose<ReferralsFilters>((
  ref,
) {
  return const ReferralsFilters();
});

// ============================================================================
// Referrals Status Filter Provider
// ============================================================================

/// Provider for managing status filter selection
///
/// Usage:
/// ```dart
/// // Read selected status (null means "All")
/// final selectedStatus = ref.watch(referralStatusFilterProvider);
///
/// // Update status filter
/// ref.read(referralStatusFilterProvider.notifier).state = ReferralStatus.completed;
///
/// // Clear filter (show all)
/// ref.read(referralStatusFilterProvider.notifier).state = null;
/// ```
final referralStatusFilterProvider = StateProvider.autoDispose<ReferralStatus?>(
  (ref) {
    return null; // Default: show all statuses
  },
);

// ============================================================================
// Referrals Tier Filter Provider
// ============================================================================

/// Provider for managing tier filter selection
///
/// Usage:
/// ```dart
/// // Read selected tier (null means "All")
/// final selectedTier = ref.watch(referralTierFilterProvider);
///
/// // Update tier filter
/// ref.read(referralTierFilterProvider.notifier).state = 'gold';
///
/// // Clear filter
/// ref.read(referralTierFilterProvider.notifier).state = null;
/// ```
final referralTierFilterProvider = StateProvider.autoDispose<String?>((ref) {
  return null; // Default: show all tiers
});

// ============================================================================
// Referrals Date Range Filter Provider
// ============================================================================

/// Provider for managing date range filter
///
/// Usage:
/// ```dart
/// final dateRange = ref.watch(referralDateRangeProvider);
///
/// ref.read(referralDateRangeProvider.notifier).state = (
///   start: DateTime(2025, 1, 1),
///   end: DateTime(2025, 1, 31),
/// );
/// ```
final referralDateRangeProvider =
    StateProvider.autoDispose<({DateTime? start, DateTime? end})>((ref) {
      return (start: null, end: null);
    });

// ============================================================================
// Referrals Search Provider
// ============================================================================

/// Provider for search functionality with debouncing
///
/// Usage:
/// ```dart
/// // Update search term (debounced)
/// ref.read(referralsSearchProvider.notifier).updateSearchTerm('john@example.com');
///
/// // Get current search term
/// final searchTerm = ref.watch(referralsSearchProvider);
/// ```
final referralsSearchProvider =
    StateNotifierProvider.autoDispose<ReferralsSearchNotifier, String>(
      (ref) => ReferralsSearchNotifier(ref),
    );

class ReferralsSearchNotifier extends StateNotifier<String> {
  final Ref _ref;

  ReferralsSearchNotifier(this._ref) : super('');

  /// Update search term and automatically update filters
  void updateSearchTerm(String term) {
    state = term;

    // Update filters with new search term
    _ref.read(referralsFiltersProvider.notifier).update((filters) {
      return filters.copyWith(search: term.isEmpty ? null : term, page: 1);
    });
  }

  /// Clear search
  void clear() {
    updateSearchTerm('');
  }
}

// ============================================================================
// Referrals Statistics Provider
// ============================================================================

/// Provider for referral statistics/metrics across all vendors
///
/// Usage:
/// ```dart
/// final statsAsync = ref.watch(referralsStatsProvider);
/// statsAsync.when(
///   data: (stats) => StatsWidget(stats),
///   loading: () => Shimmer(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final referralsStatsProvider = FutureProvider.autoDispose<ReferralsStats>((
  ref,
) async {
  final repository = ref.watch(referralsRepositoryProvider);

  // Fetch referrals for each status to calculate stats
  // This is a simple implementation - you may want to add a dedicated stats endpoint
  final allReferrals = await repository.listReferrals(
    const ReferralsFilters(pageSize: 100),
  );

  int pending = 0;
  int completed = 0;
  int cancelled = 0;
  double totalRewards = 0.0;
  final Set<String> uniqueTiers = {};

  for (final referral in allReferrals.data) {
    switch (referral.status) {
      case ReferralStatus.pending:
        pending++;
        break;
      case ReferralStatus.completed:
        completed++;
        if (referral.bonusAmount != null) {
          totalRewards += referral.bonusAmount!;
        }
        break;
      case ReferralStatus.cancelled:
        cancelled++;
        break;
    }

    if (referral.tier != null) {
      uniqueTiers.add(referral.tier!);
    }
  }

  return ReferralsStats(
    total: allReferrals.meta.totalItems,
    pending: pending,
    completed: completed,
    cancelled: cancelled,
    totalRewards: totalRewards,
    activeTiers: uniqueTiers.length,
  );
});

/// Referrals statistics model
class ReferralsStats {
  final int total;
  final int pending;
  final int completed;
  final int cancelled;
  final double totalRewards;
  final int activeTiers;

  ReferralsStats({
    required this.total,
    required this.pending,
    required this.completed,
    required this.cancelled,
    required this.totalRewards,
    required this.activeTiers,
  });

  /// Calculate completion rate
  double get completionRate {
    if (total == 0) return 0;
    return (completed / total) * 100;
  }

  /// Calculate cancellation rate
  double get cancellationRate {
    if (total == 0) return 0;
    return (cancelled / total) * 100;
  }

  /// Calculate average reward per completed referral
  double get averageReward {
    if (completed == 0) return 0;
    return totalRewards / completed;
  }
}

// ============================================================================
// Top Referrers Provider
// ============================================================================

/// Provider for fetching top referrers by completed referrals
///
/// Usage:
/// ```dart
/// final topReferrersAsync = ref.watch(topReferrersProvider(limit: 10));
/// topReferrersAsync.when(
///   data: (referrers) => TopReferrersList(referrers),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final topReferrersProvider = FutureProvider.autoDispose
    .family<List<TopReferrer>, int>((ref, limit) async {
      final repository = ref.watch(referralsRepositoryProvider);

      // Fetch completed referrals sorted by vendor
      final referrals = await repository.listReferrals(
        ReferralsFilters(
          status: ReferralStatus.completed,
          pageSize: 100,
          sortBy: 'created_at',
          sortOrder: 'desc',
        ),
      );

      // Group by referrer and count
      final Map<int, TopReferrer> referrerMap = {};

      for (final referral in referrals.data) {
        // Skip referrals without vendor information
        if (referral.referrerVendor == null) continue;

        final vendorId = referral.referrerVendor!.id;

        if (referrerMap.containsKey(vendorId)) {
          final existing = referrerMap[vendorId]!;
          referrerMap[vendorId] = TopReferrer(
            vendorId: vendorId,
            vendorName: existing.vendorName,
            vendorEmail: existing.vendorEmail,
            referralCount: existing.referralCount + 1,
            totalRewards: existing.totalRewards + (referral.bonusAmount ?? 0),
          );
        } else {
          referrerMap[vendorId] = TopReferrer(
            vendorId: vendorId,
            vendorName: referral.referrerVendor!.name,
            vendorEmail: referral.referrerVendor!.email,
            referralCount: 1,
            totalRewards: referral.bonusAmount ?? 0,
          );
        }
      }

      // Sort by referral count and take top N
      final topReferrers = referrerMap.values.toList()
        ..sort((a, b) => b.referralCount.compareTo(a.referralCount));

      return topReferrers.take(limit).toList();
    });

/// Top referrer model
class TopReferrer {
  final int vendorId;
  final String vendorName;
  final String vendorEmail;
  final int referralCount;
  final double totalRewards;

  TopReferrer({
    required this.vendorId,
    required this.vendorName,
    required this.vendorEmail,
    required this.referralCount,
    required this.totalRewards,
  });
}

// ============================================================================
// Permission-based providers for Referrals
// ============================================================================

/// Can view referrals list
final canViewReferralsProvider = Provider<bool>((ref) {
  final perms = ref.watch(permissionsProvider);
  return perms.contains(Permissions.referralsList) ||
      perms.contains(Permissions.referralsView);
});

/// Can view vendor referral statistics
final canViewReferralStatsProvider = Provider<bool>((ref) {
  final perms = ref.watch(permissionsProvider);
  return perms.contains(Permissions.referralsStats);
});
