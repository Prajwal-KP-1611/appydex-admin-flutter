/// User booking for end-user booking history
class UserBooking {
  final int id;
  final String bookingReference;
  final int serviceId;
  final String serviceName;
  final int vendorId;
  final String vendorName;
  final String status; // pending, confirmed, completed, cancelled, refunded
  final DateTime bookingDate;
  final int amount; // in paise
  final String paymentStatus; // pending, paid, failed, refunded
  final String? paymentMethod;
  final bool hasReview;
  final int? reviewRating;
  final bool hasDispute;
  final DateTime createdAt;
  final DateTime? completedAt;

  const UserBooking({
    required this.id,
    required this.bookingReference,
    required this.serviceId,
    required this.serviceName,
    required this.vendorId,
    required this.vendorName,
    required this.status,
    required this.bookingDate,
    required this.amount,
    required this.paymentStatus,
    this.paymentMethod,
    required this.hasReview,
    this.reviewRating,
    required this.hasDispute,
    required this.createdAt,
    this.completedAt,
  });

  factory UserBooking.fromJson(Map<String, dynamic> json) {
    return UserBooking(
      id: json['id'] as int,
      bookingReference: json['booking_reference'] as String,
      serviceId: json['service_id'] as int,
      serviceName: json['service_name'] as String,
      vendorId: json['vendor_id'] as int,
      vendorName: json['vendor_name'] as String,
      status: json['status'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      amount: json['amount'] as int,
      paymentStatus: json['payment_status'] as String,
      paymentMethod: json['payment_method'] as String?,
      hasReview: json['has_review'] as bool? ?? false,
      reviewRating: json['review_rating'] as int?,
      hasDispute: json['has_dispute'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'service_id': serviceId,
      'service_name': serviceName,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'status': status,
      'booking_date': bookingDate.toIso8601String(),
      'amount': amount,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'has_review': hasReview,
      'review_rating': reviewRating,
      'has_dispute': hasDispute,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Format amount for display
  String get amountFormatted {
    return '₹${(amount / 100).toStringAsFixed(2)}';
  }

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'green';
      case 'confirmed':
        return 'blue';
      case 'pending':
        return 'orange';
      case 'cancelled':
      case 'refunded':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Check if booking is active
  bool get isActive {
    return status == 'pending' || status == 'confirmed';
  }

  /// Check if booking can be reviewed
  bool get canReview {
    return status == 'completed' && !hasReview;
  }
}
