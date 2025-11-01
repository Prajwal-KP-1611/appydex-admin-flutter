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
    return _apiClient.dio.post('/auth/login', data: payload);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(tokenStorageProvider);
  return AuthRepository(apiClient: apiClient, tokenStorage: storage);
});
