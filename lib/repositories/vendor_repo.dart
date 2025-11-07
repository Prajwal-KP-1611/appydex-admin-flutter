import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../models/vendor.dart';
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

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return VendorRepository(client);
});
