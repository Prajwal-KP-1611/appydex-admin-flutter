/// User activity log entry for audit trail
class UserActivity {
  final int id;
  final int userId;
  final ActivityType activityType;
  final String description;
  final Map<String, dynamic>? metadata;
  final String ipAddress;
  final String userAgent;
  final String? deviceType;
  final String? location;
  final DateTime createdAt;

  const UserActivity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.description,
    this.metadata,
    required this.ipAddress,
    required this.userAgent,
    this.deviceType,
    this.location,
    required this.createdAt,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      activityType: ActivityType.fromString(json['activity_type'] as String),
      description: json['description'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      ipAddress: json['ip_address'] as String,
      userAgent: json['user_agent'] as String,
      deviceType: json['device_type'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': activityType.value,
      'description': description,
      'metadata': metadata,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'device_type': deviceType,
      'location': location,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get activity icon for UI
  String get icon {
    switch (activityType) {
      case ActivityType.login:
        return '🔐';
      case ActivityType.logout:
        return '🚪';
      case ActivityType.bookingCreated:
        return '📅';
      case ActivityType.payment:
        return '💳';
      case ActivityType.review:
        return '⭐';
      case ActivityType.dispute:
        return '⚠️';
      case ActivityType.profileUpdate:
        return '👤';
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Activity type enum
enum ActivityType {
  login('login', 'Login'),
  logout('logout', 'Logout'),
  bookingCreated('booking_created', 'Booking Created'),
  payment('payment', 'Payment'),
  review('review', 'Review'),
  dispute('dispute', 'Dispute'),
  profileUpdate('profile_update', 'Profile Update');

  final String value;
  final String label;

  const ActivityType(this.value, this.label);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActivityType.profileUpdate,
    );
  }
}
