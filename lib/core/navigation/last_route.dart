// import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastRoute {
  static const _key = 'last_route_path';

  /// Store the last visited route path.
  static Future<void> write(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
  }

  /// Read the last visited route path.
  static Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// On web, prefer the current browser URL (hash) if present.
  /// Returns a leading-slash path like "/service-type-requests" or null.
  static String? resolveInitialRoute() {
    try {
      // Uri.base works on all platforms; for web this includes the hash.
      final fragment = Uri.base.fragment; // e.g. '/service-type-requests'
      if (fragment.isNotEmpty && fragment.startsWith('/')) {
        return fragment;
      }
      // For non-hash strategy or other platforms, return null to fall back.
      return null;
    } catch (_) {
      return null;
    }
  }
}
