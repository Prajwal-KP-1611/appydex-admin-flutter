import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import 'admin_exceptions.dart';

/// Referral transaction model
class Referral {
  const Referral({
    required this.id,
    required this.referrerUserId,
    required this.referrerEmail,
    required this.referredUserId,
    required this.referredEmail,
    required this.status,
    required this.rewardAmount,
    required this.createdAt,
    this.completedAt,
  });

  final int id;
  final int referrerUserId;
  final String referrerEmail;
  final int referredUserId;
  final String referredEmail;
  final String status; // 'pending', 'completed', 'cancelled'
  final int rewardAmount; // Amount in smallest currency unit
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: (json['id'] as num).toInt(),
      referrerUserId: (json['referrer_user_id'] as num).toInt(),
      referrerEmail: json['referrer_email'] as String,
      referredUserId: (json['referred_user_id'] as num).toInt(),
      referredEmail: json['referred_email'] as String,
      status: json['status'] as String,
      rewardAmount: (json['reward_amount'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_user_id': referrerUserId,
      'referrer_email': referrerEmail,
      'referred_user_id': referredUserId,
      'referred_email': referredEmail,
      'status': status,
      'reward_amount': rewardAmount,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }
}

/// Repository for referral management
/// Base Path: /api/v1/admin/referrals
///
/// Provides access to referral transactions and statistics.
class ReferralRepository {
  ReferralRepository(this._client);

  final ApiClient _client;

  /// List referral transactions
  /// GET /api/v1/admin/referrals
  ///
  /// Returns list of all referral transactions with referrer and referee details.
  Future<List<Referral>> list() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/referrals',
      );

      final body = response.data ?? <String, dynamic>{};
      final referrals = body['referrals'] as List<dynamic>? ?? const [];

      return referrals
          .map((item) => Referral.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/referrals');
      }
      rethrow;
    }
  }

  /// Get referral statistics for a specific vendor
  /// GET /api/v1/admin/referrals/vendor/{vendor_id}
  ///
  /// Returns comprehensive referral statistics for the vendor.
  Future<Map<String, dynamic>> getVendorStats(int vendorId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/referrals/vendor/$vendorId',
      );
      return response.data ?? {};
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/referrals/vendor/:id');
      }
      rethrow;
    }
  }
}

/// Provider for ReferralRepository
final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReferralRepository(client);
});

/// State notifier for referrals list
class ReferralsNotifier extends StateNotifier<AsyncValue<List<Referral>>> {
  ReferralsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final ReferralRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list();
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for referrals list state
final referralsProvider =
    StateNotifierProvider<ReferralsNotifier, AsyncValue<List<Referral>>>((ref) {
      final repository = ref.watch(referralRepositoryProvider);
      return ReferralsNotifier(repository);
    });
