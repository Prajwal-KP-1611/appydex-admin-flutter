import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    int skip = 0,
    int limit = 100,
    String? status,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
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

  Future<Vendor> patch(int id, Map<String, dynamic> changes) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$id',
        method: 'PATCH',
        data: changes,
        options: idempotentOptions(),
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
  /// POST /api/v1/admin/vendors/{vendor_id}/verify
  /// Request: { "action": "approve" | "reject", "notes": "..." }
  /// Response: { "vendor_id": 1, "status": "verified", "verified_by": 10, "verified_at": "...", "notes": "..." }
  Future<VendorVerificationResult> verifyOrReject({
    required int id,
    required String action, // "approve" or "reject"
    String? notes,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/vendors/$id/verify',
        method: 'POST',
        data: {
          'action': action,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        options: idempotentOptions(),
      );
      return VendorVerificationResult.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/:id/verify');
      }
      rethrow;
    }
  }

  /// Verify/approve a vendor (legacy method for backward compatibility)
  Future<Vendor> verify(int id, {String? notes}) async {
    final result = await verifyOrReject(
      id: id,
      action: 'approve',
      notes: notes,
    );
    // Return updated vendor
    return get(result.vendorId);
  }

  /// Reject a vendor (legacy method for backward compatibility)
  Future<Vendor> reject(int id, {required String reason}) async {
    final result = await verifyOrReject(
      id: id,
      action: 'reject',
      notes: reason,
    );
    // Return updated vendor
    return get(result.vendorId);
  }

  /// Get vendor documents (KYC, etc.)
  Future<List<VendorDocument>> getDocuments(int id) async {
    try {
      final response = await _client.requestAdmin<List<dynamic>>(
        '/admin/vendors/$id/documents',
      );
      final documents = response.data ?? [];
      return documents
          .map((doc) => VendorDocument.fromJson(doc as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        // Return empty list if endpoint not found
        return [];
      }
      rethrow;
    }
  }

  /// Bulk verify multiple vendors
  Future<List<Vendor>> bulkVerify(List<int> vendorIds, {String? notes}) async {
    try {
      final response = await _client.requestAdmin<List<dynamic>>(
        '/admin/vendors/bulk_verify',
        method: 'POST',
        data: {
          'vendor_ids': vendorIds,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        options: idempotentOptions(),
      );
      final vendors = response.data ?? [];
      return vendors
          .map((v) => Vendor.fromJson(v as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/vendors/bulk_verify');
      }
      rethrow;
    }
  }
}

/// Vendor document model (for KYC, etc.)
class VendorDocument {
  const VendorDocument({
    required this.id,
    required this.vendorId,
    required this.type,
    required this.fileName,
    required this.url,
    required this.uploadedAt,
    this.status = 'pending',
  });

  final String id;
  final int vendorId;
  final String type; // 'id_proof', 'address_proof', 'business_license', etc.
  final String fileName;
  final String url; // Presigned S3 URL
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime uploadedAt;

  factory VendorDocument.fromJson(Map<String, dynamic> json) {
    return VendorDocument(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id'] as int? ?? 0,
      type: json['type'] as String? ?? 'unknown',
      fileName: json['file_name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : DateTime.now(),
    );
  }

  String get displayType {
    switch (type) {
      case 'id_proof':
        return 'ID Proof';
      case 'address_proof':
        return 'Address Proof';
      case 'business_license':
        return 'Business License';
      case 'tax_document':
        return 'Tax Document';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'id_proof':
        return Icons.badge;
      case 'address_proof':
        return Icons.location_on;
      case 'business_license':
        return Icons.business;
      case 'tax_document':
        return Icons.receipt;
      default:
        return Icons.description;
    }
  }
}

/// Result of vendor verification/rejection operation
class VendorVerificationResult {
  const VendorVerificationResult({
    required this.vendorId,
    required this.status,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
  });

  final int vendorId;
  final String status; // "verified" or "rejected"
  final int? verifiedBy;
  final DateTime? verifiedAt;
  final String? notes;

  factory VendorVerificationResult.fromJson(Map<String, dynamic> json) {
    return VendorVerificationResult(
      vendorId: json['vendor_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
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
