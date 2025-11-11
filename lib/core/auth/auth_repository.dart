import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';
import 'token_storage.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<TokenPair?> loadTokens() => _tokenStorage.read();

  Future<void> persistTokens(TokenPair tokens) => _tokenStorage.save(tokens);

  Future<void> clearTokens() => _tokenStorage.clear();

  Future<TokenPair?> forceRefresh() => _apiClient.forceRefresh();

  Future<Response<dynamic>> login(Map<String, dynamic> payload) {
    // Admin login now uses password-only authentication (no OTP).
    // Payload: { "email_or_phone": "...", "password": "..." }
    return _apiClient.dio.post('/admin/auth/login', data: payload);
  }

  /// Change admin user password
  /// POST /api/v1/admin/auth/change-password
  ///
  /// Requires current password and new password.
  /// Returns success message on successful password change.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/auth/change-password',
      method: 'POST',
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }

  /// Request OTP for admin login
  /// POST /api/v1/admin/auth/request-otp
  ///
  /// ⚠️ DEPRECATED (Nov 10, 2025): This endpoint returns HTTP 410 GONE.
  /// Admin users now use password-only authentication.
  /// No authentication required for this endpoint.
  @Deprecated('Admin OTP authentication removed. Use password-only login.')
  Future<Map<String, dynamic>> requestOtp({
    String? email,
    String? phone,
  }) async {
    if (email == null && phone == null) {
      throw ArgumentError('Either email or phone must be provided');
    }

    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/admin/auth/request-otp',
      data: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );

    return response.data ?? {};
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(tokenStorageProvider);
  return AuthRepository(apiClient: apiClient, tokenStorage: storage);
});
