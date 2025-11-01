import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Default production API origin.
const kDefaultApiBaseUrl = 'https://api.appydex.co';

/// Resolve the current build flavor from the `APP_FLAVOR` dart define.
const kAppFlavor = String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod');

/// Shared keys used when persisting configuration values.
class _ConfigKeys {
  const _ConfigKeys._();

  static String apiBaseUrl(String flavor) => 'config.$flavor.api_base_url';
  static String mockMode(String flavor) => 'config.$flavor.mock_mode';
}

/// Runtime configuration that can be persisted per build flavor.
class AppConfig {
  AppConfig._({
    required this.flavor,
    required SharedPreferences preferences,
    this.defaultBaseUrl = kDefaultApiBaseUrl,
  }) : _preferences = preferences;

  final String flavor;
  final String defaultBaseUrl;
  final SharedPreferences _preferences;

  static Future<AppConfig> load({
    required String flavor,
    String defaultBaseUrl = kDefaultApiBaseUrl,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    return AppConfig._(
      flavor: flavor,
      preferences: preferences,
      defaultBaseUrl: defaultBaseUrl,
    );
  }

  String get apiBaseUrl =>
      _preferences.getString(_ConfigKeys.apiBaseUrl(flavor)) ?? defaultBaseUrl;

  Future<void> setApiBaseUrl(String value) async {
    if (value.isEmpty) return clearApiBaseUrl();
    await _preferences.setString(_ConfigKeys.apiBaseUrl(flavor), value);
  }

  Future<void> clearApiBaseUrl() async {
    await _preferences.remove(_ConfigKeys.apiBaseUrl(flavor));
  }

  bool get mockMode =>
      _preferences.getBool(_ConfigKeys.mockMode(flavor)) ?? false;

  Future<void> setMockMode(bool enabled) async {
    await _preferences.setBool(_ConfigKeys.mockMode(flavor), enabled);
  }
}

/// Provides the [AppConfig] loaded during app bootstrap.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be loaded before runApp.');
});

/// Exposes the current API base url, responding to diagnostics overrides.
final apiBaseUrlProvider = StateNotifierProvider<ApiBaseUrlNotifier, String>((
  ref,
) {
  final config = ref.watch(appConfigProvider);
  return ApiBaseUrlNotifier(config);
});

final mockModeProvider = StateNotifierProvider<MockModeNotifier, bool>((ref) {
  final config = ref.watch(appConfigProvider);
  return MockModeNotifier(config);
});

/// Notifier that persists API base url overrides per flavor.
class ApiBaseUrlNotifier extends StateNotifier<String> {
  ApiBaseUrlNotifier(this._config) : super(_config.apiBaseUrl);

  final AppConfig _config;

  Future<void> updateBaseUrl(String value) async {
    final sanitized = value.trim();
    if (sanitized.isEmpty) {
      await _config.clearApiBaseUrl();
      state = _config.apiBaseUrl;
      return;
    }

    // Ensure we persist without trailing slash noise.
    final normalized = sanitized.endsWith('/')
        ? sanitized.substring(0, sanitized.length - 1)
        : sanitized;
    await _config.setApiBaseUrl(normalized);
    state = _config.apiBaseUrl;
  }

  Future<void> resetToDefault() async {
    await _config.clearApiBaseUrl();
    state = _config.apiBaseUrl;
  }
}

/// Utility for quick synchronous access to the latest API base url.
String resolveApiBaseUrl(Ref ref) => ref.read(apiBaseUrlProvider);

class MockModeNotifier extends StateNotifier<bool> {
  MockModeNotifier(this._config) : super(_config.mockMode);

  final AppConfig _config;

  Future<void> toggle(bool enabled) async {
    await _config.setMockMode(enabled);
    state = enabled;
  }
}

String infraBaseUrl(String apiBaseUrl) {
  return apiBaseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');
}
