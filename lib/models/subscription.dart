/// Subscription model aligned with /api/v1/admin/subscriptions
class Subscription {
  const Subscription({
    required this.id,
    required this.vendorId,
    required this.planId,
    required this.status,
    required this.startsAt,
    required this.expiresAt,
    required this.createdAt,
    this.vendorName,
    this.planName,
    this.autoRenew = true,
  });

  final int id;
  final int vendorId;
  final String? vendorName;
  final int planId;
  final String? planName;
  final String status; // 'active', 'expired', 'cancelled'
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool autoRenew;
  final DateTime createdAt;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int? ?? 0,
      vendorId: json['vendor_id'] as int? ?? 0,
      vendorName: json['vendor_name'] as String?,
      planId: json['plan_id'] as int? ?? 0,
      planName: json['plan_name'] as String?,
      status: json['status'] as String? ?? 'active',
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'] as String)
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : DateTime.now(),
      autoRenew: json['auto_renew'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      if (vendorName != null) 'vendor_name': vendorName,
      'plan_id': planId,
      if (planName != null) 'plan_name': planName,
      'status': status,
      'starts_at': startsAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'auto_renew': autoRenew,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';
}

/// Subscription cancellation result
class SubscriptionCancellationResult {
  const SubscriptionCancellationResult({
    required this.subscriptionId,
    required this.status,
    required this.cancelledAt,
    this.effectiveUntil,
  });

  final int subscriptionId;
  final String status;
  final DateTime cancelledAt;
  final DateTime? effectiveUntil;

  factory SubscriptionCancellationResult.fromJson(Map<String, dynamic> json) {
    return SubscriptionCancellationResult(
      subscriptionId: json['subscription_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : DateTime.now(),
      effectiveUntil: json['effective_until'] != null
          ? DateTime.tryParse(json['effective_until'] as String)
          : null,
    );
  }
}

/// Subscription extension result
class SubscriptionExtensionResult {
  const SubscriptionExtensionResult({
    required this.subscriptionId,
    required this.extendedByDays,
    required this.oldExpiresAt,
    required this.newExpiresAt,
    this.reason,
  });

  final int subscriptionId;
  final int extendedByDays;
  final DateTime oldExpiresAt;
  final DateTime newExpiresAt;
  final String? reason;

  factory SubscriptionExtensionResult.fromJson(Map<String, dynamic> json) {
    return SubscriptionExtensionResult(
      subscriptionId: json['subscription_id'] as int? ?? 0,
      extendedByDays: json['extended_by_days'] as int? ?? 0,
      oldExpiresAt: json['old_expires_at'] != null
          ? DateTime.parse(json['old_expires_at'] as String)
          : DateTime.now(),
      newExpiresAt: json['new_expires_at'] != null
          ? DateTime.parse(json['new_expires_at'] as String)
          : DateTime.now(),
      reason: json['reason'] as String?,
    );
  }
}
