import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../models/service.dart';
import 'admin_exceptions.dart';

/// Repository for service management operations
class ServiceRepository {
  ServiceRepository(this._client);

  final ApiClient _client;

  /// List services with optional filters
  /// Aligned with GET /api/v1/admin/services
  Future<Pagination<Service>> list({
    String? query,
    String? categoryName,
    bool? isActive,
    int? vendorId,
    int page = 1,
    int pageSize = 25,
  }) async {
    final skip = (page - 1) * pageSize;
    final params = <String, dynamic>{
      'skip': skip,
      'limit': pageSize,
      if (query != null && query.isNotEmpty) 'search': query,
      if (categoryName != null && categoryName.isNotEmpty)
        'category': categoryName,
      if (isActive != null) 'is_active': isActive,
      if (vendorId != null) 'vendor_id': vendorId,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/services',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => Service.fromJson(item));
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      if (code == 404) {
        throw AdminEndpointMissing('admin/services');
      }
      if (code == 422) {
        // Some backends may return 422 on unknown filters; degrade gracefully.
        return Pagination<Service>(
          items: const [],
          total: 0,
          page: page,
          pageSize: pageSize,
        );
      }
      rethrow;
    }
  }

  /// Get service by ID
  Future<Service> getById(int id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/services/$id',
      );
      return Service.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/services/:id');
      }
      rethrow;
    }
  }

  /// Create a new service
  /// POST /api/v1/admin/services (uses JSON body)
  Future<Service> create(ServiceRequest request) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/services',
        method: 'POST',
        data: request.toJson(),
        options: idempotentOptions(),
      );
      return Service.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      if (code == 404 || code == 405) {
        throw AdminEndpointMissing('admin/services [POST]');
      }
      rethrow;
    }
  }

  /// Update an existing service
  /// PATCH /api/v1/admin/services/{id} (uses JSON body)
  Future<Service> update(int id, ServiceRequest request) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/services/$id',
        method: 'PATCH',
        data: request.toJson(),
        options: idempotentOptions(),
      );
      return Service.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      if (code == 404 || code == 405) {
        throw AdminEndpointMissing('admin/services/:id [PATCH]');
      }
      rethrow;
    }
  }

  /// Delete a service
  Future<void> delete(int id) async {
    try {
      await _client.requestAdmin<void>(
        '/admin/services/$id',
        method: 'DELETE',
        options: idempotentOptions(),
      );
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      if (code == 404 || code == 405) {
        throw AdminEndpointMissing('admin/services/:id [DELETE]');
      }
      rethrow;
    }
  }

  /// Toggle service visibility
  /// PATCH /api/v1/admin/services/{id}/active
  Future<Service> toggleVisibility(int id, bool isVisible) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/services/$id/active',
        method: 'PATCH',
        data: {'is_active': isVisible},
        options: idempotentOptions(),
      );
      return Service.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      final code = error.response?.statusCode ?? 0;
      if (code == 404 || code == 405) {
        throw AdminEndpointMissing('admin/services/:id [PATCH]');
      }
      rethrow;
    }
  }

  /// List service categories (for dropdown/picker)
  Future<List<ServiceCategory>> listCategories() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/services/categories',
      );
      final data = response.data ?? <String, dynamic>{};
      final items = (data['items'] as List<dynamic>? ?? []);
      return items
          .map((item) => ServiceCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      // Many backends may not implement this endpoint yet or use a different path.
      // Fallback to mock categories for common client errors so the UI remains usable.
      final code = error.response?.statusCode ?? 0;
      if (code == 404 || code == 405 || code == 400 || code == 422) {
        return _mockCategories();
      }
      rethrow;
    }
  }

  /// Mock categories for testing when endpoint is not available
  List<ServiceCategory> _mockCategories() {
    return [
      const ServiceCategory(
        id: '1',
        name: 'Home Services',
        subcategories: [
          ServiceCategory(id: '1a', name: 'Cleaning', parentId: '1'),
          ServiceCategory(id: '1b', name: 'Repairs', parentId: '1'),
          ServiceCategory(id: '1c', name: 'Pest Control', parentId: '1'),
        ],
      ),
      const ServiceCategory(
        id: '2',
        name: 'Personal Care',
        subcategories: [
          ServiceCategory(id: '2a', name: 'Salon', parentId: '2'),
          ServiceCategory(id: '2b', name: 'Spa', parentId: '2'),
          ServiceCategory(id: '2c', name: 'Fitness', parentId: '2'),
        ],
      ),
      const ServiceCategory(
        id: '3',
        name: 'Professional Services',
        subcategories: [
          ServiceCategory(id: '3a', name: 'Legal', parentId: '3'),
          ServiceCategory(id: '3b', name: 'Accounting', parentId: '3'),
          ServiceCategory(id: '3c', name: 'Consulting', parentId: '3'),
        ],
      ),
      const ServiceCategory(
        id: '4',
        name: 'Events',
        subcategories: [
          ServiceCategory(id: '4a', name: 'Photography', parentId: '4'),
          ServiceCategory(id: '4b', name: 'Catering', parentId: '4'),
          ServiceCategory(id: '4c', name: 'Decorations', parentId: '4'),
        ],
      ),
    ];
  }
}

/// Riverpod provider for service repository
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ServiceRepository(client);
});

/// Notifier for managing services state
class ServicesNotifier extends StateNotifier<AsyncValue<Pagination<Service>>> {
  ServicesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final ServiceRepository _repository;

  String? _searchQuery;
  String? _categoryFilter;
  bool? _visibilityFilter;
  int _currentPage = 1;
  static const int _pageSize = 25;

  /// Load services with current filters
  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(
        query: _searchQuery,
        categoryName: _categoryFilter,
        isActive: _visibilityFilter,
        page: _currentPage,
        pageSize: _pageSize,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update search query and reload
  void search(String? query) {
    _searchQuery = query;
    _currentPage = 1;
    load();
  }

  /// Update category filter and reload
  void filterByCategory(String? categoryId) {
    _categoryFilter = categoryId;
    _currentPage = 1;
    load();
  }

  /// Update visibility filter and reload
  void filterByVisibility(bool? isVisible) {
    _visibilityFilter = isVisible;
    _currentPage = 1;
    load();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = null;
    _categoryFilter = null;
    _visibilityFilter = null;
    _currentPage = 1;
    load();
  }

  /// Change page
  void setPage(int page) {
    _currentPage = page;
    load();
  }

  /// Create a new service
  Future<void> create(ServiceRequest request) async {
    await _repository.create(request);
    await load();
  }

  /// Update an existing service
  Future<void> update(int id, ServiceRequest request) async {
    await _repository.update(id, request);
    await load();
  }

  /// Delete a service
  Future<void> delete(int id) async {
    await _repository.delete(id);
    await load();
  }

  /// Toggle service visibility
  Future<void> toggleVisibility(int id, bool isVisible) async {
    await _repository.toggleVisibility(id, isVisible);
    await load();
  }
}

/// Provider for services state
final servicesProvider =
    StateNotifierProvider<ServicesNotifier, AsyncValue<Pagination<Service>>>((
      ref,
    ) {
      final repository = ref.watch(serviceRepositoryProvider);
      return ServicesNotifier(repository);
    });
