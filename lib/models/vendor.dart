class Vendor {
  Vendor({
    required this.id,
    required this.name,
    required this.ownerEmail,
    required this.phone,
    required this.planCode,
    required this.isActive,
    required this.isVerified,
    required this.onboardingScore,
    required this.createdAt,
    this.notes,
  });

  final int id;
  final String name;
  final String ownerEmail;
  final String? phone;
  final String? planCode;
  final bool isActive;
  final bool isVerified;
  final double onboardingScore;
  final DateTime createdAt;
  final String? notes;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unnamed Vendor',
      ownerEmail: json['owner_email'] as String? ?? '',
      phone: json['phone'] as String?,
      planCode: json['plan_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      onboardingScore: (json['onboarding_score'] as num?)?.toDouble() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_email': ownerEmail,
      'phone': phone,
      'plan_code': planCode,
      'is_active': isActive,
      'is_verified': isVerified,
      'onboarding_score': onboardingScore,
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  Vendor copyWith({
    String? name,
    String? ownerEmail,
    String? phone,
    String? planCode,
    bool? isActive,
    bool? isVerified,
    double? onboardingScore,
    DateTime? createdAt,
    String? notes,
  }) {
    return Vendor(
      id: id,
      name: name ?? this.name,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      phone: phone ?? this.phone,
      planCode: planCode ?? this.planCode,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      onboardingScore: onboardingScore ?? this.onboardingScore,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}
