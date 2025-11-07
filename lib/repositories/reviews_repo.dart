import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/review.dart';
import 'admin_exceptions.dart';

/// Repository for review moderation
/// Base Path: /api/v1/admin/reviews
class ReviewsRepository {
  ReviewsRepository(this._client);

  final ApiClient _client;

  /// List reviews with filters
  /// GET /api/v1/admin/reviews
  Future<Pagination<Review>> list({
    int skip = 0,
    int limit = 100,
    String? status,
    int? vendorId,
    bool? flagged,
  }) async {
    final params = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (vendorId != null) 'vendor_id': vendorId,
      if (flagged != null) 'flagged': flagged,
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/reviews',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => Review.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/reviews');
      }
      rethrow;
    }
  }

  /// Get review details
  /// GET /api/v1/admin/reviews/{review_id}
  Future<Review> getById(int id) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/reviews/$id',
      );
      return Review.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/reviews/:id');
      }
      rethrow;
    }
  }

  /// Approve review (make visible)
  /// POST /api/v1/admin/reviews/{review_id}/approve
  Future<Review> approve(int reviewId, {String? notes}) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/reviews/$reviewId/approve',
        method: 'POST',
        data: {
          if (notes != null && notes.isNotEmpty) 'admin_notes': notes,
        },
      );
      return Review.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/reviews/:id/approve');
      }
      rethrow;
    }
  }

  /// Hide review (keep in DB but not visible to users)
  /// POST /api/v1/admin/reviews/{review_id}/hide
  Future<Review> hide(int reviewId, {required String reason}) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/reviews/$reviewId/hide',
        method: 'POST',
        data: {
          'reason': reason,
        },
      );
      return Review.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/reviews/:id/hide');
      }
      rethrow;
    }
  }

  /// Remove review permanently
  /// DELETE /api/v1/admin/reviews/{review_id}
  Future<void> remove(int reviewId, {required String reason}) async {
    try {
      await _client.requestAdmin(
        '/admin/reviews/$reviewId',
        method: 'DELETE',
        data: {
          'reason': reason,
        },
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/reviews/:id');
      }
      rethrow;
    }
  }

  /// Restore hidden review
  /// POST /api/v1/admin/reviews/{review_id}/restore
  Future<Review> restore(int reviewId) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/reviews/$reviewId/restore',
        method: 'POST',
      );
      return Review.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/reviews/:id/restore');
      }
      rethrow;
    }
  }
}

/// Provider for ReviewsRepository
final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReviewsRepository(client);
});

/// State notifier for reviews
class ReviewsNotifier extends StateNotifier<AsyncValue<Pagination<Review>>> {
  ReviewsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final ReviewsRepository _repository;

  String? _statusFilter;
  int? _vendorIdFilter;
  bool? _flaggedFilter;
  int _skip = 0;
  static const int _limit = 100;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.list(
        skip: _skip,
        limit: _limit,
        status: _statusFilter,
        vendorId: _vendorIdFilter,
        flagged: _flaggedFilter,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterByStatus(String? status) {
    _statusFilter = status;
    _skip = 0;
    load();
  }

  void filterByVendor(int? vendorId) {
    _vendorIdFilter = vendorId;
    _skip = 0;
    load();
  }

  void filterByFlagged(bool? flagged) {
    _flaggedFilter = flagged;
    _skip = 0;
    load();
  }

  void clearFilters() {
    _statusFilter = null;
    _vendorIdFilter = null;
    _flaggedFilter = null;
    _skip = 0;
    load();
  }
}

/// Provider for reviews state
final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, AsyncValue<Pagination<Review>>>(
  (ref) {
    final repository = ref.watch(reviewsRepositoryProvider);
    return ReviewsNotifier(repository);
  },
);
