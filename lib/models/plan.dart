/// Subscription Plan model
/// Aligned with /api/v1/admin/plans
class Plan {
  const Plan({
    required this.id,
    required this.code,
    required this.name,
    required this.priceCents,
    required this.billingPeriodDays,
    required this.isActive,
    this.description,
    this.trialPeriodDays,
    this.features,
    this.subscriberCount,
    this.createdAt,
  });

  final int id;
  final String code;
  final String name;
  final String? description;
  final int priceCents;
  final int billingPeriodDays;
  final int? trialPeriodDays;
  final Map<String, dynamic>? features;
  final bool isActive;
  final int? subscriberCount;
  final DateTime? createdAt;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      priceCents: json['price_cents'] as int? ?? 0,
      billingPeriodDays: json['billing_period_days'] as int? ?? 30,
      trialPeriodDays: json['trial_period_days'] as int?,
      features: json['features'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      subscriberCount: json['subscriber_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (description != null) 'description': description,
      'price_cents': priceCents,
      'billing_period_days': billingPeriodDays,
      if (trialPeriodDays != null) 'trial_period_days': trialPeriodDays,
      if (features != null) 'features': features,
      'is_active': isActive,
      if (subscriberCount != null) 'subscriber_count': subscriberCount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  String get priceDisplay => '\$${(priceCents / 100).toStringAsFixed(2)}';

  String get billingPeriodDisplay {
    if (billingPeriodDays == 30) return 'Monthly';
    if (billingPeriodDays == 365) return 'Yearly';
    return '$billingPeriodDays days';
  }
}

/// Request model for creating/updating plans
class PlanRequest {
  const PlanRequest({
    required this.code,
    required this.name,
    required this.priceCents,
    this.description,
    this.billingPeriodDays = 30,
    this.trialPeriodDays,
    this.features,
  });

  final String code;
  final String name;
  final String? description;
  final int priceCents;
  final int billingPeriodDays;
  final int? trialPeriodDays;
  final Map<String, dynamic>? features;

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'price_cents': priceCents,
    'billing_period_days': billingPeriodDays,
    if (trialPeriodDays != null) 'trial_period_days': trialPeriodDays,
    if (features != null) 'features': features,
  };
}
