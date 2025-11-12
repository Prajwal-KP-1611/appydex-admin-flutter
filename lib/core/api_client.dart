import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
// Browser adapter for enabling credential (cookie) sending in web builds.
import 'package:dio/browser.dart' show BrowserHttpClientAdapter;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

// AdminConfig and legacy X-Admin-Token removed — admin endpoints use JWT Bearer now.
import 'auth/auth_service.dart';
import 'auth/token_manager.dart';
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
    // Debug: Print the resolved base URL
    debugPrint(
      '🔧 ApiClient initialized with baseUrl: ${_dio.options.baseUrl}',
    );

    // Enable cookie credentials on web (for httpOnly refresh token flow)
    if (kIsWeb) {
      final adapter = _dio.httpClientAdapter;
      if (adapter is BrowserHttpClientAdapter) {
        adapter.withCredentials = true;
        if (kDebugMode) {
          debugPrint('[ApiClient] Web withCredentials enabled');
        }
      }
    }

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
  final TokenManager _tokenManager = TokenManager();

  Completer<void>? _refreshCompleter;

  Dio get dio => _dio;

  Future<Response<T>> requestAdmin<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) {
    final hasBody =
        (method == 'POST' || method == 'PUT' || method == 'PATCH') &&
        data != null;

    // Explicitly encode data as JSON for POST/PUT/PATCH
    final requestData = hasBody && data is Map ? jsonEncode(data) : data;

    final mergedOptions = (options ?? Options()).copyWith(
      method: method,
      extra: {...?options?.extra, 'admin': true},
      headers: {
        ...?options?.headers,
        if (hasBody) 'Content-Type': 'application/json',
      },
    );

    // Debug print for troubleshooting
    if (hasBody || method == 'DELETE') {
      debugPrint('[ApiClient] $method $path');
      debugPrint('Headers: ${mergedOptions.headers}');
      if (hasBody) debugPrint('Body: $requestData');
    }

    return _dio.request<T>(
      path,
      queryParameters: queryParameters,
      data: requestData,
      options: mergedOptions,
    );
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = _resolveBaseUrl(baseUrl);
  }

  void dispose() {
    _dio.close(force: true);
  }

  /// POST with auto-generated Idempotency-Key for safe retries
  Future<Response<T>> postIdempotent<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? idempotencyKey,
  }) {
    final key = idempotencyKey ?? _uuid.v4();
    final mergedOptions = (options ?? Options()).copyWith(
      extra: {...?options?.extra, 'idempotencyKey': key},
    );
    return requestAdmin<T>(
      path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      options: mergedOptions,
    );
  }

  /// PATCH with auto-generated Idempotency-Key for safe retries
  Future<Response<T>> patchIdempotent<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? idempotencyKey,
  }) {
    final key = idempotencyKey ?? _uuid.v4();
    final mergedOptions = (options ?? Options()).copyWith(
      extra: {...?options?.extra, 'idempotencyKey': key},
    );
    return requestAdmin<T>(
      path,
      method: 'PATCH',
      data: data,
      queryParameters: queryParameters,
      options: mergedOptions,
    );
  }

  /// DELETE with auto-generated Idempotency-Key for safe retries
  Future<Response<T>> deleteIdempotent<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? idempotencyKey,
  }) {
    final key = idempotencyKey ?? _uuid.v4();
    final mergedOptions = (options ?? Options()).copyWith(
      extra: {...?options?.extra, 'idempotencyKey': key},
    );
    return requestAdmin<T>(
      path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      options: mergedOptions,
    );
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
      if (kDebugMode) {
        debugPrint(
          '[ApiClient] Added Authorization header for ${options.method} ${options.path}',
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          '[ApiClient WARNING] No access token for ${options.method} ${options.path}',
        );
      }
    }

    final idempotencyKey = options.extra['idempotencyKey'] as String?;
    // On web, DELETE requests can fail due to CORS if custom headers
    // like Idempotency-Key are not explicitly allowed by the server.
    // To improve compatibility, omit the header for DELETE on web.
    final isDelete = options.method.toUpperCase() == 'DELETE';
    final sendIdempotencyHeader =
        idempotencyKey != null &&
        idempotencyKey.isNotEmpty &&
        !(kIsWeb && isDelete);
    if (sendIdempotencyHeader) {
      options.headers['Idempotency-Key'] = idempotencyKey;
    }

    // Admin requests are marked for diagnostics but no longer include a
    // legacy X-Admin-Token header. The server must accept JWT Bearer tokens.
    if (_isAdminRequest(options)) {
      options.extra['admin'] = true;
      if (kDebugMode) {
        debugPrint(
          '[ApiClient] _isAdminRequest=true for ${options.method} ${options.path}',
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          '[ApiClient] _isAdminRequest=FALSE for ${options.method} ${options.path}',
        );
      }
    }

    _applySendTimeoutPolicy(
      options,
      isWeb: kIsWeb,
      defaultTimeout: _dio.options.sendTimeout ?? const Duration(seconds: 10),
    );

    // Debug print AFTER all headers are added
    if (kDebugMode &&
        (options.method == 'DELETE' ||
            options.method == 'POST' ||
            options.method == 'PUT' ||
            options.method == 'PATCH')) {
      debugPrint('[ApiClient FINAL] ${options.method} ${options.uri}');
      debugPrint('All Headers: ${options.headers}');
      if (options.data != null) debugPrint('Body: ${options.data}');
    }

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

    // Automatically unwrap backend {success: true, data: ...} format
    // BUT preserve pagination envelopes `{ success, data: [...], meta: {...} }`
    if (response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;

      final hasSuccess = body.containsKey('success');
      final hasData = body.containsKey('data');
      final hasMeta = body.containsKey('meta');

      // Only unwrap when there is no `meta` sibling. If `meta` exists, keep full envelope
      // so callers can access both `data` and `meta` for pagination.
      if (hasSuccess && hasData && !hasMeta) {
        final unwrappedResponse = Response(
          requestOptions: response.requestOptions,
          data: body['data'],
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          headers: response.headers,
          isRedirect: response.isRedirect,
          redirects: response.redirects,
          extra: response.extra,
        );
        handler.next(unwrappedResponse);
        return;
      }
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

    // Debug print error response
    debugPrint(
      '[ApiClient ERROR] ${error.requestOptions.method} ${error.requestOptions.uri}',
    );
    debugPrint('Status Code: ${error.response?.statusCode}');
    debugPrint('Response Data: ${error.response?.data}');
    debugPrint('Response Headers: ${error.response?.headers}');

    // Handle 401 (Unauthorized) - single refresh then logout
    if (_shouldAttemptRefresh(error)) {
      try {
        final refreshed = await _refreshTokens();
        if (refreshed != null) {
          final retried = await _retryRequest(error.requestOptions);
          handler.resolve(retried);
          return;
        } else {
          // Refresh failed - mark session as expired (soft) for graceful UI handling
          debugPrint('[ApiClient] Refresh failed, marking session as expired');
          await _ref.read(authServiceProvider).markSessionExpired();

          // Return empty response to prevent UI errors - banner will handle re-login
          final emptyResponse = Response(
            requestOptions: error.requestOptions,
            statusCode: 401,
            data: {
              'success': false,
              'error': {'message': 'Session expired'},
            },
          );
          handler.resolve(emptyResponse);
          return;
        }
      } catch (refreshError) {
        // Refresh attempt failed - mark session as expired
        debugPrint(
          '[ApiClient] Refresh error: $refreshError, marking session as expired',
        );
        await _ref.read(authServiceProvider).markSessionExpired();

        // Return empty response to prevent UI errors
        final emptyResponse = Response(
          requestOptions: error.requestOptions,
          statusCode: 401,
          data: {
            'success': false,
            'error': {'message': 'Session expired'},
          },
        );
        handler.resolve(emptyResponse);
        return;
      }
    }

    // Handle 403 (Forbidden) - log and show user-friendly message
    if (error.response?.statusCode == 403) {
      debugPrint('[ApiClient] 403 Forbidden: Access denied');
      // Toast will be shown by UI layer via AppHttpException
    }

    // Handle 422 (Unprocessable Entity) - validation errors
    if (error.response?.statusCode == 422) {
      debugPrint('[ApiClient] 422 Validation error: ${error.response?.data}');
      // Validation details extracted in _wrapError for inline field errors
    }

    // Handle 429 (Rate Limited) - log and suggest backoff
    if (error.response?.statusCode == 429) {
      debugPrint('[ApiClient] 429 Rate limited: Too many requests');
      // UI should briefly disable actions and retry with backoff
    }

    // Handle 5xx (Server Error) - log and allow component-level retry
    if (error.response?.statusCode != null &&
        error.response!.statusCode! >= 500) {
      debugPrint('[ApiClient] ${error.response!.statusCode} Server error');
      // Component can show retry button
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
      Response<Map<String, dynamic>>? response;

      if (kDebugMode) {
        debugPrint('[ApiClient] Attempting token refresh (source: $source)');
        debugPrint(
          '[ApiClient] Refresh token available: ${refreshToken != null && refreshToken.isNotEmpty ? "YES (${refreshToken.length} chars)" : "NO"}',
        );
      }

      if (refreshToken == null || refreshToken.isEmpty) {
        // Cookie-based fallback (web): attempt refresh without body
        if (kIsWeb) {
          if (kDebugMode) {
            debugPrint(
              '[ApiClient] No refresh token stored – attempting cookie refresh',
            );
          }
          response = await _dio.post<Map<String, dynamic>>(
            '/admin/auth/refresh', // Use admin endpoint
            options: Options(
              extra: const {
                'skipAuth': true,
                'isRefreshRequest': true,
                'skipErrorWrapping': true,
              },
              validateStatus: (_) => true,
            ),
          );
        } else {
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
      } else {
        // Send refresh token in request body
        response = await _dio.post<Map<String, dynamic>>(
          '/admin/auth/refresh', // Use admin endpoint
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
      }

      TokenPair? tokens;
      Object? error;
      if (response.statusCode == 200) {
        final data = response.data ?? <String, dynamic>{};
        final parsed = TokenPair.fromJson(data);

        // Some backends (especially when using httpOnly cookie refresh on web)
        // return only a new access token and rely on the httpOnly refresh
        // cookie for subsequent refreshes. Treat an access-token-only
        // response as a successful refresh on web so we don't force a logout
        // when a refresh_token is not present in the response body.
        final hasAccess = parsed.accessToken.isNotEmpty;
        final hasRefresh = parsed.refreshToken.isNotEmpty;

        if (hasAccess) {
          // If the response omitted the refresh token, preserve any
          // existing refresh token we had (useful for native flows) or
          // allow empty refresh token for cookie-based web flows.
          final effectiveRefresh = hasRefresh
              ? parsed.refreshToken
              : (refreshToken ?? '');
          final tokensToSave = TokenPair(
            accessToken: parsed.accessToken,
            refreshToken: effectiveRefresh,
          );

          tokens = tokensToSave;
          await _tokenStorage.save(tokensToSave);
          _tokenManager.markRefreshed();

          // Start auto-refresh timer after successful token save
          startAutoRefresh();

          if (kDebugMode) {
            debugPrint('[ApiClient] ✅ Token refresh successful');
            debugPrint(
              '[ApiClient] New access token: ${parsed.accessToken.length} chars',
            );
            debugPrint(
              '[ApiClient] Refresh token: ${effectiveRefresh.isNotEmpty ? "${effectiveRefresh.length} chars" : "empty (cookie-based)"}',
            );
          }
        } else {
          error = const TokenRefreshException('Invalid refresh response');

          if (kDebugMode) {
            debugPrint(
              '[ApiClient] ❌ Refresh failed: No access token in response',
            );
          }
        }
      } else if (response.statusCode == null) {
        error = const TokenRefreshException('Refresh failed without response');
      } else {
        // Non-200 response (401, 422, etc.) - refresh failed
        final statusCode = response.statusCode;
        final responseData = response.data;
        String errorMessage = 'Refresh failed with status $statusCode';

        // Try to extract error message from response
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] as String?;
          final detail = responseData['detail'] as String?;
          errorMessage = message ?? detail ?? errorMessage;
        }

        error = TokenRefreshException(errorMessage);

        if (kDebugMode) {
          debugPrint('[ApiClient] Refresh failed: $statusCode - $errorMessage');
          debugPrint('[ApiClient] Response data: $responseData');
        }
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

  /// Starts the auto-refresh timer that proactively refreshes tokens before expiry
  void startAutoRefresh() {
    _tokenManager.startAutoRefresh(() async {
      await _refreshTokens(source: 'auto');
    });
  }

  /// Stops the auto-refresh timer (call on logout)
  void stopAutoRefresh() {
    _tokenManager.stopAutoRefresh();
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
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Standardized messages for common HTTP status codes
    if (statusCode == 401) {
      debugPrint('[ApiClient] 401 Unauthorized - Session expired');
      return 'Your session has expired. Please log in again.';
    }
    if (statusCode == 403) {
      return 'Access denied. You do not have permission to perform this action.';
    }
    if (statusCode == 422) {
      // Check if this is an auth-related 422 error
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        final errorData = data['error'] as Map<String, dynamic>?;
        final errorMessage = errorData?['message'] as String?;

        // If message contains auth-related keywords, treat as auth error
        final authKeywords = [
          'authorization',
          'token',
          'jwt',
          'authentication',
          'bearer',
          'refresh',
        ];
        final fullMessage = '${message ?? ''} ${errorMessage ?? ''}'
            .toLowerCase();

        if (authKeywords.any((keyword) => fullMessage.contains(keyword))) {
          debugPrint('[ApiClient] 422 Auth error - Token/session invalid');
          return 'Your session has expired. Please log in again.';
        }

        // Extract validation message if available
        if (data['detail'] is String) {
          return data['detail'] as String;
        }
        if (message != null) {
          return message;
        }
      }
      return 'Invalid data submitted. Please check your inputs.';
    }
    if (statusCode == 429) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again in a moment.';
    }

    // Extract message from response data
    if (data is Map<String, dynamic>) {
      if (data['detail'] is String) {
        return data['detail'] as String;
      }
      if (data['message'] is String) {
        return data['message'] as String;
      }
    }

    // Fallback to DioException message
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

    // Sentry breadcrumbs for failed requests (non-sensitive metadata)
    try {
      // Only log error & warning responses
      final status = response?.statusCode ?? 0;
      if (status >= 400) {
        Sentry.addBreadcrumb(
          Breadcrumb(
            category: 'http',
            type: 'http',
            data: {
              'method': options.method,
              'url': options.uri.toString(),
              'status_code': status,
              if (traceId != null) 'trace_id': traceId,
            },
            level: status >= 500 ? SentryLevel.error : SentryLevel.warning,
            message: 'HTTP ${options.method} ${options.path} failed',
          ),
        );
      }
    } catch (_) {
      // Ignore Sentry issues silently
    }
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
