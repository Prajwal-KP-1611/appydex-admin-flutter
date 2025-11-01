import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart'
    as api
    show ApiClient, apiClientProvider, extractTraceId;
import '../../core/auth/auth_controller.dart';
import '../../core/config.dart';
import '../../core/utils/dns_utils.dart';

class DiagnosticCallResult {
  const DiagnosticCallResult({
    required this.url,
    this.statusCode,
    this.bodyPreview,
    this.traceId,
    this.errorMessage,
    this.hint,
    this.latency,
  });

  final String url;
  final int? statusCode;
  final String? bodyPreview;
  final String? traceId;
  final String? errorMessage;
  final String? hint;
  final Duration? latency;

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
  String get statusLabel => statusCode?.toString() ?? 'Network error';
}

DiagnosticCallResult buildDiagnosticResult({
  required String url,
  Response<dynamic>? response,
  Object? error,
  Duration? latency,
}) {
  int? statusCode;
  String? traceId;
  String? bodyPreview;
  String? errorMessage;
  String? hint;

  if (response != null) {
    statusCode = response.statusCode;
    traceId = api.extractTraceId(response);
    bodyPreview = _stringifyDiagnosticData(response.data);
  }

  if (error != null) {
    errorMessage = error.toString();
    if (error is DioException && error.response != null) {
      statusCode = error.response?.statusCode;
      traceId = api.extractTraceId(error.response);
      bodyPreview = _stringifyDiagnosticData(error.response?.data);
    }
  }

  if (statusCode == 404) {
    hint =
        '404 — endpoint not implemented on server. For health check, ensure you call /healthz at root.';
  }

  if (bodyPreview != null && bodyPreview.length > 1200) {
    bodyPreview = '${bodyPreview.substring(0, 1200)}…';
  }

  return DiagnosticCallResult(
    url: url,
    statusCode: statusCode,
    traceId: traceId,
    bodyPreview: bodyPreview,
    errorMessage: errorMessage,
    hint: hint,
    latency: latency,
  );
}

class DiagnosticsState {
  const DiagnosticsState({
    this.dnsResult = const AsyncValue.data(null),
    this.healthResult = const AsyncValue.data(null),
    this.refreshResult = const AsyncValue.data(null),
    this.isSavingBaseUrl = false,
  });

  final AsyncValue<DnsLookupResult?> dnsResult;
  final AsyncValue<DiagnosticCallResult?> healthResult;
  final AsyncValue<DiagnosticCallResult?> refreshResult;
  final bool isSavingBaseUrl;

  DiagnosticsState copyWith({
    AsyncValue<DnsLookupResult?>? dnsResult,
    AsyncValue<DiagnosticCallResult?>? healthResult,
    AsyncValue<DiagnosticCallResult?>? refreshResult,
    bool? isSavingBaseUrl,
  }) {
    return DiagnosticsState(
      dnsResult: dnsResult ?? this.dnsResult,
      healthResult: healthResult ?? this.healthResult,
      refreshResult: refreshResult ?? this.refreshResult,
      isSavingBaseUrl: isSavingBaseUrl ?? this.isSavingBaseUrl,
    );
  }
}

class DiagnosticsController extends StateNotifier<DiagnosticsState> {
  DiagnosticsController(this._ref, this._apiClient)
    : super(const DiagnosticsState());

  final Ref _ref;
  final api.ApiClient _apiClient;

  String get _currentBaseUrl => _ref.read(apiBaseUrlProvider);

  Future<void> runDnsCheck() async {
    state = state.copyWith(dnsResult: const AsyncValue.loading());
    try {
      final uri = Uri.parse(_currentBaseUrl);
      final result = await performDnsLookup(uri.host);
      state = state.copyWith(dnsResult: AsyncValue.data(result));
    } catch (error, stackTrace) {
      state = state.copyWith(dnsResult: AsyncValue.error(error, stackTrace));
    }
  }

  Future<void> pingHealthz() async {
    state = state.copyWith(healthResult: const AsyncValue.loading());
    final stopwatch = Stopwatch()..start();
    final url = _healthUrl();
    try {
      final response = await _apiClient.dio.get<dynamic>(
        url,
        options: Options(
          extra: const {'skipAuth': true, 'skipErrorWrapping': true},
          validateStatus: (_) => true,
        ),
      );
      stopwatch.stop();
      final result = buildDiagnosticResult(
        url: url,
        response: response,
        latency: stopwatch.elapsed,
      );
      state = state.copyWith(healthResult: AsyncValue.data(result));
    } catch (error) {
      stopwatch.stop();
      final result = buildDiagnosticResult(url: url, error: error);
      state = state.copyWith(healthResult: AsyncValue.data(result));
    }
  }

  Future<void> forceRefreshToken() async {
    state = state.copyWith(refreshResult: const AsyncValue.loading());
    final stopwatch = Stopwatch()..start();
    try {
      final attempt = await _apiClient.refreshWithDetails(source: 'manual');
      stopwatch.stop();

      if (attempt.tokens != null) {
        _ref.read(authControllerProvider.notifier).applyTokens(attempt.tokens!);
      }

      final url =
          attempt.response?.requestOptions.uri.toString() ??
          '${_apiClient.dio.options.baseUrl}/auth/refresh';

      final result = buildDiagnosticResult(
        url: url,
        response: attempt.response,
        error: attempt.error,
        latency: stopwatch.elapsed,
      );
      state = state.copyWith(refreshResult: AsyncValue.data(result));
    } catch (error) {
      stopwatch.stop();
      final url = '${_apiClient.dio.options.baseUrl}/auth/refresh';
      final result = buildDiagnosticResult(url: url, error: error);
      state = state.copyWith(refreshResult: AsyncValue.data(result));
    }
  }

  Future<void> applyBaseUrl(String value) async {
    state = state.copyWith(isSavingBaseUrl: true);
    try {
      await _ref.read(apiBaseUrlProvider.notifier).updateBaseUrl(value);
    } finally {
      state = state.copyWith(isSavingBaseUrl: false);
    }
  }

  Future<void> resetBaseUrl() =>
      _ref.read(apiBaseUrlProvider.notifier).resetToDefault();

  Future<void> toggleMockMode(bool enabled) =>
      _ref.read(mockModeProvider.notifier).toggle(enabled);

  String _healthUrl() {
    final base = infraBaseUrl(_currentBaseUrl);
    if (base.isEmpty) return '/healthz';
    return base.endsWith('/') ? '${base}healthz' : '$base/healthz';
  }
}

String? _stringifyDiagnosticData(dynamic data) {
  if (data == null) return null;
  if (data is String) return data;
  try {
    return const JsonEncoder.withIndent('  ').convert(data);
  } catch (_) {
    return data.toString();
  }
}

final diagnosticsControllerProvider =
    StateNotifierProvider<DiagnosticsController, DiagnosticsState>((ref) {
      final client = ref.watch(api.apiClientProvider);
      return DiagnosticsController(ref, client);
    });
