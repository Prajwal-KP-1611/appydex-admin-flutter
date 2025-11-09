import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/utils/idempotency.dart';
import 'admin_exceptions.dart';

/// Refund request model
class RefundRequest {
  const RefundRequest({
    required this.id,
    required this.bookingId,
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
    this.rejectedAt,
    this.adminNotes,
    this.refundIdRazorpay,
  });

  final int id;
  final int bookingId;
  final String paymentId;
  final int userId;
  final int amount; // Amount in smallest currency unit (e.g., paise)
  final String reason;
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? adminNotes;
  final String? refundIdRazorpay;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';

  factory RefundRequest.fromJson(Map<String, dynamic> json) {
    return RefundRequest(
      id: (json['id'] as num).toInt(),
      bookingId: (json['booking_id'] as num).toInt(),
      paymentId: json['payment_id'] as String,
      userId: (json['user_id'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
      reason: json['reason'] as String,
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      adminNotes: json['admin_notes'] as String?,
      refundIdRazorpay: json['refund_id_razorpay'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'payment_id': paymentId,
      'user_id': userId,
      'amount': amount,
      'reason': reason,
      'status': status,
      'requested_at': requestedAt.toIso8601String(),
      if (approvedAt != null) 'approved_at': approvedAt!.toIso8601String(),
      if (rejectedAt != null) 'rejected_at': rejectedAt!.toIso8601String(),
      if (adminNotes != null) 'admin_notes': adminNotes,
      if (refundIdRazorpay != null) 'refund_id_razorpay': refundIdRazorpay,
    };
  }
}

/// Repository for refund management
/// Base Path: /api/v1/admin/refunds
///
/// Handles refund request listing, approval, and rejection workflows.
class RefundRepository {
  RefundRepository(this._client);

  final ApiClient _client;

  /// List refund requests with pagination and filters
  /// GET /api/v1/admin/refunds
  ///
  /// Query Parameters:
  /// - status: Filter by status (pending, approved, rejected, completed)
  Future<List<RefundRequest>> list({String? status}) async {
    final params = <String, dynamic>{
      if (status != null && status.isNotEmpty) 'status': status,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/refunds',
        queryParameters: params,
      );

      final body = response.data ?? <String, dynamic>{};
      final refunds = body['refunds'] as List<dynamic>? ?? const [];

      return refunds
          .map((item) => RefundRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/refunds');
      }
      rethrow;
    }
  }

  /// Approve a refund request
  /// POST /api/v1/admin/refunds/{refund_id}/approve
  ///
  /// Approves the refund and initiates processing through payment gateway.
  /// Requires Idempotency-Key header to prevent duplicate approvals.
  Future<Map<String, dynamic>> approve({
    required int refundId,
    String? notes,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/refunds/$refundId/approve',
        method: 'POST',
        data: {if (notes != null && notes.isNotEmpty) 'notes': notes},
        options: idempotentOptions(),
      );

      return response.data ?? {};
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/refunds/:id/approve');
      }
      if (error.response?.statusCode == 400) {
        final message =
            error.response?.data['detail'] as String? ??
            'Invalid refund approval request';
        throw AdminValidationError(message);
      }
      rethrow;
    }
  }

  /// Reject a refund request
  /// POST /api/v1/admin/refunds/{refund_id}/reject
  ///
  /// Rejects the refund request with a reason.
  /// Requires Idempotency-Key header to prevent duplicate rejections.
  Future<Map<String, dynamic>> reject({
    required int refundId,
    required String reason,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/refunds/$refundId/reject',
        method: 'POST',
        data: {'reason': reason},
        options: idempotentOptions(),
      );

      return response.data ?? {};
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/refunds/:id/reject');
      }
      if (error.response?.statusCode == 400) {
        final message =
            error.response?.data['detail'] as String? ??
            'Invalid refund rejection request';
        throw AdminValidationError(message);
      }
      rethrow;
    }
  }
}

/// Provider for RefundRepository
final refundRepositoryProvider = Provider<RefundRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return RefundRepository(client);
});

/// State notifier for refund requests list
class RefundsNotifier extends StateNotifier<AsyncValue<List<RefundRequest>>> {
  RefundsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final RefundRepository _repository;

  String? _statusFilter;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(status: _statusFilter);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByStatus(String? status) {
    _statusFilter = status;
    load();
  }

  void clearFilters() {
    _statusFilter = null;
    load();
  }
}

/// Provider for refunds list state
final refundsProvider =
    StateNotifierProvider<RefundsNotifier, AsyncValue<List<RefundRequest>>>((
      ref,
    ) {
      final repository = ref.watch(refundRepositoryProvider);
      return RefundsNotifier(repository);
    });
