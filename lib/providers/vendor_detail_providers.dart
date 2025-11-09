import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/vendor.dart';
import '../models/vendor_analytics.dart';
import '../models/vendor_application.dart';
import '../models/vendor_payout.dart';
import '../models/vendor_revenue.dart';
import '../models/vendor_service.dart';
import '../repositories/vendor_repo.dart';

/// Repository provider
final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VendorRepository(apiClient);
});

// ============================================================================
// APPLICATION PROVIDER
// ============================================================================

/// Provides vendor application details and registration progress
/// Usage: ref.watch(vendorApplicationProvider(vendorId))
final vendorApplicationProvider = FutureProvider.autoDispose
    .family<VendorApplication, int>((ref, vendorId) async {
      final repo = ref.watch(vendorRepositoryProvider);
      return await repo.getApplication(vendorId);
    });

// ============================================================================
// SERVICES PROVIDER
// ============================================================================

/// Parameters for filtering vendor services
class VendorServicesParams {
  const VendorServicesParams({
    required this.vendorId,
    this.page = 1,
    this.pageSize = 20,
    this.status,
    this.category,
  });

  final int vendorId;
  final int page;
  final int pageSize;
  final String? status;
  final String? category;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorServicesParams &&
        other.vendorId == vendorId &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.status == status &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(vendorId, page, pageSize, status, category);
  }
}

/// Provides paginated list of vendor services with optional filters
/// Usage: ref.watch(vendorServicesProvider(VendorServicesParams(vendorId: 1, status: 'active')))
final vendorServicesProvider = FutureProvider.autoDispose
    .family<Pagination<VendorService>, VendorServicesParams>((
      ref,
      params,
    ) async {
      final repo = ref.watch(vendorRepositoryProvider);
      return await repo.getServices(
        params.vendorId,
        page: params.page,
        pageSize: params.pageSize,
        status: params.status,
        category: params.category,
      );
    });

// ============================================================================
// BOOKINGS PROVIDER
// ============================================================================

/// Parameters for filtering vendor bookings
class VendorBookingsParams {
  const VendorBookingsParams({
    required this.vendorId,
    this.page = 1,
    this.pageSize = 20,
    this.status,
    this.fromDate,
    this.toDate,
    this.sort = 'created_at',
  });

  final int vendorId;
  final int page;
  final int pageSize;
  final String? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String sort;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorBookingsParams &&
        other.vendorId == vendorId &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.status == status &&
        other.fromDate == fromDate &&
        other.toDate == toDate &&
        other.sort == sort;
  }

  @override
  int get hashCode {
    return Object.hash(
      vendorId,
      page,
      pageSize,
      status,
      fromDate,
      toDate,
      sort,
    );
  }
}

/// Provides vendor bookings with summary statistics
/// Returns both paginated bookings and summary
/// Usage: ref.watch(vendorBookingsProvider(VendorBookingsParams(vendorId: 1, status: 'completed')))
final vendorBookingsProvider = FutureProvider.autoDispose
    .family<VendorBookingsResult, VendorBookingsParams>((ref, params) async {
      final repo = ref.watch(vendorRepositoryProvider);
      return await repo.getBookings(
        params.vendorId,
        page: params.page,
        pageSize: params.pageSize,
        status: params.status,
        fromDate: params.fromDate,
        toDate: params.toDate,
        sort: params.sort,
      );
    });

// ============================================================================
// LEADS PROVIDER
// ============================================================================

/// Parameters for filtering vendor leads
class VendorLeadsParams {
  const VendorLeadsParams({
    required this.vendorId,
    this.page = 1,
    this.pageSize = 20,
    this.status,
  });

  final int vendorId;
  final int page;
  final int pageSize;
  final String? status;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorLeadsParams &&
        other.vendorId == vendorId &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(vendorId, page, pageSize, status);
  }
}

/// Provides vendor leads with conversion statistics
/// Returns both paginated leads and summary
/// Usage: ref.watch(vendorLeadsProvider(VendorLeadsParams(vendorId: 1, status: 'new')))
final vendorLeadsProvider = FutureProvider.autoDispose
    .family<VendorLeadsResult, VendorLeadsParams>((ref, params) async {
      final repo = ref.watch(vendorRepositoryProvider);
      return await repo.getLeads(
        params.vendorId,
        page: params.page,
        pageSize: params.pageSize,
        status: params.status,
      );
    });

// ============================================================================
// REVENUE PROVIDER
// ============================================================================

/// Parameters for vendor revenue queries
class VendorRevenueParams {
  const VendorRevenueParams({
    required this.vendorId,
    this.fromDate,
    this.toDate,
    this.groupBy = 'day',
  });

  final int vendorId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String groupBy; // 'day', 'week', 'month'

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorRevenueParams &&
        other.vendorId == vendorId &&
        other.fromDate == fromDate &&
        other.toDate == toDate &&
        other.groupBy == groupBy;
  }

  @override
  int get hashCode {
    return Object.hash(vendorId, fromDate, toDate, groupBy);
  }
}

/// Provides vendor revenue summary with time series data for charts
/// Usage: ref.watch(vendorRevenueProvider(VendorRevenueParams(vendorId: 1, groupBy: 'month')))
final vendorRevenueProvider = FutureProvider.autoDispose
    .family<VendorRevenue, VendorRevenueParams>((ref, params) async {
      final repo = ref.watch(vendorRepositoryProvider);
      return await repo.getRevenue(
        params.vendorId,
        fromDate: params.fromDate,
        toDate: params.toDate,
        groupBy: params.groupBy,
      );
    });

// ============================================================================
// PAYOUTS PROVIDER
// ============================================================================

/// Parameters for vendor payouts
class VendorPayoutsParams {
  const VendorPayoutsParams({
    required this.vendorId,
    this.page = 1,
    this.pageSize = 20,
  });

  final int vendorId;
  final int page;
  final int pageSize;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorPayoutsParams &&
        other.vendorId == vendorId &&
        other.page == page &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode {
    return Object.hash(vendorId, page, pageSize);
  }
}

/// Provides paginated vendor payout history
/// Usage: ref.watch(vendorPayoutsProvider(VendorPayoutsParams(vendorId: 1)))
final vendorPayoutsProvider = FutureProvider.autoDispose
    .family<Pagination<VendorPayout>, VendorPayoutsParams>((ref, params) async {
      final repo = ref.watch(vendorRepositoryProvider);
      return await repo.getPayouts(
        params.vendorId,
        page: params.page,
        pageSize: params.pageSize,
      );
    });

// ============================================================================
// ANALYTICS PROVIDER
// ============================================================================

/// Parameters for vendor analytics
class VendorAnalyticsParams {
  const VendorAnalyticsParams({
    required this.vendorId,
    this.fromDate,
    this.toDate,
  });

  final int vendorId;
  final DateTime? fromDate;
  final DateTime? toDate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorAnalyticsParams &&
        other.vendorId == vendorId &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode {
    return Object.hash(vendorId, fromDate, toDate);
  }
}

/// Provides comprehensive vendor performance analytics
/// Usage: ref.watch(vendorAnalyticsProvider(VendorAnalyticsParams(vendorId: 1, fromDate: DateTime(...))))
final vendorAnalyticsProvider = FutureProvider.autoDispose
    .family<VendorAnalytics, VendorAnalyticsParams>((ref, params) async {
      final repo = ref.watch(vendorRepositoryProvider);
      return await repo.getAnalytics(
        params.vendorId,
        fromDate: params.fromDate,
        toDate: params.toDate,
      );
    });

// ============================================================================
// DOCUMENTS PROVIDER
// ============================================================================

/// Provides list of vendor documents (not paginated)
/// Usage: ref.watch(vendorDocumentsProvider(vendorId))
final vendorDocumentsProvider = FutureProvider.autoDispose
    .family<List<VendorDocument>, int>((ref, vendorId) async {
      final repo = ref.watch(vendorRepositoryProvider);
      return await repo.getDocumentsList(vendorId);
    });

// Note: VendorDocument is imported from vendor.dart, not vendor_application.dart

// ============================================================================
// DOCUMENT VERIFICATION PROVIDER
// ============================================================================

/// Provider for document verification actions
/// This is a StateNotifier to handle mutations
final vendorDocumentVerificationProvider = Provider<VendorDocumentVerification>(
  (ref) {
    final repo = ref.watch(vendorRepositoryProvider);
    return VendorDocumentVerification(repo);
  },
);

class VendorDocumentVerification {
  VendorDocumentVerification(this._repository);

  final VendorRepository _repository;

  /// Verify (approve or reject) a vendor document
  /// Usage: await ref.read(vendorDocumentVerificationProvider).verifyDocument(...)
  Future<void> verifyDocument({
    required int vendorId,
    required String documentId,
    required bool approve,
    String? notes,
  }) async {
    await _repository.verifyDocument(
      vendorId,
      documentId,
      approve: approve,
      notes: notes,
    );
  }
}
