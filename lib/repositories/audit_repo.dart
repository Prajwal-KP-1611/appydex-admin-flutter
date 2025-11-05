import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/audit_event.dart';
import 'admin_exceptions.dart';

/// Repository for audit log operations
/// Base Path: /api/v1/admin/audit
///
/// Provides comprehensive audit trail for admin actions including
/// filtering, searching, and metadata queries.
class AuditRepository {
  AuditRepository(this._client);

  final ApiClient _client;

  /// List audit logs with filters
  /// GET /api/v1/admin/audit
  Future<Pagination<AuditEvent>> list({
    String? action,
    String? adminIdentifier,
    String? subjectType,
    String? subjectId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 50,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (action != null && action.isNotEmpty) 'action': action,
      if (adminIdentifier != null && adminIdentifier.isNotEmpty)
        'admin_identifier': adminIdentifier,
      if (subjectType != null && subjectType.isNotEmpty)
        'subject_type': subjectType,
      if (subjectId != null && subjectId.isNotEmpty) 'subject_id': subjectId,
      if (from != null) 'created_after': from.toIso8601String(),
      if (to != null) 'created_before': to.toIso8601String(),
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/audit',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => AuditEvent.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/audit');
      }
      rethrow;
    }
  }

  /// Get audit log details by ID
  /// GET /api/v1/admin/audit/{log_id}
  ///
  /// Returns detailed audit log entry including:
  /// - Actor details (admin who performed action)
  /// - Resource details (what was modified)
  /// - Before/after state diff
  /// - Metadata (IP, user agent, trace ID)
  Future<AuditEvent> getById(String logId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/audit/$logId',
      );
      return AuditEvent.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/audit/:id');
      }
      rethrow;
    }
  }

  /// List available audit actions
  /// GET /api/v1/admin/audit/actions
  ///
  /// Returns list of all possible audit action types:
  /// - vendor_verification_approved
  /// - admin_account_created
  /// - role_assigned
  /// - etc.
  ///
  /// Useful for populating filter dropdowns in UI
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

  /// List available resource types
  /// GET /api/v1/admin/audit/resource-types
  ///
  /// Returns list of all resource types that can be audited:
  /// - vendor
  /// - user
  /// - service
  /// - subscription
  /// - campaign
  /// - payment
  /// - etc.
  ///
  /// Useful for populating filter dropdowns in UI
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

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuditRepository(client);
});

/// Provider for available audit actions
/// Cached for the lifetime of the app
final auditActionsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(auditRepositoryProvider);
  return repository.listActions();
});

/// Provider for available resource types
/// Cached for the lifetime of the app
final auditResourceTypesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(auditRepositoryProvider);
  return repository.listResourceTypes();
});
