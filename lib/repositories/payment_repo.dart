import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/payment_intent.dart';
import 'admin_exceptions.dart';

/// Repository for payment management
/// Base Path: /api/v1/admin/payments
class PaymentRepository {
  PaymentRepository(this._client);

  final ApiClient _client;

  /// List payment intents
  /// GET /api/v1/admin/payments
  Future<Pagination<PaymentIntent>> list({
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

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/payments',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => PaymentIntent.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/payments');
      }
      rethrow;
    }
  }

  /// Get payment intent details
  /// GET /api/v1/admin/payments/{payment_id}
  Future<PaymentIntent> getById(String id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/payments/$id',
      );
      return PaymentIntent.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/payments/:id');
      }
      rethrow;
    }
  }

  /// Refund a payment
  /// POST /api/v1/admin/payments/{payment_id}/refund
  /// 
  /// Requires Idempotency-Key header to prevent duplicate refunds.
  /// Backend should return 200 if already refunded with same key.
  Future<PaymentIntent> refundPayment({
    required String paymentId,
    required String idempotencyKey,
    String? reason,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/payments/$paymentId/refund',
        method: 'POST',
        data: {
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );
      return PaymentIntent.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/payments/:id/refund');
      }
      if (error.response?.statusCode == 400) {
        final message = error.response?.data['detail'] as String? ?? 
                        'Invalid refund request';
        throw AdminValidationError(message);
      }
      rethrow;
    }
  }

  /// Get invoice download URL
  /// GET /api/v1/admin/payments/{payment_id}/invoice
  /// 
  /// Returns a pre-signed URL or direct PDF download.
  Future<String> getInvoiceDownloadUrl(String paymentId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/payments/$paymentId/invoice',
      );
      final downloadUrl = response.data?['download_url'] as String?;
      if (downloadUrl == null || downloadUrl.isEmpty) {
        throw Exception('Invoice URL not available');
      }
      return downloadUrl;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/payments/:id/invoice');
      }
      rethrow;
    }
  }
}

/// Provider for PaymentRepository
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PaymentRepository(client);
});

/// State notifier for payments
class PaymentsNotifier
    extends StateNotifier<AsyncValue<Pagination<PaymentIntent>>> {
  PaymentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final PaymentRepository _repository;

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
}

/// Provider for payments state
final paymentsProvider =
    StateNotifierProvider<
      PaymentsNotifier,
      AsyncValue<Pagination<PaymentIntent>>
    >((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return PaymentsNotifier(repository);
    });
