import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dispute.dart';
import '../../models/dispute_message.dart';
import '../../repositories/end_users_repo.dart';

/// Provider for user disputes with pagination and filters
final userDisputesProvider = StateNotifierProvider.autoDispose
    .family<UserDisputesNotifier, AsyncValue<UserDisputesState>, int>((
      ref,
      userId,
    ) {
      final repository = ref.watch(endUsersRepositoryProvider);
      return UserDisputesNotifier(repository: repository, userId: userId);
    });

class UserDisputesState {
  final List<Dispute> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final DisputeSummary summary;

  const UserDisputesState({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.summary,
  });
}

class UserDisputesNotifier
    extends StateNotifier<AsyncValue<UserDisputesState>> {
  UserDisputesNotifier({
    required EndUsersRepository repository,
    required int userId,
  }) : _repository = repository,
       _userId = userId,
       super(const AsyncValue.loading()) {
    loadDisputes();
  }

  final EndUsersRepository _repository;
  final int _userId;
  int _currentPage = 1;
  int _pageSize = 20;
  String? _status;
  String? _type;
  String? _priority;

  Future<void> loadDisputes({
    int? page,
    int? pageSize,
    String? status,
    String? type,
    String? priority,
  }) async {
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;
    if (status != null) _status = status;
    if (type != null) _type = type;
    if (priority != null) _priority = priority;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.getDisputes(
        _userId,
        page: _currentPage,
        pageSize: _pageSize,
        status: _status,
        type: _type,
        priority: _priority,
      );

      return UserDisputesState(
        items: result['items'] as List<Dispute>,
        total: result['total'] as int,
        page: result['page'] as int,
        pageSize: result['page_size'] as int,
        totalPages: result['total_pages'] as int,
        summary: result['summary'] as DisputeSummary,
      );
    });
  }

  void nextPage() {
    final currentData = state.value;
    if (currentData != null && _currentPage < currentData.totalPages) {
      loadDisputes(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadDisputes(page: _currentPage - 1);
    }
  }

  void clearFilters() {
    _status = null;
    _type = null;
    _priority = null;
    loadDisputes(page: 1);
  }

  /// Refresh disputes after an action
  Future<void> refresh() async {
    await loadDisputes(page: _currentPage);
  }
}

/// Provider for single dispute detail
final disputeDetailProvider = StateNotifierProvider.autoDispose
    .family<DisputeDetailNotifier, AsyncValue<Dispute>, int>((ref, disputeId) {
      final repository = ref.watch(endUsersRepositoryProvider);
      return DisputeDetailNotifier(
        repository: repository,
        disputeId: disputeId,
      );
    });

class DisputeDetailNotifier extends StateNotifier<AsyncValue<Dispute>> {
  DisputeDetailNotifier({
    required EndUsersRepository repository,
    required int disputeId,
  }) : _repository = repository,
       _disputeId = disputeId,
       super(const AsyncValue.loading()) {
    loadDispute();
  }

  final EndUsersRepository _repository;
  final int _disputeId;

  Future<void> loadDispute() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getDisputeDetail(_disputeId);
    });
  }

  /// Refresh dispute after an action
  Future<void> refresh() async {
    await loadDispute();
  }
}

/// Provider for dispute actions (update, assign, add message)
final disputeActionsProvider = Provider.autoDispose.family<DisputeActions, int>(
  (ref, disputeId) {
    final repository = ref.watch(endUsersRepositoryProvider);
    return DisputeActions(
      repository: repository,
      disputeId: disputeId,
      ref: ref,
    );
  },
);

class DisputeActions {
  DisputeActions({
    required EndUsersRepository repository,
    required int disputeId,
    required AutoDisposeProviderRef ref,
  }) : _repository = repository,
       _disputeId = disputeId,
       _ref = ref;

  final EndUsersRepository _repository;
  final int _disputeId;
  final AutoDisposeProviderRef _ref;

  /// Update dispute status and resolution
  Future<Dispute> update({
    String? status,
    String? resolutionType,
    int? refundAmount,
    String? adminNotes,
    String? resolutionDetails,
    bool? notifyUser,
    bool? notifyVendor,
    String? idempotencyKey,
  }) async {
    final dispute = await _repository.updateDispute(
      _disputeId,
      status: status,
      resolutionType: resolutionType,
      refundAmount: refundAmount,
      adminNotes: adminNotes,
      resolutionDetails: resolutionDetails,
      notifyUser: notifyUser,
      notifyVendor: notifyVendor,
      idempotencyKey: idempotencyKey,
    );

    // Refresh dispute detail
    _ref.invalidate(disputeDetailProvider(_disputeId));

    return dispute;
  }

  /// Add message to dispute thread
  Future<DisputeMessage> addMessage({
    required String message,
    bool isInternal = false,
    List<String>? attachments,
    String? idempotencyKey,
  }) async {
    final disputeMessage = await _repository.addDisputeMessage(
      _disputeId,
      message: message,
      isInternal: isInternal,
      attachments: attachments,
      idempotencyKey: idempotencyKey,
    );

    // Refresh dispute detail to show new message
    _ref.invalidate(disputeDetailProvider(_disputeId));

    return disputeMessage;
  }

  /// Assign dispute to admin user
  Future<void> assign({
    required int adminUserId,
    String? notes,
    String? idempotencyKey,
  }) async {
    await _repository.assignDispute(
      _disputeId,
      adminUserId: adminUserId,
      notes: notes,
      idempotencyKey: idempotencyKey,
    );

    // Refresh dispute detail to show assignment
    _ref.invalidate(disputeDetailProvider(_disputeId));
  }
}

/// Provider for global disputes dashboard with filters
final globalDisputesProvider =
    StateNotifierProvider.autoDispose<
      GlobalDisputesNotifier,
      AsyncValue<GlobalDisputesState>
    >((ref) {
      final repository = ref.watch(endUsersRepositoryProvider);
      return GlobalDisputesNotifier(repository: repository);
    });

class GlobalDisputesState {
  final List<Dispute> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const GlobalDisputesState({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}

class GlobalDisputesNotifier
    extends StateNotifier<AsyncValue<GlobalDisputesState>> {
  GlobalDisputesNotifier({required EndUsersRepository repository})
    : _repository = repository,
      super(const AsyncValue.loading()) {
    loadDisputes();
  }

  final EndUsersRepository _repository;
  int _currentPage = 1;
  int _pageSize = 20;
  String? _status;
  String? _type;
  String? _priority;
  int? _assignedTo;
  bool? _unassigned;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _sort;

  Future<void> loadDisputes({
    int? page,
    int? pageSize,
    String? status,
    String? type,
    String? priority,
    int? assignedTo,
    bool? unassigned,
    DateTime? fromDate,
    DateTime? toDate,
    String? sort,
  }) async {
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;
    if (status != null) _status = status;
    if (type != null) _type = type;
    if (priority != null) _priority = priority;
    if (assignedTo != null) _assignedTo = assignedTo;
    if (unassigned != null) _unassigned = unassigned;
    if (fromDate != null) _fromDate = fromDate;
    if (toDate != null) _toDate = toDate;
    if (sort != null) _sort = sort;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.getAllDisputes(
        page: _currentPage,
        pageSize: _pageSize,
        status: _status,
        type: _type,
        priority: _priority,
        assignedTo: _assignedTo,
        unassigned: _unassigned,
        fromDate: _fromDate,
        toDate: _toDate,
        sort: _sort,
      );

      return GlobalDisputesState(
        items: result['items'] as List<Dispute>,
        total: result['total'] as int,
        page: result['page'] as int,
        pageSize: result['page_size'] as int,
        totalPages: result['total_pages'] as int,
      );
    });
  }

  void nextPage() {
    final currentData = state.value;
    if (currentData != null && _currentPage < currentData.totalPages) {
      loadDisputes(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadDisputes(page: _currentPage - 1);
    }
  }

  void clearFilters() {
    _status = null;
    _type = null;
    _priority = null;
    _assignedTo = null;
    _unassigned = null;
    _fromDate = null;
    _toDate = null;
    _sort = null;
    loadDisputes(page: 1);
  }

  /// Show only unassigned disputes
  void showUnassigned() {
    _unassigned = true;
    _assignedTo = null;
    loadDisputes(page: 1);
  }

  /// Show disputes assigned to specific admin
  void showAssignedTo(int adminUserId) {
    _assignedTo = adminUserId;
    _unassigned = false;
    loadDisputes(page: 1);
  }

  /// Filter by priority
  void filterByPriority(String priority) {
    _priority = priority;
    loadDisputes(page: 1);
  }

  /// Filter by status
  void filterByStatus(String status) {
    _status = status;
    loadDisputes(page: 1);
  }

  /// Sort disputes (created_at, priority, deadline)
  void sortBy(String sortField) {
    _sort = sortField;
    loadDisputes(page: 1);
  }

  /// Refresh disputes after an action
  Future<void> refresh() async {
    await loadDisputes(page: _currentPage);
  }
}
