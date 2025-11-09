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

  /// Get system health status
  /// GET /api/v1/admin/system/health
  ///
  /// Returns detailed health status for all system services including
  /// PostgreSQL, Redis, MongoDB, and Celery.
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/system/health',
      );
      return response.data ?? {};
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/system/health');
      }
      rethrow;
    }
  }

  /// List available backups
  /// GET /api/v1/admin/system/backups
  ///
  /// Returns list of available backup files with metadata.
  Future<List<Map<String, dynamic>>> listBackups() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/system/backups',
      );
      final backups = response.data?['backups'] as List<dynamic>? ?? const [];
      return backups.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/system/backups');
      }
      rethrow;
    }
  }

  /// Trigger system backup
  /// POST /api/v1/admin/system/backup
  ///
  /// Manually triggers a backup job. Requires super_admin permission.
  ///
  /// Parameters:
  /// - target: Database to backup (postgres, redis, mongo, all)
  /// - notes: Optional notes about the backup
  ///
  /// Returns job_id for tracking backup progress.
  Future<String> triggerBackup({String target = 'all', String? notes}) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/system/backup',
        method: 'POST',
        data: {
          'target': target,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      final jobId = response.data?['job_id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        throw Exception('Missing job_id in backup response');
      }
      return jobId;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/system/backup');
      }
      if (error.response?.statusCode == 403) {
        throw AdminValidationError(
          'Insufficient permissions (super_admin required)',
        );
      }
      rethrow;
    }
  }

  /// Restore from backup
  /// POST /api/v1/admin/system/restore
  ///
  /// ⚠️ DANGEROUS OPERATION - Restores system from a backup.
  /// Requires super_admin permission and explicit confirmation.
  ///
  /// Parameters:
  /// - backupId: ID of the backup to restore
  /// - confirm: Confirmation string (RESTORE_DATABASE_{backupId})
  ///
  /// Returns job_id for tracking restore progress.
  Future<String> restoreFromBackup({required String backupId}) async {
    final confirmString = 'RESTORE_DATABASE_$backupId';

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/system/restore',
        method: 'POST',
        data: {'backup_id': backupId, 'confirm': confirmString},
      );
      final jobId = response.data?['job_id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        throw Exception('Missing job_id in restore response');
      }
      return jobId;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/system/restore');
      }
      if (error.response?.statusCode == 400) {
        final message =
            error.response?.data['message'] as String? ??
            'Invalid restore request';
        throw AdminValidationError(message);
      }
      if (error.response?.statusCode == 403) {
        throw AdminValidationError(
          'Insufficient permissions (super_admin required)',
        );
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
