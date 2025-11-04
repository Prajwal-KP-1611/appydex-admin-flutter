import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/admin_role.dart';
import '../api_client.dart';
import 'token_storage.dart';

/// Secure storage keys for admin authentication
class _AuthKeys {
  static const String session = 'admin_session';
  static const String lastEmail = 'admin_last_email';
}

/// Authentication service for admin panel
class AuthService {
  AuthService({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
    FlutterSecureStorage? storage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage,
       _storage = storage ?? const FlutterSecureStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final FlutterSecureStorage _storage;

  /// Login with email and password
  Future<AdminSession> login({
    required String email,
    required String password,
    String otp = '000000',
  }) async {
    try {
      final payload = {
        'email_or_phone': email.trim(),
        'password': password.trim(),
        'otp': otp.trim(),
      };
      // Debug print for verification
      print('LOGIN PAYLOAD: ${jsonEncode(payload)}');
      print('LOGIN URL: ${_apiClient.dio.options.baseUrl}/auth/login');
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: payload,
        options: Options(
          extra: const {'skipAuth': true},
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw AppHttpException(
          message: 'Login failed',
          statusCode: response.statusCode,
        );
      }

      final session = AdminSession.fromJson(response.data!);

      if (!session.isValid) {
        throw AppHttpException(
          message: 'Invalid session data received',
          statusCode: 200,
        );
      }

      // Save session and email for future logins
      await _saveSession(session);
      await _storage.write(key: _AuthKeys.lastEmail, value: email);

      return session;
    } on DioException catch (e) {
      // Try to extract backend error message
      String errorMessage = 'Login failed';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage =
              data['message'] as String? ??
              data['error'] as String? ??
              data['detail'] as String? ??
              'Login failed';
        }
      }

      print(
        'LOGIN ERROR: Status=${e.response?.statusCode}, Message=$errorMessage, Data=${e.response?.data}',
      );

      final error = e.error;
      if (error is AppHttpException) {
        rethrow;
      }
      throw AppHttpException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Restore session from secure storage
  Future<AdminSession?> restoreSession() async {
    try {
      final sessionJson = await _storage.read(key: _AuthKeys.session);
      if (sessionJson == null || sessionJson.isEmpty) {
        return null;
      }

      final data = jsonDecode(sessionJson) as Map<String, dynamic>;
      final session = AdminSession.fromJson(data);

      if (!session.isValid) {
        await logout();
        return null;
      }

      return session;
    } catch (e) {
      // If we can't restore, clear corrupted data
      await logout();
      return null;
    }
  }

  /// Get last used email for login convenience
  Future<String?> getLastEmail() async {
    return _storage.read(key: _AuthKeys.lastEmail);
  }

  /// Switch active role (for multi-role admins)
  Future<AdminSession> switchRole({
    required AdminSession currentSession,
    required AdminRole newRole,
  }) async {
    if (!currentSession.roles.contains(newRole)) {
      throw AppHttpException(
        message: 'You do not have access to this role',
        statusCode: 403,
      );
    }

    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/switch-role',
        data: {'role': newRole.value},
      );

      if (response.statusCode != 200 || response.data == null) {
        throw AppHttpException(
          message: 'Failed to switch role',
          statusCode: response.statusCode,
        );
      }

      // Update session with new active role and possibly new tokens
      final updatedSession = AdminSession.fromJson({
        ...currentSession.toJson(),
        ...response.data!,
        'active_role': newRole.value,
      });

      await _saveSession(updatedSession);
      return updatedSession;
    } on DioException catch (e) {
      final error = e.error;
      if (error is AppHttpException) {
        rethrow;
      }
      throw AppHttpException(
        message: error?.toString() ?? 'Failed to switch role',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Refresh the current session
  Future<AdminSession?> refreshSession(AdminSession currentSession) async {
    try {
      final refreshAttempt = await _apiClient.refreshWithDetails(
        source: 'auth_service',
      );

      if (refreshAttempt.tokens == null) {
        await logout();
        return null;
      }

      final updatedSession = currentSession.copyWith(
        accessToken: refreshAttempt.tokens!.accessToken,
        refreshToken: refreshAttempt.tokens!.refreshToken,
      );

      await _saveSession(updatedSession);
      return updatedSession;
    } catch (e) {
      await logout();
      return null;
    }
  }

  /// Logout and clear all session data
  Future<void> logout() async {
    await _storage.delete(key: _AuthKeys.session);
    await _tokenStorage.clear();
    // Keep last email for convenience
  }

  /// Save session to secure storage
  Future<void> _saveSession(AdminSession session) async {
    final sessionJson = jsonEncode(session.toJson());
    await _storage.write(key: _AuthKeys.session, value: sessionJson);

    // Also save tokens to TokenStorage so ApiClient can use them
    await _tokenStorage.save(
      TokenPair(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
  }

  /// Validate if current session is still active
  Future<bool> validateSession(AdminSession session) async {
    if (session.isExpired) {
      return false;
    }

    try {
      // Try to fetch admin profile to validate token
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/admin/me',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthService(apiClient: apiClient, tokenStorage: tokenStorage);
});

/// Provider for current admin session state
final adminSessionProvider =
    StateNotifierProvider<AdminSessionNotifier, AdminSession?>((ref) {
      return AdminSessionNotifier(ref: ref);
    });

/// Notifier for managing admin session state
class AdminSessionNotifier extends StateNotifier<AdminSession?> {
  AdminSessionNotifier({required Ref ref}) : _ref = ref, super(null);

  final Ref _ref;
  AuthService get _authService => _ref.read(authServiceProvider);

  /// Initialize session on app start
  Future<void> initialize() async {
    try {
      final session = await _authService.restoreSession();
      state = session;
    } catch (e) {
      // Silently fail on session restoration errors
      // User will just need to login again
      state = null;
    }
  }

  /// Login
  Future<void> login({
    required String email,
    required String password,
    String otp = '000000',
  }) async {
    final session = await _authService.login(
      email: email,
      password: password,
      otp: otp,
    );
    state = session;
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  /// Switch role
  Future<void> switchRole(AdminRole newRole) async {
    if (state == null) return;

    final updatedSession = await _authService.switchRole(
      currentSession: state!,
      newRole: newRole,
    );
    state = updatedSession;
  }

  /// Refresh session
  Future<void> refresh() async {
    if (state == null) return;

    final updatedSession = await _authService.refreshSession(state!);
    state = updatedSession;
  }

  /// Check if authenticated
  bool get isAuthenticated => state != null && state!.isValid;

  /// Get current role
  AdminRole? get currentRole => state?.activeRole;

  /// Check if user has specific permission
  bool hasPermission(String module, String action) {
    return state?.activeRole.hasPermission(module, action) ?? false;
  }
}

/// Convenience provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(adminSessionProvider);
  return session != null && session.isValid;
});

/// Provider for current admin role
final currentAdminRoleProvider = Provider<AdminRole?>((ref) {
  final session = ref.watch(adminSessionProvider);
  return session?.activeRole;
});
