import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Web: Use SharedPreferences (same as AuthService for consistency)
      try {
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.setString(_accessKey, tokens.accessToken),
          prefs.setString(_refreshKey, tokens.refreshToken),
        ]);
        debugPrint('[TokenStorage] Tokens saved to web storage');
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

    // Read from persistent storage
    try {
      String? token;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(_accessKey);
      } else {
        token = await _secureStorage.read(key: _accessKey);
      }
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

    // Read from persistent storage
    try {
      String? token;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(_refreshKey);
      } else {
        token = await _secureStorage.read(key: _refreshKey);
      }
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
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await Future.wait([
          prefs.remove(_accessKey),
          prefs.remove(_refreshKey),
        ]);
      } else {
        await Future.wait([
          _secureStorage.delete(key: _accessKey),
          _secureStorage.delete(key: _refreshKey),
        ]);
      }
      debugPrint('[TokenStorage] Tokens cleared');
    } catch (e) {
      debugPrint('[TokenStorage] Failed to clear tokens: $e');
    }
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
