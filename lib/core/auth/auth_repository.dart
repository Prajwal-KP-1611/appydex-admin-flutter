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
    // TODO(AUTH-002): Implement full login payload handling with OTP support.
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
  /// Sends OTP to admin's email/phone for login verification.
  /// No authentication required for this endpoint.
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
