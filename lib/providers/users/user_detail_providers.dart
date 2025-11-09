import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/pagination.dart';
import '../../models/end_user_enhanced.dart';
import '../../models/user_booking.dart';
import '../../models/user_payment.dart';
import '../../models/user_review.dart';
import '../../models/user_activity.dart';
import '../../models/user_session.dart';
import '../../repositories/end_users_repo.dart';

/// Provider for fetching enhanced user profile
final userDetailProvider = FutureProvider.autoDispose
    .family<EndUserEnhanced, int>((ref, userId) async {
      final repository = ref.watch(endUsersRepositoryProvider);
      return repository.getUser(userId);
    });

/// Provider for user bookings with pagination
final userBookingsProvider = StateNotifierProvider.autoDispose
    .family<UserBookingsNotifier, AsyncValue<Pagination<UserBooking>>, int>((
      ref,
      userId,
    ) {
      final repository = ref.watch(endUsersRepositoryProvider);
      return UserBookingsNotifier(repository: repository, userId: userId);
    });

class UserBookingsNotifier
    extends StateNotifier<AsyncValue<Pagination<UserBooking>>> {
  UserBookingsNotifier({
    required EndUsersRepository repository,
    required int userId,
  }) : _repository = repository,
       _userId = userId,
       super(const AsyncValue.loading()) {
    loadBookings();
  }

  final EndUsersRepository _repository;
  final int _userId;
  int _currentPage = 1;
  int _pageSize = 20;
  String? _status;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _sort;
  String? _order;

  Future<void> loadBookings({
    int? page,
    int? pageSize,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? sort,
    String? order,
  }) async {
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;
    if (status != null) _status = status;
    if (fromDate != null) _fromDate = fromDate;
    if (toDate != null) _toDate = toDate;
    if (sort != null) _sort = sort;
    if (order != null) _order = order;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getBookings(
        _userId,
        page: _currentPage,
        pageSize: _pageSize,
        status: _status,
        fromDate: _fromDate,
        toDate: _toDate,
        sort: _sort,
        order: _order,
      );
    });
  }

  void nextPage() {
    final currentData = state.value;
    if (currentData != null && _currentPage < currentData.totalPages) {
      loadBookings(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadBookings(page: _currentPage - 1);
    }
  }

  void clearFilters() {
    _status = null;
    _fromDate = null;
    _toDate = null;
    _sort = null;
    _order = null;
    loadBookings(page: 1);
  }
}

/// Provider for user payments with summary
final userPaymentsProvider = StateNotifierProvider.autoDispose
    .family<UserPaymentsNotifier, AsyncValue<UserPaymentsState>, int>((
      ref,
      userId,
    ) {
      final repository = ref.watch(endUsersRepositoryProvider);
      return UserPaymentsNotifier(repository: repository, userId: userId);
    });

class UserPaymentsState {
  final List<UserPayment> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final PaymentSummary summary;

  const UserPaymentsState({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.summary,
  });
}

class UserPaymentsNotifier
    extends StateNotifier<AsyncValue<UserPaymentsState>> {
  UserPaymentsNotifier({
    required EndUsersRepository repository,
    required int userId,
  }) : _repository = repository,
       _userId = userId,
       super(const AsyncValue.loading()) {
    loadPayments();
  }

  final EndUsersRepository _repository;
  final int _userId;
  int _currentPage = 1;
  int _pageSize = 20;

  Future<void> loadPayments({int? page, int? pageSize}) async {
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _repository.getPayments(
        _userId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      return UserPaymentsState(
        items: result['items'] as List<UserPayment>,
        total: result['total'] as int,
        page: result['page'] as int,
        pageSize: result['page_size'] as int,
        totalPages: result['total_pages'] as int,
        summary: result['summary'] as PaymentSummary,
      );
    });
  }

  void nextPage() {
    final currentData = state.value;
    if (currentData != null && _currentPage < currentData.totalPages) {
      loadPayments(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadPayments(page: _currentPage - 1);
    }
  }
}

/// Provider for user reviews with pagination
final userReviewsProvider = StateNotifierProvider.autoDispose
    .family<UserReviewsNotifier, AsyncValue<Pagination<UserReview>>, int>((
      ref,
      userId,
    ) {
      final repository = ref.watch(endUsersRepositoryProvider);
      return UserReviewsNotifier(repository: repository, userId: userId);
    });

class UserReviewsNotifier
    extends StateNotifier<AsyncValue<Pagination<UserReview>>> {
  UserReviewsNotifier({
    required EndUsersRepository repository,
    required int userId,
  }) : _repository = repository,
       _userId = userId,
       super(const AsyncValue.loading()) {
    loadReviews();
  }

  final EndUsersRepository _repository;
  final int _userId;
  int _currentPage = 1;
  int _pageSize = 20;
  int? _rating;
  bool? _hasResponse;

  Future<void> loadReviews({
    int? page,
    int? pageSize,
    int? rating,
    bool? hasResponse,
  }) async {
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;
    if (rating != null) _rating = rating;
    if (hasResponse != null) _hasResponse = hasResponse;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getReviews(
        _userId,
        page: _currentPage,
        pageSize: _pageSize,
        rating: _rating,
        hasResponse: _hasResponse,
      );
    });
  }

  void nextPage() {
    final currentData = state.value;
    if (currentData != null && _currentPage < currentData.totalPages) {
      loadReviews(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadReviews(page: _currentPage - 1);
    }
  }

  void clearFilters() {
    _rating = null;
    _hasResponse = null;
    loadReviews(page: 1);
  }
}

/// Provider for user activity log with pagination
final userActivityProvider = StateNotifierProvider.autoDispose
    .family<UserActivityNotifier, AsyncValue<Pagination<UserActivity>>, int>((
      ref,
      userId,
    ) {
      final repository = ref.watch(endUsersRepositoryProvider);
      return UserActivityNotifier(repository: repository, userId: userId);
    });

class UserActivityNotifier
    extends StateNotifier<AsyncValue<Pagination<UserActivity>>> {
  UserActivityNotifier({
    required EndUsersRepository repository,
    required int userId,
  }) : _repository = repository,
       _userId = userId,
       super(const AsyncValue.loading()) {
    loadActivity();
  }

  final EndUsersRepository _repository;
  final int _userId;
  int _currentPage = 1;
  int _pageSize = 20;
  String? _activityType;
  DateTime? _fromDate;
  DateTime? _toDate;

  Future<void> loadActivity({
    int? page,
    int? pageSize,
    String? activityType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;
    if (activityType != null) _activityType = activityType;
    if (fromDate != null) _fromDate = fromDate;
    if (toDate != null) _toDate = toDate;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getActivity(
        _userId,
        page: _currentPage,
        pageSize: _pageSize,
        activityType: _activityType,
        fromDate: _fromDate,
        toDate: _toDate,
      );
    });
  }

  void nextPage() {
    final currentData = state.value;
    if (currentData != null && _currentPage < currentData.totalPages) {
      loadActivity(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadActivity(page: _currentPage - 1);
    }
  }

  void clearFilters() {
    _activityType = null;
    _fromDate = null;
    _toDate = null;
    loadActivity(page: 1);
  }
}

/// Provider for user sessions
final userSessionsProvider = FutureProvider.autoDispose
    .family<UserSessions, int>((ref, userId) async {
      final repository = ref.watch(endUsersRepositoryProvider);
      return repository.getSessions(userId);
    });

/// Provider for user actions (suspend, reactivate, etc.)
final userActionsProvider = Provider.autoDispose.family<UserActions, int>((
  ref,
  userId,
) {
  final repository = ref.watch(endUsersRepositoryProvider);
  return UserActions(repository: repository, userId: userId, ref: ref);
});

class UserActions {
  UserActions({
    required EndUsersRepository repository,
    required int userId,
    required AutoDisposeProviderRef ref,
  }) : _repository = repository,
       _userId = userId,
       _ref = ref;

  final EndUsersRepository _repository;
  final int _userId;
  final AutoDisposeProviderRef _ref;

  /// Suspend user
  Future<void> suspend({
    required String reason,
    int? durationDays,
    bool notifyUser = true,
    String? internalNotes,
    String? idempotencyKey,
  }) async {
    await _repository.suspendUser(
      _userId,
      reason: reason,
      durationDays: durationDays,
      notifyUser: notifyUser,
      internalNotes: internalNotes,
      idempotencyKey: idempotencyKey,
    );
    // Invalidate user detail to refresh
    _ref.invalidate(userDetailProvider(_userId));
  }

  /// Reactivate user
  Future<void> reactivate({
    String? notes,
    bool notifyUser = true,
    String? idempotencyKey,
  }) async {
    await _repository.reactivateUser(
      _userId,
      notes: notes,
      notifyUser: notifyUser,
      idempotencyKey: idempotencyKey,
    );
    // Invalidate user detail to refresh
    _ref.invalidate(userDetailProvider(_userId));
  }

  /// Force logout all sessions
  Future<Map<String, dynamic>> forceLogoutAll({String? idempotencyKey}) async {
    final result = await _repository.forceLogoutAll(
      _userId,
      idempotencyKey: idempotencyKey,
    );
    // Invalidate sessions to refresh
    _ref.invalidate(userSessionsProvider(_userId));
    return result;
  }

  /// Update trust score
  Future<Map<String, dynamic>> updateTrustScore({
    required int score,
    required String reason,
    bool applyRestrictions = false,
    String? idempotencyKey,
  }) async {
    final result = await _repository.updateTrustScore(
      _userId,
      score: score,
      reason: reason,
      applyRestrictions: applyRestrictions,
      idempotencyKey: idempotencyKey,
    );
    // Invalidate user detail to refresh
    _ref.invalidate(userDetailProvider(_userId));
    return result;
  }
}
