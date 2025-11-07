import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/utils/idempotency.dart';
import '../models/admin_role.dart';

/// Repository for role management operations
/// Base Path: /api/v1/admin/roles
class RoleRepository {
  RoleRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// List available roles
  /// GET /api/v1/admin/roles/available
  Future<List<AdminRole>> getAvailableRoles() async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/roles/available',
    );

    final data = response.data;
    if (data == null) return AdminRole.values;

    final adminRoles = data['admin_roles'] as List<dynamic>? ?? [];
    if (adminRoles.isEmpty) return AdminRole.values;
    return adminRoles
        .map((item) {
          if (item is String) return AdminRole.fromString(item);
          if (item is Map<String, dynamic>) {
            final roleValue = item['role'] as String? ?? '';
            return AdminRole.fromString(roleValue);
          }
          return null;
        })
        .whereType<AdminRole>()
        .toList();
  }

  /// Assign role to user
  /// POST /api/v1/admin/roles/assign
  /// Request: { "user_id": 42, "role": "vendor" }
  /// Response: { "user_id": 42, "role": "vendor", "assigned": true, "message": "..." }
  Future<RoleAssignmentResult> assignRole({
    required int userId,
    required String role,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/roles/assign',
      method: 'POST',
      queryParameters: {'user_id': userId, 'role': role},
      options: idempotentOptions(),
    );

    return RoleAssignmentResult.fromJson(response.data ?? {});
  }

  /// Revoke role from user
  /// DELETE /api/v1/admin/roles/revoke
  /// Request: { "user_id": 42, "role": "vendor" }
  /// Response: { "user_id": 42, "role": "vendor", "revoked": true, "message": "..." }
  Future<RoleRevocationResult> revokeRole({
    required int userId,
    required String role,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/roles/revoke',
      method: 'DELETE',
      queryParameters: {'user_id': userId, 'role': role},
      options: idempotentOptions(),
    );

    return RoleRevocationResult.fromJson(response.data ?? {});
  }
}

/// Result of role assignment operation
class RoleAssignmentResult {
  const RoleAssignmentResult({
    required this.userId,
    required this.role,
    required this.assigned,
    this.message,
  });

  final int userId;
  final String role;
  final bool assigned;
  final String? message;

  factory RoleAssignmentResult.fromJson(Map<String, dynamic> json) {
    return RoleAssignmentResult(
      userId: json['user_id'] as int? ?? 0,
      role: json['role'] as String? ?? '',
      assigned: json['assigned'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// Result of role revocation operation
class RoleRevocationResult {
  const RoleRevocationResult({
    required this.userId,
    required this.role,
    required this.revoked,
    this.message,
  });

  final int userId;
  final String role;
  final bool revoked;
  final String? message;

  factory RoleRevocationResult.fromJson(Map<String, dynamic> json) {
    return RoleRevocationResult(
      userId: json['user_id'] as int? ?? 0,
      role: json['role'] as String? ?? '',
      revoked: json['revoked'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// Provider for RoleRepository
final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoleRepository(apiClient: apiClient);
});
