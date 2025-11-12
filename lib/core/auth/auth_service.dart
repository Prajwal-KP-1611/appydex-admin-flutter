import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/admin_role.dart';
import '../api_client.dart';
import 'token_storage.dart';

/// Check if a JWT token is expired
bool _isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final json = jsonDecode(decoded) as Map<String, dynamic>;

    final exp = json['exp'] as int?;
    if (exp == null) return false; // No expiry means valid

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final isExpired = DateTime.now().isAfter(expiryDate);

    if (kDebugMode) {
      debugPrint('[JWT] Token expiry: $expiryDate');
      debugPrint('[JWT] Current time: ${DateTime.now()}');
      debugPrint('[JWT] Is expired: $isExpired');
    }

    return isExpired;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[JWT] Error checking expiration: $e');
    }
    return true; // Assume expired if we can't parse
  }
}

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

  /// Login with email or phone and password
  ///
  /// The [email] parameter accepts either an email address or phone number.
  /// Backend automatically detects whether it's an email (contains @) or phone number.
  ///
  /// Example:
  /// - Email: `admin@example.com`
  /// - Phone: `+1234567890`
  Future<AdminSession> login({
    required String
    email, // Accepts both email and phone for backward compatibility
    required String password,
  }) async {
    try {
      final payload = {
        'email_or_phone': email.trim(),
        'password': password.trim(),
      };
      // Debug print for verification
      debugPrint('LOGIN PAYLOAD: ${jsonEncode(payload)}');
      debugPrint(
        'LOGIN URL: ${_apiClient.dio.options.baseUrl}/admin/auth/login',
      );
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/admin/auth/login',
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

      debugPrint('LOGIN RESPONSE: ${jsonEncode(response.data)}');

      // Response is automatically unwrapped by API client interceptor
      final session = AdminSession.fromJson(response.data!);

      if (!session.isValid) {
        throw AppHttpException(
          message: 'Invalid session data received',
          statusCode: 200,
        );
      }

      // Fetch user profile to get email if not included in login response
      AdminSession finalSession = session;
      if (session.email == null || session.email!.isEmpty) {
        try {
          if (kDebugMode) {
            debugPrint(
              '[AuthService.login] Email missing, fetching from /admin/me...',
            );
          }
          final meResponse = await _apiClient.dio.get<Map<String, dynamic>>(
            '/admin/me',
            options: Options(
              headers: {'Authorization': 'Bearer ${session.accessToken}'},
            ),
          );

          if (meResponse.data != null) {
            final userEmail = meResponse.data!['email'] as String?;
            if (kDebugMode) {
              debugPrint(
                '[AuthService.login] Fetched email from /admin/me: $userEmail',
              );
            }
            if (userEmail != null) {
              finalSession = session.copyWith(email: userEmail);
            }
          }
        } catch (e) {
          // Silently fall back - /admin/me endpoint may not be implemented yet
          if (kDebugMode) {
            debugPrint(
              '[AuthService.login] /admin/me not available (expected if endpoint not implemented)',
            );
          }
          // Continue with session even if email fetch fails
        }
      }

      // Fallback: if backend still didn't provide email, use the typed email
      if (finalSession.email == null || finalSession.email!.isEmpty) {
        debugPrint(
          '[AuthService.login] Backend did not provide email. Using typed email: $email',
        );
        finalSession = finalSession.copyWith(email: email);
      }

      // Save session and email for future logins
      await _saveSession(finalSession);
      await _write(_AuthKeys.lastEmail, email);

      return finalSession;
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

      debugPrint(
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
      debugPrint(
        '[AuthService.restoreSession] Starting session restoration...',
      );
      debugPrint(
        '[AuthService.restoreSession] Platform: ${kIsWeb ? "WEB" : "MOBILE/DESKTOP"}',
      );

      final sessionJson = await _read(_AuthKeys.session);
      debugPrint(
        '[AuthService.restoreSession] Session JSON length: ${sessionJson?.length ?? 0}',
      );

      if (sessionJson == null || sessionJson.isEmpty) {
        debugPrint(
          '[AuthService.restoreSession] No session data found in storage',
        );
        return null;
      }

      debugPrint('[AuthService.restoreSession] Parsing session JSON...');
      final data = jsonDecode(sessionJson) as Map<String, dynamic>;
      var session = AdminSession.fromJson(data);

      debugPrint(
        '[AuthService.restoreSession] Session parsed: ${session.email}',
      );
      debugPrint(
        '[AuthService.restoreSession] Session valid: ${session.isValid}',
      );
      debugPrint(
        '[AuthService.restoreSession] Access token length: ${session.accessToken.length}',
      );
      debugPrint(
        '[AuthService.restoreSession] Refresh token length: ${session.refreshToken.length}',
      );

      if (!session.isValid) {
        debugPrint('[AuthService.restoreSession] Session invalid, clearing...');
        await logout();
        return null;
      }

      // Check if access token is expired and attempt silent refresh
      if (_isTokenExpired(session.accessToken)) {
        debugPrint('[AuthService.restoreSession] ⚠️ Access token is EXPIRED');
        debugPrint('[AuthService.restoreSession] Attempting silent refresh...');
        try {
          final attempt = await _apiClient.refreshWithDetails(
            source: 'restore_session',
          );
          if (attempt.tokens != null) {
            debugPrint(
              '[AuthService.restoreSession] ✅ Silent refresh succeeded',
            );
            session = session.copyWith(
              accessToken: attempt.tokens!.accessToken,
              refreshToken: attempt.tokens!.refreshToken,
            );
            await _saveSession(session);
          } else {
            // Silent refresh failed. Don't force immediate logout - mark session as expired
            // and persist the state so the UI can surface a re-login prompt. This avoids
            // a jarring immediate logout when the user returns after being away.
            debugPrint(
              '[AuthService.restoreSession] ❌ Silent refresh failed - marking session as expired (soft)',
            );
            session = session.copyWith(expiresAt: DateTime.now());
            await _saveSession(session);
            // Continue without returning; callers can detect expiration via session.isExpired
          }
        } catch (e) {
          // On errors during refresh (network, CSRF mismatch, etc.), prefer a soft-expire
          // over forcing logout. Persist the expired session so the app can show a
          // re-login banner or require re-auth on protected actions.
          debugPrint(
            '[AuthService.restoreSession] ❌ Error during refresh (soft-expire): $e',
          );
          session = session.copyWith(expiresAt: DateTime.now());
          await _saveSession(session);
          // Continue and return the soft-expired session
        }
      }

      // If email is missing, try to fetch profile and update cached session
      if (session.email == null || session.email!.isEmpty) {
        try {
          debugPrint(
            '[AuthService.restoreSession] Email missing. Fetching /admin/me ...',
          );
          final meResponse = await _apiClient.dio.get<Map<String, dynamic>>(
            '/admin/me',
          );
          final userEmail = meResponse.data?['email'] as String?;
          final activeRoleStr =
              (meResponse.data?['active_role'] ?? meResponse.data?['role'])
                  as String?;
          final rolesList = (meResponse.data?['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();

          if (userEmail != null || activeRoleStr != null || rolesList != null) {
            session = session.copyWith(
              email: userEmail ?? session.email,
              roles: rolesList != null
                  ? rolesList.map((r) => AdminRole.fromString(r)).toList()
                  : session.roles,
              activeRole: activeRoleStr != null
                  ? AdminRole.fromString(activeRoleStr)
                  : session.activeRole,
            );
            await _saveSession(session);
            debugPrint(
              '[AuthService.restoreSession] Updated session from /admin/me (email/roles/active_role).',
            );
          }
        } catch (e) {
          debugPrint(
            '[AuthService.restoreSession] Failed to fetch /admin/me: $e',
          );
        }

        // Final fallback: if still missing, use last saved email from storage
        if (session.email == null || session.email!.isEmpty) {
          final last = await _read(_AuthKeys.lastEmail);
          if (last != null && last.isNotEmpty) {
            debugPrint(
              '[AuthService.restoreSession] Using last saved email: $last',
            );
            session = session.copyWith(email: last);
            await _saveSession(session);
          }
        }
      }

      debugPrint(
        '[AuthService.restoreSession] ✅ Session restored successfully',
      );
      return session;
    } catch (e, stack) {
      // If we can't restore, clear corrupted data
      debugPrint('[AuthService.restoreSession] ❌ Error restoring session: $e');
      debugPrint('[AuthService.restoreSession] Stack trace: $stack');
      await logout();
      return null;
    }
  }

  /// Get last used email for login convenience
  Future<String?> getLastEmail() async {
    return _read(_AuthKeys.lastEmail);
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
    // Stop auto-refresh timer before clearing tokens
    _apiClient.stopAutoRefresh();

    await _delete(_AuthKeys.session);
    await _tokenStorage.clear();
    // Keep last email for convenience
  }

  /// Mark current session as expired without logging out
  /// This allows UI to show re-login prompt instead of errors
  Future<void> markSessionExpired() async {
    try {
      final sessionJson = await _read(_AuthKeys.session);
      if (sessionJson == null || sessionJson.isEmpty) {
        return;
      }

      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;

      // Update the expiry time to now (mark as expired)
      sessionData['expires_at'] = DateTime.now().toIso8601String();

      // Save the updated session
      final updatedSessionJson = jsonEncode(sessionData);
      await _write(_AuthKeys.session, updatedSessionJson);

      debugPrint('[AuthService.markSessionExpired] Session marked as expired');
    } catch (e) {
      debugPrint('[AuthService.markSessionExpired] Error: $e');
    }
  }

  /// Save session to secure storage
  Future<void> _saveSession(AdminSession session) async {
    final sessionJson = jsonEncode(session.toJson());
    await _write(_AuthKeys.session, sessionJson);

    // Also save tokens to TokenStorage so ApiClient can use them
    await _tokenStorage.save(
      TokenPair(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );

    // Start auto-refresh timer after successful login
    _apiClient.startAutoRefresh();
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

  // --- Storage helpers (web uses SharedPreferences) ---
  Future<void> _write(String key, String value) async {
    debugPrint(
      '[AuthService._write] Writing key: $key, value length: ${value.length}, platform: ${kIsWeb ? "WEB" : "MOBILE"}',
    );
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(key, value);
      debugPrint('[AuthService._write] Web storage write result: $result');

      // Verify write
      final verify = prefs.getString(key);
      debugPrint(
        '[AuthService._write] Verification read length: ${verify?.length ?? 0}',
      );
      return;
    }
    await _storage.write(key: key, value: value);
    debugPrint('[AuthService._write] Secure storage write complete');
  }

  Future<String?> _read(String key) async {
    debugPrint(
      '[AuthService._read] Reading key: $key, platform: ${kIsWeb ? "WEB" : "MOBILE"}',
    );
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(key);
      debugPrint(
        '[AuthService._read] Web storage read length: ${value?.length ?? 0}',
      );
      return value;
    }
    final value = await _storage.read(key: key);
    debugPrint(
      '[AuthService._read] Secure storage read length: ${value?.length ?? 0}',
    );
    return value;
  }

  Future<void> _delete(String key) async {
    debugPrint(
      '[AuthService._delete] Deleting key: $key, platform: ${kIsWeb ? "WEB" : "MOBILE"}',
    );
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      debugPrint('[AuthService._delete] Web storage delete complete');
      return;
    }
    await _storage.delete(key: key);
    debugPrint('[AuthService._delete] Secure storage delete complete');
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
      debugPrint('[AdminSession] Initializing session...');
      final session = await _authService.restoreSession();
      if (session != null) {
        debugPrint(
          '[AdminSession] Session restored: ${session.email}, role: ${session.activeRole.displayName}',
        );
      } else {
        debugPrint('[AdminSession] No session found');
      }
      state = session;
    } catch (e) {
      // Silently fail on session restoration errors
      // User will just need to login again
      debugPrint('[AdminSession] Failed to restore session: $e');
      state = null;
    }
  }

  /// Login
  Future<void> login({required String email, required String password}) async {
    debugPrint('[AdminSession] Attempting login for: $email');
    final session = await _authService.login(email: email, password: password);
    debugPrint(
      '[AdminSession] Login successful: ${session.email}, roles: ${session.roles.map((r) => r.displayName).join(", ")}',
    );
    state = session;
  }

  /// Logout
  Future<void> logout() async {
    debugPrint('[AdminSession] Logging out...');
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
  // Consider session authenticated only if it's present, has a token and is not expired.
  return session != null && session.isValid && !session.isExpired;
});

/// Provider that indicates whether the current session is expired (soft-expire)
final sessionExpiredProvider = Provider<bool>((ref) {
  final session = ref.watch(adminSessionProvider);
  return session != null && session.isExpired;
});

/// Provider for current admin role
final currentAdminRoleProvider = Provider<AdminRole?>((ref) {
  final session = ref.watch(adminSessionProvider);
  return session?.activeRole;
});
