import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Maintains runtime admin configuration (token, toggles).
class AdminConfig {
  AdminConfig._();

  static final _tokenNotifier = ValueNotifier<String?>(null);

  static String? get adminToken => _tokenNotifier.value;

  static set adminToken(String? value) {
    _tokenNotifier.value = value?.trim().isEmpty ?? true ? null : value?.trim();
  }

  static ValueListenable<String?> get tokenListenable => _tokenNotifier;

  /// Computes infra base (without /api/v1 suffix) for health/metrics calls.
  static String infraBase(String apiBase) {
    return apiBase.replaceFirst(RegExp(r'/api/v1/?$'), '');
  }
}

/// Riverpod provider to expose the current admin token.
final adminTokenProvider = StateNotifierProvider<_AdminTokenNotifier, String?>((
  ref,
) {
  return _AdminTokenNotifier();
});

class _AdminTokenNotifier extends StateNotifier<String?> {
  _AdminTokenNotifier() : super(AdminConfig.adminToken) {
    AdminConfig.tokenListenable.addListener(_sync);
  }

  void _sync() {
    state = AdminConfig.adminToken;
  }

  @override
  void dispose() {
    AdminConfig.tokenListenable.removeListener(_sync);
    super.dispose();
  }
}
