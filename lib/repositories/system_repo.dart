import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/system_health.dart';
import 'admin_exceptions.dart';

/// Repository for system health and monitoring operations
/// Base Path: /api/v1/admin/system
///
/// Provides insights into ephemeral data lifecycle, cleanup processes,
/// and overall system health metrics for admin monitoring.
class SystemRepository {
  SystemRepository(this._client);

  final ApiClient _client;

  /// Get ephemeral data statistics
  /// GET /api/v1/admin/system/ephemeral-stats
  ///
  /// Returns statistics for short-lived data:
  /// - Idempotency keys (30-day retention)
  /// - Webhook events (90-day retention)
  /// - Refresh tokens (14-day retention)
  ///
  /// This endpoint helps admins monitor data lifecycle and cleanup processes.
  Future<EphemeralStats> getEphemeralStats() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/system/ephemeral-stats',
      );
      return EphemeralStats.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/system/ephemeral-stats');
      }
      rethrow;
    }
  }

  /// Trigger manual cleanup (if implemented by backend)
  /// POST /api/v1/admin/system/cleanup
  ///
  /// Note: This endpoint may not be implemented yet in all backends.
  /// Cleanup typically runs automatically via scheduled tasks.
  Future<void> triggerCleanup() async {
    try {
      await _client.requestAdmin<void>('/admin/system/cleanup', method: 'POST');
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/system/cleanup');
      }
      rethrow;
    }
  }
}

/// Provider for SystemRepository
final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SystemRepository(client);
});

/// Provider for ephemeral stats
/// Auto-refreshes every 5 minutes
final ephemeralStatsProvider = FutureProvider.autoDispose<EphemeralStats>((
  ref,
) async {
  final repository = ref.watch(systemRepositoryProvider);

  // Keep alive for 5 minutes before re-fetching
  final link = ref.keepAlive();
  Future.delayed(const Duration(minutes: 5), link.close);

  return repository.getEphemeralStats();
});
