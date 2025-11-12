/// Referrals repository for admin panel
/// Handles all referral-related API calls
library;

import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/paginated_response.dart';
import '../models/referral.dart';
import 'bookings_repository.dart'; // For AdminEndpointMissing exception

class ReferralsRepository {
  final ApiClient _apiClient;

  ReferralsRepository(this._apiClient);

  /// List all referrals with optional filters
  ///
  /// **Endpoint:** GET /api/v1/admin/referrals
  /// **Permissions:** referrals.view
  ///
  /// Example:
  /// ```dart
  /// final filters = ReferralsFilters(
  ///   status: ReferralStatus.completed,
  ///   referrerId: 12,
  ///   page: 1,
  ///   pageSize: 25,
  /// );
  /// final result = await repository.listReferrals(filters);
  /// ```
  Future<PaginatedResponse<ReferralListItem>> listReferrals([
    ReferralsFilters? filters,
  ]) async {
    try {
      final queryParams =
          filters?.toQueryParameters() ??
          {
            'page': '1',
            'page_size': '25',
            'sort_by': 'created_at',
            'sort_order': 'desc',
          };

      final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
        '/admin/referrals',
        method: 'GET',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AdminEndpointMissing(
          endpoint: '/admin/referrals',
          message:
              'API returned null response. The endpoint may not be implemented yet.',
        );
      }

      // Handle case where API returns a list instead of paginated response
      if (response.data is List) {
        throw AdminEndpointMissing(
          endpoint: '/admin/referrals',
          message:
              'API returned a list instead of a paginated response. Expected format: {data: [...], meta: {...}}',
        );
      }

      return PaginatedResponse<ReferralListItem>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ReferralListItem.fromJson(json),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw AdminEndpointMissing(
          endpoint: 'GET /admin/referrals',
          message: 'Permission denied: referrals.view required',
        );
      }
      rethrow;
    }
  }

  /// Get referrals for a specific vendor
  ///
  /// **Endpoint:** GET /api/v1/admin/referrals/vendor/{vendor_id}
  /// **Permissions:** referrals.view
  ///
  /// Example:
  /// ```dart
  /// final referrals = await repository.getVendorReferrals(12);
  /// ```
  Future<VendorReferralStats> getVendorReferrals(int vendorId) async {
    try {
      final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
        '/admin/referrals/vendor/$vendorId',
        method: 'GET',
      );

      // Response is automatically unwrapped by ApiClient
      return VendorReferralStats.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw VendorNotFoundException(vendorId);
      }
      if (e.response?.statusCode == 403) {
        throw AdminEndpointMissing(
          endpoint: 'GET /admin/referrals/vendor/{id}',
          message: 'Permission denied: referrals.view required',
        );
      }
      rethrow;
    }
  }
}

/// Vendor referral statistics
class VendorReferralStats {
  final int vendorId;
  final String vendorName;
  final int totalReferrals;
  final int pendingReferrals;
  final int completedReferrals;
  final int cancelledReferrals;
  final int totalRewardsEarned;
  final String? currentTier;
  final List<ReferralListItem> recentReferrals;

  VendorReferralStats({
    required this.vendorId,
    required this.vendorName,
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.completedReferrals,
    required this.cancelledReferrals,
    required this.totalRewardsEarned,
    this.currentTier,
    required this.recentReferrals,
  });

  factory VendorReferralStats.fromJson(Map<String, dynamic> json) {
    return VendorReferralStats(
      vendorId: json['vendor_id'] as int,
      vendorName: json['vendor_name'] as String,
      totalReferrals: json['total_referrals'] as int,
      pendingReferrals: json['pending_referrals'] as int,
      completedReferrals: json['completed_referrals'] as int,
      cancelledReferrals: json['cancelled_referrals'] as int,
      totalRewardsEarned: json['total_rewards_earned'] as int,
      currentTier: json['current_tier'] as String?,
      recentReferrals: (json['recent_referrals'] as List<dynamic>)
          .map((e) => ReferralListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ============================================================================
// Custom Exceptions
// ============================================================================

/// Exception thrown when vendor not found (404)
class VendorNotFoundException implements Exception {
  final int vendorId;

  VendorNotFoundException(this.vendorId);

  @override
  String toString() => 'Vendor not found: $vendorId';
}
