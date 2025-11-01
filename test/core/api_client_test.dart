import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appydex_admin/core/api_client.dart' as api_client;
import 'package:appydex_admin/core/admin_config.dart';
import 'package:appydex_admin/core/auth/token_storage.dart';
import 'package:appydex_admin/core/config.dart';

class FakeTokenStorage implements TokenStorage {
  TokenPair? _tokens;

  void seed(TokenPair tokens) {
    _tokens = tokens;
  }

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

class RefreshTestAdapter implements HttpClientAdapter {
  RefreshTestAdapter({this.failRefresh = false});

  final bool failRefresh;
  int refreshCalls = 0;
  int protectedCalls = 0;
  final List<String?> observedAuthHeaders = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    if (options.path == '/auth/refresh') {
      refreshCalls += 1;
      if (failRefresh) {
        return ResponseBody.fromString(
          '{"detail":"refresh failed"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
            'x-trace-id': ['refresh-401'],
          },
        );
      }

      return ResponseBody.fromString(
        '{"access_token":"new-access","refresh_token":"new-refresh"}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (options.path == '/protected') {
      observedAuthHeaders.add(options.headers['Authorization'] as String?);
      protectedCalls += 1;
      if (protectedCalls == 1) {
        return ResponseBody.fromString(
          '{"detail":"Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
            'x-trace-id': ['trace-unauthorized'],
          },
        );
      }

      return ResponseBody.fromString(
        '{"ok":true}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    throw StateError('Unexpected path ${options.path}');
  }

  @override
  void close({bool force = false}) {}
}

class CapturingAdapter implements HttpClientAdapter {
  CapturingAdapter(this.onRequest);

  final Future<ResponseBody> Function(RequestOptions options) onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) {
    return onRequest(options);
  }

  @override
  void close({bool force = false}) {}
}

Future<
  ({
    ProviderContainer container,
    api_client.ApiClient client,
    FakeTokenStorage storage,
    RefreshTestAdapter adapter,
  })
>
_createClient({bool failRefresh = false}) async {
  SharedPreferences.setMockInitialValues({});
  final config = await AppConfig.load(flavor: 'test');
  final storage = FakeTokenStorage();
  final adapter = RefreshTestAdapter(failRefresh: failRefresh);
  final dio = Dio(BaseOptions(baseUrl: '${config.apiBaseUrl}/api/v1'))
    ..httpClientAdapter = adapter;

  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(config),
      tokenStorageProvider.overrideWithValue(storage),
      api_client.apiClientProvider.overrideWith(
        (ref) => api_client.ApiClient(
          ref: ref,
          tokenStorage: storage,
          baseUrl: config.apiBaseUrl,
          dio: dio,
        ),
      ),
    ],
  );

  final client = container.read(api_client.apiClientProvider);
  return (
    container: container,
    client: client,
    storage: storage,
    adapter: adapter,
  );
}

void main() {
  test('requestAdmin injects admin token header', () async {
    final setup = await _createClient();
    addTearDown(() {
      setup.container.dispose();
      AdminConfig.adminToken = null;
    });

    AdminConfig.adminToken = 'test-token';

    late RequestOptions captured;
    setup.client.dio.httpClientAdapter = CapturingAdapter((options) async {
      captured = options;
      return ResponseBody.fromString(
        '{"items":[],"total":0,"page":1,"page_size":20}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    await setup.client.requestAdmin<Map<String, dynamic>>('/admin/vendors');

    expect(captured.headers['X-Admin-Token'], 'test-token');
    expect(captured.extra['admin'], isTrue);
  });

  test('requestAdmin skips admin header when token missing', () async {
    final setup = await _createClient();
    addTearDown(() {
      setup.container.dispose();
      AdminConfig.adminToken = null;
    });

    late RequestOptions captured;
    setup.client.dio.httpClientAdapter = CapturingAdapter((options) async {
      captured = options;
      return ResponseBody.fromString(
        '{"items":[],"total":0,"page":1,"page_size":20}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    await setup.client.requestAdmin<Map<String, dynamic>>('/admin/vendors');

    expect(captured.headers['X-Admin-Token'], isNull);
    expect(captured.extra['admin'], isTrue);
  });

  test('refreshes once on 401 and retries request', () async {
    final setup = await _createClient();
    addTearDown(setup.container.dispose);

    setup.storage.seed(
      const TokenPair(
        accessToken: 'initial-access',
        refreshToken: 'initial-refresh',
      ),
    );

    final response = await setup.client.dio.get<Map<String, dynamic>>(
      '/protected',
    );

    expect(response.statusCode, 200);
    expect(response.data, {'ok': true});
    expect(setup.adapter.protectedCalls, 2);
    expect(setup.adapter.refreshCalls, 1);
    final saved = await setup.storage.read();
    expect(
      saved,
      const TokenPair(accessToken: 'new-access', refreshToken: 'new-refresh'),
    );
    expect(setup.adapter.observedAuthHeaders.first, 'Bearer initial-access');
    expect(setup.adapter.observedAuthHeaders.last, 'Bearer new-access');
  });

  test('forceRefresh reports failure but keeps existing tokens', () async {
    final setup = await _createClient(failRefresh: true);
    addTearDown(setup.container.dispose);

    setup.storage.seed(
      const TokenPair(
        accessToken: 'initial-access',
        refreshToken: 'initial-refresh',
      ),
    );

    final result = await setup.client.forceRefresh();

    expect(result, isNull);
    expect(await setup.storage.read(), isNotNull);
    expect(setup.adapter.refreshCalls, 1);

    final attempt = setup.container.read(api_client.lastRefreshAttemptProvider);
    expect(attempt, isNotNull);
    expect(attempt!.statusCode, 401);
    expect(attempt.success, isFalse);
  });

  group('_requestHasBody', () {
    test('returns false for GET without data', () {
      final options = RequestOptions(path: '/healthz', method: 'GET');
      expect(api_client.requestHasBodyForTesting(options), isFalse);
    });

    test('returns false for POST without data', () {
      final options = RequestOptions(path: '/auth/login', method: 'POST');
      expect(api_client.requestHasBodyForTesting(options), isFalse);
    });

    test('returns true for POST with map data', () {
      final options = RequestOptions(
        path: '/auth/login',
        method: 'POST',
        data: {'a': 'b'},
      );
      expect(api_client.requestHasBodyForTesting(options), isTrue);
    });

    test('returns true for POST with FormData', () {
      final options = RequestOptions(
        path: '/upload',
        method: 'POST',
        data: FormData(),
      );
      expect(api_client.requestHasBodyForTesting(options), isTrue);
    });
  });

  group('extractTraceId', () {
    test('pulls from headers', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/ping'),
        statusCode: 200,
        headers: Headers.fromMap({
          'x-trace-id': ['abc'],
        }),
      );
      expect(api_client.extractTraceIdForTesting(response), 'abc');
    });

    test('falls back to response body', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/ping'),
        statusCode: 404,
        data: {'trace_id': 'from-body'},
      );
      expect(api_client.extractTraceIdForTesting(response), 'from-body');
    });
  });
}
