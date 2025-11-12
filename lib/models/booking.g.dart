// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingUserImpl _$$BookingUserImplFromJson(Map json) => $checkedCreate(
  r'_$BookingUserImpl',
  json,
  ($checkedConvert) {
    final val = _$BookingUserImpl(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      name: $checkedConvert('name', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String),
      displayName: $checkedConvert('display_name', (v) => v as String),
      phone: $checkedConvert('phone', (v) => v as String?),
      totalBookings: $checkedConvert(
        'total_bookings',
        (v) => (v as num?)?.toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'totalBookings': 'total_bookings',
  },
);

Map<String, dynamic> _$$BookingUserImplToJson(_$BookingUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'display_name': instance.displayName,
      'phone': instance.phone,
      'total_bookings': instance.totalBookings,
    };

_$BookingVendorImpl _$$BookingVendorImplFromJson(Map json) => $checkedCreate(
  r'_$BookingVendorImpl',
  json,
  ($checkedConvert) {
    final val = _$BookingVendorImpl(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      displayName: $checkedConvert('display_name', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String),
      phone: $checkedConvert('phone', (v) => v as String?),
      totalBookings: $checkedConvert(
        'total_bookings',
        (v) => (v as num?)?.toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'totalBookings': 'total_bookings',
  },
);

Map<String, dynamic> _$$BookingVendorImplToJson(_$BookingVendorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'email': instance.email,
      'phone': instance.phone,
      'total_bookings': instance.totalBookings,
    };

_$BookingListItemImpl _$$BookingListItemImplFromJson(Map json) =>
    $checkedCreate(
      r'_$BookingListItemImpl',
      json,
      ($checkedConvert) {
        final val = _$BookingListItemImpl(
          id: $checkedConvert('id', (v) => (v as num).toInt()),
          bookingNumber: $checkedConvert('booking_number', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$BookingStatusEnumMap, v),
          ),
          user: $checkedConvert(
            'user',
            (v) => BookingUser.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
          vendor: $checkedConvert(
            'vendor',
            (v) => BookingVendor.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
          serviceId: $checkedConvert('service_id', (v) => (v as num).toInt()),
          scheduledAt: $checkedConvert(
            'scheduled_at',
            (v) => DateTime.parse(v as String),
          ),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'bookingNumber': 'booking_number',
        'serviceId': 'service_id',
        'scheduledAt': 'scheduled_at',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$$BookingListItemImplToJson(
  _$BookingListItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'booking_number': instance.bookingNumber,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'user': instance.user.toJson(),
  'vendor': instance.vendor.toJson(),
  'service_id': instance.serviceId,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.scheduled: 'scheduled',
  BookingStatus.paid: 'paid',
  BookingStatus.completed: 'completed',
  BookingStatus.canceled: 'canceled',
};

_$BookingDetailsImpl _$$BookingDetailsImplFromJson(Map json) => $checkedCreate(
  r'_$BookingDetailsImpl',
  json,
  ($checkedConvert) {
    final val = _$BookingDetailsImpl(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      bookingNumber: $checkedConvert('booking_number', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$BookingStatusEnumMap, v),
      ),
      user: $checkedConvert(
        'user',
        (v) => BookingUser.fromJson(Map<String, dynamic>.from(v as Map)),
      ),
      vendor: $checkedConvert(
        'vendor',
        (v) => BookingVendor.fromJson(Map<String, dynamic>.from(v as Map)),
      ),
      serviceId: $checkedConvert('service_id', (v) => (v as num).toInt()),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => DateTime.parse(v as String),
      ),
      estimatedEndAt: $checkedConvert(
        'estimated_end_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'bookingNumber': 'booking_number',
    'serviceId': 'service_id',
    'scheduledAt': 'scheduled_at',
    'estimatedEndAt': 'estimated_end_at',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'idempotencyKey': 'idempotency_key',
  },
);

Map<String, dynamic> _$$BookingDetailsImplToJson(
  _$BookingDetailsImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'booking_number': instance.bookingNumber,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'user': instance.user.toJson(),
  'vendor': instance.vendor.toJson(),
  'service_id': instance.serviceId,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'estimated_end_at': instance.estimatedEndAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'idempotency_key': instance.idempotencyKey,
};

_$BookingUpdateRequestImpl _$$BookingUpdateRequestImplFromJson(Map json) =>
    $checkedCreate(
      r'_$BookingUpdateRequestImpl',
      json,
      ($checkedConvert) {
        final val = _$BookingUpdateRequestImpl(
          status: $checkedConvert(
            'status',
            (v) => $enumDecodeNullable(_$BookingStatusEnumMap, v),
          ),
          adminNotes: $checkedConvert('admin_notes', (v) => v as String?),
          cancellationReason: $checkedConvert(
            'cancellation_reason',
            (v) => v as String?,
          ),
          notifyUser: $checkedConvert('notify_user', (v) => v as bool? ?? true),
          notifyVendor: $checkedConvert(
            'notify_vendor',
            (v) => v as bool? ?? true,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'adminNotes': 'admin_notes',
        'cancellationReason': 'cancellation_reason',
        'notifyUser': 'notify_user',
        'notifyVendor': 'notify_vendor',
      },
    );

Map<String, dynamic> _$$BookingUpdateRequestImplToJson(
  _$BookingUpdateRequestImpl instance,
) => <String, dynamic>{
  'status': _$BookingStatusEnumMap[instance.status],
  'admin_notes': instance.adminNotes,
  'cancellation_reason': instance.cancellationReason,
  'notify_user': instance.notifyUser,
  'notify_vendor': instance.notifyVendor,
};

_$BookingsFiltersImpl _$$BookingsFiltersImplFromJson(
  Map json,
) => $checkedCreate(
  r'_$BookingsFiltersImpl',
  json,
  ($checkedConvert) {
    final val = _$BookingsFiltersImpl(
      page: $checkedConvert('page', (v) => (v as num?)?.toInt() ?? 1),
      pageSize: $checkedConvert('page_size', (v) => (v as num?)?.toInt() ?? 25),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$BookingStatusEnumMap, v),
      ),
      search: $checkedConvert('search', (v) => v as String?),
      vendorId: $checkedConvert('vendor_id', (v) => (v as num?)?.toInt()),
      userId: $checkedConvert('user_id', (v) => (v as num?)?.toInt()),
      serviceId: $checkedConvert('service_id', (v) => (v as num?)?.toInt()),
      fromDate: $checkedConvert(
        'from_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      toDate: $checkedConvert(
        'to_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      sortBy: $checkedConvert('sort_by', (v) => v as String? ?? 'created_at'),
      sortOrder: $checkedConvert('sort_order', (v) => v as String? ?? 'desc'),
    );
    return val;
  },
  fieldKeyMap: const {
    'pageSize': 'page_size',
    'vendorId': 'vendor_id',
    'userId': 'user_id',
    'serviceId': 'service_id',
    'fromDate': 'from_date',
    'toDate': 'to_date',
    'sortBy': 'sort_by',
    'sortOrder': 'sort_order',
  },
);

Map<String, dynamic> _$$BookingsFiltersImplToJson(
  _$BookingsFiltersImpl instance,
) => <String, dynamic>{
  'page': instance.page,
  'page_size': instance.pageSize,
  'status': _$BookingStatusEnumMap[instance.status],
  'search': instance.search,
  'vendor_id': instance.vendorId,
  'user_id': instance.userId,
  'service_id': instance.serviceId,
  'from_date': instance.fromDate?.toIso8601String(),
  'to_date': instance.toDate?.toIso8601String(),
  'sort_by': instance.sortBy,
  'sort_order': instance.sortOrder,
};
