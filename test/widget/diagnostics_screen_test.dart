import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appydex_admin/core/api_client.dart';
import 'package:appydex_admin/core/auth/token_storage.dart';
import 'package:appydex_admin/core/config.dart';
import 'package:appydex_admin/main.dart';

class _FakeTokenStorage implements TokenStorage {
  TokenPair? _tokens;

  @override
  Future<void> clear() async {
    _tokens = null;
  }

  @override
  Future<TokenPair?> read() async => _tokens;

  @override
  Future<String?> readAccessToken() async => _tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => _tokens?.refreshToken;

  @override
  Future<void> save(TokenPair tokens) async {
    _tokens = tokens;
  }
}

class _NoopAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"detail":"noop"}',
      501,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Diagnostics screen renders base URL overrides', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final config = await AppConfig.load(flavor: 'test');
    final tokenStorage = _FakeTokenStorage();
    final dio = Dio(BaseOptions(baseUrl: '${config.apiBaseUrl}/api/v1'))
      ..httpClientAdapter = _NoopAdapter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          apiClientProvider.overrideWith(
            (ref) => ApiClient(
              ref: ref,
              tokenStorage: tokenStorage,
              baseUrl: config.apiBaseUrl,
              dio: dio,
            ),
          ),
        ],
        child: const AppydexAdminApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('API Base URL'), findsOneWidget);

    // Find the specific TextField for the API Base URL by its decoration label.
    final baseFieldFinder = find.byWidgetPredicate((widget) {
      if (widget is TextField) {
        final label = widget.decoration?.labelText;
        return label == 'Override base URL';
      }
      return false;
    });
    expect(baseFieldFinder, findsOneWidget);

    final textField = tester.widget<TextField>(baseFieldFinder);
    expect(textField.controller?.text, config.apiBaseUrl);

    await tester.enterText(baseFieldFinder, 'https://test.api');
    await tester.tap(find.text('Save override'));
    await tester.pumpAndSettle();

    expect(find.text('Base URL updated to https://test.api'), findsOneWidget);
  });
}
