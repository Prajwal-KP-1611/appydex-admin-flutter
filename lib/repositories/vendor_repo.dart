import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../models/vendor.dart';
import '../models/vendor_analytics.dart';
import '../models/vendor_application.dart';
import '../models/vendor_booking.dart';
import '../models/vendor_lead.dart';
import '../models/vendor_payout.dart';
import '../models/vendor_revenue.dart';
import '../models/vendor_service.dart';
import 'admin_exceptions.dart';

class VendorRepository {
  VendorRepository(this._client);

  final ApiClient _client;

  /// List vendors
  /// GET /api/v1/admin/vendors
  Future<Pagination<Vendor>> list({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? query,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (status != null && status.isNotEmpty) 'status': status,
      if (query != null && query.isNotEmpty) 'q': query,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => Vendor.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors');
      }
      rethrow;
    }
  }

  /// Get vendor by ID
  /// GET /api/v1/admin/vendors/{vendor_id}
  Future<Vendor> get(int id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$id',
      );
      return Vendor.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id');
      }
      rethrow;
    }
  }

  /// Verify or reject a vendor
  /// POST /api/v1/admin/vendors/{vendor_id}/verify?status=verified|rejected
  Future<VendorStatusChangeResult> verifyOrReject({
    required int id,
    required String status, // "verified" or "rejected"
    String? notes,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$id/verify',
        method: 'POST',
        queryParameters: {
          'status': status,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        options: idempotentOptions(),
      );
      return VendorStatusChangeResult.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/verify');
      }
      rethrow;
    }
  }

  Future<VendorStatusChangeResult> verify(int id, {String? notes}) {
    return verifyOrReject(id: id, status: 'verified', notes: notes);
  }

  Future<VendorStatusChangeResult> reject(int id, {required String reason}) {
    return verifyOrReject(id: id, status: 'rejected', notes: reason);
  }

  /// Get vendor documents (KYC, etc.) via vendor detail endpoint.
  Future<List<VendorDocument>> getDocuments(int id) async {
    final vendor = await get(id);
    return vendor.documents;
  }

  // ==================== NEW VENDOR MANAGEMENT METHODS ====================

  /// Get vendor application details with registration progress
  /// GET /api/v1/admin/vendors/{vendor_id}/application
  Future<VendorApplication> getApplication(int vendorId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/application',
      );
      return VendorApplication.fromJson(response.data ?? {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/application');
      }
      rethrow;
    }
  }

  /// List vendor services with filtering
  /// GET /api/v1/admin/vendors/{vendor_id}/services
  Future<Pagination<VendorService>> getServices(
    int vendorId, {
    String? status,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/services',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (status != null) 'status': status,
          if (category != null) 'category': category,
        },
      );
      return Pagination.fromJson(
        response.data ?? {},
        (json) => VendorService.fromJson(json),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/services');
      }
      rethrow;
    }
  }

  /// List vendor bookings with summary
  /// GET /api/v1/admin/vendors/{vendor_id}/bookings
  Future<VendorBookingsResult> getBookings(
    int vendorId, {
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String sort = 'created_at',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/bookings',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (status != null) 'status': status,
          if (fromDate != null) 'from_date': fromDate.toIso8601String(),
          if (toDate != null) 'to_date': toDate.toIso8601String(),
          'sort': sort,
        },
      );

      final data = response.data ?? {};
      final bookings = Pagination.fromJson(
        data,
        (json) => VendorBooking.fromJson(json),
      );
      final summary = VendorBookingSummary.fromJson(data['summary'] ?? {});

      return VendorBookingsResult(bookings: bookings, summary: summary);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/bookings');
      }
      rethrow;
    }
  }

  /// Get vendor revenue summary with time series
  /// GET /api/v1/admin/vendors/{vendor_id}/revenue
  Future<VendorRevenue> getRevenue(
    int vendorId, {
    DateTime? fromDate,
    DateTime? toDate,
    String groupBy = 'day',
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/revenue',
        queryParameters: {
          if (fromDate != null) 'from_date': fromDate.toIso8601String(),
          if (toDate != null) 'to_date': toDate.toIso8601String(),
          'group_by': groupBy,
        },
      );
      return VendorRevenue.fromJson(response.data ?? {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/revenue');
      }
      rethrow;
    }
  }

  /// List vendor leads with conversion tracking
  /// GET /api/v1/admin/vendors/{vendor_id}/leads
  Future<VendorLeadsResult> getLeads(
    int vendorId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/leads',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (status != null) 'status': status,
        },
      );

      final data = response.data ?? {};
      final leads = Pagination.fromJson(
        data,
        (json) => VendorLead.fromJson(json),
      );
      final summary = VendorLeadSummary.fromJson(data['summary'] ?? {});

      return VendorLeadsResult(leads: leads, summary: summary);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/leads');
      }
      rethrow;
    }
  }

  /// List vendor payouts
  /// GET /api/v1/admin/vendors/{vendor_id}/payouts
  Future<Pagination<VendorPayout>> getPayouts(
    int vendorId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/payouts',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return Pagination.fromJson(
        response.data ?? {},
        (json) => VendorPayout.fromJson(json),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/payouts');
      }
      rethrow;
    }
  }

  /// Get vendor analytics dashboard
  /// GET /api/v1/admin/vendors/{vendor_id}/analytics
  Future<VendorAnalytics> getAnalytics(
    int vendorId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/analytics',
        queryParameters: {
          if (fromDate != null) 'from_date': fromDate.toIso8601String(),
          if (toDate != null) 'to_date': toDate.toIso8601String(),
        },
      );
      return VendorAnalytics.fromJson(response.data ?? {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/analytics');
      }
      rethrow;
    }
  }

  /// List vendor documents
  /// GET /api/v1/admin/vendors/{vendor_id}/documents
  Future<List<VendorDocument>> getDocumentsList(int vendorId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/documents',
      );
      final items = (response.data?['items'] as List?) ?? [];
      return items.map((json) => VendorDocument.fromJson(json)).toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/documents');
      }
      rethrow;
    }
  }

  /// Verify or reject a document
  /// POST /api/v1/admin/vendors/{vendor_id}/documents/{document_id}/verify
  Future<void> verifyDocument(
    int vendorId,
    String documentId, {
    required bool approve,
    String? notes,
  }) async {
    try {
      await _client.requestAdmin(
        '/admin/vendors/$vendorId/documents/$documentId/verify',
        method: 'POST',
        data: {
          'status': approve ? 'verified' : 'rejected',
          if (notes != null) 'notes': notes,
        },
        options: idempotentOptions(),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing(
          'admin/vendors/:id/documents/:doc_id/verify',
        );
      }
      rethrow;
    }
  }

  // ==================== VENDOR SUSPENSION MANAGEMENT ====================

  /// Suspend vendor account
  /// POST /api/v1/admin/vendors/{vendor_id}/suspend
  ///
  /// Temporarily blocks vendor from:
  /// - Accepting new bookings
  /// - Listing services
  /// - Accessing vendor dashboard
  ///
  /// Existing bookings remain active for customer protection.
  Future<VendorSuspensionResult> suspend(
    int vendorId, {
    required String reason,
    int? durationDays,
    bool notifyVendor = true,
    String? internalNotes,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/suspend',
        method: 'POST',
        data: {
          'reason': reason,
          if (durationDays != null) 'duration_days': durationDays,
          'notify_vendor': notifyVendor,
          if (internalNotes != null && internalNotes.isNotEmpty)
            'internal_notes': internalNotes,
        },
        options: idempotentOptions(),
      );
      return VendorSuspensionResult.fromJson(response.data ?? {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/suspend');
      }
      rethrow;
    }
  }

  /// Reactivate suspended vendor account
  /// POST /api/v1/admin/vendors/{vendor_id}/reactivate
  ///
  /// Restores full vendor access and functionality.
  Future<VendorReactivationResult> reactivate(
    int vendorId, {
    String? notes,
    bool notifyVendor = true,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$vendorId/reactivate',
        method: 'POST',
        data: {
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'notify_vendor': notifyVendor,
        },
        options: idempotentOptions(),
      );
      return VendorReactivationResult.fromJson(response.data ?? {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/reactivate');
      }
      rethrow;
    }
  }
}

// Helper result classes for methods that return multiple values

class VendorBookingsResult {
  final Pagination<VendorBooking> bookings;
  final VendorBookingSummary summary;

  VendorBookingsResult({required this.bookings, required this.summary});
}

class VendorLeadsResult {
  final Pagination<VendorLead> leads;
  final VendorLeadSummary summary;

  VendorLeadsResult({required this.leads, required this.summary});
}

/// Result of vendor verification/rejection operation
class VendorStatusChangeResult {
  const VendorStatusChangeResult({
    required this.vendorId,
    required this.status,
    this.previousStatus,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
  });

  final int vendorId;
  final String status; // "verified" or "rejected"
  final String? previousStatus;
  final int? verifiedBy;
  final DateTime? verifiedAt;
  final String? notes;

  factory VendorStatusChangeResult.fromJson(Map<String, dynamic> json) {
    return VendorStatusChangeResult(
      vendorId: json['vendor_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      previousStatus: json['previous_status'] as String?,
      verifiedBy: json['verified_by'] as int?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}

/// Result of vendor suspension operation
class VendorSuspensionResult {
  const VendorSuspensionResult({
    required this.vendorId,
    required this.status,
    this.suspendedUntil,
    this.reason,
    this.suspendedBy,
    this.suspendedAt,
  });

  final int vendorId;
  final String status; // "suspended"
  final DateTime? suspendedUntil;
  final String? reason;
  final int? suspendedBy;
  final DateTime? suspendedAt;

  factory VendorSuspensionResult.fromJson(Map<String, dynamic> json) {
    return VendorSuspensionResult(
      vendorId: json['vendor_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'suspended',
      suspendedUntil: json['suspended_until'] != null
          ? DateTime.tryParse(json['suspended_until'] as String)
          : null,
      reason: json['reason'] as String?,
      suspendedBy: json['suspended_by'] as int?,
      suspendedAt: json['suspended_at'] != null
          ? DateTime.tryParse(json['suspended_at'] as String)
          : null,
    );
  }
}

/// Result of vendor reactivation operation
class VendorReactivationResult {
  const VendorReactivationResult({
    required this.vendorId,
    required this.status,
    this.reactivatedBy,
    this.reactivatedAt,
    this.notes,
  });

  final int vendorId;
  final String status; // "active" or "verified"
  final int? reactivatedBy;
  final DateTime? reactivatedAt;
  final String? notes;

  factory VendorReactivationResult.fromJson(Map<String, dynamic> json) {
    return VendorReactivationResult(
      vendorId: json['vendor_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      reactivatedBy: json['reactivated_by'] as int?,
      reactivatedAt: json['reactivated_at'] != null
          ? DateTime.tryParse(json['reactivated_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return VendorRepository(client);
});
