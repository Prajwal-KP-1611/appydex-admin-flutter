import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/vendor.dart';
import 'admin_exceptions.dart';

class VendorRepository {
  VendorRepository(this._client);

  final ApiClient _client;

  Future<Pagination<Vendor>> list({
    String? query,
    String? status,
    String? planCode,
    bool? verified,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (query != null && query.isNotEmpty) 'query': query,
      if (status != null && status.isNotEmpty) 'status': status,
      if (planCode != null && planCode.isNotEmpty) 'plan_code': planCode,
      if (verified != null) 'verified': verified,
      if (createdAfter != null) 'created_after': createdAfter.toIso8601String(),
      if (createdBefore != null)
        'created_before': createdBefore.toIso8601String(),
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => Vendor.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors');
      }
      rethrow;
    }
  }

  Future<Vendor> get(int id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$id',
      );
      return Vendor.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id');
      }
      rethrow;
    }
  }

  Future<Vendor> patch(int id, Map<String, dynamic> changes) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$id',
        method: 'PATCH',
        data: changes,
        options: Options(headers: const {'Content-Type': 'application/json'}),
      );
      return Vendor.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id');
      }
      rethrow;
    }
  }
}

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return VendorRepository(client);
});
