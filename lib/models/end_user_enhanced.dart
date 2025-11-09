/// Enhanced end-user model with complete activity, verification, engagement, and risk data
/// Matches backend response from GET /admin/users/{id}
class EndUserEnhanced {
  final int id;
  final String email;
  final String phone;
  final String name;
  final String? profilePictureUrl;
  final bool isActive;
  final bool isSuspended;
  final String? suspensionReason;
  final String accountStatus;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? lastActiveAt;

  // Nested objects
  final ActivitySummary activitySummary;
  final Verification verification;
  final Engagement engagement;
  final RiskIndicators riskIndicators;

  const EndUserEnhanced({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    this.profilePictureUrl,
    required this.isActive,
    required this.isSuspended,
    this.suspensionReason,
    required this.accountStatus,
    required this.emailVerified,
    required this.phoneVerified,
    required this.createdAt,
    this.lastLoginAt,
    this.lastActiveAt,
    required this.activitySummary,
    required this.verification,
    required this.engagement,
    required this.riskIndicators,
  });

  factory EndUserEnhanced.fromJson(Map<String, dynamic> json) {
    return EndUserEnhanced(
      id: json['id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isSuspended: json['is_suspended'] as bool? ?? false,
      suspensionReason: json['suspension_reason'] as String?,
      accountStatus: json['account_status'] as String? ?? 'active',
      emailVerified: json['email_verified'] as bool? ?? false,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      activitySummary: ActivitySummary.fromJson(
        json['activity_summary'] as Map<String, dynamic>,
      ),
      verification: Verification.fromJson(
        json['verification'] as Map<String, dynamic>,
      ),
      engagement: Engagement.fromJson(
        json['engagement'] as Map<String, dynamic>,
      ),
      riskIndicators: RiskIndicators.fromJson(
        json['risk_indicators'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'profile_picture_url': profilePictureUrl,
      'is_active': isActive,
      'is_suspended': isSuspended,
      'suspension_reason': suspensionReason,
      'account_status': accountStatus,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'activity_summary': activitySummary.toJson(),
      'verification': verification.toJson(),
      'engagement': engagement.toJson(),
      'risk_indicators': riskIndicators.toJson(),
    };
  }

  /// Check if user is currently suspended
  bool get isCurrentlySuspended => isSuspended && !isActive;

  /// Get display status for UI
  String get displayStatus {
    if (isSuspended) return 'Suspended';
    if (!isActive) return 'Inactive';
    return 'Active';
  }

  EndUserEnhanced copyWith({
    int? id,
    String? email,
    String? phone,
    String? name,
    String? profilePictureUrl,
    bool? isActive,
    bool? isSuspended,
    String? suspensionReason,
    String? accountStatus,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastActiveAt,
    ActivitySummary? activitySummary,
    Verification? verification,
    Engagement? engagement,
    RiskIndicators? riskIndicators,
  }) {
    return EndUserEnhanced(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isActive: isActive ?? this.isActive,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      accountStatus: accountStatus ?? this.accountStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      activitySummary: activitySummary ?? this.activitySummary,
      verification: verification ?? this.verification,
      engagement: engagement ?? this.engagement,
      riskIndicators: riskIndicators ?? this.riskIndicators,
    );
  }
}

/// User activity summary with bookings, spending, reviews, disputes
class ActivitySummary {
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final int pendingBookings;
  final int totalSpent; // in paise
  final int totalReviews;
  final double averageRatingGiven;
  final int totalDisputes;
  final int openDisputes;
  final int walletBalance; // in paise
  final int loyaltyPoints;

  const ActivitySummary({
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.pendingBookings,
    required this.totalSpent,
    required this.totalReviews,
    required this.averageRatingGiven,
    required this.totalDisputes,
    required this.openDisputes,
    required this.walletBalance,
    required this.loyaltyPoints,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      totalBookings: json['total_bookings'] as int? ?? 0,
      completedBookings: json['completed_bookings'] as int? ?? 0,
      cancelledBookings: json['cancelled_bookings'] as int? ?? 0,
      pendingBookings: json['pending_bookings'] as int? ?? 0,
      totalSpent: json['total_spent'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      averageRatingGiven:
          (json['average_rating_given'] as num?)?.toDouble() ?? 0.0,
      totalDisputes: json['total_disputes'] as int? ?? 0,
      openDisputes: json['open_disputes'] as int? ?? 0,
      walletBalance: json['wallet_balance'] as int? ?? 0,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bookings': totalBookings,
      'completed_bookings': completedBookings,
      'cancelled_bookings': cancelledBookings,
      'pending_bookings': pendingBookings,
      'total_spent': totalSpent,
      'total_reviews': totalReviews,
      'average_rating_given': averageRatingGiven,
      'total_disputes': totalDisputes,
      'open_disputes': openDisputes,
      'wallet_balance': walletBalance,
      'loyalty_points': loyaltyPoints,
    };
  }

  /// Calculate booking completion rate (0-1)
  double get completionRate {
    if (totalBookings == 0) return 0.0;
    return completedBookings / totalBookings;
  }

  /// Calculate cancellation rate (0-1)
  double get cancellationRate {
    if (totalBookings == 0) return 0.0;
    return cancelledBookings / totalBookings;
  }

  /// Format total spent as currency
  String get totalSpentFormatted {
    return '₹${(totalSpent / 100).toStringAsFixed(2)}';
  }

  /// Check if user has active bookings
  bool get hasActiveBookings => pendingBookings > 0;

  /// Check if user has open disputes
  bool get hasOpenDisputes => openDisputes > 0;
}

/// User verification status
class Verification {
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final bool identityVerified;
  final String? identityDocumentType;
  final DateTime? identityVerifiedAt;

  const Verification({
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.identityVerified,
    this.identityDocumentType,
    this.identityVerifiedAt,
  });

  factory Verification.fromJson(Map<String, dynamic> json) {
    return Verification(
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      phoneVerifiedAt: json['phone_verified_at'] != null
          ? DateTime.parse(json['phone_verified_at'] as String)
          : null,
      identityVerified: json['identity_verified'] as bool? ?? false,
      identityDocumentType: json['identity_document_type'] as String?,
      identityVerifiedAt: json['identity_verified_at'] != null
          ? DateTime.parse(json['identity_verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'phone_verified_at': phoneVerifiedAt?.toIso8601String(),
      'identity_verified': identityVerified,
      'identity_document_type': identityDocumentType,
      'identity_verified_at': identityVerifiedAt?.toIso8601String(),
    };
  }

  /// Check if user is fully verified
  bool get isFullyVerified =>
      emailVerifiedAt != null && phoneVerifiedAt != null && identityVerified;

  /// Check if user has basic verification (email + phone)
  bool get hasBasicVerification =>
      emailVerifiedAt != null && phoneVerifiedAt != null;

  /// Get verification level (0-3)
  int get verificationLevel {
    int level = 0;
    if (emailVerifiedAt != null) level++;
    if (phoneVerifiedAt != null) level++;
    if (identityVerified) level++;
    return level;
  }
}

/// User engagement metrics
class Engagement {
  final int totalLogins;
  final int daysSinceRegistration;
  final int daysSinceLastActivity;
  final List<String> favoriteCategories;
  final String? preferredPaymentMethod;
  final String? deviceType;

  const Engagement({
    required this.totalLogins,
    required this.daysSinceRegistration,
    required this.daysSinceLastActivity,
    required this.favoriteCategories,
    this.preferredPaymentMethod,
    this.deviceType,
  });

  factory Engagement.fromJson(Map<String, dynamic> json) {
    return Engagement(
      totalLogins: json['total_logins'] as int? ?? 0,
      daysSinceRegistration: json['days_since_registration'] as int? ?? 0,
      daysSinceLastActivity: json['days_since_last_activity'] as int? ?? 0,
      favoriteCategories:
          (json['favorite_categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferredPaymentMethod: json['preferred_payment_method'] as String?,
      deviceType: json['device_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_logins': totalLogins,
      'days_since_registration': daysSinceRegistration,
      'days_since_last_activity': daysSinceLastActivity,
      'favorite_categories': favoriteCategories,
      'preferred_payment_method': preferredPaymentMethod,
      'device_type': deviceType,
    };
  }

  /// Check if user is recently active (last 7 days)
  bool get isRecentlyActive => daysSinceLastActivity <= 7;

  /// Check if user is dormant (30+ days inactive)
  bool get isDormant => daysSinceLastActivity >= 30;

  /// Get engagement level (low, medium, high)
  String get engagementLevel {
    if (totalLogins > 50 && daysSinceLastActivity < 7) return 'High';
    if (totalLogins > 20 && daysSinceLastActivity < 30) return 'Medium';
    return 'Low';
  }
}

/// Risk indicators and trust score
class RiskIndicators {
  final bool hasPaymentFailures;
  final int failedPaymentCount;
  final bool hasDisputes;
  final double disputeWinRate; // 0-1
  final double cancellationRate; // 0-1
  final int trustScore; // 0-100

  const RiskIndicators({
    required this.hasPaymentFailures,
    required this.failedPaymentCount,
    required this.hasDisputes,
    required this.disputeWinRate,
    required this.cancellationRate,
    required this.trustScore,
  });

  factory RiskIndicators.fromJson(Map<String, dynamic> json) {
    return RiskIndicators(
      hasPaymentFailures: json['has_payment_failures'] as bool? ?? false,
      failedPaymentCount: json['failed_payment_count'] as int? ?? 0,
      hasDisputes: json['has_disputes'] as bool? ?? false,
      disputeWinRate: (json['dispute_win_rate'] as num?)?.toDouble() ?? 0.0,
      cancellationRate: (json['cancellation_rate'] as num?)?.toDouble() ?? 0.0,
      trustScore: json['trust_score'] as int? ?? 75,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_payment_failures': hasPaymentFailures,
      'failed_payment_count': failedPaymentCount,
      'has_disputes': hasDisputes,
      'dispute_win_rate': disputeWinRate,
      'cancellation_rate': cancellationRate,
      'trust_score': trustScore,
    };
  }

  /// Get trust score color for UI
  String get trustScoreColor {
    if (trustScore >= 70) return 'green';
    if (trustScore >= 50) return 'orange';
    return 'red';
  }

  /// Check if user is high risk
  bool get isHighRisk {
    return trustScore < 50 ||
        hasPaymentFailures ||
        cancellationRate > 0.3 ||
        (hasDisputes && disputeWinRate < 0.3);
  }

  /// Check if user needs enhanced verification
  bool get needsEnhancedVerification => trustScore < 50;

  /// Get risk level (low, medium, high, critical)
  String get riskLevel {
    if (trustScore < 30) return 'Critical';
    if (trustScore < 50) return 'High';
    if (trustScore < 70) return 'Medium';
    return 'Low';
  }

  /// Get list of risk flags for display
  List<String> get riskFlags {
    List<String> flags = [];
    if (hasPaymentFailures) {
      flags.add('Payment Failures ($failedPaymentCount)');
    }
    if (cancellationRate > 0.3) {
      flags.add(
        'High Cancellation Rate (${(cancellationRate * 100).toInt()}%)',
      );
    }
    if (hasDisputes && disputeWinRate < 0.5) {
      flags.add('Poor Dispute Resolution History');
    }
    if (trustScore < 50) {
      flags.add('Low Trust Score ($trustScore/100)');
    }
    return flags;
  }
}
