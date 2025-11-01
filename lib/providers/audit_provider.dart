import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/export_util.dart';
import '../core/pagination.dart';
import '../models/audit_event.dart';
import '../providers/mock_admin_fallback.dart';
import '../repositories/admin_exceptions.dart';
import '../repositories/audit_repo.dart';

const _auditSentinel = Object();

class AuditFilter {
  const AuditFilter({
    this.action,
    this.adminIdentifier,
    this.subjectType,
    this.subjectId,
    this.from,
    this.to,
    this.page = 1,
    this.pageSize = 50,
  });

  final String? action;
  final String? adminIdentifier;
  final String? subjectType;
  final String? subjectId;
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int pageSize;

  AuditFilter copyWith({
    Object? action = _auditSentinel,
    Object? adminIdentifier = _auditSentinel,
    Object? subjectType = _auditSentinel,
    Object? subjectId = _auditSentinel,
    Object? from = _auditSentinel,
    Object? to = _auditSentinel,
    int? page,
    int? pageSize,
  }) {
    return AuditFilter(
      action: action == _auditSentinel ? this.action : action as String?,
      adminIdentifier: adminIdentifier == _auditSentinel
          ? this.adminIdentifier
          : adminIdentifier as String?,
      subjectType: subjectType == _auditSentinel
          ? this.subjectType
          : subjectType as String?,
      subjectId: subjectId == _auditSentinel
          ? this.subjectId
          : subjectId as String?,
      from: from == _auditSentinel ? this.from : from as DateTime?,
      to: to == _auditSentinel ? this.to : to as DateTime?,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class AuditState {
  const AuditState({
    required this.filter,
    required this.data,
    this.usingMock = false,
    this.missingEndpoint,
  });

  factory AuditState.initial() =>
      AuditState(filter: const AuditFilter(), data: const AsyncValue.loading());

  final AuditFilter filter;
  final AsyncValue<Pagination<AuditEvent>> data;
  final bool usingMock;
  final AdminEndpointMissing? missingEndpoint;

  AuditState copyWith({
    AuditFilter? filter,
    AsyncValue<Pagination<AuditEvent>>? data,
    bool? usingMock,
    AdminEndpointMissing? missingEndpoint,
    bool clearMissing = false,
  }) {
    return AuditState(
      filter: filter ?? this.filter,
      data: data ?? this.data,
      usingMock: usingMock ?? this.usingMock,
      missingEndpoint: clearMissing
          ? null
          : (missingEndpoint ?? this.missingEndpoint),
    );
  }
}

class AuditNotifier extends StateNotifier<AuditState> {
  AuditNotifier(
    Ref ref, {
    AuditRepository? repository,
    MockAdminFallback? fallback,
  }) : _repo = repository ?? ref.read(auditRepositoryProvider),
       _mock = fallback ?? ref.read(mockAdminFallbackProvider),
       super(AuditState.initial()) {
    load();
  }

  final AuditRepository _repo;
  final MockAdminFallback _mock;

  Future<void> load({AuditFilter? override, bool forceMock = false}) async {
    final filter = override ?? state.filter;
    state = state.copyWith(filter: filter, data: const AsyncValue.loading());
    try {
      final result = forceMock || state.usingMock
          ? _mock.auditLog(page: filter.page, pageSize: filter.pageSize)
          : await _repo.list(
              action: filter.action,
              adminIdentifier: filter.adminIdentifier,
              subjectType: filter.subjectType,
              subjectId: filter.subjectId,
              from: filter.from,
              to: filter.to,
              page: filter.page,
              pageSize: filter.pageSize,
            );
      state = state.copyWith(
        data: AsyncValue.data(result),
        usingMock: forceMock || state.usingMock,
        clearMissing: true,
      );
    } on AdminEndpointMissing catch (missing) {
      final fallback = _mock.auditLog(
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

  void updateFilter(AuditFilter filter) {
    load(override: filter.copyWith(page: 1));
  }

  void setPage(int page) {
    load(override: state.filter.copyWith(page: page));
  }

  void useMock() => load(forceMock: true);

  String exportCsv() {
    final data = state.data.value?.items ?? const <AuditEvent>[];
    final rows = data
        .map(
          (event) => {
            'id': event.id,
            'admin_identifier': event.adminIdentifier,
            'action': event.action,
            'subject_type': event.subjectType,
            'subject_id': event.subjectId,
            'created_at': event.createdAt.toIso8601String(),
            'payload': event.payload?.toString() ?? '',
          },
        )
        .toList();
    return toCsv(rows);
  }
}

final auditProvider = StateNotifierProvider<AuditNotifier, AuditState>((ref) {
  return AuditNotifier(ref);
});
