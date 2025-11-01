import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appydex_admin/core/api_client.dart';

void main() {
  group('applySendTimeoutPolicyForPlatform', () {
    const defaultTimeout = Duration(seconds: 15);

    test('disables sendTimeout for GET without body on web', () {
      final options = RequestOptions(
        path: '/healthz',
        method: 'GET',
        sendTimeout: const Duration(seconds: 5),
      );

      applySendTimeoutPolicyForPlatform(
        options,
        isWeb: true,
        defaultTimeout: defaultTimeout,
      );

      expect(options.sendTimeout, Duration.zero);
    });

    test('disables sendTimeout for POST without body on web', () {
      final options = RequestOptions(
        path: '/auth/login',
        method: 'POST',
        sendTimeout: const Duration(seconds: 5),
      );

      applySendTimeoutPolicyForPlatform(
        options,
        isWeb: true,
        defaultTimeout: defaultTimeout,
      );

      expect(options.sendTimeout, Duration.zero);
    });

    test('preserves sendTimeout for POST with JSON body on web', () {
      final options = RequestOptions(
        path: '/auth/login',
        method: 'POST',
        data: {'email_or_phone': 'admin@appydex.co'},
        sendTimeout: const Duration(seconds: 8),
      );

      applySendTimeoutPolicyForPlatform(
        options,
        isWeb: true,
        defaultTimeout: defaultTimeout,
      );

      expect(options.sendTimeout, const Duration(seconds: 8));
    });

    test('restores default when body exists but timeout was zero', () {
      final options = RequestOptions(
        path: '/auth/login',
        method: 'POST',
        data: {'email_or_phone': 'admin@appydex.co'},
        sendTimeout: Duration.zero,
      );

      applySendTimeoutPolicyForPlatform(
        options,
        isWeb: true,
        defaultTimeout: defaultTimeout,
      );

      expect(options.sendTimeout, defaultTimeout);
    });

    test('does nothing for non-web platforms', () {
      final options = RequestOptions(
        path: '/healthz',
        method: 'GET',
        sendTimeout: const Duration(seconds: 5),
      );

      applySendTimeoutPolicyForPlatform(
        options,
        isWeb: false,
        defaultTimeout: defaultTimeout,
      );

      expect(options.sendTimeout, const Duration(seconds: 5));
    });
  });
}
