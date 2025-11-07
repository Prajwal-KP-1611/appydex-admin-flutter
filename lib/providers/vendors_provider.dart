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
    this.page = 1,
    this.pageSize = 20,
  });

  final String? query;
  final String? status;
  final int page;
  final int pageSize;

  VendorsFilter copyWith({
    Object? query = _sentinel,
    Object? status = _sentinel,
    int? page,
    int? pageSize,
  }) {
    return VendorsFilter(
      query: query == _sentinel ? this.query : query as String?,
      status: status == _sentinel ? this.status : status as String?,
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
    await _executeMutation(() => _repo.verify(id, notes: notes));
  }

  Future<void> bulkVerify({String? notes}) async {
    final ids = state.selected.toList();
    await _executeMutation(() async {
      for (final id in ids) {
        await _repo.verify(id, notes: notes);
      }
    }, clearSelection: true);
  }

  Future<void> rejectVendor(int id, {required String reason}) async {
    await _executeMutation(() => _repo.reject(id, reason: reason));
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
            'user_id': vendor.userId,
            'company_name': vendor.companyName,
            'slug': vendor.slug,
            'status': vendor.status,
            'contact_email': vendor.contactEmail ?? '',
            'contact_phone': vendor.contactPhone ?? '',
            'business_type': vendor.businessType ?? '',
            'created_at': vendor.createdAt.toIso8601String(),
            if (vendor.metadata.isNotEmpty) 'metadata': vendor.metadata,
          },
        )
        .toList();
    return toCsv(rows);
  }

  Future<void> _executeMutation(
    Future<void> Function() mutation, {
    bool clearSelection = false,
  }) async {
    try {
      if (state.usingMock) {
        if (clearSelection) {
          state = state.copyWith(selected: <int>{});
        }
        await load(forceMock: true);
        return;
      }

      await mutation();
      if (clearSelection) {
        state = state.copyWith(selected: <int>{});
      }
      await load();
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
