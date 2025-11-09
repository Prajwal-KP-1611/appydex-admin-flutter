import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/end_user_enhanced.dart';
import '../models/user_booking.dart';
import '../models/user_payment.dart';
import '../models/user_review.dart';
import '../models/dispute.dart';
import '../models/dispute_message.dart';
import 'admin_exceptions.dart';
import '../models/user_activity.dart';
import '../models/user_session.dart';

/// End-user (customer) model
class EndUser {
  const EndUser({
    required this.id,
    required this.email,
    this.phone,
    this.name,
    this.isActive = true,
    this.isSuspended = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.bookingCount,
    this.createdAt,
    this.lastLoginAt,
  });

  final int id;
  final String email;
  final String? phone;
  final String? name;
  final bool isActive;
  final bool isSuspended;
  final bool emailVerified;
  final bool phoneVerified;
  final int? bookingCount;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  factory EndUser.fromJson(Map<String, dynamic> json) {
    return EndUser(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isSuspended: json['is_suspended'] as bool? ?? false,
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      bookingCount: json['booking_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (phone != null) 'phone': phone,
      if (name != null) 'name': name,
      'is_active': isActive,
      'is_suspended': isSuspended,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      if (bookingCount != null) 'booking_count': bookingCount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastLoginAt != null) 'last_login_at': lastLoginAt!.toIso8601String(),
    };
  }

  EndUser copyWith({
    int? id,
    String? email,
    String? phone,
    String? name,
    bool? isActive,
    bool? isSuspended,
    bool? emailVerified,
    bool? phoneVerified,
    int? bookingCount,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return EndUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isSuspended: isSuspended ?? this.isSuspended,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      bookingCount: bookingCount ?? this.bookingCount,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// Repository for end-users management
class EndUsersRepository {
  EndUsersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// List all end-users with pagination and filters
  /// GET /api/v1/admin/users
  /// ⚠️ NOTE: Backend endpoint is MISSING! Ticket: BACKEND-USERS-LIST-001
  Future<Pagination<EndUser>> list({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    bool useMockData = false,
  }) async {
    // If mock data requested, return fake data
    if (useMockData) {
      return _getMockUsersList(
        page: page,
        pageSize: pageSize,
        search: search,
        status: status,
      );
    }

    try {
      final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
        '/admin/users',
        queryParameters: {
          'page': page,
          'limit': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      return Pagination.fromJson(
        response.data ?? {},
        (json) => EndUser.fromJson(json),
      );
    } catch (e) {
      // Check if this is a 422 validation error for missing Authorization
      final is422Auth =
          e is AppHttpException &&
          e.statusCode == 422 &&
          e.toString().toLowerCase().contains('authorization');

      if (is422Auth) {
        throw Exception(
          'Authentication required. Please log out and log back in.',
        );
      }

      // Check if this is a 404 error (endpoint missing)
      final is404 =
          e is AppHttpException && e.statusCode == 404 ||
          e.toString().contains('404') ||
          e.toString().contains('statusCode: 404');

      if (is404) {
        throw AdminEndpointMissing('GET /api/v1/admin/users');
      }
      rethrow;
    }
  }

  /// Generate mock users data for development
  Pagination<EndUser> _getMockUsersList({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
  }) {
    // Generate 79 fake users (matching backend count)
    final allUsers = List.generate(79, (i) {
      final id = i + 1;
      return EndUser(
        id: id,
        email: 'user$id@example.com',
        name: 'User $id',
        phone: '+9198765${(43210 + id).toString().padLeft(5, '0')}',
        isActive: status == null || status == 'active',
        isSuspended: status == 'suspended',
        createdAt: DateTime.now().subtract(Duration(days: id * 3)),
        bookingCount: (id % 10) + 5,
      );
    });

    // Apply search filter
    var filtered = allUsers;
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filtered = allUsers
          .where(
            (u) =>
                u.email.toLowerCase().contains(searchLower) ||
                (u.name?.toLowerCase().contains(searchLower) ?? false) ||
                (u.phone?.contains(search) ?? false),
          )
          .toList();
    }

    // Apply status filter
    if (status == 'active') {
      filtered = filtered.where((u) => u.isActive && !u.isSuspended).toList();
    } else if (status == 'suspended') {
      filtered = filtered.where((u) => u.isSuspended).toList();
    }

    // Paginate
    final total = filtered.length;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);
    final pageItems = filtered.sublist(startIndex.clamp(0, total), endIndex);

    return Pagination(
      items: pageItems,
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get single user by ID
  /// GET /api/v1/admin/users/{user_id}
  Future<EndUser> getById(int userId) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId',
    );

    if (response.data == null) {
      throw AppHttpException(message: 'User not found', statusCode: 404);
    }

    return EndUser.fromJson(response.data!);
  }

  /// Suspend user account
  /// PATCH /api/v1/admin/users/{user_id}/suspend
  Future<void> suspend(int userId, {String? reason}) async {
    await _apiClient.requestAdmin<void>(
      '/admin/users/$userId/suspend',
      method: 'PATCH',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
  }

  /// Unsuspend user account
  /// PATCH /api/v1/admin/users/{user_id}/unsuspend
  Future<void> unsuspend(int userId) async {
    await _apiClient.requestAdmin<void>(
      '/admin/users/$userId/unsuspend',
      method: 'PATCH',
    );
  }

  /// Anonymize user data (GDPR)
  /// POST /api/v1/admin/users/{user_id}/anonymize
  Future<void> anonymize(int userId) async {
    await _apiClient.requestAdmin<void>(
      '/admin/users/$userId/anonymize',
      method: 'POST',
    );
  }

  // ============================================================================
  // ENHANCED END-USER MANAGEMENT METHODS (Nov 9, 2025)
  // ============================================================================

  /// Get enhanced user profile with full activity data
  /// GET /api/v1/admin/users/{user_id}
  Future<EndUserEnhanced> getUser(int userId) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId',
    );

    if (response.data == null) {
      throw AppHttpException(message: 'User not found', statusCode: 404);
    }

    return EndUserEnhanced.fromJson(response.data!);
  }

  /// Get user bookings history with pagination
  /// GET /api/v1/admin/users/{user_id}/bookings
  Future<Pagination<UserBooking>> getBookings(
    int userId, {
    int page = 1,
    int pageSize = 20,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? sort,
    String? order,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/bookings',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null && status.isNotEmpty) 'status': status,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        if (sort != null) 'sort': sort,
        if (order != null) 'order': order,
      },
    );

    return Pagination.fromJson(
      response.data ?? {},
      (json) => UserBooking.fromJson(json),
    );
  }

  /// Get user payment history with pagination
  /// GET /api/v1/admin/users/{user_id}/payments
  Future<Map<String, dynamic>> getPayments(
    int userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/payments',
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    if (response.data == null) {
      return {
        'items': <UserPayment>[],
        'total': 0,
        'page': page,
        'page_size': pageSize,
        'total_pages': 0,
        'summary': PaymentSummary.fromJson({}),
      };
    }

    final data = response.data!;
    return {
      'items':
          (data['items'] as List<dynamic>?)
              ?.map((e) => UserPayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      'total': data['total'] as int? ?? 0,
      'page': data['page'] as int? ?? page,
      'page_size': data['page_size'] as int? ?? pageSize,
      'total_pages': data['total_pages'] as int? ?? 0,
      'summary': PaymentSummary.fromJson(
        data['summary'] as Map<String, dynamic>? ?? {},
      ),
    };
  }

  /// Get user reviews
  /// GET /api/v1/admin/users/{user_id}/reviews
  Future<Pagination<UserReview>> getReviews(
    int userId, {
    int page = 1,
    int pageSize = 20,
    int? rating,
    bool? hasResponse,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/reviews',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (rating != null) 'rating': rating,
        if (hasResponse != null) 'has_response': hasResponse,
      },
    );

    return Pagination.fromJson(
      response.data ?? {},
      (json) => UserReview.fromJson(json),
    );
  }

  /// Get user disputes with pagination
  /// GET /api/v1/admin/users/{user_id}/disputes
  Future<Map<String, dynamic>> getDisputes(
    int userId, {
    int page = 1,
    int pageSize = 20,
    String? status,
    String? type,
    String? priority,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/disputes',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null && status.isNotEmpty) 'status': status,
        if (type != null && type.isNotEmpty) 'type': type,
        if (priority != null && priority.isNotEmpty) 'priority': priority,
      },
    );

    if (response.data == null) {
      return {
        'items': <Dispute>[],
        'total': 0,
        'page': page,
        'page_size': pageSize,
        'total_pages': 0,
        'summary': DisputeSummary.fromJson({}),
      };
    }

    final data = response.data!;
    return {
      'items':
          (data['items'] as List<dynamic>?)
              ?.map((e) => Dispute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      'total': data['total'] as int? ?? 0,
      'page': data['page'] as int? ?? page,
      'page_size': data['page_size'] as int? ?? pageSize,
      'total_pages': data['total_pages'] as int? ?? 0,
      'summary': DisputeSummary.fromJson(
        data['summary'] as Map<String, dynamic>? ?? {},
      ),
    };
  }

  /// Get dispute detail
  /// GET /api/v1/admin/users/disputes/{dispute_id}
  Future<Dispute> getDisputeDetail(int disputeId) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/disputes/$disputeId',
    );

    if (response.data == null) {
      throw AppHttpException(message: 'Dispute not found', statusCode: 404);
    }

    return Dispute.fromJson(response.data!);
  }

  /// Update dispute status and resolution
  /// PATCH /api/v1/admin/users/disputes/{dispute_id}
  Future<Dispute> updateDispute(
    int disputeId, {
    String? status,
    String? resolutionType,
    int? refundAmount,
    String? adminNotes,
    String? resolutionDetails,
    bool? notifyUser,
    bool? notifyVendor,
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/disputes/$disputeId',
      method: 'PATCH',
      data: {
        if (status != null) 'status': status,
        if (resolutionType != null) 'resolution_type': resolutionType,
        if (refundAmount != null) 'refund_amount': refundAmount,
        if (adminNotes != null) 'admin_notes': adminNotes,
        if (resolutionDetails != null) 'resolution_details': resolutionDetails,
        if (notifyUser != null) 'notify_user': notifyUser,
        if (notifyVendor != null) 'notify_vendor': notifyVendor,
      },
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );

    if (response.data == null) {
      throw AppHttpException(
        message: 'Failed to update dispute',
        statusCode: 500,
      );
    }

    return Dispute.fromJson(response.data!);
  }

  /// Add message to dispute thread
  /// POST /api/v1/admin/users/disputes/{dispute_id}/messages
  Future<DisputeMessage> addDisputeMessage(
    int disputeId, {
    required String message,
    bool isInternal = false,
    List<String>? attachments,
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/disputes/$disputeId/messages',
      method: 'POST',
      data: {
        'message': message,
        'is_internal': isInternal,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments,
      },
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );

    if (response.data == null) {
      throw AppHttpException(message: 'Failed to add message', statusCode: 500);
    }

    return DisputeMessage.fromJson(response.data!);
  }

  /// Assign dispute to admin user
  /// POST /api/v1/admin/users/disputes/{dispute_id}/assign
  Future<void> assignDispute(
    int disputeId, {
    required int adminUserId,
    String? notes,
    String? idempotencyKey,
  }) async {
    await _apiClient.requestAdmin<void>(
      '/admin/users/disputes/$disputeId/assign',
      method: 'POST',
      data: {
        'admin_user_id': adminUserId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );
  }

  /// Get user activity log with pagination
  /// GET /api/v1/admin/users/{user_id}/activity
  Future<Pagination<UserActivity>> getActivity(
    int userId, {
    int page = 1,
    int pageSize = 20,
    String? activityType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/activity',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (activityType != null && activityType.isNotEmpty)
          'activity_type': activityType,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
      },
    );

    return Pagination.fromJson(
      response.data ?? {},
      (json) => UserActivity.fromJson(json),
    );
  }

  /// Get user sessions (active and recent)
  /// GET /api/v1/admin/users/{user_id}/sessions
  Future<UserSessions> getSessions(int userId) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/sessions',
    );

    if (response.data == null) {
      return const UserSessions(activeSessions: [], recentLogins: []);
    }

    return UserSessions.fromJson(response.data!);
  }

  /// Suspend user with reason and duration
  /// POST /api/v1/admin/users/{user_id}/suspend
  Future<Map<String, dynamic>> suspendUser(
    int userId, {
    required String reason,
    int? durationDays,
    bool notifyUser = true,
    String? internalNotes,
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/suspend',
      method: 'POST',
      data: {
        'reason': reason,
        if (durationDays != null) 'duration_days': durationDays,
        'notify_user': notifyUser,
        if (internalNotes != null && internalNotes.isNotEmpty)
          'internal_notes': internalNotes,
      },
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );

    return response.data ?? {};
  }

  /// Reactivate suspended user
  /// POST /api/v1/admin/users/{user_id}/reactivate
  Future<void> reactivateUser(
    int userId, {
    String? notes,
    bool notifyUser = true,
    String? idempotencyKey,
  }) async {
    await _apiClient.requestAdmin<void>(
      '/admin/users/$userId/reactivate',
      method: 'POST',
      data: {
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'notify_user': notifyUser,
      },
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );
  }

  /// Force logout all user sessions
  /// POST /api/v1/admin/users/{user_id}/logout-all
  Future<Map<String, dynamic>> forceLogoutAll(
    int userId, {
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/logout-all',
      method: 'POST',
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );

    return response.data ?? {'sessions_terminated': 0};
  }

  /// Update user trust score manually
  /// PATCH /api/v1/admin/users/{user_id}/trust-score
  Future<Map<String, dynamic>> updateTrustScore(
    int userId, {
    required int score,
    required String reason,
    bool applyRestrictions = false,
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/$userId/trust-score',
      method: 'PATCH',
      data: {
        'score': score,
        'reason': reason,
        'apply_restrictions': applyRestrictions,
      },
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );

    return response.data ?? {};
  }

  /// Get all disputes (global view) with filters
  /// GET /api/v1/admin/users/disputes
  Future<Map<String, dynamic>> getAllDisputes({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? type,
    String? priority,
    int? assignedTo,
    bool? unassigned,
    DateTime? fromDate,
    DateTime? toDate,
    String? sort,
  }) async {
    final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
      '/admin/users/disputes',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null && status.isNotEmpty) 'status': status,
        if (type != null && type.isNotEmpty) 'type': type,
        if (priority != null && priority.isNotEmpty) 'priority': priority,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (unassigned != null) 'unassigned': unassigned,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        if (sort != null) 'sort': sort,
      },
    );

    if (response.data == null) {
      return {
        'items': <Dispute>[],
        'total': 0,
        'page': page,
        'page_size': pageSize,
        'total_pages': 0,
      };
    }

    final data = response.data!;
    return {
      'items':
          (data['items'] as List<dynamic>?)
              ?.map((e) => Dispute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      'total': data['total'] as int? ?? 0,
      'page': data['page'] as int? ?? page,
      'page_size': data['page_size'] as int? ?? pageSize,
      'total_pages': data['total_pages'] as int? ?? 0,
    };
  }
}

final endUsersRepositoryProvider = Provider<EndUsersRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EndUsersRepository(apiClient: apiClient);
});

/// State provider for end-users list
final endUsersProvider =
    StateNotifierProvider<EndUsersNotifier, AsyncValue<Pagination<EndUser>>>((
      ref,
    ) {
      final repository = ref.watch(endUsersRepositoryProvider);
      return EndUsersNotifier(repository: repository);
    });

class EndUsersNotifier extends StateNotifier<AsyncValue<Pagination<EndUser>>> {
  EndUsersNotifier({required EndUsersRepository repository})
    : _repository = repository,
      super(const AsyncValue.loading()) {
    loadUsers();
  }

  final EndUsersRepository _repository;
  int _currentPage = 1;
  int _pageSize = 20;
  String? _search;
  String? _status;
  bool _useMockData = false;

  /// Enable mock data mode (when backend endpoint is missing)
  void enableMockData() {
    _useMockData = true;
    loadUsers();
  }

  Future<void> loadUsers({
    int? page,
    int? pageSize,
    String? search,
    String? status,
  }) async {
    if (page != null) _currentPage = page;
    if (pageSize != null) _pageSize = pageSize;
    if (search != null) _search = search;
    if (status != null) _status = status;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.list(
        page: _currentPage,
        pageSize: _pageSize,
        search: _search,
        status: _status,
        useMockData: _useMockData,
      );
    });
  }

  Future<void> suspendUser(int userId, {String? reason}) async {
    await _repository.suspend(userId, reason: reason);
    await loadUsers();
  }

  Future<void> unsuspendUser(int userId) async {
    await _repository.unsuspend(userId);
    await loadUsers();
  }

  Future<void> anonymizeUser(int userId) async {
    await _repository.anonymize(userId);
    await loadUsers();
  }

  void nextPage() {
    final currentData = state.value;
    if (currentData != null && _currentPage < currentData.totalPages) {
      loadUsers(page: _currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      loadUsers(page: _currentPage - 1);
    }
  }
}
