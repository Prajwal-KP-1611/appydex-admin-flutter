import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../core/utils/idempotency.dart';
import '../models/invoice.dart';
import 'admin_exceptions.dart';

/// Repository for invoice management
/// Base Path: /api/v1/admin/invoices
///
/// Admins have full oversight of platform invoices, including search,
/// filtering, PDF downloads, resend via email, and statistics.
class InvoiceRepository {
  InvoiceRepository(this._client);

  final ApiClient _client;

  /// List invoices with pagination and filters
  /// GET /api/v1/admin/invoices
  ///
  /// Query Parameters:
  /// - page: Page number (1-indexed)
  /// - page_size: Records per page
  /// - actor_type: Filter by type (subscription, booking, etc.)
  /// - actor_id: Filter by specific entity ID
  /// - search: Search by invoice number (partial matches)
  Future<Pagination<Invoice>> list({
    int page = 1,
    int pageSize = 50,
    String? actorType,
    int? actorId,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (actorType != null && actorType.isNotEmpty) 'actor_type': actorType,
      if (actorId != null) 'actor_id': actorId,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/invoices',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => Invoice.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/invoices');
      }
      rethrow;
    }
  }

  /// Get invoice details by ID
  /// GET /api/v1/admin/invoices/{invoice_id}
  Future<Invoice> getById(int id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/invoices/$id',
      );
      return Invoice.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/invoices/:id');
      }
      rethrow;
    }
  }

  /// Download invoice PDF
  /// GET /api/v1/admin/invoices/{invoice_id}/download
  ///
  /// Returns: Raw PDF bytes that can be saved or displayed
  /// Content-Type: application/pdf
  Future<List<int>> downloadPdf(int id) async {
    try {
      final response = await _client.requestAdmin<List<int>>(
        '/admin/invoices/$id/download',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );
      return response.data ?? [];
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/invoices/:id/download');
      }
      rethrow;
    }
  }

  /// Resend invoice email to vendor
  /// POST /api/v1/admin/invoices/{invoice_id}/resend-email
  ///
  /// Request Body (optional):
  /// - email: Custom email address (defaults to vendor email if not provided)
  ///
  /// Response: { "message": "...", "invoice_id": 101, "email": "..." }
  Future<InvoiceEmailResult> resendEmail({
    required int invoiceId,
    String? email,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/invoices/$invoiceId/resend-email',
        method: 'POST',
        data: InvoiceEmailRequest(email: email).toJson(),
        options: idempotentOptions(),
      );
      return InvoiceEmailResult.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/invoices/:id/resend-email');
      }
      rethrow;
    }
  }

  /// Get invoice statistics summary
  /// GET /api/v1/admin/invoices/stats/summary
  ///
  /// Returns aggregate statistics:
  /// - Total invoices count
  /// - Total revenue (gross, tax, net)
  /// - Breakdown by actor type (subscription, booking, etc.)
  Future<InvoiceStats> getStatsSummary() async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/invoices/stats/summary',
      );
      return InvoiceStats.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/invoices/stats/summary');
      }
      rethrow;
    }
  }
}

/// Provider for InvoiceRepository
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return InvoiceRepository(client);
});

/// State notifier for invoices list
class InvoicesNotifier extends StateNotifier<AsyncValue<Pagination<Invoice>>> {
  InvoicesNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final InvoiceRepository _repository;

  String? _actorTypeFilter;
  int? _actorIdFilter;
  String? _searchQuery;
  int _currentPage = 1;
  static const int _pageSize = 50;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(
        page: _currentPage,
        pageSize: _pageSize,
        actorType: _actorTypeFilter,
        actorId: _actorIdFilter,
        search: _searchQuery,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByActorType(String? actorType) {
    _actorTypeFilter = actorType;
    _currentPage = 1;
    load();
  }

  void filterByActorId(int? actorId) {
    _actorIdFilter = actorId;
    _currentPage = 1;
    load();
  }

  void search(String? query) {
    _searchQuery = query;
    _currentPage = 1;
    load();
  }

  void clearFilters() {
    _actorTypeFilter = null;
    _actorIdFilter = null;
    _searchQuery = null;
    _currentPage = 1;
    load();
  }

  void setPage(int page) {
    _currentPage = page;
    load();
  }

  Future<void> resendEmail({required int invoiceId, String? email}) async {
    await _repository.resendEmail(invoiceId: invoiceId, email: email);
    // No need to reload list after sending email
  }

  Future<List<int>> downloadPdf(int invoiceId) async {
    return _repository.downloadPdf(invoiceId);
  }
}

/// Provider for invoices state
final invoicesProvider =
    StateNotifierProvider<InvoicesNotifier, AsyncValue<Pagination<Invoice>>>((
      ref,
    ) {
      final repository = ref.watch(invoiceRepositoryProvider);
      return InvoicesNotifier(repository);
    });

/// Provider for invoice statistics
final invoiceStatsProvider = FutureProvider<InvoiceStats>((ref) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getStatsSummary();
});
