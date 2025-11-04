/// Promo Ledger Entry model
class PromoLedgerEntry {
  const PromoLedgerEntry({
    required this.id,
    required this.vendorId,
    required this.daysCredited,
    required this.campaignType,
    required this.createdAt,
    this.vendorName,
    this.description,
  });

  final int id;
  final int vendorId;
  final String? vendorName;
  final int daysCredited;
  final String
  campaignType; // 'referral_bonus', 'signup_bonus', 'admin_compensation', etc.
  final String? description;
  final DateTime createdAt;

  factory PromoLedgerEntry.fromJson(Map<String, dynamic> json) {
    return PromoLedgerEntry(
      id: json['id'] as int? ?? 0,
      vendorId: json['vendor_id'] as int? ?? 0,
      vendorName: json['vendor_name'] as String?,
      daysCredited: json['days_credited'] as int? ?? 0,
      campaignType: json['campaign_type'] as String? ?? '',
      description: json['description'] as String?,
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
      'days_credited': daysCredited,
      'campaign_type': campaignType,
      if (description != null) 'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Referral model
class Referral {
  const Referral({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.status,
    required this.createdAt,
    this.referrerName,
    this.referredName,
    this.creditedAt,
  });

  final int id;
  final int referrerId;
  final String? referrerName;
  final int referredId;
  final String? referredName;
  final String status; // 'pending', 'credited', 'expired'
  final DateTime? creditedAt;
  final DateTime createdAt;

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as int? ?? 0,
      referrerId: json['referrer_id'] as int? ?? 0,
      referrerName: json['referrer_name'] as String?,
      referredId: json['referred_id'] as int? ?? 0,
      referredName: json['referred_name'] as String?,
      status: json['status'] as String? ?? 'pending',
      creditedAt: json['credited_at'] != null
          ? DateTime.tryParse(json['credited_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isCredited => status == 'credited';
  bool get isExpired => status == 'expired';
}

/// Referral Code model
class ReferralCode {
  const ReferralCode({
    required this.id,
    required this.userId,
    required this.code,
    required this.usageCount,
    required this.isActive,
    required this.createdAt,
    this.userName,
  });

  final int id;
  final int userId;
  final String? userName;
  final String code;
  final int usageCount;
  final bool isActive;
  final DateTime createdAt;

  factory ReferralCode.fromJson(Map<String, dynamic> json) {
    return ReferralCode(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String?,
      code: json['code'] as String? ?? '',
      usageCount: json['usage_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Campaign Statistics model
class CampaignStats {
  const CampaignStats({
    required this.promoDaysByCampaign,
    required this.referrals,
    required this.activeReferralCodes,
    required this.totalPromoDaysCredited,
  });

  final Map<String, int> promoDaysByCampaign;
  final ReferralStats referrals;
  final int activeReferralCodes;
  final int totalPromoDaysCredited;

  factory CampaignStats.fromJson(Map<String, dynamic> json) {
    return CampaignStats(
      promoDaysByCampaign:
          (json['promo_days_by_campaign'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int? ?? 0),
          ) ??
          {},
      referrals: ReferralStats.fromJson(
        json['referrals'] as Map<String, dynamic>? ?? {},
      ),
      activeReferralCodes: json['active_referral_codes'] as int? ?? 0,
      totalPromoDaysCredited: json['total_promo_days_credited'] as int? ?? 0,
    );
  }
}

/// Referral Statistics model
class ReferralStats {
  const ReferralStats({
    required this.total,
    required this.pending,
    required this.credited,
  });

  final int total;
  final int pending;
  final int credited;

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      credited: json['credited'] as int? ?? 0,
    );
  }
}

/// Vendor Referral Snapshot model
class VendorReferralSnapshot {
  const VendorReferralSnapshot({
    required this.vendorId,
    required this.referralsMade,
    required this.referralsCredited,
    required this.totalPromoDaysEarned,
    this.activeReferralCode,
    this.referrals = const [],
  });

  final int vendorId;
  final int referralsMade;
  final int referralsCredited;
  final int totalPromoDaysEarned;
  final String? activeReferralCode;
  final List<Referral> referrals;

  factory VendorReferralSnapshot.fromJson(Map<String, dynamic> json) {
    return VendorReferralSnapshot(
      vendorId: json['vendor_id'] as int? ?? 0,
      referralsMade: json['referrals_made'] as int? ?? 0,
      referralsCredited: json['referrals_credited'] as int? ?? 0,
      totalPromoDaysEarned: json['total_promo_days_earned'] as int? ?? 0,
      activeReferralCode: json['active_referral_code'] as String?,
      referrals:
          (json['referrals'] as List<dynamic>?)
              ?.map((item) => Referral.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
