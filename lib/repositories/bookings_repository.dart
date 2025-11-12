/// Bookings repository for admin panel
/// Handles all booking-related API calls
library;

import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/paginated_response.dart';
import '../models/booking.dart';

class BookingsRepository {
  final ApiClient _apiClient;

  BookingsRepository(this._apiClient);

  /// List all bookings with optional filters
  ///
  /// **Endpoint:** GET /api/v1/admin/bookings
  /// **Permissions:** bookings.view
  ///
  /// Example:
  /// ```dart
  /// final filters = BookingsFilters(
  ///   status: BookingStatus.pending,
  ///   page: 1,
  ///   pageSize: 25,
  /// );
  /// final result = await repository.listBookings(filters);
  /// ```
  Future<PaginatedResponse<BookingListItem>> listBookings([
    BookingsFilters? filters,
  ]) async {
    try {
      final queryParams =
          filters?.toQueryParameters() ??
          {
            'page': '1',
            'page_size': '25',
            'sort_by': 'created_at',
            'sort_order': 'desc',
          };

      final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
        '/admin/bookings',
        method: 'GET',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw AdminEndpointMissing(
          endpoint: '/admin/bookings',
          message:
              'API returned null response. The endpoint may not be implemented yet.',
        );
      }

      // Handle case where API returns a list instead of paginated response
      if (response.data is List) {
        throw AdminEndpointMissing(
          endpoint: '/admin/bookings',
          message:
              'API returned a list instead of a paginated response. Expected format: {data: [...], meta: {...}}',
        );
      }

      return PaginatedResponse<BookingListItem>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => BookingListItem.fromJson(json),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw AdminEndpointMissing(
          endpoint: 'GET /admin/bookings',
          message: 'Permission denied: bookings.view required',
        );
      }
      rethrow;
    }
  }

  /// Get detailed booking information
  ///
  /// **Endpoint:** GET /api/v1/admin/bookings/{id}
  /// **Permissions:** bookings.view
  ///
  /// Example:
  /// ```dart
  /// final booking = await repository.getBookingDetails(123);
  /// ```
  ///
  /// Throws [AdminEndpointMissing] if endpoint not implemented or forbidden
  /// Throws [DioException] with 404 if booking not found
  Future<BookingDetails> getBookingDetails(int bookingId) async {
    try {
      final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
        '/admin/bookings/$bookingId',
        method: 'GET',
      );

      // Response is automatically unwrapped by ApiClient
      return BookingDetails.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw BookingNotFoundException(bookingId);
      }
      if (e.response?.statusCode == 403) {
        throw AdminEndpointMissing(
          endpoint: 'GET /admin/bookings/{id}',
          message: 'Permission denied: bookings.view required',
        );
      }
      rethrow;
    }
  }

  /// Update booking status or add admin notes
  ///
  /// **Endpoint:** PATCH /api/v1/admin/bookings/{id}
  /// **Permissions:** bookings.edit, bookings.cancel (for cancellation)
  ///
  /// Example:
  /// ```dart
  /// // Complete booking
  /// await repository.updateBooking(
  ///   123,
  ///   BookingUpdateRequest(status: BookingStatus.completed),
  /// );
  ///
  /// // Cancel booking with reason
  /// await repository.updateBooking(
  ///   123,
  ///   BookingUpdateRequest(
  ///     status: BookingStatus.canceled,
  ///     cancellationReason: 'Customer requested cancellation',
  ///     notifyUser: true,
  ///   ),
  /// );
  ///
  /// // Add admin notes without status change
  /// await repository.updateBooking(
  ///   123,
  ///   BookingUpdateRequest(
  ///     adminNotes: 'Called customer to confirm',
  ///     notifyUser: false,
  ///     notifyVendor: false,
  ///   ),
  /// );
  /// ```
  ///
  /// Throws [InvalidStatusTransitionException] if status transition not allowed
  /// Throws [ValidationException] if required fields missing (e.g., cancellation_reason)
  Future<BookingUpdateResponse> updateBooking(
    int bookingId,
    BookingUpdateRequest request, {
    String? idempotencyKey,
  }) async {
    try {
      // Build query parameters from request
      final queryParams = <String, String>{};

      if (request.status != null) {
        queryParams['status'] = request.status!.name;
      }
      if (request.adminNotes != null) {
        queryParams['admin_notes'] = request.adminNotes!;
      }
      if (request.cancellationReason != null) {
        queryParams['cancellation_reason'] = request.cancellationReason!;
      }
      queryParams['notify_user'] = request.notifyUser.toString();
      queryParams['notify_vendor'] = request.notifyVendor.toString();

      // Prepare headers
      final headers = <String, String>{};
      if (idempotencyKey != null) {
        headers['Idempotency-Key'] = idempotencyKey;
      }

      final response = await _apiClient.requestAdmin<Map<String, dynamic>>(
        '/admin/bookings/$bookingId',
        method: 'PATCH',
        queryParameters: queryParams,
        options: Options(
          extra: {if (idempotencyKey != null) 'idempotencyKey': idempotencyKey},
        ),
      );

      // Response is automatically unwrapped by ApiClient
      return BookingUpdateResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final error = e.response?.data['error'];
        if (error?['code'] == 'VALIDATION_ERROR') {
          throw ValidationException(error['message'], field: error['field']);
        }
        if (error?['code'] == 'INVALID_STATUS_TRANSITION') {
          throw InvalidStatusTransitionException(
            currentStatus: error['current_status'],
            requestedStatus: error['requested_status'],
            message: error['message'],
          );
        }
      }
      if (e.response?.statusCode == 404) {
        throw BookingNotFoundException(bookingId);
      }
      if (e.response?.statusCode == 403) {
        throw AdminEndpointMissing(
          endpoint: 'PATCH /admin/bookings/{id}',
          message:
              'Permission denied: bookings.edit or bookings.cancel required',
        );
      }
      rethrow;
    }
  }
}

/// Booking update response
class BookingUpdateResponse {
  final int id;
  final String bookingNumber;
  final BookingStatus status;
  final DateTime updatedAt;
  final int updatedBy;

  BookingUpdateResponse({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory BookingUpdateResponse.fromJson(Map<String, dynamic> json) {
    return BookingUpdateResponse(
      id: json['id'] as int,
      bookingNumber: json['booking_number'] as String,
      status: BookingStatus.values.firstWhere((e) => e.name == json['status']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      updatedBy: json['updated_by'] as int,
    );
  }
}

// ============================================================================
// Custom Exceptions
// ============================================================================

/// Exception thrown when booking not found (404)
class BookingNotFoundException implements Exception {
  final int bookingId;

  BookingNotFoundException(this.bookingId);

  @override
  String toString() => 'Booking not found: $bookingId';
}

/// Exception thrown when invalid status transition attempted
class InvalidStatusTransitionException implements Exception {
  final String currentStatus;
  final String requestedStatus;
  final String message;

  InvalidStatusTransitionException({
    required this.currentStatus,
    required this.requestedStatus,
    required this.message,
  });

  @override
  String toString() => message;
}

/// Exception thrown for validation errors
class ValidationException implements Exception {
  final String message;
  final String? field;

  ValidationException(this.message, {this.field});

  @override
  String toString() => field != null ? '$field: $message' : message;
}

/// Exception thrown when endpoint not implemented or forbidden
class AdminEndpointMissing implements Exception {
  final String endpoint;
  final String message;

  AdminEndpointMissing({required this.endpoint, required this.message});

  @override
  String toString() => 'Admin endpoint missing: $endpoint - $message';
}
