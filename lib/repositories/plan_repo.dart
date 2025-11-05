import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/utils/idempotency.dart';
import '../models/plan.dart';
import 'admin_exceptions.dart';

/// Repository for plan management
/// Base Path: /api/v1/admin/plans
class PlanRepository {
  PlanRepository(this._client);

  final ApiClient _client;

  /// List plans
  /// GET /api/v1/admin/plans
  Future<List<Plan>> list({bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/plans',
        queryParameters: queryParams,
      );
      final body = response.data ?? <String, dynamic>{};
      final items = body['items'] as List<dynamic>? ?? [];
      return items
          .map((item) => Plan.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/plans');
      }
      rethrow;
    }
  }

  /// Get plan details
  /// GET /api/v1/admin/plans/{plan_id}
  Future<Plan> getById(int id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/plans/$id',
      );
      return Plan.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/plans/:id');
      }
      rethrow;
    }
  }

  /// Create new plan
  /// POST /api/v1/admin/plans
  Future<Plan> create(PlanRequest request) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/plans',
        method: 'POST',
        data: request.toJson(),
        options: idempotentOptions(),
      );
      return Plan.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/plans [POST]');
      }
      rethrow;
    }
  }

  /// Update plan
  /// PATCH /api/v1/admin/plans/{plan_id}
  Future<Plan> update(int id, PlanRequest request) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/plans/$id',
        method: 'PATCH',
        data: request.toJson(),
        options: idempotentOptions(),
      );
      return Plan.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/plans/:id [PATCH]');
      }
      rethrow;
    }
  }

  /// Deactivate plan (soft delete)
  /// DELETE /api/v1/admin/plans/{plan_id}
  Future<void> deactivate(int id) async {
    try {
      await _client.requestAdmin<void>(
        '/admin/plans/$id',
        method: 'DELETE',
        options: idempotentOptions(),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/plans/:id [DELETE]');
      }
      rethrow;
    }
  }

  /// Reactivate plan
  /// POST /api/v1/admin/plans/{plan_id}/reactivate
  Future<Plan> reactivate(int id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/plans/$id/reactivate',
        method: 'POST',
        options: idempotentOptions(),
      );
      return Plan.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/plans/:id/reactivate');
      }
      rethrow;
    }
  }

  /// Hard delete plan (permanent)
  /// DELETE /api/v1/admin/plans/{plan_id}/hard-delete
  Future<void> hardDelete(int id) async {
    try {
      await _client.requestAdmin<void>(
        '/admin/plans/$id/hard-delete',
        method: 'DELETE',
        options: idempotentOptions(),
      );
    } on DioException {
      rethrow;
    }
  }
}

/// Provider for PlanRepository
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PlanRepository(client);
});

/// State notifier for plans
class PlansNotifier extends StateNotifier<AsyncValue<List<Plan>>> {
  PlansNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final PlanRepository _repository;
  bool? _isActiveFilter;

  Future<void> load({bool? isActive}) async {
    _isActiveFilter = isActive;
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(isActive: isActive);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> create(PlanRequest request) async {
    await _repository.create(request);
    await load(isActive: _isActiveFilter);
  }

  Future<void> update(int id, PlanRequest request) async {
    await _repository.update(id, request);
    await load(isActive: _isActiveFilter);
  }

  Future<void> deactivate(int id) async {
    await _repository.deactivate(id);
    await load(isActive: _isActiveFilter);
  }

  Future<void> reactivate(int id) async {
    await _repository.reactivate(id);
    await load(isActive: _isActiveFilter);
  }

  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);
    await load(isActive: _isActiveFilter);
  }
}

/// Provider for plans state
final plansProvider =
    StateNotifierProvider<PlansNotifier, AsyncValue<List<Plan>>>((ref) {
      final repository = ref.watch(planRepositoryProvider);
      return PlansNotifier(repository);
    });
