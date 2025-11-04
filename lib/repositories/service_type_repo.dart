import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../models/service_type.dart';

/// Repository for service type (master catalog) management
/// Base Path: /api/v1/admin/service-types
class ServiceTypeRepository {
  ServiceTypeRepository(this._client);

  final ApiClient _client;

  /// List service types
  /// GET /api/v1/admin/service-types
  Future<Pagination<ServiceType>> list({
    int skip = 0,
    int limit = 100,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/service-types',
      queryParameters: params,
    );

    final body = response.data ?? <String, dynamic>{};
    return Pagination.fromJson(body, (item) => ServiceType.fromJson(item));
  }

  /// Get service type by ID
  /// GET /api/v1/admin/service-types/{service_type_id}
  Future<ServiceType> getById(String id) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/service-types/$id',
    );
    return ServiceType.fromJson(response.data ?? const {});
  }

  /// Create new service type
  /// POST /api/v1/admin/service-types
  Future<ServiceType> create(ServiceTypeRequest request) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/service-types',
      method: 'POST',
      data: request.toJson(),
      options: idempotentOptions(),
    );
    return ServiceType.fromJson(response.data ?? const {});
  }

  /// Update service type
  /// PUT /api/v1/admin/service-types/{service_type_id}
  Future<ServiceType> update(String id, ServiceTypeRequest request) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/service-types/$id',
      method: 'PUT',
      data: request.toJson(),
      options: idempotentOptions(),
    );
    return ServiceType.fromJson(response.data ?? const {});
  }

  /// Delete service type
  /// DELETE /api/v1/admin/service-types/{service_type_id}
  /// ⚠️ Warning: This will CASCADE delete all related services!
  Future<void> delete(String id) async {
    await _client.requestAdmin<void>(
      '/admin/service-types/$id',
      method: 'DELETE',
      options: idempotentOptions(),
    );
  }
}

/// Provider for ServiceTypeRepository
final serviceTypeRepositoryProvider = Provider<ServiceTypeRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ServiceTypeRepository(client);
});

/// State notifier for service types
class ServiceTypesNotifier
    extends StateNotifier<AsyncValue<Pagination<ServiceType>>> {
  ServiceTypesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final ServiceTypeRepository _repository;

  String? _searchQuery;
  int _skip = 0;
  static const int _limit = 100;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(
        skip: _skip,
        limit: _limit,
        search: _searchQuery,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void search(String? query) {
    _searchQuery = query;
    _skip = 0;
    load();
  }

  void clearFilters() {
    _searchQuery = null;
    _skip = 0;
    load();
  }

  Future<void> create(ServiceTypeRequest request) async {
    await _repository.create(request);
    await load();
  }

  Future<void> update(String id, ServiceTypeRequest request) async {
    await _repository.update(id, request);
    await load();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await load();
  }
}

/// Provider for service types state
final serviceTypesProvider =
    StateNotifierProvider<
      ServiceTypesNotifier,
      AsyncValue<Pagination<ServiceType>>
    >((ref) {
      final repository = ref.watch(serviceTypeRepositoryProvider);
      return ServiceTypesNotifier(repository);
    });
