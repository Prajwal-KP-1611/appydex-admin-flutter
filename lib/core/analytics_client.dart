import 'dart:async';

import 'package:dio/dio.dart';

import 'admin_config.dart';
import 'api_client.dart';

class AnalyticsClient {
  AnalyticsClient({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Map<String, num>> loadCoreMetrics() async {
    final metrics = <String, num>{};
    final base = _apiClient.dio.options.baseUrl;
    final infra = AdminConfig.infraBase(base);

    try {
      final sanitizedInfra = infra.isEmpty
          ? ''
          : (infra.endsWith('/')
                ? infra.substring(0, infra.length - 1)
                : infra);
      final metricsUrl = sanitizedInfra.isEmpty
          ? '/metrics'
          : '$sanitizedInfra/metrics';

      final response = await _apiClient.dio.get<String>(
        metricsUrl,
        options: Options(
          extra: const {'skipAuth': true, 'skipErrorWrapping': true},
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        metrics.addAll(_parsePrometheus(response.data!));
      } else {
        metrics.addAll(await _fallbackMetrics());
      }
    } catch (_) {
      metrics.addAll(await _fallbackMetrics());
    }

    return {
      'vendors_total': metrics['appydex_vendors_total'] ?? 0,
      'vendors_pending_verification':
          metrics['appydex_vendors_pending_verification'] ?? 0,
      'bookings_today': metrics['appydex_bookings_today'] ?? 0,
      'active_subscriptions': metrics['appydex_active_subscriptions'] ?? 0,
      'revenue_30d_cents': metrics['appydex_revenue_last_30d_cents'] ?? 0,
      'payment_failures_7d': metrics['appydex_payments_failures_7d'] ?? 0,
      'error_rate_5m': metrics['appydex_error_rate_5m'] ?? 0,
    };
  }

  Future<Map<String, num>> _fallbackMetrics() async {
    try {
      final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
        '/admin/metrics',
        options: Options(extra: const {'skipErrorWrapping': true}),
      );
      final data = response.data ?? const {};
      return data.map(
        (key, value) =>
            MapEntry(key, value is num ? value : num.tryParse('$value') ?? 0),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const {};
      }
      rethrow;
    }
  }

  Map<String, num> _parsePrometheus(String payload) {
    final metrics = <String, num>{};
    final lines = payload.split('\n');
    for (final line in lines) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final name = parts[0];
      final value = num.tryParse(parts[1]);
      if (value != null) {
        metrics[name] = value;
      }
    }
    return metrics;
  }
}
