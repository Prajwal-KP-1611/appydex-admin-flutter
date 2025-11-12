import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/subscription_payment.dart';
import 'admin_exceptions.dart';

/// Repository for subscription payment management
/// Base Path: /api/v1/admin/subscriptions/payments
class SubscriptionPaymentRepository {
  SubscriptionPaymentRepository(this._client);

  final ApiClient _client;

  /// List subscription payments with filtering and pagination
  /// GET /api/v1/admin/subscriptions/payments
  Future<Pagination<SubscriptionPayment>> list({
    int page = 1,
    int perPage = 20,
    String? status,
    int? vendorId,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    String? sortOrder,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (status != null && status.isNotEmpty) 'status': status,
      if (vendorId != null) 'vendor_id': vendorId,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (sortBy != null) 'sort_by': sortBy,
      if (sortOrder != null) 'sort_order': sortOrder,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/subscriptions/payments',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};

      // Backend returns: { payments: [...], pagination: {...} }
      final payments =
          (body['payments'] as List?)
              ?.map(
                (e) => SubscriptionPayment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [];

      final paginationData = body['pagination'] as Map<String, dynamic>? ?? {};

      return Pagination<SubscriptionPayment>(
        items: payments,
        total: paginationData['total_items'] as int? ?? 0,
        page: paginationData['page'] as int? ?? page,
        pageSize: paginationData['per_page'] as int? ?? perPage,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/subscriptions/payments');
      }
      rethrow;
    }
  }

  /// Get subscription payment details
  /// GET /api/v1/admin/subscriptions/payments/{payment_id}
  Future<SubscriptionPayment> getById(String paymentId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/subscriptions/payments/$paymentId',
      );
      return SubscriptionPayment.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/subscriptions/payments/:id');
      }
      rethrow;
    }
  }

  /// Get payment summary statistics
  /// GET /api/v1/admin/subscriptions/payments/summary
  Future<SubscriptionPaymentSummary> getSummary({
    DateTime? startDate,
    DateTime? endDate,
    int? vendorId,
  }) async {
    final params = <String, dynamic>{
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (vendorId != null) 'vendor_id': vendorId,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/subscriptions/payments/summary',
        queryParameters: params,
      );
      // Backend returns: { summary: {...} }
      final summaryData =
          response.data?['summary'] as Map<String, dynamic>? ??
          response.data ??
          const {};
      return SubscriptionPaymentSummary.fromJson(summaryData);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/subscriptions/payments/summary');
      }
      rethrow;
    }
  }

  /// Get invoice download URL
  /// GET /api/v1/admin/subscriptions/payments/{payment_id}/invoice
  ///
  /// Backend returns 302 redirect to invoice URL
  Future<String> getInvoiceUrl(String paymentId) async {
    try {
      final response = await _client.requestAdmin(
        '/admin/subscriptions/payments/$paymentId/invoice',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Handle 302 redirect
      if (response.statusCode == 302 || response.statusCode == 301) {
        final location = response.headers.value('location');
        if (location != null && location.isNotEmpty) {
          return location;
        }
      }

      // Fallback: try to get invoice_url from response body
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final invoiceUrl = data['invoice_url'] as String?;
        if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
          return invoiceUrl;
        }
      }

      throw Exception('Invoice URL not available');
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/subscriptions/payments/:id/invoice');
      }
      rethrow;
    }
  }
}

final subscriptionPaymentRepositoryProvider =
    Provider<SubscriptionPaymentRepository>((ref) {
      final client = ref.watch(apiClientProvider);
      return SubscriptionPaymentRepository(client);
    });
