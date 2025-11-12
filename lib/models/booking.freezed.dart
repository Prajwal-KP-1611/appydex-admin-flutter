// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookingUser _$BookingUserFromJson(Map<String, dynamic> json) {
  return _BookingUser.fromJson(json);
}

/// @nodoc
mixin _$BookingUser {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  int? get totalBookings => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String name,
      String email,
      String displayName,
      String? phone,
      int? totalBookings,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String name,
      String email,
      String displayName,
      String? phone,
      int? totalBookings,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String name,
      String email,
      String displayName,
      String? phone,
      int? totalBookings,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingUser value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingUser value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingUser value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this BookingUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingUserCopyWith<BookingUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingUserCopyWith<$Res> {
  factory $BookingUserCopyWith(
    BookingUser value,
    $Res Function(BookingUser) then,
  ) = _$BookingUserCopyWithImpl<$Res, BookingUser>;
  @useResult
  $Res call({
    int id,
    String name,
    String email,
    String displayName,
    String? phone,
    int? totalBookings,
  });
}

/// @nodoc
class _$BookingUserCopyWithImpl<$Res, $Val extends BookingUser>
    implements $BookingUserCopyWith<$Res> {
  _$BookingUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? displayName = null,
    Object? phone = freezed,
    Object? totalBookings = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalBookings: freezed == totalBookings
                ? _value.totalBookings
                : totalBookings // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookingUserImplCopyWith<$Res>
    implements $BookingUserCopyWith<$Res> {
  factory _$$BookingUserImplCopyWith(
    _$BookingUserImpl value,
    $Res Function(_$BookingUserImpl) then,
  ) = __$$BookingUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String email,
    String displayName,
    String? phone,
    int? totalBookings,
  });
}

/// @nodoc
class __$$BookingUserImplCopyWithImpl<$Res>
    extends _$BookingUserCopyWithImpl<$Res, _$BookingUserImpl>
    implements _$$BookingUserImplCopyWith<$Res> {
  __$$BookingUserImplCopyWithImpl(
    _$BookingUserImpl _value,
    $Res Function(_$BookingUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? displayName = null,
    Object? phone = freezed,
    Object? totalBookings = freezed,
  }) {
    return _then(
      _$BookingUserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalBookings: freezed == totalBookings
            ? _value.totalBookings
            : totalBookings // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingUserImpl implements _BookingUser {
  const _$BookingUserImpl({
    required this.id,
    required this.name,
    required this.email,
    required this.displayName,
    this.phone,
    this.totalBookings,
  });

  factory _$BookingUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingUserImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final String? phone;
  @override
  final int? totalBookings;

  @override
  String toString() {
    return 'BookingUser(id: $id, name: $name, email: $email, displayName: $displayName, phone: $phone, totalBookings: $totalBookings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    email,
    displayName,
    phone,
    totalBookings,
  );

  /// Create a copy of BookingUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingUserImplCopyWith<_$BookingUserImpl> get copyWith =>
      __$$BookingUserImplCopyWithImpl<_$BookingUserImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String name,
      String email,
      String displayName,
      String? phone,
      int? totalBookings,
    )
    $default,
  ) {
    return $default(id, name, email, displayName, phone, totalBookings);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String name,
      String email,
      String displayName,
      String? phone,
      int? totalBookings,
    )?
    $default,
  ) {
    return $default?.call(id, name, email, displayName, phone, totalBookings);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String name,
      String email,
      String displayName,
      String? phone,
      int? totalBookings,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, name, email, displayName, phone, totalBookings);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingUser value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingUser value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingUser value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingUserImplToJson(this);
  }
}

abstract class _BookingUser implements BookingUser {
  const factory _BookingUser({
    required final int id,
    required final String name,
    required final String email,
    required final String displayName,
    final String? phone,
    final int? totalBookings,
  }) = _$BookingUserImpl;

  factory _BookingUser.fromJson(Map<String, dynamic> json) =
      _$BookingUserImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get email;
  @override
  String get displayName;
  @override
  String? get phone;
  @override
  int? get totalBookings;

  /// Create a copy of BookingUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingUserImplCopyWith<_$BookingUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingVendor _$BookingVendorFromJson(Map<String, dynamic> json) {
  return _BookingVendor.fromJson(json);
}

/// @nodoc
mixin _$BookingVendor {
  int get id => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  int? get totalBookings => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String displayName,
      String email,
      String? phone,
      int? totalBookings,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String displayName,
      String email,
      String? phone,
      int? totalBookings,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String displayName,
      String email,
      String? phone,
      int? totalBookings,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingVendor value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingVendor value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingVendor value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this BookingVendor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingVendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingVendorCopyWith<BookingVendor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingVendorCopyWith<$Res> {
  factory $BookingVendorCopyWith(
    BookingVendor value,
    $Res Function(BookingVendor) then,
  ) = _$BookingVendorCopyWithImpl<$Res, BookingVendor>;
  @useResult
  $Res call({
    int id,
    String displayName,
    String email,
    String? phone,
    int? totalBookings,
  });
}

/// @nodoc
class _$BookingVendorCopyWithImpl<$Res, $Val extends BookingVendor>
    implements $BookingVendorCopyWith<$Res> {
  _$BookingVendorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingVendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? email = null,
    Object? phone = freezed,
    Object? totalBookings = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalBookings: freezed == totalBookings
                ? _value.totalBookings
                : totalBookings // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookingVendorImplCopyWith<$Res>
    implements $BookingVendorCopyWith<$Res> {
  factory _$$BookingVendorImplCopyWith(
    _$BookingVendorImpl value,
    $Res Function(_$BookingVendorImpl) then,
  ) = __$$BookingVendorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String displayName,
    String email,
    String? phone,
    int? totalBookings,
  });
}

/// @nodoc
class __$$BookingVendorImplCopyWithImpl<$Res>
    extends _$BookingVendorCopyWithImpl<$Res, _$BookingVendorImpl>
    implements _$$BookingVendorImplCopyWith<$Res> {
  __$$BookingVendorImplCopyWithImpl(
    _$BookingVendorImpl _value,
    $Res Function(_$BookingVendorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingVendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? email = null,
    Object? phone = freezed,
    Object? totalBookings = freezed,
  }) {
    return _then(
      _$BookingVendorImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalBookings: freezed == totalBookings
            ? _value.totalBookings
            : totalBookings // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingVendorImpl implements _BookingVendor {
  const _$BookingVendorImpl({
    required this.id,
    required this.displayName,
    required this.email,
    this.phone,
    this.totalBookings,
  });

  factory _$BookingVendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingVendorImplFromJson(json);

  @override
  final int id;
  @override
  final String displayName;
  @override
  final String email;
  @override
  final String? phone;
  @override
  final int? totalBookings;

  @override
  String toString() {
    return 'BookingVendor(id: $id, displayName: $displayName, email: $email, phone: $phone, totalBookings: $totalBookings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingVendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, displayName, email, phone, totalBookings);

  /// Create a copy of BookingVendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingVendorImplCopyWith<_$BookingVendorImpl> get copyWith =>
      __$$BookingVendorImplCopyWithImpl<_$BookingVendorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String displayName,
      String email,
      String? phone,
      int? totalBookings,
    )
    $default,
  ) {
    return $default(id, displayName, email, phone, totalBookings);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String displayName,
      String email,
      String? phone,
      int? totalBookings,
    )?
    $default,
  ) {
    return $default?.call(id, displayName, email, phone, totalBookings);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String displayName,
      String email,
      String? phone,
      int? totalBookings,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, displayName, email, phone, totalBookings);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingVendor value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingVendor value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingVendor value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingVendorImplToJson(this);
  }
}

abstract class _BookingVendor implements BookingVendor {
  const factory _BookingVendor({
    required final int id,
    required final String displayName,
    required final String email,
    final String? phone,
    final int? totalBookings,
  }) = _$BookingVendorImpl;

  factory _BookingVendor.fromJson(Map<String, dynamic> json) =
      _$BookingVendorImpl.fromJson;

  @override
  int get id;
  @override
  String get displayName;
  @override
  String get email;
  @override
  String? get phone;
  @override
  int? get totalBookings;

  /// Create a copy of BookingVendor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingVendorImplCopyWith<_$BookingVendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingListItem _$BookingListItemFromJson(Map<String, dynamic> json) {
  return _BookingListItem.fromJson(json);
}

/// @nodoc
mixin _$BookingListItem {
  int get id => throw _privateConstructorUsedError;
  String get bookingNumber => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  BookingUser get user => throw _privateConstructorUsedError;
  BookingVendor get vendor => throw _privateConstructorUsedError;
  int get serviceId => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime createdAt,
      DateTime updatedAt,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime createdAt,
      DateTime updatedAt,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime createdAt,
      DateTime updatedAt,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingListItem value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingListItem value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingListItem value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this BookingListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingListItemCopyWith<BookingListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingListItemCopyWith<$Res> {
  factory $BookingListItemCopyWith(
    BookingListItem value,
    $Res Function(BookingListItem) then,
  ) = _$BookingListItemCopyWithImpl<$Res, BookingListItem>;
  @useResult
  $Res call({
    int id,
    String bookingNumber,
    BookingStatus status,
    BookingUser user,
    BookingVendor vendor,
    int serviceId,
    DateTime scheduledAt,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $BookingUserCopyWith<$Res> get user;
  $BookingVendorCopyWith<$Res> get vendor;
}

/// @nodoc
class _$BookingListItemCopyWithImpl<$Res, $Val extends BookingListItem>
    implements $BookingListItemCopyWith<$Res> {
  _$BookingListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingNumber = null,
    Object? status = null,
    Object? user = null,
    Object? vendor = null,
    Object? serviceId = null,
    Object? scheduledAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            bookingNumber: null == bookingNumber
                ? _value.bookingNumber
                : bookingNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BookingStatus,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as BookingUser,
            vendor: null == vendor
                ? _value.vendor
                : vendor // ignore: cast_nullable_to_non_nullable
                      as BookingVendor,
            serviceId: null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as int,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of BookingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingUserCopyWith<$Res> get user {
    return $BookingUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of BookingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingVendorCopyWith<$Res> get vendor {
    return $BookingVendorCopyWith<$Res>(_value.vendor, (value) {
      return _then(_value.copyWith(vendor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingListItemImplCopyWith<$Res>
    implements $BookingListItemCopyWith<$Res> {
  factory _$$BookingListItemImplCopyWith(
    _$BookingListItemImpl value,
    $Res Function(_$BookingListItemImpl) then,
  ) = __$$BookingListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String bookingNumber,
    BookingStatus status,
    BookingUser user,
    BookingVendor vendor,
    int serviceId,
    DateTime scheduledAt,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $BookingUserCopyWith<$Res> get user;
  @override
  $BookingVendorCopyWith<$Res> get vendor;
}

/// @nodoc
class __$$BookingListItemImplCopyWithImpl<$Res>
    extends _$BookingListItemCopyWithImpl<$Res, _$BookingListItemImpl>
    implements _$$BookingListItemImplCopyWith<$Res> {
  __$$BookingListItemImplCopyWithImpl(
    _$BookingListItemImpl _value,
    $Res Function(_$BookingListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingNumber = null,
    Object? status = null,
    Object? user = null,
    Object? vendor = null,
    Object? serviceId = null,
    Object? scheduledAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$BookingListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        bookingNumber: null == bookingNumber
            ? _value.bookingNumber
            : bookingNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BookingStatus,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as BookingUser,
        vendor: null == vendor
            ? _value.vendor
            : vendor // ignore: cast_nullable_to_non_nullable
                  as BookingVendor,
        serviceId: null == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as int,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingListItemImpl implements _BookingListItem {
  const _$BookingListItemImpl({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.user,
    required this.vendor,
    required this.serviceId,
    required this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$BookingListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingListItemImplFromJson(json);

  @override
  final int id;
  @override
  final String bookingNumber;
  @override
  final BookingStatus status;
  @override
  final BookingUser user;
  @override
  final BookingVendor vendor;
  @override
  final int serviceId;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'BookingListItem(id: $id, bookingNumber: $bookingNumber, status: $status, user: $user, vendor: $vendor, serviceId: $serviceId, scheduledAt: $scheduledAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingNumber, bookingNumber) ||
                other.bookingNumber == bookingNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bookingNumber,
    status,
    user,
    vendor,
    serviceId,
    scheduledAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of BookingListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingListItemImplCopyWith<_$BookingListItemImpl> get copyWith =>
      __$$BookingListItemImplCopyWithImpl<_$BookingListItemImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime createdAt,
      DateTime updatedAt,
    )
    $default,
  ) {
    return $default(
      id,
      bookingNumber,
      status,
      user,
      vendor,
      serviceId,
      scheduledAt,
      createdAt,
      updatedAt,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime createdAt,
      DateTime updatedAt,
    )?
    $default,
  ) {
    return $default?.call(
      id,
      bookingNumber,
      status,
      user,
      vendor,
      serviceId,
      scheduledAt,
      createdAt,
      updatedAt,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime createdAt,
      DateTime updatedAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        id,
        bookingNumber,
        status,
        user,
        vendor,
        serviceId,
        scheduledAt,
        createdAt,
        updatedAt,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingListItem value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingListItem value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingListItem value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingListItemImplToJson(this);
  }
}

abstract class _BookingListItem implements BookingListItem {
  const factory _BookingListItem({
    required final int id,
    required final String bookingNumber,
    required final BookingStatus status,
    required final BookingUser user,
    required final BookingVendor vendor,
    required final int serviceId,
    required final DateTime scheduledAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$BookingListItemImpl;

  factory _BookingListItem.fromJson(Map<String, dynamic> json) =
      _$BookingListItemImpl.fromJson;

  @override
  int get id;
  @override
  String get bookingNumber;
  @override
  BookingStatus get status;
  @override
  BookingUser get user;
  @override
  BookingVendor get vendor;
  @override
  int get serviceId;
  @override
  DateTime get scheduledAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of BookingListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingListItemImplCopyWith<_$BookingListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingDetails _$BookingDetailsFromJson(Map<String, dynamic> json) {
  return _BookingDetails.fromJson(json);
}

/// @nodoc
mixin _$BookingDetails {
  int get id => throw _privateConstructorUsedError;
  String get bookingNumber => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  BookingUser get user => throw _privateConstructorUsedError;
  BookingVendor get vendor => throw _privateConstructorUsedError;
  int get serviceId => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get estimatedEndAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get idempotencyKey => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime? estimatedEndAt,
      DateTime createdAt,
      DateTime updatedAt,
      String? idempotencyKey,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime? estimatedEndAt,
      DateTime createdAt,
      DateTime updatedAt,
      String? idempotencyKey,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime? estimatedEndAt,
      DateTime createdAt,
      DateTime updatedAt,
      String? idempotencyKey,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingDetails value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingDetails value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingDetails value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this BookingDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingDetailsCopyWith<BookingDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingDetailsCopyWith<$Res> {
  factory $BookingDetailsCopyWith(
    BookingDetails value,
    $Res Function(BookingDetails) then,
  ) = _$BookingDetailsCopyWithImpl<$Res, BookingDetails>;
  @useResult
  $Res call({
    int id,
    String bookingNumber,
    BookingStatus status,
    BookingUser user,
    BookingVendor vendor,
    int serviceId,
    DateTime scheduledAt,
    DateTime? estimatedEndAt,
    DateTime createdAt,
    DateTime updatedAt,
    String? idempotencyKey,
  });

  $BookingUserCopyWith<$Res> get user;
  $BookingVendorCopyWith<$Res> get vendor;
}

/// @nodoc
class _$BookingDetailsCopyWithImpl<$Res, $Val extends BookingDetails>
    implements $BookingDetailsCopyWith<$Res> {
  _$BookingDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingNumber = null,
    Object? status = null,
    Object? user = null,
    Object? vendor = null,
    Object? serviceId = null,
    Object? scheduledAt = null,
    Object? estimatedEndAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? idempotencyKey = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            bookingNumber: null == bookingNumber
                ? _value.bookingNumber
                : bookingNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BookingStatus,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as BookingUser,
            vendor: null == vendor
                ? _value.vendor
                : vendor // ignore: cast_nullable_to_non_nullable
                      as BookingVendor,
            serviceId: null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as int,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            estimatedEndAt: freezed == estimatedEndAt
                ? _value.estimatedEndAt
                : estimatedEndAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            idempotencyKey: freezed == idempotencyKey
                ? _value.idempotencyKey
                : idempotencyKey // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of BookingDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingUserCopyWith<$Res> get user {
    return $BookingUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of BookingDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingVendorCopyWith<$Res> get vendor {
    return $BookingVendorCopyWith<$Res>(_value.vendor, (value) {
      return _then(_value.copyWith(vendor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingDetailsImplCopyWith<$Res>
    implements $BookingDetailsCopyWith<$Res> {
  factory _$$BookingDetailsImplCopyWith(
    _$BookingDetailsImpl value,
    $Res Function(_$BookingDetailsImpl) then,
  ) = __$$BookingDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String bookingNumber,
    BookingStatus status,
    BookingUser user,
    BookingVendor vendor,
    int serviceId,
    DateTime scheduledAt,
    DateTime? estimatedEndAt,
    DateTime createdAt,
    DateTime updatedAt,
    String? idempotencyKey,
  });

  @override
  $BookingUserCopyWith<$Res> get user;
  @override
  $BookingVendorCopyWith<$Res> get vendor;
}

/// @nodoc
class __$$BookingDetailsImplCopyWithImpl<$Res>
    extends _$BookingDetailsCopyWithImpl<$Res, _$BookingDetailsImpl>
    implements _$$BookingDetailsImplCopyWith<$Res> {
  __$$BookingDetailsImplCopyWithImpl(
    _$BookingDetailsImpl _value,
    $Res Function(_$BookingDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingNumber = null,
    Object? status = null,
    Object? user = null,
    Object? vendor = null,
    Object? serviceId = null,
    Object? scheduledAt = null,
    Object? estimatedEndAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? idempotencyKey = freezed,
  }) {
    return _then(
      _$BookingDetailsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        bookingNumber: null == bookingNumber
            ? _value.bookingNumber
            : bookingNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BookingStatus,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as BookingUser,
        vendor: null == vendor
            ? _value.vendor
            : vendor // ignore: cast_nullable_to_non_nullable
                  as BookingVendor,
        serviceId: null == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as int,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        estimatedEndAt: freezed == estimatedEndAt
            ? _value.estimatedEndAt
            : estimatedEndAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        idempotencyKey: freezed == idempotencyKey
            ? _value.idempotencyKey
            : idempotencyKey // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingDetailsImpl implements _BookingDetails {
  const _$BookingDetailsImpl({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.user,
    required this.vendor,
    required this.serviceId,
    required this.scheduledAt,
    this.estimatedEndAt,
    required this.createdAt,
    required this.updatedAt,
    this.idempotencyKey,
  });

  factory _$BookingDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingDetailsImplFromJson(json);

  @override
  final int id;
  @override
  final String bookingNumber;
  @override
  final BookingStatus status;
  @override
  final BookingUser user;
  @override
  final BookingVendor vendor;
  @override
  final int serviceId;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime? estimatedEndAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? idempotencyKey;

  @override
  String toString() {
    return 'BookingDetails(id: $id, bookingNumber: $bookingNumber, status: $status, user: $user, vendor: $vendor, serviceId: $serviceId, scheduledAt: $scheduledAt, estimatedEndAt: $estimatedEndAt, createdAt: $createdAt, updatedAt: $updatedAt, idempotencyKey: $idempotencyKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingDetailsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingNumber, bookingNumber) ||
                other.bookingNumber == bookingNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.estimatedEndAt, estimatedEndAt) ||
                other.estimatedEndAt == estimatedEndAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.idempotencyKey, idempotencyKey) ||
                other.idempotencyKey == idempotencyKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bookingNumber,
    status,
    user,
    vendor,
    serviceId,
    scheduledAt,
    estimatedEndAt,
    createdAt,
    updatedAt,
    idempotencyKey,
  );

  /// Create a copy of BookingDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingDetailsImplCopyWith<_$BookingDetailsImpl> get copyWith =>
      __$$BookingDetailsImplCopyWithImpl<_$BookingDetailsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime? estimatedEndAt,
      DateTime createdAt,
      DateTime updatedAt,
      String? idempotencyKey,
    )
    $default,
  ) {
    return $default(
      id,
      bookingNumber,
      status,
      user,
      vendor,
      serviceId,
      scheduledAt,
      estimatedEndAt,
      createdAt,
      updatedAt,
      idempotencyKey,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime? estimatedEndAt,
      DateTime createdAt,
      DateTime updatedAt,
      String? idempotencyKey,
    )?
    $default,
  ) {
    return $default?.call(
      id,
      bookingNumber,
      status,
      user,
      vendor,
      serviceId,
      scheduledAt,
      estimatedEndAt,
      createdAt,
      updatedAt,
      idempotencyKey,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String bookingNumber,
      BookingStatus status,
      BookingUser user,
      BookingVendor vendor,
      int serviceId,
      DateTime scheduledAt,
      DateTime? estimatedEndAt,
      DateTime createdAt,
      DateTime updatedAt,
      String? idempotencyKey,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        id,
        bookingNumber,
        status,
        user,
        vendor,
        serviceId,
        scheduledAt,
        estimatedEndAt,
        createdAt,
        updatedAt,
        idempotencyKey,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingDetails value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingDetails value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingDetails value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingDetailsImplToJson(this);
  }
}

abstract class _BookingDetails implements BookingDetails {
  const factory _BookingDetails({
    required final int id,
    required final String bookingNumber,
    required final BookingStatus status,
    required final BookingUser user,
    required final BookingVendor vendor,
    required final int serviceId,
    required final DateTime scheduledAt,
    final DateTime? estimatedEndAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? idempotencyKey,
  }) = _$BookingDetailsImpl;

  factory _BookingDetails.fromJson(Map<String, dynamic> json) =
      _$BookingDetailsImpl.fromJson;

  @override
  int get id;
  @override
  String get bookingNumber;
  @override
  BookingStatus get status;
  @override
  BookingUser get user;
  @override
  BookingVendor get vendor;
  @override
  int get serviceId;
  @override
  DateTime get scheduledAt;
  @override
  DateTime? get estimatedEndAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get idempotencyKey;

  /// Create a copy of BookingDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingDetailsImplCopyWith<_$BookingDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingUpdateRequest _$BookingUpdateRequestFromJson(Map<String, dynamic> json) {
  return _BookingUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$BookingUpdateRequest {
  BookingStatus? get status => throw _privateConstructorUsedError;
  String? get adminNotes => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  bool get notifyUser => throw _privateConstructorUsedError;
  bool get notifyVendor => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      BookingStatus? status,
      String? adminNotes,
      String? cancellationReason,
      bool notifyUser,
      bool notifyVendor,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      BookingStatus? status,
      String? adminNotes,
      String? cancellationReason,
      bool notifyUser,
      bool notifyVendor,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      BookingStatus? status,
      String? adminNotes,
      String? cancellationReason,
      bool notifyUser,
      bool notifyVendor,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingUpdateRequest value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingUpdateRequest value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingUpdateRequest value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this BookingUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingUpdateRequestCopyWith<BookingUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingUpdateRequestCopyWith<$Res> {
  factory $BookingUpdateRequestCopyWith(
    BookingUpdateRequest value,
    $Res Function(BookingUpdateRequest) then,
  ) = _$BookingUpdateRequestCopyWithImpl<$Res, BookingUpdateRequest>;
  @useResult
  $Res call({
    BookingStatus? status,
    String? adminNotes,
    String? cancellationReason,
    bool notifyUser,
    bool notifyVendor,
  });
}

/// @nodoc
class _$BookingUpdateRequestCopyWithImpl<
  $Res,
  $Val extends BookingUpdateRequest
>
    implements $BookingUpdateRequestCopyWith<$Res> {
  _$BookingUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? adminNotes = freezed,
    Object? cancellationReason = freezed,
    Object? notifyUser = null,
    Object? notifyVendor = null,
  }) {
    return _then(
      _value.copyWith(
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BookingStatus?,
            adminNotes: freezed == adminNotes
                ? _value.adminNotes
                : adminNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancellationReason: freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            notifyUser: null == notifyUser
                ? _value.notifyUser
                : notifyUser // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyVendor: null == notifyVendor
                ? _value.notifyVendor
                : notifyVendor // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookingUpdateRequestImplCopyWith<$Res>
    implements $BookingUpdateRequestCopyWith<$Res> {
  factory _$$BookingUpdateRequestImplCopyWith(
    _$BookingUpdateRequestImpl value,
    $Res Function(_$BookingUpdateRequestImpl) then,
  ) = __$$BookingUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BookingStatus? status,
    String? adminNotes,
    String? cancellationReason,
    bool notifyUser,
    bool notifyVendor,
  });
}

/// @nodoc
class __$$BookingUpdateRequestImplCopyWithImpl<$Res>
    extends _$BookingUpdateRequestCopyWithImpl<$Res, _$BookingUpdateRequestImpl>
    implements _$$BookingUpdateRequestImplCopyWith<$Res> {
  __$$BookingUpdateRequestImplCopyWithImpl(
    _$BookingUpdateRequestImpl _value,
    $Res Function(_$BookingUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? adminNotes = freezed,
    Object? cancellationReason = freezed,
    Object? notifyUser = null,
    Object? notifyVendor = null,
  }) {
    return _then(
      _$BookingUpdateRequestImpl(
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BookingStatus?,
        adminNotes: freezed == adminNotes
            ? _value.adminNotes
            : adminNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancellationReason: freezed == cancellationReason
            ? _value.cancellationReason
            : cancellationReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        notifyUser: null == notifyUser
            ? _value.notifyUser
            : notifyUser // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyVendor: null == notifyVendor
            ? _value.notifyVendor
            : notifyVendor // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingUpdateRequestImpl implements _BookingUpdateRequest {
  const _$BookingUpdateRequestImpl({
    this.status,
    this.adminNotes,
    this.cancellationReason,
    this.notifyUser = true,
    this.notifyVendor = true,
  });

  factory _$BookingUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingUpdateRequestImplFromJson(json);

  @override
  final BookingStatus? status;
  @override
  final String? adminNotes;
  @override
  final String? cancellationReason;
  @override
  @JsonKey()
  final bool notifyUser;
  @override
  @JsonKey()
  final bool notifyVendor;

  @override
  String toString() {
    return 'BookingUpdateRequest(status: $status, adminNotes: $adminNotes, cancellationReason: $cancellationReason, notifyUser: $notifyUser, notifyVendor: $notifyVendor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingUpdateRequestImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.notifyUser, notifyUser) ||
                other.notifyUser == notifyUser) &&
            (identical(other.notifyVendor, notifyVendor) ||
                other.notifyVendor == notifyVendor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    adminNotes,
    cancellationReason,
    notifyUser,
    notifyVendor,
  );

  /// Create a copy of BookingUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingUpdateRequestImplCopyWith<_$BookingUpdateRequestImpl>
  get copyWith =>
      __$$BookingUpdateRequestImplCopyWithImpl<_$BookingUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      BookingStatus? status,
      String? adminNotes,
      String? cancellationReason,
      bool notifyUser,
      bool notifyVendor,
    )
    $default,
  ) {
    return $default(
      status,
      adminNotes,
      cancellationReason,
      notifyUser,
      notifyVendor,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      BookingStatus? status,
      String? adminNotes,
      String? cancellationReason,
      bool notifyUser,
      bool notifyVendor,
    )?
    $default,
  ) {
    return $default?.call(
      status,
      adminNotes,
      cancellationReason,
      notifyUser,
      notifyVendor,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      BookingStatus? status,
      String? adminNotes,
      String? cancellationReason,
      bool notifyUser,
      bool notifyVendor,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        status,
        adminNotes,
        cancellationReason,
        notifyUser,
        notifyVendor,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingUpdateRequest value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingUpdateRequest value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingUpdateRequest value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingUpdateRequestImplToJson(this);
  }
}

abstract class _BookingUpdateRequest implements BookingUpdateRequest {
  const factory _BookingUpdateRequest({
    final BookingStatus? status,
    final String? adminNotes,
    final String? cancellationReason,
    final bool notifyUser,
    final bool notifyVendor,
  }) = _$BookingUpdateRequestImpl;

  factory _BookingUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$BookingUpdateRequestImpl.fromJson;

  @override
  BookingStatus? get status;
  @override
  String? get adminNotes;
  @override
  String? get cancellationReason;
  @override
  bool get notifyUser;
  @override
  bool get notifyVendor;

  /// Create a copy of BookingUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingUpdateRequestImplCopyWith<_$BookingUpdateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

BookingsFilters _$BookingsFiltersFromJson(Map<String, dynamic> json) {
  return _BookingsFilters.fromJson(json);
}

/// @nodoc
mixin _$BookingsFilters {
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  BookingStatus? get status => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  int? get vendorId => throw _privateConstructorUsedError;
  int? get userId => throw _privateConstructorUsedError;
  int? get serviceId => throw _privateConstructorUsedError;
  DateTime? get fromDate => throw _privateConstructorUsedError;
  DateTime? get toDate => throw _privateConstructorUsedError;
  String get sortBy => throw _privateConstructorUsedError;
  String get sortOrder => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int page,
      int pageSize,
      BookingStatus? status,
      String? search,
      int? vendorId,
      int? userId,
      int? serviceId,
      DateTime? fromDate,
      DateTime? toDate,
      String sortBy,
      String sortOrder,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int page,
      int pageSize,
      BookingStatus? status,
      String? search,
      int? vendorId,
      int? userId,
      int? serviceId,
      DateTime? fromDate,
      DateTime? toDate,
      String sortBy,
      String sortOrder,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int page,
      int pageSize,
      BookingStatus? status,
      String? search,
      int? vendorId,
      int? userId,
      int? serviceId,
      DateTime? fromDate,
      DateTime? toDate,
      String sortBy,
      String sortOrder,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingsFilters value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingsFilters value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingsFilters value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this BookingsFilters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingsFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingsFiltersCopyWith<BookingsFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingsFiltersCopyWith<$Res> {
  factory $BookingsFiltersCopyWith(
    BookingsFilters value,
    $Res Function(BookingsFilters) then,
  ) = _$BookingsFiltersCopyWithImpl<$Res, BookingsFilters>;
  @useResult
  $Res call({
    int page,
    int pageSize,
    BookingStatus? status,
    String? search,
    int? vendorId,
    int? userId,
    int? serviceId,
    DateTime? fromDate,
    DateTime? toDate,
    String sortBy,
    String sortOrder,
  });
}

/// @nodoc
class _$BookingsFiltersCopyWithImpl<$Res, $Val extends BookingsFilters>
    implements $BookingsFiltersCopyWith<$Res> {
  _$BookingsFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingsFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? pageSize = null,
    Object? status = freezed,
    Object? search = freezed,
    Object? vendorId = freezed,
    Object? userId = freezed,
    Object? serviceId = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
    Object? sortBy = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            pageSize: null == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BookingStatus?,
            search: freezed == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String?,
            vendorId: freezed == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as int?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int?,
            serviceId: freezed == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as int?,
            fromDate: freezed == fromDate
                ? _value.fromDate
                : fromDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            toDate: freezed == toDate
                ? _value.toDate
                : toDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            sortBy: null == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookingsFiltersImplCopyWith<$Res>
    implements $BookingsFiltersCopyWith<$Res> {
  factory _$$BookingsFiltersImplCopyWith(
    _$BookingsFiltersImpl value,
    $Res Function(_$BookingsFiltersImpl) then,
  ) = __$$BookingsFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int page,
    int pageSize,
    BookingStatus? status,
    String? search,
    int? vendorId,
    int? userId,
    int? serviceId,
    DateTime? fromDate,
    DateTime? toDate,
    String sortBy,
    String sortOrder,
  });
}

/// @nodoc
class __$$BookingsFiltersImplCopyWithImpl<$Res>
    extends _$BookingsFiltersCopyWithImpl<$Res, _$BookingsFiltersImpl>
    implements _$$BookingsFiltersImplCopyWith<$Res> {
  __$$BookingsFiltersImplCopyWithImpl(
    _$BookingsFiltersImpl _value,
    $Res Function(_$BookingsFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingsFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? pageSize = null,
    Object? status = freezed,
    Object? search = freezed,
    Object? vendorId = freezed,
    Object? userId = freezed,
    Object? serviceId = freezed,
    Object? fromDate = freezed,
    Object? toDate = freezed,
    Object? sortBy = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _$BookingsFiltersImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        pageSize: null == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BookingStatus?,
        search: freezed == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String?,
        vendorId: freezed == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int?,
        serviceId: freezed == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as int?,
        fromDate: freezed == fromDate
            ? _value.fromDate
            : fromDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        toDate: freezed == toDate
            ? _value.toDate
            : toDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        sortBy: null == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingsFiltersImpl extends _BookingsFilters {
  const _$BookingsFiltersImpl({
    this.page = 1,
    this.pageSize = 25,
    this.status,
    this.search,
    this.vendorId,
    this.userId,
    this.serviceId,
    this.fromDate,
    this.toDate,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
  }) : super._();

  factory _$BookingsFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingsFiltersImplFromJson(json);

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int pageSize;
  @override
  final BookingStatus? status;
  @override
  final String? search;
  @override
  final int? vendorId;
  @override
  final int? userId;
  @override
  final int? serviceId;
  @override
  final DateTime? fromDate;
  @override
  final DateTime? toDate;
  @override
  @JsonKey()
  final String sortBy;
  @override
  @JsonKey()
  final String sortOrder;

  @override
  String toString() {
    return 'BookingsFilters(page: $page, pageSize: $pageSize, status: $status, search: $search, vendorId: $vendorId, userId: $userId, serviceId: $serviceId, fromDate: $fromDate, toDate: $toDate, sortBy: $sortBy, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingsFiltersImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.fromDate, fromDate) ||
                other.fromDate == fromDate) &&
            (identical(other.toDate, toDate) || other.toDate == toDate) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    page,
    pageSize,
    status,
    search,
    vendorId,
    userId,
    serviceId,
    fromDate,
    toDate,
    sortBy,
    sortOrder,
  );

  /// Create a copy of BookingsFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingsFiltersImplCopyWith<_$BookingsFiltersImpl> get copyWith =>
      __$$BookingsFiltersImplCopyWithImpl<_$BookingsFiltersImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int page,
      int pageSize,
      BookingStatus? status,
      String? search,
      int? vendorId,
      int? userId,
      int? serviceId,
      DateTime? fromDate,
      DateTime? toDate,
      String sortBy,
      String sortOrder,
    )
    $default,
  ) {
    return $default(
      page,
      pageSize,
      status,
      search,
      vendorId,
      userId,
      serviceId,
      fromDate,
      toDate,
      sortBy,
      sortOrder,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int page,
      int pageSize,
      BookingStatus? status,
      String? search,
      int? vendorId,
      int? userId,
      int? serviceId,
      DateTime? fromDate,
      DateTime? toDate,
      String sortBy,
      String sortOrder,
    )?
    $default,
  ) {
    return $default?.call(
      page,
      pageSize,
      status,
      search,
      vendorId,
      userId,
      serviceId,
      fromDate,
      toDate,
      sortBy,
      sortOrder,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int page,
      int pageSize,
      BookingStatus? status,
      String? search,
      int? vendorId,
      int? userId,
      int? serviceId,
      DateTime? fromDate,
      DateTime? toDate,
      String sortBy,
      String sortOrder,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        page,
        pageSize,
        status,
        search,
        vendorId,
        userId,
        serviceId,
        fromDate,
        toDate,
        sortBy,
        sortOrder,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BookingsFilters value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BookingsFilters value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BookingsFilters value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingsFiltersImplToJson(this);
  }
}

abstract class _BookingsFilters extends BookingsFilters {
  const factory _BookingsFilters({
    final int page,
    final int pageSize,
    final BookingStatus? status,
    final String? search,
    final int? vendorId,
    final int? userId,
    final int? serviceId,
    final DateTime? fromDate,
    final DateTime? toDate,
    final String sortBy,
    final String sortOrder,
  }) = _$BookingsFiltersImpl;
  const _BookingsFilters._() : super._();

  factory _BookingsFilters.fromJson(Map<String, dynamic> json) =
      _$BookingsFiltersImpl.fromJson;

  @override
  int get page;
  @override
  int get pageSize;
  @override
  BookingStatus? get status;
  @override
  String? get search;
  @override
  int? get vendorId;
  @override
  int? get userId;
  @override
  int? get serviceId;
  @override
  DateTime? get fromDate;
  @override
  DateTime? get toDate;
  @override
  String get sortBy;
  @override
  String get sortOrder;

  /// Create a copy of BookingsFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingsFiltersImplCopyWith<_$BookingsFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
