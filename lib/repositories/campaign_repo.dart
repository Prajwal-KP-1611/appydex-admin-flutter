import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../models/campaign.dart';
import 'admin_exceptions.dart';

/// Repository for campaign management
/// Base Path: /api/v1/admin/campaigns
class CampaignRepository {
  CampaignRepository(this._client);

  final ApiClient _client;

  /// List promo ledger entries
  /// GET /api/v1/admin/campaigns/promo-ledger
  Future<Pagination<PromoLedgerEntry>> listPromoLedger({
    int skip = 0,
    int limit = 100,
    int? vendorId,
    String? campaignType,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (vendorId != null) 'vendor_id': vendorId,
      if (campaignType != null && campaignType.isNotEmpty)
        'campaign_type': campaignType,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/campaigns/promo-ledger',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(
        body,
        (item) => PromoLedgerEntry.fromJson(item),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/campaigns/promo-ledger');
      }
      rethrow;
    }
  }

  /// Manually credit promo days
  /// POST /api/v1/admin/campaigns/promo-credit
  Future<PromoLedgerEntry> creditPromoDays({
    required int vendorId,
    required int days,
    required String campaignType,
    String? description,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/campaigns/promo-credit',
        method: 'POST',
        data: {
          'vendor_id': vendorId,
          'days': days,
          'campaign_type': campaignType,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
        options: idempotentOptions(),
      );
      return PromoLedgerEntry.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/campaigns/promo-credit');
      }
      rethrow;
    }
  }

  /// Delete promo ledger entry
  /// DELETE /api/v1/admin/campaigns/promo-ledger/{entry_id}
  Future<void> deletePromoLedgerEntry(int entryId) async {
    try {
      await _client.requestAdmin<void>(
        '/admin/campaigns/promo-ledger/$entryId',
        method: 'DELETE',
        options: idempotentOptions(),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/campaigns/promo-ledger/:id');
      }
      rethrow;
    }
  }

  /// List referrals
  /// GET /api/v1/admin/campaigns/referrals
  Future<Pagination<Referral>> listReferrals({
    int skip = 0,
    int limit = 100,
    int? referrerId,
    int? referredId,
    String? status,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (referrerId != null) 'referrer_id': referrerId,
      if (referredId != null) 'referred_id': referredId,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/campaigns/referrals',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => Referral.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/campaigns/referrals');
      }
      rethrow;
    }
  }

  /// List referral codes
  /// GET /api/v1/admin/campaigns/referral-codes
  Future<Pagination<ReferralCode>> listReferralCodes({
    int skip = 0,
    int limit = 100,
    int? userId,
    bool? isActive,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (userId != null) 'user_id': userId,
      if (isActive != null) 'is_active': isActive,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/campaigns/referral-codes',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => ReferralCode.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/campaigns/referral-codes');
      }
      rethrow;
    }
  }

  /// Get campaign statistics
  /// GET /api/v1/admin/campaigns/stats
  Future<CampaignStats> getCampaignStats() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/campaigns/stats',
      );
      return CampaignStats.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/campaigns/stats');
      }
      rethrow;
    }
  }

  /// Get vendor referral snapshot
  /// GET /api/v1/admin/referrals/vendor/{vendor_id}
  Future<VendorReferralSnapshot> getVendorReferralSnapshot(int vendorId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/referrals/vendor/$vendorId',
      );
      return VendorReferralSnapshot.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/referrals/vendor/:id');
      }
      rethrow;
    }
  }
}

/// Provider for CampaignRepository
final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return CampaignRepository(client);
});

/// State notifier for promo ledger
class PromoLedgerNotifier
    extends StateNotifier<AsyncValue<Pagination<PromoLedgerEntry>>> {
  PromoLedgerNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final CampaignRepository _repository;

  int? _vendorIdFilter;
  String? _campaignTypeFilter;
  int _skip = 0;
  static const int _limit = 100;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.listPromoLedger(
        skip: _skip,
        limit: _limit,
        vendorId: _vendorIdFilter,
        campaignType: _campaignTypeFilter,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByVendor(int? vendorId) {
    _vendorIdFilter = vendorId;
    _skip = 0;
    load();
  }

  void filterByCampaignType(String? campaignType) {
    _campaignTypeFilter = campaignType;
    _skip = 0;
    load();
  }

  void clearFilters() {
    _vendorIdFilter = null;
    _campaignTypeFilter = null;
    _skip = 0;
    load();
  }

  Future<void> creditDays({
    required int vendorId,
    required int days,
    required String campaignType,
    String? description,
  }) async {
    await _repository.creditPromoDays(
      vendorId: vendorId,
      days: days,
      campaignType: campaignType,
      description: description,
    );
    await load();
  }

  Future<void> deleteEntry(int entryId) async {
    await _repository.deletePromoLedgerEntry(entryId);
    await load();
  }
}

/// Provider for promo ledger state
final promoLedgerProvider =
    StateNotifierProvider<
      PromoLedgerNotifier,
      AsyncValue<Pagination<PromoLedgerEntry>>
    >((ref) {
      final repository = ref.watch(campaignRepositoryProvider);
      return PromoLedgerNotifier(repository);
    });

/// Provider for campaign stats
final campaignStatsProvider = FutureProvider<CampaignStats>((ref) async {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.getCampaignStats();
});
