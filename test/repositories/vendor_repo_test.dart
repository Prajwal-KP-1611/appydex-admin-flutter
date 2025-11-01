import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appydex_admin/core/admin_config.dart';
import 'package:appydex_admin/core/api_client.dart';
import 'package:appydex_admin/core/auth/token_storage.dart';
import 'package:appydex_admin/core/config.dart';
import 'package:appydex_admin/repositories/admin_exceptions.dart';
import 'package:appydex_admin/repositories/vendor_repo.dart';

class _FakeStorage implements TokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<TokenPair?> read() async => null;

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> save(TokenPair tokens) async {}
}

class _StaticAdapter implements HttpClientAdapter {
  _StaticAdapter(this.onRequest);

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

Future<({ProviderContainer container, ApiClient client, VendorRepository repo})>
_bootstrapWithAdapter(HttpClientAdapter adapter) async {
  SharedPreferences.setMockInitialValues({});
  final config = await AppConfig.load(flavor: 'test');
  final dio = Dio(BaseOptions(baseUrl: '${config.apiBaseUrl}/api/v1'))
    ..httpClientAdapter = adapter;
  final storage = _FakeStorage();

  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(config),
      tokenStorageProvider.overrideWithValue(storage),
      apiClientProvider.overrideWith(
        (ref) => ApiClient(
          ref: ref,
          tokenStorage: storage,
          baseUrl: config.apiBaseUrl,
          dio: dio,
        ),
      ),
    ],
  );

  final client = container.read(apiClientProvider);
  final repo = VendorRepository(client);
  return (container: container, client: client, repo: repo);
}

void main() {
  setUp(() {
    AdminConfig.adminToken = 'test-token';
  });

  tearDown(() {
    AdminConfig.adminToken = null;
  });

  test('list returns pagination from admin endpoint', () async {
    late RequestOptions captured;
    final adapter = _StaticAdapter((options) async {
      captured = options;
      return ResponseBody.fromString(
        '{"items":[{"id":1,"name":"Acme","owner_email":"owner@example.com","is_active":true,"is_verified":false,"onboarding_score":0.7,"created_at":"2024-01-01T00:00:00Z"}],"total":1,"page":1,"page_size":20}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final setup = await _bootstrapWithAdapter(adapter);
    addTearDown(setup.container.dispose);

    final page = await setup.repo.list();

    expect(page.items, hasLength(1));
    expect(page.items.first.name, 'Acme');
    expect(captured.headers['X-Admin-Token'], 'test-token');
    expect(captured.path, '/admin/vendors');
  });

  test('list throws AdminEndpointMissing on 404', () async {
    final adapter = _StaticAdapter((options) async {
      return ResponseBody.fromString(
        '{"detail":"Not Found"}',
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final setup = await _bootstrapWithAdapter(adapter);
    addTearDown(setup.container.dispose);

    expect(() => setup.repo.list(), throwsA(isA<AdminEndpointMissing>()));
  });
}
