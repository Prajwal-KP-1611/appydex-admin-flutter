/// Subscription Plan model
/// Aligned with /api/v1/admin/plans
class Plan {
  const Plan({
    required this.id,
    required this.code,
    required this.name,
    required this.priceCents,
    required this.durationDays,
    required this.isActive,
    this.description,
    this.trialDays,
    this.promoDays,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String code;
  final String name;
  final String? description;
  final int priceCents;
  final int durationDays;
  final int? trialDays;
  final int? promoDays;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      priceCents: json['price_cents'] as int? ?? 0,
      durationDays: json['duration_days'] as int? ?? 30,
      trialDays: json['trial_days'] as int? ?? 0,
      promoDays: json['promo_days'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
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
      'duration_days': durationDays,
      if (trialDays != null) 'trial_days': trialDays,
      if (promoDays != null) 'promo_days': promoDays,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  String get priceDisplay => '₹${(priceCents / 100).toStringAsFixed(2)}';

  String get durationDisplay {
    if (durationDays == 30) return 'Monthly (30 days)';
    if (durationDays == 365) return 'Yearly (365 days)';
    if (durationDays % 30 == 0) {
      return '${durationDays ~/ 30} Months ($durationDays days)';
    }
    return '$durationDays days';
  }

  String get statusLabel => isActive ? 'Active' : 'Inactive';
}

/// Request model for creating/updating plans
class PlanRequest {
  const PlanRequest({
    required this.code,
    required this.name,
    required this.priceCents,
    this.description,
    this.durationDays = 30,
    this.trialDays = 0,
    this.promoDays = 0,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String? description;
  final int priceCents;
  final int durationDays;
  final int trialDays;
  final int promoDays;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'price_cents': priceCents,
    'duration_days': durationDays,
    'trial_days': trialDays,
    'promo_days': promoDays,
    'is_active': isActive,
  };
}
