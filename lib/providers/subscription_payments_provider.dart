import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/pagination.dart';
import '../models/subscription_payment.dart';
import '../repositories/subscription_payment_repo.dart';

/// Filter state for subscription payments
class SubscriptionPaymentFilter {
  const SubscriptionPaymentFilter({
    this.page = 1,
    this.pageSize = 20,
    this.status,
    this.vendorId,
    this.startDate,
    this.endDate,
  });

  final int page;
  final int pageSize;
  final String? status;
  final int? vendorId;
  final DateTime? startDate;
  final DateTime? endDate;

  SubscriptionPaymentFilter copyWith({
    int? page,
    int? pageSize,
    String? status,
    int? vendorId,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStatus = false,
    bool clearVendorId = false,
    bool clearDates = false,
  }) {
    return SubscriptionPaymentFilter(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      status: clearStatus ? null : (status ?? this.status),
      vendorId: clearVendorId ? null : (vendorId ?? this.vendorId),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }
}

/// State for subscription payments list
class SubscriptionPaymentsState {
  const SubscriptionPaymentsState({
    required this.data,
    required this.filter,
    this.summary,
    this.missingEndpoint,
  });

  final AsyncValue<Pagination<SubscriptionPayment>> data;
  final SubscriptionPaymentFilter filter;
  final AsyncValue<SubscriptionPaymentSummary>? summary;
  final Object? missingEndpoint;

  SubscriptionPaymentsState copyWith({
    AsyncValue<Pagination<SubscriptionPayment>>? data,
    SubscriptionPaymentFilter? filter,
    AsyncValue<SubscriptionPaymentSummary>? summary,
    Object? missingEndpoint,
    bool clearMissingEndpoint = false,
  }) {
    return SubscriptionPaymentsState(
      data: data ?? this.data,
      filter: filter ?? this.filter,
      summary: summary ?? this.summary,
      missingEndpoint: clearMissingEndpoint
          ? null
          : (missingEndpoint ?? this.missingEndpoint),
    );
  }
}

/// Notifier for subscription payments
class SubscriptionPaymentsNotifier
    extends StateNotifier<SubscriptionPaymentsState> {
  SubscriptionPaymentsNotifier(this._repository)
    : super(
        const SubscriptionPaymentsState(
          data: AsyncValue.loading(),
          filter: SubscriptionPaymentFilter(),
        ),
      ) {
    load();
  }

  final SubscriptionPaymentRepository _repository;

  Future<void> load() async {
    state = state.copyWith(data: const AsyncValue.loading());

    try {
      final result = await _repository.list(
        page: state.filter.page,
        perPage: state.filter.pageSize,
        status: state.filter.status,
        vendorId: state.filter.vendorId,
        startDate: state.filter.startDate,
        endDate: state.filter.endDate,
      );

      state = state.copyWith(
        data: AsyncValue.data(result),
        clearMissingEndpoint: true,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        data: AsyncValue.error(error, stackTrace),
        missingEndpoint: error,
      );
    }
  }

  Future<void> loadSummary() async {
    state = state.copyWith(summary: const AsyncValue.loading());

    try {
      final result = await _repository.getSummary(
        startDate: state.filter.startDate,
        endDate: state.filter.endDate,
        vendorId: state.filter.vendorId,
      );

      state = state.copyWith(summary: AsyncValue.data(result));
    } catch (error, stackTrace) {
      state = state.copyWith(summary: AsyncValue.error(error, stackTrace));
    }
  }

  void updateFilter(SubscriptionPaymentFilter filter) {
    state = state.copyWith(filter: filter);
    load();
    if (filter.startDate != null || filter.endDate != null) {
      loadSummary();
    }
  }

  void setPage(int page) {
    updateFilter(state.filter.copyWith(page: page));
  }

  void setDateRange(DateTime? startDate, DateTime? endDate) {
    updateFilter(
      state.filter.copyWith(
        startDate: startDate,
        endDate: endDate,
        page: 1,
        clearDates: startDate == null && endDate == null,
      ),
    );
  }

  void setMonthYear(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    setDateRange(startDate, endDate);
  }

  void clearFilters() {
    updateFilter(const SubscriptionPaymentFilter(page: 1, pageSize: 20));
  }

  void useMock() {
    // Generate mock data for development
    final mockPayments = List.generate(
      20,
      (i) => SubscriptionPayment(
        id: 'pay_mock_${i + 1}',
        subscriptionId: i + 1,
        vendorId: (i % 5) + 1,
        vendorName: 'Mock Vendor ${(i % 5) + 1}',
        planId: (i % 3) + 1,
        planName: ['Basic', 'Pro', 'Enterprise'][i % 3],
        amountCents: [2999, 4999, 9999][i % 3],
        currency: 'usd',
        status: ['succeeded', 'failed', 'pending'][i % 3],
        paymentMethod: 'card',
        paymentMethodDetails: {'brand': 'visa', 'last4': '4242'},
        description: 'Mock payment ${i + 1}',
        createdAt: DateTime.now().subtract(Duration(days: i * 2)),
        succeededAt: i % 3 == 0
            ? DateTime.now().subtract(Duration(days: i * 2))
            : null,
      ),
    );

    state = state.copyWith(
      data: AsyncValue.data(
        Pagination<SubscriptionPayment>(
          items: mockPayments,
          total: 100,
          page: 1,
          pageSize: 20,
        ),
      ),
      clearMissingEndpoint: true,
    );
  }

  String exportCurrentCsv() {
    final payments = state.data.valueOrNull?.items ?? [];
    if (payments.isEmpty) return '';

    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      'Payment ID,Date,Vendor,Plan,Amount,Status,Payment Method,Invoice ID',
    );

    // Rows
    for (final payment in payments) {
      buffer.writeln(
        [
          payment.id,
          payment.createdAt.toIso8601String(),
          payment.vendorName ?? 'Vendor #${payment.vendorId}',
          payment.planName ?? 'Plan #${payment.planId}',
          payment.amountDisplay,
          payment.status,
          payment.cardDisplay,
          payment.invoiceId ?? '',
        ].join(','),
      );
    }

    return buffer.toString();
  }
}

/// Provider for subscription payments
final subscriptionPaymentsProvider =
    StateNotifierProvider<
      SubscriptionPaymentsNotifier,
      SubscriptionPaymentsState
    >((ref) {
      final repository = ref.watch(subscriptionPaymentRepositoryProvider);
      return SubscriptionPaymentsNotifier(repository);
    });
