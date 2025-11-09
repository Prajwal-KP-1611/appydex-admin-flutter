/// User review written by end-user
class UserReview {
  final int id;
  final int bookingId;
  final int serviceId;
  final String serviceName;
  final int vendorId;
  final String vendorName;
  final int rating; // 1-5
  final String? title;
  final String? comment;
  final List<String> photos;
  final int helpfulCount;
  final String? vendorResponse;
  final DateTime? vendorRespondedAt;
  final bool isVerified;
  final DateTime createdAt;

  const UserReview({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.serviceName,
    required this.vendorId,
    required this.vendorName,
    required this.rating,
    this.title,
    this.comment,
    required this.photos,
    required this.helpfulCount,
    this.vendorResponse,
    this.vendorRespondedAt,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      serviceId: json['service_id'] as int,
      serviceName: json['service_name'] as String,
      vendorId: json['vendor_id'] as int,
      vendorName: json['vendor_name'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      helpfulCount: json['helpful_count'] as int? ?? 0,
      vendorResponse: json['vendor_response'] as String?,
      vendorRespondedAt: json['vendor_responded_at'] != null
          ? DateTime.parse(json['vendor_responded_at'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'service_id': serviceId,
      'service_name': serviceName,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'rating': rating,
      'title': title,
      'comment': comment,
      'photos': photos,
      'helpful_count': helpfulCount,
      'vendor_response': vendorResponse,
      'vendor_responded_at': vendorRespondedAt?.toIso8601String(),
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get rating stars for display
  String get ratingStars {
    return '⭐' * rating + '☆' * (5 - rating);
  }

  /// Check if review has photos
  bool get hasPhotos => photos.isNotEmpty;

  /// Check if vendor has responded
  bool get hasVendorResponse => vendorResponse != null;

  /// Get review sentiment (positive, neutral, negative)
  String get sentiment {
    if (rating >= 4) return 'Positive';
    if (rating >= 3) return 'Neutral';
    return 'Negative';
  }

  /// Get sentiment color
  String get sentimentColor {
    if (rating >= 4) return 'green';
    if (rating >= 3) return 'orange';
    return 'red';
  }

  /// Check if review is detailed
  bool get isDetailed {
    return comment != null && comment!.length > 50;
  }
}
