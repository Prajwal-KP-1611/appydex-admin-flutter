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
/// - Access tokens stored in localStorage (persistent across refreshes)
/// - Refresh tokens stored in localStorage (enables token refresh after reload)
/// - Production should use httpOnly cookies for maximum security
/// - Current implementation: localStorage for admin panel convenience
/// - IMPORTANT: Only use over HTTPS in production
///
/// Mobile platforms use flutter_secure_storage (iOS Keychain, Android KeyStore).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  // In-memory cache for performance
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  Future<void> save(TokenPair tokens) async {
    _cachedAccessToken = tokens.accessToken;
    _cachedRefreshToken = tokens.refreshToken;

    if (kIsWeb) {
      // Web: persist to localStorage for cross-refresh persistence
      try {
        // Use flutter_secure_storage which falls back to web storage on web
        await Future.wait([
          _secureStorage.write(key: _accessKey, value: tokens.accessToken),
          _secureStorage.write(key: _refreshKey, value: tokens.refreshToken),
        ]);
      } catch (e) {
        debugPrint('[TokenStorage] Failed to persist tokens on web: $e');
        // Tokens remain in memory cache
      }
    } else {
      // Native: use secure storage (Keychain/KeyStore)
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
    // Return cached value if available
    if (_cachedAccessToken != null) return _cachedAccessToken;

    // Read from persistent storage (works on both web and native)
    try {
      final token = await _secureStorage.read(key: _accessKey);
      _cachedAccessToken = token;
      return token;
    } catch (e) {
      debugPrint('[TokenStorage] Failed to read access token: $e');
      return null;
    }
  }

  Future<String?> readRefreshToken() async {
    // Return cached value if available
    if (_cachedRefreshToken != null) return _cachedRefreshToken;

    // Read from persistent storage (works on both web and native)
    try {
      final token = await _secureStorage.read(key: _refreshKey);
      _cachedRefreshToken = token;
      return token;
    } catch (e) {
      debugPrint('[TokenStorage] Failed to read refresh token: $e');
      return null;
    }
  }

  Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;

    // Clear from persistent storage on all platforms
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessKey),
        _secureStorage.delete(key: _refreshKey),
      ]);
    } catch (e) {
      debugPrint('[TokenStorage] Failed to clear tokens: $e');
    }
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
