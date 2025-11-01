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

/// Handles persisting auth tokens using secure storage where available.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';

  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  Future<void> save(TokenPair tokens) async {
    await Future.wait([
      _write(_accessKey, tokens.accessToken),
      _write(_refreshKey, tokens.refreshToken),
    ]);
    _cachedAccessToken = tokens.accessToken;
    _cachedRefreshToken = tokens.refreshToken;
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
    if (_cachedAccessToken != null) return _cachedAccessToken;
    final token = await _read(_accessKey);
    _cachedAccessToken = token;
    return token;
  }

  Future<String?> readRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    final token = await _read(_refreshKey);
    _cachedRefreshToken = token;
    return token;
  }

  Future<void> clear() async {
    await Future.wait([_delete(_accessKey), _delete(_refreshKey)]);
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _secureStorage.read(key: key);
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }
    await _secureStorage.delete(key: key);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});
