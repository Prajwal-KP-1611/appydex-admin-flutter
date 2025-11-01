import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/subscription.dart';
import 'admin_exceptions.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._client);

  final ApiClient _client;

  Future<Pagination<Subscription>> list({
    int? vendorId,
    String? planCode,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (vendorId != null) 'vendor_id': vendorId,
      if (planCode != null && planCode.isNotEmpty) 'plan_code': planCode,
      if (status != null && status.isNotEmpty) 'status': status,
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

  Future<Subscription> activate({
    required int subscriptionId,
    required int paidMonths,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/subscriptions/$subscriptionId/activate',
        method: 'POST',
        data: {'paid_months': paidMonths},
        options: Options(headers: const {'Content-Type': 'application/json'}),
      );
      return Subscription.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('subscriptions/:id/activate');
      }
      rethrow;
    }
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SubscriptionRepository(client);
});
