import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple value object for holding access and refresh tokens.
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }

  Map<String, String> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  final String accessToken;
  final String refreshToken;

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenPair &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(accessToken, refreshToken);
}

/// Handles persisting auth tokens.
/// 
/// SECURITY NOTE (Web Platform):
/// - Uses IN-MEMORY storage only on web (not persistent across refreshes)
/// - Refresh tokens are never stored in localStorage/sessionStorage (XSS risk)
/// - Production should use httpOnly cookies managed by backend
/// - Current implementation: session-based auth (logout on tab close/refresh)
/// 
/// Mobile platforms use flutter_secure_storage (iOS Keychain, Android KeyStore).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  // In-memory cache (web-only persistence)
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  Future<void> save(TokenPair tokens) async {
    _cachedAccessToken = tokens.accessToken;
    _cachedRefreshToken = tokens.refreshToken;
    
    // Only persist on native platforms (not web)
    if (!kIsWeb) {
      await Future.wait([
        _secureStorage.write(key: _accessKey, value: tokens.accessToken),
        _secureStorage.write(key: _refreshKey, value: tokens.refreshToken),
      ]);
    }
  }

  Future<TokenPair?> read() async {
    final access = await readAccessToken();
    final refresh = await readRefreshToken();
    if (access == null ||
        access.isEmpty ||
        refresh == null ||
        refresh.isEmpty) {
      return null;
    }
    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  Future<String?> readAccessToken() async {
    if (kIsWeb) {
      // Web: memory-only
      return _cachedAccessToken;
    }
    
    // Native: read from secure storage with cache
    if (_cachedAccessToken != null) return _cachedAccessToken;
    final token = await _secureStorage.read(key: _accessKey);
    _cachedAccessToken = token;
    return token;
  }

  Future<String?> readRefreshToken() async {
    if (kIsWeb) {
      // Web: memory-only
      return _cachedRefreshToken;
    }
    
    // Native: read from secure storage with cache
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    final token = await _secureStorage.read(key: _refreshKey);
    _cachedRefreshToken = token;
    return token;
  }

  Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    
    if (!kIsWeb) {
      await Future.wait([
        _secureStorage.delete(key: _accessKey),
        _secureStorage.delete(key: _refreshKey),
      ]);
    }
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
