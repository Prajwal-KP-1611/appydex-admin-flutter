import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/utils/idempotency.dart';
import '../models/admin_role.dart';
import '../models/admin_user.dart';

/// Repository for admin user management
class AdminUserRepository {
  AdminUserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// List all admin users with optional filters
  /// GET /api/v1/admin/accounts
  Future<List<AdminUser>> list({int skip = 0, int limit = 100}) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/accounts',
      queryParameters: {'skip': skip, 'limit': limit},
    );

    final data = response.data;
    if (data == null) return [];

    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get single admin user by ID
  /// GET /api/v1/admin/accounts/{user_id}
  Future<AdminUser> getById(int userId) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/accounts/$userId',
    );

    if (response.data == null) {
      throw AppHttpException(message: 'Admin user not found', statusCode: 404);
    }

    return AdminUser.fromJson(response.data!);
  }

  /// Create new admin user
  /// POST /api/v1/admin/accounts
  /// Request: Query parameters: ?email=...&password=...&role=...&name=...
  /// Response: { "id": 10, "email": "...", "name": "...", "role": "...", "created": true }
  Future<AdminUser> create(AdminUserRequest request) async {
    final queryParams = {
      'email': request.email,
      'password': request.password,
      'role': request.role,
      if (request.name != null) 'name': request.name,
    };

    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/accounts',
      method: 'POST',
      queryParameters: queryParams,
      options: idempotentOptions(),
    );

    if (response.data == null) {
      throw AppHttpException(
        message: 'Failed to create admin user',
        statusCode: response.statusCode,
      );
    }

    return AdminUser.fromJson(response.data!);
  }

  /// Update existing admin user
  /// PUT /api/v1/admin/accounts/{user_id}
  /// Request: JSON body (all fields optional): { "email": "...", "name": "...", "password": "..." }
  /// Response: { "id": 10, "email": "...", "name": "...", "updated_fields": [...], "updated": true }
  Future<AdminUser> update(int userId, AdminUserUpdateRequest request) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/accounts/$userId',
      method: 'PUT',
      data: request.toJson(),
      options: idempotentOptions(),
    );

    if (response.data == null) {
      throw AppHttpException(
        message: 'Failed to update admin user',
        statusCode: response.statusCode,
      );
    }

    return AdminUser.fromJson(response.data!);
  }

  /// Delete admin user
  /// DELETE /api/v1/admin/accounts/{user_id}
  /// Response: { "deleted": true, "user_id": 10 }
  Future<void> delete(int userId) async {
    await _apiClient.requestAdmin<void>(
      '/admin/accounts/$userId',
      method: 'DELETE',
      options: idempotentOptions(),
    );
  }

  /// Activate/deactivate admin user
  /// Note: Use PATCH /admin/accounts/{user_id} with is_active field
  Future<AdminUser> toggleActive(int userId, bool isActive) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/accounts/$userId',
      method: 'PATCH',
      data: {'is_active': isActive},
      options: idempotentOptions(),
    );

    if (response.data == null) {
      throw AppHttpException(
        message: 'Failed to toggle admin status',
        statusCode: response.statusCode,
      );
    }

    return AdminUser.fromJson(response.data!);
  }

  /// Get available roles and permissions
  /// Note: This is now handled by RoleRepository
  Future<List<AdminRole>> getAvailableRoles() async {
    return AdminRole.values;
  }
}

/// Provider for AdminUserRepository
final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminUserRepository(apiClient: apiClient);
});

/// State provider for admin users list
final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, AsyncValue<List<AdminUser>>>((
      ref,
    ) {
      final repository = ref.watch(adminUserRepositoryProvider);
      return AdminUsersNotifier(repository: repository);
    });

class AdminUsersNotifier extends StateNotifier<AsyncValue<List<AdminUser>>> {
  AdminUsersNotifier({required AdminUserRepository repository})
    : _repository = repository,
      super(const AsyncValue.loading()) {
    loadUsers();
  }

  final AdminUserRepository _repository;

  Future<void> loadUsers({int skip = 0, int limit = 100}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.list(skip: skip, limit: limit);
    });
  }

  Future<void> createUser(AdminUserRequest request) async {
    await _repository.create(request);
    await loadUsers();
  }

  Future<void> updateUser(int userId, AdminUserUpdateRequest request) async {
    await _repository.update(userId, request);
    await loadUsers();
  }

  Future<void> deleteUser(int userId) async {
    await _repository.delete(userId);
    await loadUsers();
  }

  Future<void> toggleActive(int userId, bool isActive) async {
    await _repository.toggleActive(userId, isActive);
    await loadUsers();
  }
}
