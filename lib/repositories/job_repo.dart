import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../widgets/job_poller.dart';
import 'admin_exceptions.dart';

/// Job metadata and filters
class JobMeta {
  const JobMeta({this.format, this.filters, this.rowCount});

  final String? format;
  final Map<String, dynamic>? filters;
  final int? rowCount;

  factory JobMeta.fromJson(Map<String, dynamic> json) {
    return JobMeta(
      format: json['format'] as String?,
      filters: json['filters'] as Map<String, dynamic>?,
      rowCount: (json['row_count'] as num?)?.toInt(),
    );
  }
}

/// Background job model
class Job {
  const Job({
    required this.id,
    required this.type,
    required this.status,
    this.progress,
    this.meta,
    this.resultUrl,
    this.resultExpiresAt,
    this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.error,
  });

  final String id;
  final String type;
  final String status;
  final int? progress;
  final JobMeta? meta;
  final String? resultUrl;
  final DateTime? resultExpiresAt;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? error;

  JobStatus get jobStatus => JobStatus.fromString(status);

  bool get isComplete =>
      status == 'succeeded' || status == 'failed' || status == 'cancelled';

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toInt(),
      meta: json['meta'] != null
          ? JobMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      resultUrl: json['result_url'] as String?,
      resultExpiresAt: json['result_expires_at'] != null
          ? DateTime.parse(json['result_expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'] as String)
          : null,
      error: json['error'] as String?,
    );
  }
}

/// Repository for background job management
/// Base Path: /api/v1/admin/jobs
///
/// Provides access to long-running background jobs like exports,
/// bulk operations, and system maintenance tasks.
class JobRepository {
  JobRepository(this._client);

  final ApiClient _client;

  /// List background jobs with pagination and filters
  /// GET /api/v1/admin/jobs
  ///
  /// Query Parameters:
  /// - page: Page number (default: 1)
  /// - page_size: Items per page (default: 20)
  /// - status: Filter by status (queued, running, succeeded, failed, cancelled)
  /// - type: Filter by job type
  Future<Pagination<Job>> list({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? type,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (status != null && status.isNotEmpty) 'status': status,
      if (type != null && type.isNotEmpty) 'type': type,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/jobs',
        queryParameters: params,
      );

      final body = response.data ?? <String, dynamic>{};

      return Pagination.fromJson(body, (item) => Job.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/jobs');
      }
      rethrow;
    }
  }

  /// Get detailed information about a specific job
  /// GET /api/v1/admin/jobs/{job_id}
  ///
  /// Returns complete job details including progress, metadata, and results.
  Future<Job> getById(String jobId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/jobs/$jobId',
      );

      if (response.data == null) {
        throw AdminValidationError('Job $jobId not found');
      }

      return Job.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/jobs/$jobId');
      }
      rethrow;
    }
  }

  /// Cancel a running or queued job
  /// POST /api/v1/admin/jobs/{job_id}/cancel
  ///
  /// Requests cancellation of the job. The job may take time to cancel
  /// if it's currently processing.
  Future<Job> cancel(String jobId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/jobs/$jobId/cancel',
        method: 'POST',
        options: idempotentOptions(),
      );

      if (response.data == null) {
        throw AdminValidationError('Job $jobId not found');
      }

      return Job.fromJson(response.data!);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/jobs/$jobId/cancel');
      }
      if (error.response?.statusCode == 400) {
        final message =
            error.response?.data['detail'] as String? ?? 'Cannot cancel job';
        throw AdminValidationError(message);
      }
      rethrow;
    }
  }

  /// Delete a completed or failed job
  /// DELETE /api/v1/admin/jobs/{job_id}
  ///
  /// Removes the job record from the system. Only works for completed,
  /// failed, or cancelled jobs.
  Future<void> delete(String jobId) async {
    try {
      await _client.requestAdmin<void>(
        '/admin/jobs/$jobId',
        method: 'DELETE',
        options: idempotentOptions(),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/jobs/$jobId');
      }
      if (error.response?.statusCode == 400) {
        final message =
            error.response?.data['detail'] as String? ?? 'Cannot delete job';
        throw AdminValidationError(message);
      }
      rethrow;
    }
  }
}

/// Provider for JobRepository
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return JobRepository(client);
});

/// State notifier for background jobs list
class JobsNotifier extends StateNotifier<AsyncValue<Pagination<Job>>> {
  JobsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final JobRepository _repository;

  String? _statusFilter;
  String? _typeFilter;
  int _page = 1;
  static const int _pageSize = 20;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(
        page: _page,
        pageSize: _pageSize,
        status: _statusFilter,
        type: _typeFilter,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByStatus(String? status) {
    _statusFilter = status;
    _page = 1;
    load();
  }

  void filterByType(String? type) {
    _typeFilter = type;
    _page = 1;
    load();
  }

  void nextPage() {
    _page++;
    load();
  }

  void previousPage() {
    if (_page > 1) {
      _page--;
      load();
    }
  }

  void clearFilters() {
    _statusFilter = null;
    _typeFilter = null;
    _page = 1;
    load();
  }
}

/// Provider for jobs list state
final jobsProvider =
    StateNotifierProvider<JobsNotifier, AsyncValue<Pagination<Job>>>((ref) {
      final repository = ref.watch(jobRepositoryProvider);
      return JobsNotifier(repository);
    });
