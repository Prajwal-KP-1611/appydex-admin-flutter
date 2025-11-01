import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/export_util.dart';
import '../core/pagination.dart';
import '../models/vendor.dart';
import '../providers/mock_admin_fallback.dart';
import '../repositories/admin_exceptions.dart';
import '../repositories/vendor_repo.dart';

const _sentinel = Object();

class VendorsFilter {
  const VendorsFilter({
    this.query,
    this.status,
    this.planCode,
    this.verified,
    this.createdAfter,
    this.createdBefore,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? query;
  final String? status;
  final String? planCode;
  final bool? verified;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final int page;
  final int pageSize;

  VendorsFilter copyWith({
    Object? query = _sentinel,
    Object? status = _sentinel,
    Object? planCode = _sentinel,
    Object? verified = _sentinel,
    Object? createdAfter = _sentinel,
    Object? createdBefore = _sentinel,
    int? page,
    int? pageSize,
  }) {
    return VendorsFilter(
      query: query == _sentinel ? this.query : query as String?,
      status: status == _sentinel ? this.status : status as String?,
      planCode: planCode == _sentinel ? this.planCode : planCode as String?,
      verified: verified == _sentinel ? this.verified : verified as bool?,
      createdAfter: createdAfter == _sentinel
          ? this.createdAfter
          : createdAfter as DateTime?,
      createdBefore: createdBefore == _sentinel
          ? this.createdBefore
          : createdBefore as DateTime?,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class VendorsState {
  const VendorsState({
    required this.filter,
    required this.data,
    required this.selected,
    this.missingEndpoint,
    this.usingMock = false,
  });

  factory VendorsState.initial() => VendorsState(
    filter: const VendorsFilter(),
    data: const AsyncValue.loading(),
    selected: <int>{},
  );

  final VendorsFilter filter;
  final AsyncValue<Pagination<Vendor>> data;
  final Set<int> selected;
  final AdminEndpointMissing? missingEndpoint;
  final bool usingMock;

  VendorsState copyWith({
    VendorsFilter? filter,
    AsyncValue<Pagination<Vendor>>? data,
    Set<int>? selected,
    AdminEndpointMissing? missingEndpoint,
    bool clearMissing = false,
    bool? usingMock,
  }) {
    return VendorsState(
      filter: filter ?? this.filter,
      data: data ?? this.data,
      selected: selected ?? this.selected,
      missingEndpoint: clearMissing
          ? null
          : (missingEndpoint ?? this.missingEndpoint),
      usingMock: usingMock ?? this.usingMock,
    );
  }
}

class VendorsNotifier extends StateNotifier<VendorsState> {
  VendorsNotifier(
    Ref ref, {
    VendorRepository? repository,
    MockAdminFallback? fallback,
  }) : _repo = repository ?? ref.read(vendorRepositoryProvider),
       _mock = fallback ?? ref.read(mockAdminFallbackProvider),
       super(VendorsState.initial()) {
    load();
  }

  final VendorRepository _repo;
  final MockAdminFallback _mock;

  Future<void> load({VendorsFilter? override, bool forceMock = false}) async {
    final filter = override ?? state.filter;
    state = state.copyWith(filter: filter, data: const AsyncValue.loading());
    try {
      final result = forceMock || state.usingMock
          ? _mock.vendors(page: filter.page, pageSize: filter.pageSize)
          : await _repo.list(
              query: filter.query,
              status: filter.status,
              planCode: filter.planCode,
              verified: filter.verified,
              createdAfter: filter.createdAfter,
              createdBefore: filter.createdBefore,
              page: filter.page,
              pageSize: filter.pageSize,
            );

      state = state.copyWith(
        data: AsyncValue.data(result),
        selected: <int>{},
        clearMissing: true,
        usingMock: forceMock || state.usingMock,
      );
    } on AdminEndpointMissing catch (missing) {
      final fallback = _mock.vendors(
        page: filter.page,
        pageSize: filter.pageSize,
      );
      state = state.copyWith(
        data: AsyncValue.data(fallback),
        missingEndpoint: missing,
        usingMock: true,
        selected: <int>{},
      );
    } catch (error, stackTrace) {
      state = state.copyWith(data: AsyncValue.error(error, stackTrace));
    }
  }

  void updateFilter(VendorsFilter filter) {
    load(override: filter.copyWith(page: 1));
  }

  void setPage(int page) {
    load(override: state.filter.copyWith(page: page));
  }

  void toggleSelection(int id) {
    final next = Set<int>.from(state.selected);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selected: next);
  }

  void clearSelection() {
    state = state.copyWith(selected: <int>{});
  }

  void selectAll(Iterable<Vendor> vendors) {
    state = state.copyWith(selected: vendors.map((e) => e.id).toSet());
  }

  Future<void> verifyVendor(int id, {String? notes}) async {
    await _mutateVendor(id, {
      'is_verified': true,
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> toggleActive(int id, bool isActive) async {
    await _mutateVendor(id, {'is_active': isActive});
  }

  Future<void> bulkVerify({String? notes}) async {
    final ids = state.selected.toList();
    for (final id in ids) {
      await _mutateVendor(id, {
        'is_verified': true,
        if (notes != null) 'notes': notes,
      });
    }
    clearSelection();
  }

  Future<void> bulkDeactivate() async {
    final ids = state.selected.toList();
    for (final id in ids) {
      await _mutateVendor(id, {'is_active': false});
    }
    clearSelection();
  }

  Future<void> useMockData() async {
    await load(forceMock: true);
  }

  String exportCurrentCsv() {
    final data = state.data.value?.items ?? const <Vendor>[];
    final rows = data
        .map(
          (vendor) => {
            'id': vendor.id,
            'name': vendor.name,
            'owner_email': vendor.ownerEmail,
            'phone': vendor.phone ?? '',
            'plan_code': vendor.planCode ?? '',
            'is_active': vendor.isActive,
            'is_verified': vendor.isVerified,
            'onboarding_score': vendor.onboardingScore,
            'created_at': vendor.createdAt.toIso8601String(),
          },
        )
        .toList();
    return toCsv(rows);
  }

  Future<void> _mutateVendor(int id, Map<String, dynamic> changes) async {
    try {
      final updated = state.usingMock
          ? _mock
                .vendors(
                  page: state.filter.page,
                  pageSize: state.filter.pageSize,
                )
                .items
                .firstWhere((element) => element.id == id)
                .copyWith(
                  isVerified: changes['is_verified'] as bool? ?? false,
                  isActive: changes['is_active'] as bool? ?? true,
                  notes: changes['notes'] as String?,
                )
          : await _repo.patch(id, changes);

      final current = state.data.valueOrNull;
      if (current == null) return;
      final updatedItems = current.items
          .map((vendor) => vendor.id == id ? updated : vendor)
          .toList();
      state = state.copyWith(
        data: AsyncValue.data(
          Pagination(
            items: updatedItems,
            total: current.total,
            page: current.page,
            pageSize: current.pageSize,
          ),
        ),
      );
    } on AdminEndpointMissing catch (missing) {
      state = state.copyWith(missingEndpoint: missing, usingMock: true);
      await load(forceMock: true);
    } catch (error, stackTrace) {
      state = state.copyWith(data: AsyncValue.error(error, stackTrace));
    }
  }
}

final vendorsProvider = StateNotifierProvider<VendorsNotifier, VendorsState>((
  ref,
) {
  return VendorsNotifier(ref);
});
