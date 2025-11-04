import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../models/subscription.dart';
import 'admin_exceptions.dart';

/// Repository for subscription management
/// Base Path: /api/v1/admin/subscriptions
class SubscriptionRepository {
  SubscriptionRepository(this._client);

  final ApiClient _client;

  /// List subscriptions
  /// GET /api/v1/admin/subscriptions
  Future<Pagination<Subscription>> list({
    int skip = 0,
    int limit = 100,
    String? status,
    int? vendorId,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (vendorId != null) 'vendor_id': vendorId,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/subscriptions',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => Subscription.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/subscriptions');
      }
      rethrow;
    }
  }

  /// Get subscription details
  /// GET /api/v1/admin/subscriptions/{subscription_id}
  Future<Subscription> getById(int id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/subscriptions/$id',
      );
      return Subscription.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/subscriptions/:id');
      }
      rethrow;
    }
  }

  /// Cancel subscription
  /// PATCH /api/v1/admin/subscriptions/{subscription_id}/cancel
  Future<SubscriptionCancellationResult> cancel({
    required int subscriptionId,
    String? reason,
    bool immediate = false,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/subscriptions/$subscriptionId/cancel',
        method: 'PATCH',
        data: {
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          'immediate': immediate,
        },
        options: idempotentOptions(),
      );
      return SubscriptionCancellationResult.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/subscriptions/:id/cancel');
      }
      rethrow;
    }
  }

  /// Extend subscription
  /// PATCH /api/v1/admin/subscriptions/{subscription_id}/extend
  Future<SubscriptionExtensionResult> extend({
    required int subscriptionId,
    required int days,
    String? reason,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/subscriptions/$subscriptionId/extend',
        method: 'PATCH',
        data: {
          'days': days,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
        options: idempotentOptions(),
      );
      return SubscriptionExtensionResult.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/subscriptions/:id/extend');
      }
      rethrow;
    }
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SubscriptionRepository(client);
});

/// State notifier for subscriptions
class SubscriptionsNotifier
    extends StateNotifier<AsyncValue<Pagination<Subscription>>> {
  SubscriptionsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final SubscriptionRepository _repository;

  String? _statusFilter;
  int? _vendorIdFilter;
  int _skip = 0;
  static const int _limit = 100;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(
        skip: _skip,
        limit: _limit,
        status: _statusFilter,
        vendorId: _vendorIdFilter,
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

  void filterByVendor(int? vendorId) {
    _vendorIdFilter = vendorId;
    _skip = 0;
    load();
  }

  void clearFilters() {
    _statusFilter = null;
    _vendorIdFilter = null;
    _skip = 0;
    load();
  }

  Future<void> cancel({
    required int subscriptionId,
    String? reason,
    bool immediate = false,
  }) async {
    await _repository.cancel(
      subscriptionId: subscriptionId,
      reason: reason,
      immediate: immediate,
    );
    await load();
  }

  Future<void> extend({
    required int subscriptionId,
    required int days,
    String? reason,
  }) async {
    await _repository.extend(
      subscriptionId: subscriptionId,
      days: days,
      reason: reason,
    );
    await load();
  }
}

/// Provider for subscriptions state
final subscriptionsProvider =
    StateNotifierProvider<
      SubscriptionsNotifier,
      AsyncValue<Pagination<Subscription>>
    >((ref) {
      final repository = ref.watch(subscriptionRepositoryProvider);
      return SubscriptionsNotifier(repository);
    });
