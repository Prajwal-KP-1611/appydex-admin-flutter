import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/audit_log.dart';
import 'admin_exceptions.dart';

/// Repository for audit log management
/// Base Path: /api/v1/admin/audit
class AuditLogRepository {
  AuditLogRepository(this._client);

  final ApiClient _client;

  /// List audit logs
  /// GET /api/v1/admin/audit
  Future<Pagination<AuditLog>> list({
    int skip = 0,
    int limit = 100,
    int? actorUserId,
    String? resourceType,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (resourceType != null && resourceType.isNotEmpty)
        'resource_type': resourceType,
      if (action != null && action.isNotEmpty) 'action': action,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/audit',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => AuditLog.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/audit');
      }
      rethrow;
    }
  }

  /// Get audit log details
  /// GET /api/v1/admin/audit/{log_id}
  Future<AuditLogDetails> getById(String id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/audit/$id',
      );
      return AuditLogDetails.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/audit/:id');
      }
      rethrow;
    }
  }

  /// List available actions
  /// GET /api/v1/admin/audit/actions
  Future<List<String>> listActions() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/audit/actions',
      );
      final data = response.data ?? <String, dynamic>{};
      final actions = data['actions'] as List<dynamic>? ?? [];
      return actions.map((action) => action.toString()).toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/audit/actions');
      }
      rethrow;
    }
  }

  /// List resource types
  /// GET /api/v1/admin/audit/resource-types
  Future<List<String>> listResourceTypes() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/audit/resource-types',
      );
      final data = response.data ?? <String, dynamic>{};
      final types = data['resource_types'] as List<dynamic>? ?? [];
      return types.map((type) => type.toString()).toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/audit/resource-types');
      }
      rethrow;
    }
  }
}

/// Provider for AuditLogRepository
final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuditLogRepository(client);
});

/// State notifier for audit logs
class AuditLogsNotifier
    extends StateNotifier<AsyncValue<Pagination<AuditLog>>> {
  AuditLogsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final AuditLogRepository _repository;

  int? _actorUserIdFilter;
  String? _resourceTypeFilter;
  String? _actionFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  int _skip = 0;
  static const int _limit = 100;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(
        skip: _skip,
        limit: _limit,
        actorUserId: _actorUserIdFilter,
        resourceType: _resourceTypeFilter,
        action: _actionFilter,
        startDate: _startDateFilter,
        endDate: _endDateFilter,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByActor(int? actorUserId) {
    _actorUserIdFilter = actorUserId;
    _skip = 0;
    load();
  }

  void filterByResourceType(String? resourceType) {
    _resourceTypeFilter = resourceType;
    _skip = 0;
    load();
  }

  void filterByAction(String? action) {
    _actionFilter = action;
    _skip = 0;
    load();
  }

  void filterByDateRange(DateTime? startDate, DateTime? endDate) {
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    _skip = 0;
    load();
  }

  void clearFilters() {
    _actorUserIdFilter = null;
    _resourceTypeFilter = null;
    _actionFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _skip = 0;
    load();
  }
}

/// Provider for audit logs state
final auditLogsProvider =
    StateNotifierProvider<AuditLogsNotifier, AsyncValue<Pagination<AuditLog>>>((
      ref,
    ) {
      final repository = ref.watch(auditLogRepositoryProvider);
      return AuditLogsNotifier(repository);
    });

/// Provider for available actions
final auditActionsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(auditLogRepositoryProvider);
  return repository.listActions();
});

/// Provider for available resource types
final auditResourceTypesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(auditLogRepositoryProvider);
  return repository.listResourceTypes();
});
