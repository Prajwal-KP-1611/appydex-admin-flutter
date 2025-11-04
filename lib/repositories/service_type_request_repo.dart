import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../models/service_type_request.dart';

/// Repository for service type request management
/// Base Path: /api/v1/admin/service-type-requests
/// Manage vendor requests for new service categories
class ServiceTypeRequestRepository {
  ServiceTypeRequestRepository(this._client);

  final ApiClient _client;

  /// List service type requests
  /// GET /api/v1/admin/service-type-requests
  Future<Pagination<ServiceTypeRequest>> list({
    int skip = 0,
    int limit = 100,
    String? status,
    int? vendorId,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (vendorId != null) 'vendor_id': vendorId,
    };

    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/service-type-requests',
      queryParameters: params,
    );

    final body = response.data ?? <String, dynamic>{};
    return Pagination.fromJson(
      body,
      (item) => ServiceTypeRequest.fromJson(item),
    );
  }

  /// Get request details
  /// GET /api/v1/admin/service-type-requests/{request_id}
  Future<ServiceTypeRequest> getById(int id) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/service-type-requests/$id',
    );
    return ServiceTypeRequest.fromJson(response.data ?? const {});
  }

  /// Approve request
  /// POST /api/v1/admin/service-type-requests/{request_id}/approve
  /// Creates new ServiceType in master catalog
  ///
  /// ✅ UPDATED: Backend now uses Pydantic model (commit ca48178)
  /// Sends: {"review_notes": "text"} or {} for empty
  Future<ServiceTypeRequestApprovalResult> approve({
    required int requestId,
    String? reviewNotes,
  }) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/service-type-requests/$requestId/approve',
      method: 'POST',
      data: reviewNotes != null && reviewNotes.isNotEmpty
          ? {'review_notes': reviewNotes}
          : {}, // Empty object if no notes
      options: idempotentOptions(),
    );
    return ServiceTypeRequestApprovalResult.fromJson(response.data ?? const {});
  }

  /// Reject request
  /// POST /api/v1/admin/service-type-requests/{request_id}/reject
  ///
  /// ✅ UPDATED: Backend now uses Pydantic model (commit ca48178)
  /// Validation: review_notes required, min 20 characters, max 1000
  /// Sends: {"review_notes": "detailed feedback..."}
  Future<ServiceTypeRequestRejectionResult> reject({
    required int requestId,
    required String reviewNotes,
  }) async {
    // Client-side validation for better UX (backend also validates)
    if (reviewNotes.trim().length < 20) {
      throw ArgumentError(
        'Review notes must be at least 20 characters to provide actionable feedback to vendors',
      );
    }

    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/service-type-requests/$requestId/reject',
      method: 'POST',
      data: {'review_notes': reviewNotes},
      options: idempotentOptions(),
    );
    return ServiceTypeRequestRejectionResult.fromJson(
      response.data ?? const {},
    );
  }

  /// Get SLA statistics
  /// GET /api/v1/admin/service-type-requests/stats
  /// Monitor SLA compliance and review performance
  ///
  /// ✅ FIXED: Route ordering corrected in backend (already in code at line 94)
  /// Route /stats is now defined BEFORE /{request_id} parameterized route
  /// Requires backend restart to reload route registration
  ///
  /// ⚠️ TEMPORARY: Try-catch remains until backend restart confirmed
  /// TODO: Remove try-catch after backend deployment verified
  Future<ServiceTypeRequestStats> getStats() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/service-type-requests/stats',
      );
      return ServiceTypeRequestStats.fromJson(response.data ?? const {});
    } catch (e) {
      // TEMPORARY FALLBACK: Return empty stats if endpoint still has route conflict
      // This will be removed after backend restart is confirmed
      return ServiceTypeRequestStats(
        pendingTotal: 0,
        pendingUnder24h: 0,
        pending24To48h: 0,
        pendingOver48h: 0,
        overdueRequests: const [],
        approvedThisMonth: 0,
        rejectedThisMonth: 0,
        avgReviewTimeHours: 0.0,
        slaComplianceRate: 0.0,
        monthStart: DateTime.now(),
      );
    }
  }
}

/// Provider for ServiceTypeRequestRepository
final serviceTypeRequestRepositoryProvider =
    Provider<ServiceTypeRequestRepository>((ref) {
      final client = ref.watch(apiClientProvider);
      return ServiceTypeRequestRepository(client);
    });

/// State notifier for service type requests
class ServiceTypeRequestsNotifier
    extends StateNotifier<AsyncValue<Pagination<ServiceTypeRequest>>> {
  ServiceTypeRequestsNotifier(this._repository)
    : super(const AsyncValue.loading()) {
    load();
  }

  final ServiceTypeRequestRepository _repository;

  String? _statusFilter;
  int? _vendorIdFilter;
  int _skip = 0;
  static const int _limit = 100;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(
        skip: _skip,
        limit: _limit,
        status: _statusFilter,
        vendorId: _vendorIdFilter,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByStatus(String? status) {
    _statusFilter = status;
    _skip = 0;
    load();
  }

  void filterByVendor(int? vendorId) {
    _vendorIdFilter = vendorId;
    _skip = 0;
    load();
  }

  void clearFilters() {
    _statusFilter = null;
    _vendorIdFilter = null;
    _skip = 0;
    load();
  }

  Future<void> approve(int requestId, {String? reviewNotes}) async {
    await _repository.approve(requestId: requestId, reviewNotes: reviewNotes);
    await load();
  }

  Future<void> reject(int requestId, {required String reviewNotes}) async {
    await _repository.reject(requestId: requestId, reviewNotes: reviewNotes);
    await load();
  }
}

/// Provider for service type requests state
final serviceTypeRequestsProvider =
    StateNotifierProvider<
      ServiceTypeRequestsNotifier,
      AsyncValue<Pagination<ServiceTypeRequest>>
    >((ref) {
      final repository = ref.watch(serviceTypeRequestRepositoryProvider);
      return ServiceTypeRequestsNotifier(repository);
    });
