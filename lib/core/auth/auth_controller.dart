import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'token_storage.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, loading, error }

class AuthState {
  const AuthState({required this.status, this.tokens, this.errorMessage});

  factory AuthState.initial() => const AuthState(status: AuthStatus.unknown);

  final AuthStatus status;
  final TokenPair? tokens;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && tokens != null;

  AuthState copyWith({
    AuthStatus? status,
    TokenPair? tokens,
    bool removeTokens = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      tokens: removeTokens ? null : (tokens ?? this.tokens),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState.initial()) {
    _bootstrap();
  }

  final Ref _ref;

  AuthRepository get _repository => _ref.read(authRepositoryProvider);

  Future<void> _bootstrap() async {
    final tokens = await _repository.loadTokens();
    if (tokens != null && tokens.isValid) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        tokens: tokens,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        removeTokens: true,
        clearError: true,
      );
    }
  }

  Future<TokenPair?> refreshTokens() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final result = await _repository.forceRefresh();
      if (result == null || !result.isValid) {
        final hasTokens = state.tokens != null;
        state = state.copyWith(
          status: hasTokens
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          errorMessage: 'Unable to refresh session.',
        );
        return null;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        tokens: result,
        clearError: true,
      );
      return result;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  void applyTokens(TokenPair tokens) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      tokens: tokens,
      clearError: true,
    );
  }

  Future<void> logout() async {
    await _repository.clearTokens();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      removeTokens: true,
      clearError: true,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref);
  },
);
