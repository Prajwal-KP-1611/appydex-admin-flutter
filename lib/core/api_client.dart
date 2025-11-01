import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'admin_config.dart';
import 'auth/token_storage.dart';
import 'config.dart';

const _uuid = Uuid();

/// Records the details of the most recent failed request for diagnostics.
class LastRequestFailure {
  LastRequestFailure({
    required this.method,
    required this.url,
    required this.statusCode,
    required this.requestHeaders,
    required this.requestBody,
    required this.responseBody,
    required this.traceId,
    required this.timestamp,
  });

  final String method;
  final String url;
  final int? statusCode;
  final Map<String, dynamic> requestHeaders;
  final String? requestBody;
  final String? responseBody;
  final String? traceId;
  final DateTime timestamp;

  /// Generates a curl command that mirrors the failed request.
  String toCurl() {
    final buffer = StringBuffer('curl -X $method "$url"');
    requestHeaders.forEach((key, value) {
      buffer.write(' \\\n  -H "$key: $value"');
    });
    if (requestBody != null && requestBody!.isNotEmpty) {
      buffer.write(' \\\n  -d \'$requestBody\'');
    }
    return buffer.toString();
  }
}

final lastRequestFailureProvider = StateProvider<LastRequestFailure?>(
  (ref) => null,
);

final lastTraceIdProvider = StateProvider<String?>((ref) => null);

class RefreshAttempt {
  RefreshAttempt({
    required this.source,
    this.tokens,
    this.response,
    this.error,
    required this.timestamp,
    this.traceId,
  });

  final String source;
  final TokenPair? tokens;
  final Response<dynamic>? response;
  final Object? error;
  final DateTime timestamp;
  final String? traceId;

  bool get success => tokens != null;
  int? get statusCode => response?.statusCode;
  String get url => response?.requestOptions.uri.toString() ?? '';
}

final lastRefreshAttemptProvider = StateProvider<RefreshAttempt?>(
  (ref) => null,
);

/// Lightweight domain error surfaced to UI layers.
class AppHttpException implements Exception {
  AppHttpException({
    required this.message,
    required this.statusCode,
    this.traceId,
    this.details,
  });

  final String message;
  final int? statusCode;
  final String? traceId;
  final Map<String, dynamic>? details;

  @override
  String toString() =>
      'AppHttpException(statusCode: $statusCode, traceId: $traceId, message: $message)';
}

class TokenRefreshException implements Exception {
  const TokenRefreshException(this.message);
  final String message;
  @override
  String toString() => 'TokenRefreshException($message)';
}

class ApiClient {
  ApiClient({
    required Ref ref,
    required TokenStorage tokenStorage,
    required String baseUrl,
    Dio? dio,
    Duration timeout = const Duration(seconds: 10),
  }) : _ref = ref,
       _tokenStorage = tokenStorage,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: _resolveBaseUrl(baseUrl),
               connectTimeout: timeout,
               receiveTimeout: timeout,
               sendTimeout: timeout,
               headers: {'Accept': 'application/json', 'X-API-Version': 'v1'},
             ),
           ) {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
        onResponse: _onResponse,
      ),
    );
  }

  final Ref _ref;
  final TokenStorage _tokenStorage;
  final Dio _dio;

  Completer<void>? _refreshCompleter;

  Dio get dio => _dio;

  Future<Response<T>> requestAdmin<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) {
    final mergedOptions = (options ?? Options()).copyWith(
      method: method,
      extra: {...?options?.extra, 'admin': true},
    );

    return _dio.request<T>(
      path,
      queryParameters: queryParameters,
      data: data,
      options: mergedOptions,
    );
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = _resolveBaseUrl(baseUrl);
  }

  void dispose() {
    _dio.close(force: true);
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent('Accept', () => 'application/json');
    options.headers.putIfAbsent('X-API-Version', () => 'v1');

    final traceId = (options.extra['trace_id'] as String?) ?? _uuid.v4();
    options.headers['X-Trace-Id'] = traceId;
    options.extra['trace_id'] = traceId;
    _ref.read(lastTraceIdProvider.notifier).state = traceId;

    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }

    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final idempotencyKey = options.extra['idempotencyKey'] as String?;
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      options.headers['Idempotency-Key'] = idempotencyKey;
    }

    if (_isAdminRequest(options)) {
      final adminToken =
          _ref.read(adminTokenProvider) ?? AdminConfig.adminToken;
      if (adminToken != null && adminToken.isNotEmpty) {
        options.headers['X-Admin-Token'] = adminToken;
      } else {
        options.headers.remove('X-Admin-Token');
      }
      options.extra['admin'] = true;
    }

    _applySendTimeoutPolicy(
      options,
      isWeb: kIsWeb,
      defaultTimeout: _dio.options.sendTimeout ?? const Duration(seconds: 10),
    );

    handler.next(options);
  }

  Future<void> _onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final traceId =
        response.headers.value('x-trace-id') ??
        response.requestOptions.extra['trace_id'] as String?;

    if (traceId != null) {
      _ref.read(lastTraceIdProvider.notifier).state = traceId;
    }

    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final traceId = _extractTraceId(error);

    if (traceId != null) {
      _ref.read(lastTraceIdProvider.notifier).state = traceId;
    }

    if (_shouldAttemptRefresh(error)) {
      try {
        final refreshed = await _refreshTokens();
        if (refreshed != null) {
          final retried = await _retryRequest(error.requestOptions);
          handler.resolve(retried);
          return;
        }
      } catch (_) {
        // Propagate failure so diagnostics can surface it.
      }
    }

    _captureFailure(error, traceId);
    handler.next(_wrapError(error, traceId));
  }

  static String _resolveBaseUrl(String origin) {
    final sanitized = origin.endsWith('/')
        ? origin.substring(0, origin.length - 1)
        : origin;
    if (sanitized.endsWith('/api/v1')) return sanitized;
    return '$sanitized/api/v1';
  }

  bool _shouldAttemptRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != 401) return false;
    final options = error.requestOptions;
    if (options.extra['skipAuth'] == true) return false;
    if (options.extra['isRefreshRequest'] == true) return false;
    final attempt = options.extra['retryAttempt'] as int? ?? 0;
    return attempt < 1;
  }

  Future<TokenPair?> _refreshTokens({String source = 'auto'}) async {
    final attempt = await _executeRefresh(source: source);
    return attempt.tokens;
  }

  Future<RefreshAttempt> _executeRefresh({String source = 'auto'}) async {
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      final existingAttempt = _ref.read(lastRefreshAttemptProvider);
      if (existingAttempt != null) {
        return existingAttempt;
      }
    }

    final completer = Completer<void>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        final attempt = RefreshAttempt(
          source: source,
          tokens: null,
          response: null,
          error: const TokenRefreshException('Missing refresh token'),
          timestamp: DateTime.now(),
          traceId: null,
        );
        _ref.read(lastRefreshAttemptProvider.notifier).state = attempt;
        return attempt;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          extra: const {
            'skipAuth': true,
            'isRefreshRequest': true,
            'skipErrorWrapping': true,
          },
          validateStatus: (_) => true,
        ),
      );

      TokenPair? tokens;
      Object? error;
      if (response.statusCode == 200) {
        final data = response.data ?? <String, dynamic>{};
        final parsed = TokenPair.fromJson(data);
        if (parsed.isValid) {
          tokens = parsed;
          await _tokenStorage.save(parsed);
        } else {
          error = const TokenRefreshException('Invalid refresh response');
        }
      } else if (response.statusCode == null) {
        error = const TokenRefreshException('Refresh failed without response');
      }

      final attempt = RefreshAttempt(
        source: source,
        tokens: tokens,
        response: response,
        error: error,
        timestamp: DateTime.now(),
        traceId: extractTraceId(response),
      );

      _ref.read(lastRefreshAttemptProvider.notifier).state = attempt;
      return attempt;
    } on DioException catch (error) {
      _captureFailure(error, _extractTraceId(error));
      final attempt = RefreshAttempt(
        source: source,
        tokens: null,
        response: error.response,
        error: error,
        timestamp: DateTime.now(),
        traceId: _extractTraceId(error),
      );
      _ref.read(lastRefreshAttemptProvider.notifier).state = attempt;
      return attempt;
    } catch (error) {
      final attempt = RefreshAttempt(
        source: source,
        tokens: null,
        response: null,
        error: error,
        timestamp: DateTime.now(),
        traceId: null,
      );
      _ref.read(lastRefreshAttemptProvider.notifier).state = attempt;
      return attempt;
    } finally {
      if (!completer.isCompleted) completer.complete();
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = requestOptions.copyWith(
      headers: Map<String, dynamic>.from(requestOptions.headers),
      data: requestOptions.data,
      extra: {
        ...requestOptions.extra,
        'retryAttempt': (requestOptions.extra['retryAttempt'] as int? ?? 0) + 1,
      },
    );

    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }

    return _dio.fetch<dynamic>(options);
  }

  DioException _wrapError(DioException error, String? traceId) {
    if (error.requestOptions.extra['skipErrorWrapping'] == true) {
      return error;
    }

    final message = _inferErrorMessage(error);
    final exception = AppHttpException(
      message: message,
      statusCode: error.response?.statusCode,
      traceId: traceId,
      details: _extractValidationDetails(error),
    );

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: exception,
      stackTrace: error.stackTrace,
    );
  }

  Map<String, dynamic>? _extractValidationDetails(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['detail'] is List) {
      return {'detail': data['detail']};
    }
    return null;
  }

  String _inferErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['detail'] is String) {
        return data['detail'] as String;
      }
      if (data['message'] is String) {
        return data['message'] as String;
      }
    }
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
    return 'Something went wrong. Please try again.';
  }

  void _captureFailure(DioException error, String? traceId) {
    final options = error.requestOptions;
    final response = error.response;

    final headers = <String, dynamic>{};
    headers.addAll(options.headers);

    final requestBody = _stringify(options.data);
    final responseBody = _stringify(response?.data);

    _ref.read(lastRequestFailureProvider.notifier).state = LastRequestFailure(
      method: options.method,
      url: options.uri.toString(),
      statusCode: response?.statusCode,
      requestHeaders: headers,
      requestBody: requestBody,
      responseBody: responseBody,
      traceId: traceId,
      timestamp: DateTime.now(),
    );
  }

  String? _stringify(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  String? _extractTraceId(DioException error) {
    return extractTraceId(error.response) ??
        error.requestOptions.extra['trace_id'] as String?;
  }

  /// Allows manual flows to force a refresh call without throwing.
  Future<TokenPair?> forceRefresh() => _refreshTokens(source: 'manual');

  /// Returns detailed refresh attempt information for diagnostics.
  Future<RefreshAttempt> refreshWithDetails({String source = 'manual'}) =>
      _executeRefresh(source: source);
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final storage = ref.watch(tokenStorageProvider);
  final client = ApiClient(ref: ref, tokenStorage: storage, baseUrl: baseUrl);

  ref.onDispose(client.dispose);

  return client;
});

bool _requestHasBody(RequestOptions options) {
  final method = options.method.toUpperCase();
  if (method == 'GET' || method == 'HEAD') {
    return false;
  }

  final data = options.data;
  if (data == null) return false;
  if (data is FormData) return true;
  if (data is Stream) return true;
  return true;
}

@visibleForTesting
bool requestHasBodyForTesting(RequestOptions options) =>
    _requestHasBody(options);

@visibleForTesting
void applySendTimeoutPolicyForPlatform(
  RequestOptions options, {
  required bool isWeb,
  Duration? defaultTimeout,
}) {
  if (!isWeb) return;
  if (!_requestHasBody(options)) {
    if (kDebugMode) {
      debugPrint(
        '[ApiClient] Disabled sendTimeout for ${options.method} ${options.uri} on web (no request body).',
      );
    }
    options.sendTimeout = Duration.zero;
    return;
  }

  if (options.sendTimeout == Duration.zero) {
    options.sendTimeout = defaultTimeout ?? const Duration(seconds: 15);
  }
}

void _applySendTimeoutPolicy(
  RequestOptions options, {
  required bool isWeb,
  required Duration defaultTimeout,
}) {
  applySendTimeoutPolicyForPlatform(
    options,
    isWeb: isWeb,
    defaultTimeout: defaultTimeout,
  );
}

String? extractTraceId(Response<dynamic>? response) {
  if (response == null) return null;
  final header = response.headers.value('x-trace-id');
  if (header != null && header.isNotEmpty) {
    return header;
  }

  final data = response.data;
  if (data is Map && data['trace_id'] is String) {
    return data['trace_id'] as String;
  }
  return null;
}

@visibleForTesting
String? extractTraceIdForTesting(Response<dynamic>? response) =>
    extractTraceId(response);

bool _isAdminRequest(RequestOptions options) {
  if (options.extra['admin'] == true) return true;
  final path = options.path;
  if (path.startsWith('/api/v1/admin')) return true;
  if (path.startsWith('/admin/')) return true;
  if (path == '/admin' || path == '/api/v1/admin') return true;
  return false;
}
