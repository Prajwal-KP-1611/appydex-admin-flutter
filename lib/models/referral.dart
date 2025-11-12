/// Referral model for admin panel
/// Represents a referral relationship between vendors and users/vendors
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'referral.freezed.dart';
part 'referral.g.dart';

/// Referral status enum
enum ReferralStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

/// Extension to get display text for referral status
extension ReferralStatusExtension on ReferralStatus {
  String get displayName {
    switch (this) {
      case ReferralStatus.pending:
        return 'Pending';
      case ReferralStatus.completed:
        return 'Completed';
      case ReferralStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get color for status badge
  String get colorHex {
    switch (this) {
      case ReferralStatus.pending:
        return '#FFA500'; // Orange
      case ReferralStatus.completed:
        return '#28A745'; // Green
      case ReferralStatus.cancelled:
        return '#DC3545'; // Red
    }
  }
}

/// Referrer vendor information
@freezed
class ReferrerVendor with _$ReferrerVendor {
  const factory ReferrerVendor({
    required int id,
    required String name,
    required String email,
  }) = _ReferrerVendor;

  factory ReferrerVendor.fromJson(Map<String, dynamic> json) =>
      _$ReferrerVendorFromJson(json);
}

/// Referred user/vendor information
@freezed
class ReferredEntity with _$ReferredEntity {
  const factory ReferredEntity({
    required int id,
    required String type, // 'user' or 'vendor'
    required String name,
    required String email,
    required String phone,
  }) = _ReferredEntity;

  factory ReferredEntity.fromJson(Map<String, dynamic> json) =>
      _$ReferredEntityFromJson(json);
}

/// Referral list item
@freezed
class ReferralListItem with _$ReferralListItem {
  const factory ReferralListItem({
    required int id,
    ReferrerVendor? referrerVendor,
    ReferredEntity? referred,
    required String referredType,
    required ReferralStatus status,
    String? tier,
    int? milestoneNumber,
    double? bonusAmount,
    required bool milestoneAwarded,
    DateTime? bonusAppliedAt,
    required DateTime createdAt,
  }) = _ReferralListItem;

  factory ReferralListItem.fromJson(Map<String, dynamic> json) =>
      _$ReferralListItemFromJson(json);
}

/// Referrals filters for API requests
@freezed
class ReferralsFilters with _$ReferralsFilters {
  const factory ReferralsFilters({
    @Default(1) int page,
    @Default(25) int pageSize,
    int? referrerId,
    int? referredId,
    ReferralStatus? status,
    String? tier,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    @Default('created_at') String sortBy,
    @Default('desc') String sortOrder,
  }) = _ReferralsFilters;

  factory ReferralsFilters.fromJson(Map<String, dynamic> json) =>
      _$ReferralsFiltersFromJson(json);

  /// Convert to query parameters
  const ReferralsFilters._();

  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (referrerId != null) {
      params['referrer_id'] = referrerId.toString();
    }
    if (referredId != null) {
      params['referred_id'] = referredId.toString();
    }
    if (status != null) {
      params['status'] = status!.name;
    }
    if (tier != null) {
      params['tier'] = tier!;
    }
    if (search != null) {
      params['search'] = search!;
    }
    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String();
    }

    return params;
  }
}
