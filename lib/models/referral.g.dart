// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferrerVendorImpl _$$ReferrerVendorImplFromJson(Map json) =>
    $checkedCreate(r'_$ReferrerVendorImpl', json, ($checkedConvert) {
      final val = _$ReferrerVendorImpl(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$$ReferrerVendorImplToJson(
  _$ReferrerVendorImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
};

_$ReferredEntityImpl _$$ReferredEntityImplFromJson(Map json) =>
    $checkedCreate(r'_$ReferredEntityImpl', json, ($checkedConvert) {
      final val = _$ReferredEntityImpl(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        type: $checkedConvert('type', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$$ReferredEntityImplToJson(
  _$ReferredEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
};

_$ReferralListItemImpl _$$ReferralListItemImplFromJson(Map json) =>
    $checkedCreate(
      r'_$ReferralListItemImpl',
      json,
      ($checkedConvert) {
        final val = _$ReferralListItemImpl(
          id: $checkedConvert('id', (v) => (v as num).toInt()),
          referrerVendor: $checkedConvert(
            'referrer_vendor',
            (v) => v == null
                ? null
                : ReferrerVendor.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
          referred: $checkedConvert(
            'referred',
            (v) => v == null
                ? null
                : ReferredEntity.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
          referredType: $checkedConvert('referred_type', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$ReferralStatusEnumMap, v),
          ),
          tier: $checkedConvert('tier', (v) => v as String?),
          milestoneNumber: $checkedConvert(
            'milestone_number',
            (v) => (v as num?)?.toInt(),
          ),
          bonusAmount: $checkedConvert(
            'bonus_amount',
            (v) => (v as num?)?.toDouble(),
          ),
          milestoneAwarded: $checkedConvert(
            'milestone_awarded',
            (v) => v as bool,
          ),
          bonusAppliedAt: $checkedConvert(
            'bonus_applied_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'referrerVendor': 'referrer_vendor',
        'referredType': 'referred_type',
        'milestoneNumber': 'milestone_number',
        'bonusAmount': 'bonus_amount',
        'milestoneAwarded': 'milestone_awarded',
        'bonusAppliedAt': 'bonus_applied_at',
        'createdAt': 'created_at',
      },
    );

Map<String, dynamic> _$$ReferralListItemImplToJson(
  _$ReferralListItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'referrer_vendor': instance.referrerVendor?.toJson(),
  'referred': instance.referred?.toJson(),
  'referred_type': instance.referredType,
  'status': _$ReferralStatusEnumMap[instance.status]!,
  'tier': instance.tier,
  'milestone_number': instance.milestoneNumber,
  'bonus_amount': instance.bonusAmount,
  'milestone_awarded': instance.milestoneAwarded,
  'bonus_applied_at': instance.bonusAppliedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$ReferralStatusEnumMap = {
  ReferralStatus.pending: 'pending',
  ReferralStatus.completed: 'completed',
  ReferralStatus.cancelled: 'cancelled',
};

_$ReferralsFiltersImpl _$$ReferralsFiltersImplFromJson(
  Map json,
) => $checkedCreate(
  r'_$ReferralsFiltersImpl',
  json,
  ($checkedConvert) {
    final val = _$ReferralsFiltersImpl(
      page: $checkedConvert('page', (v) => (v as num?)?.toInt() ?? 1),
      pageSize: $checkedConvert('page_size', (v) => (v as num?)?.toInt() ?? 25),
      referrerId: $checkedConvert('referrer_id', (v) => (v as num?)?.toInt()),
      referredId: $checkedConvert('referred_id', (v) => (v as num?)?.toInt()),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$ReferralStatusEnumMap, v),
      ),
      tier: $checkedConvert('tier', (v) => v as String?),
      search: $checkedConvert('search', (v) => v as String?),
      startDate: $checkedConvert(
        'start_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      endDate: $checkedConvert(
        'end_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      sortBy: $checkedConvert('sort_by', (v) => v as String? ?? 'created_at'),
      sortOrder: $checkedConvert('sort_order', (v) => v as String? ?? 'desc'),
    );
    return val;
  },
  fieldKeyMap: const {
    'pageSize': 'page_size',
    'referrerId': 'referrer_id',
    'referredId': 'referred_id',
    'startDate': 'start_date',
    'endDate': 'end_date',
    'sortBy': 'sort_by',
    'sortOrder': 'sort_order',
  },
);

Map<String, dynamic> _$$ReferralsFiltersImplToJson(
  _$ReferralsFiltersImpl instance,
) => <String, dynamic>{
  'page': instance.page,
  'page_size': instance.pageSize,
  'referrer_id': instance.referrerId,
  'referred_id': instance.referredId,
  'status': _$ReferralStatusEnumMap[instance.status],
  'tier': instance.tier,
  'search': instance.search,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'sort_by': instance.sortBy,
  'sort_order': instance.sortOrder,
};
