/// Booking model for admin panel
/// Represents a booking with user, vendor, and service information
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

/// Booking status enum
enum BookingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('paid')
  paid,
  @JsonValue('completed')
  completed,
  @JsonValue('canceled')
  canceled,
}

/// Extension to get display text for booking status
extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.scheduled:
        return 'Scheduled';
      case BookingStatus.paid:
        return 'Paid';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.canceled:
        return 'Canceled';
    }
  }

  /// Get color for status badge
  String get colorHex {
    switch (this) {
      case BookingStatus.pending:
        return '#FFA500'; // Orange
      case BookingStatus.scheduled:
        return '#007BFF'; // Blue
      case BookingStatus.paid:
        return '#28A745'; // Green
      case BookingStatus.completed:
        return '#6C757D'; // Gray
      case BookingStatus.canceled:
        return '#DC3545'; // Red
    }
  }
}

/// Booking user information
@freezed
class BookingUser with _$BookingUser {
  const factory BookingUser({
    required int id,
    required String name,
    required String email,
    required String displayName,
    String? phone,
    int? totalBookings,
  }) = _BookingUser;

  factory BookingUser.fromJson(Map<String, dynamic> json) =>
      _$BookingUserFromJson(json);
}

/// Booking vendor information
@freezed
class BookingVendor with _$BookingVendor {
  const factory BookingVendor({
    required int id,
    required String displayName,
    required String email,
    String? phone,
    int? totalBookings,
  }) = _BookingVendor;

  factory BookingVendor.fromJson(Map<String, dynamic> json) =>
      _$BookingVendorFromJson(json);
}

/// Booking list item (used in list view)
@freezed
class BookingListItem with _$BookingListItem {
  const factory BookingListItem({
    required int id,
    required String bookingNumber,
    required BookingStatus status,
    required BookingUser user,
    required BookingVendor vendor,
    required int serviceId,
    required DateTime scheduledAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BookingListItem;

  factory BookingListItem.fromJson(Map<String, dynamic> json) =>
      _$BookingListItemFromJson(json);
}

/// Detailed booking information
@freezed
class BookingDetails with _$BookingDetails {
  const factory BookingDetails({
    required int id,
    required String bookingNumber,
    required BookingStatus status,
    required BookingUser user,
    required BookingVendor vendor,
    required int serviceId,
    required DateTime scheduledAt,
    DateTime? estimatedEndAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? idempotencyKey,
  }) = _BookingDetails;

  factory BookingDetails.fromJson(Map<String, dynamic> json) =>
      _$BookingDetailsFromJson(json);
}

/// Booking update request
@freezed
class BookingUpdateRequest with _$BookingUpdateRequest {
  const factory BookingUpdateRequest({
    BookingStatus? status,
    String? adminNotes,
    String? cancellationReason,
    @Default(true) bool notifyUser,
    @Default(true) bool notifyVendor,
  }) = _BookingUpdateRequest;

  factory BookingUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$BookingUpdateRequestFromJson(json);
}

/// Bookings filter options
@freezed
class BookingsFilters with _$BookingsFilters {
  const factory BookingsFilters({
    @Default(1) int page,
    @Default(25) int pageSize,
    BookingStatus? status,
    String? search,
    int? vendorId,
    int? userId,
    int? serviceId,
    DateTime? fromDate,
    DateTime? toDate,
    @Default('created_at') String sortBy,
    @Default('desc') String sortOrder,
  }) = _BookingsFilters;

  factory BookingsFilters.fromJson(Map<String, dynamic> json) =>
      _$BookingsFiltersFromJson(json);

  /// Convert filters to query parameters
  const BookingsFilters._();

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (status != null) {
      params['status'] = status!.name;
    }
    if (search != null) {
      params['search'] = search!;
    }
    if (vendorId != null) {
      params['vendor_id'] = vendorId.toString();
    }
    if (userId != null) {
      params['user_id'] = userId.toString();
    }
    if (serviceId != null) {
      params['service_id'] = serviceId.toString();
    }
    if (fromDate != null) {
      params['from_date'] = fromDate!.toIso8601String();
    }
    if (toDate != null) {
      params['to_date'] = toDate!.toIso8601String();
    }

    return params;
  }
}

/// Booking update response
class BookingUpdateResponse {
  final int id;
  final BookingStatus status;
  final String message;

  BookingUpdateResponse({
    required this.id,
    required this.status,
    required this.message,
  });

  factory BookingUpdateResponse.fromJson(Map<String, dynamic> json) {
    return BookingUpdateResponse(
      id: json['id'] as int,
      status: BookingStatus.values.firstWhere((e) => e.name == json['status']),
      message: json['message'] as String,
    );
  }
}
