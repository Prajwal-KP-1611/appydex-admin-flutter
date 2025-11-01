import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/export_util.dart';
import '../core/pagination.dart';
import '../models/subscription.dart';
import '../providers/mock_admin_fallback.dart';
import '../repositories/admin_exceptions.dart';
import '../repositories/subscription_repo.dart';

const _subSentinel = Object();

class SubscriptionsFilter {
  const SubscriptionsFilter({
    this.vendorId,
    this.planCode,
    this.status,
    this.page = 1,
    this.pageSize = 20,
  });

  final int? vendorId;
  final String? planCode;
  final String? status;
  final int page;
  final int pageSize;

  SubscriptionsFilter copyWith({
    Object? vendorId = _subSentinel,
    Object? planCode = _subSentinel,
    Object? status = _subSentinel,
    int? page,
    int? pageSize,
  }) {
    return SubscriptionsFilter(
      vendorId: vendorId == _subSentinel ? this.vendorId : vendorId as int?,
      planCode: planCode == _subSentinel ? this.planCode : planCode as String?,
      status: status == _subSentinel ? this.status : status as String?,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class SubscriptionsState {
  const SubscriptionsState({
    required this.filter,
    required this.data,
    this.missingEndpoint,
    this.usingMock = false,
  });

  factory SubscriptionsState.initial() => SubscriptionsState(
    filter: const SubscriptionsFilter(),
    data: const AsyncValue.loading(),
  );

  final SubscriptionsFilter filter;
  final AsyncValue<Pagination<Subscription>> data;
  final AdminEndpointMissing? missingEndpoint;
  final bool usingMock;

  SubscriptionsState copyWith({
    SubscriptionsFilter? filter,
    AsyncValue<Pagination<Subscription>>? data,
    AdminEndpointMissing? missingEndpoint,
    bool clearMissing = false,
    bool? usingMock,
  }) {
    return SubscriptionsState(
      filter: filter ?? this.filter,
      data: data ?? this.data,
      missingEndpoint: clearMissing
          ? null
          : (missingEndpoint ?? this.missingEndpoint),
      usingMock: usingMock ?? this.usingMock,
    );
  }
}

class SubscriptionsNotifier extends StateNotifier<SubscriptionsState> {
  SubscriptionsNotifier(
    Ref ref, {
    SubscriptionRepository? repository,
    MockAdminFallback? fallback,
  }) : _repo = repository ?? ref.read(subscriptionRepositoryProvider),
       _mock = fallback ?? ref.read(mockAdminFallbackProvider),
       super(SubscriptionsState.initial()) {
    load();
  }

  final SubscriptionRepository _repo;
  final MockAdminFallback _mock;

  Future<void> load({
    SubscriptionsFilter? override,
    bool forceMock = false,
  }) async {
    final filter = override ?? state.filter;
    state = state.copyWith(filter: filter, data: const AsyncValue.loading());
    try {
      final result = forceMock || state.usingMock
          ? _mock.subscriptions(page: filter.page, pageSize: filter.pageSize)
          : await _repo.list(
              vendorId: filter.vendorId,
              planCode: filter.planCode,
              status: filter.status,
              page: filter.page,
              pageSize: filter.pageSize,
            );
      state = state.copyWith(
        data: AsyncValue.data(result),
        usingMock: forceMock || state.usingMock,
        clearMissing: true,
      );
    } on AdminEndpointMissing catch (missing) {
      final fallback = _mock.subscriptions(
        page: filter.page,
        pageSize: filter.pageSize,
      );
      state = state.copyWith(
        data: AsyncValue.data(fallback),
        usingMock: true,
        missingEndpoint: missing,
      );
    } catch (error, stack) {
      state = state.copyWith(data: AsyncValue.error(error, stack));
    }
  }

  void updateFilter(SubscriptionsFilter filter) {
    load(override: filter.copyWith(page: 1));
  }

  void setPage(int page) {
    load(override: state.filter.copyWith(page: page));
  }

  Future<void> activate(int subscriptionId, {required int paidMonths}) async {
    try {
      if (state.usingMock) {
        await load(forceMock: true);
        return;
      }
      await _repo.activate(
        subscriptionId: subscriptionId,
        paidMonths: paidMonths,
      );
      await load();
    } on AdminEndpointMissing catch (missing) {
      state = state.copyWith(missingEndpoint: missing, usingMock: true);
      await load(forceMock: true);
    } catch (error, stack) {
      state = state.copyWith(data: AsyncValue.error(error, stack));
    }
  }

  void useMock() => load(forceMock: true);

  String exportCurrentCsv() {
    final data = state.data.value?.items ?? const <Subscription>[];
    final rows = data
        .map(
          (subscription) => {
            'id': subscription.id,
            'vendor_id': subscription.vendorId,
            'plan_code': subscription.planCode,
            'status': subscription.status,
            'start_at': subscription.startAt?.toIso8601String() ?? '',
            'end_at': subscription.endAt?.toIso8601String() ?? '',
            'paid_months': subscription.paidMonths,
          },
        )
        .toList();
    return toCsv(rows);
  }
}

final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, SubscriptionsState>((ref) {
      return SubscriptionsNotifier(ref);
    });
