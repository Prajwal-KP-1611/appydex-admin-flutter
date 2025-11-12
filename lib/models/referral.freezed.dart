// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReferrerVendor _$ReferrerVendorFromJson(Map<String, dynamic> json) {
  return _ReferrerVendor.fromJson(json);
}

/// @nodoc
mixin _$ReferrerVendor {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int id, String name, String email) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int id, String name, String email)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int id, String name, String email)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferrerVendor value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferrerVendor value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferrerVendor value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ReferrerVendor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferrerVendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferrerVendorCopyWith<ReferrerVendor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferrerVendorCopyWith<$Res> {
  factory $ReferrerVendorCopyWith(
    ReferrerVendor value,
    $Res Function(ReferrerVendor) then,
  ) = _$ReferrerVendorCopyWithImpl<$Res, ReferrerVendor>;
  @useResult
  $Res call({int id, String name, String email});
}

/// @nodoc
class _$ReferrerVendorCopyWithImpl<$Res, $Val extends ReferrerVendor>
    implements $ReferrerVendorCopyWith<$Res> {
  _$ReferrerVendorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferrerVendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? email = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReferrerVendorImplCopyWith<$Res>
    implements $ReferrerVendorCopyWith<$Res> {
  factory _$$ReferrerVendorImplCopyWith(
    _$ReferrerVendorImpl value,
    $Res Function(_$ReferrerVendorImpl) then,
  ) = __$$ReferrerVendorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String email});
}

/// @nodoc
class __$$ReferrerVendorImplCopyWithImpl<$Res>
    extends _$ReferrerVendorCopyWithImpl<$Res, _$ReferrerVendorImpl>
    implements _$$ReferrerVendorImplCopyWith<$Res> {
  __$$ReferrerVendorImplCopyWithImpl(
    _$ReferrerVendorImpl _value,
    $Res Function(_$ReferrerVendorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferrerVendor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? email = null}) {
    return _then(
      _$ReferrerVendorImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferrerVendorImpl implements _ReferrerVendor {
  const _$ReferrerVendorImpl({
    required this.id,
    required this.name,
    required this.email,
  });

  factory _$ReferrerVendorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferrerVendorImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String email;

  @override
  String toString() {
    return 'ReferrerVendor(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferrerVendorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email);

  /// Create a copy of ReferrerVendor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferrerVendorImplCopyWith<_$ReferrerVendorImpl> get copyWith =>
      __$$ReferrerVendorImplCopyWithImpl<_$ReferrerVendorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int id, String name, String email) $default,
  ) {
    return $default(id, name, email);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int id, String name, String email)? $default,
  ) {
    return $default?.call(id, name, email);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int id, String name, String email)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, name, email);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferrerVendor value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferrerVendor value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferrerVendor value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferrerVendorImplToJson(this);
  }
}

abstract class _ReferrerVendor implements ReferrerVendor {
  const factory _ReferrerVendor({
    required final int id,
    required final String name,
    required final String email,
  }) = _$ReferrerVendorImpl;

  factory _ReferrerVendor.fromJson(Map<String, dynamic> json) =
      _$ReferrerVendorImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get email;

  /// Create a copy of ReferrerVendor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferrerVendorImplCopyWith<_$ReferrerVendorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferredEntity _$ReferredEntityFromJson(Map<String, dynamic> json) {
  return _ReferredEntity.fromJson(json);
}

/// @nodoc
mixin _$ReferredEntity {
  int get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // 'user' or 'vendor'
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String type,
      String name,
      String email,
      String phone,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String type,
      String name,
      String email,
      String phone,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String type,
      String name,
      String email,
      String phone,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferredEntity value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferredEntity value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferredEntity value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ReferredEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferredEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferredEntityCopyWith<ReferredEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferredEntityCopyWith<$Res> {
  factory $ReferredEntityCopyWith(
    ReferredEntity value,
    $Res Function(ReferredEntity) then,
  ) = _$ReferredEntityCopyWithImpl<$Res, ReferredEntity>;
  @useResult
  $Res call({int id, String type, String name, String email, String phone});
}

/// @nodoc
class _$ReferredEntityCopyWithImpl<$Res, $Val extends ReferredEntity>
    implements $ReferredEntityCopyWith<$Res> {
  _$ReferredEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferredEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReferredEntityImplCopyWith<$Res>
    implements $ReferredEntityCopyWith<$Res> {
  factory _$$ReferredEntityImplCopyWith(
    _$ReferredEntityImpl value,
    $Res Function(_$ReferredEntityImpl) then,
  ) = __$$ReferredEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String type, String name, String email, String phone});
}

/// @nodoc
class __$$ReferredEntityImplCopyWithImpl<$Res>
    extends _$ReferredEntityCopyWithImpl<$Res, _$ReferredEntityImpl>
    implements _$$ReferredEntityImplCopyWith<$Res> {
  __$$ReferredEntityImplCopyWithImpl(
    _$ReferredEntityImpl _value,
    $Res Function(_$ReferredEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferredEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
  }) {
    return _then(
      _$ReferredEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferredEntityImpl implements _ReferredEntity {
  const _$ReferredEntityImpl({
    required this.id,
    required this.type,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory _$ReferredEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferredEntityImplFromJson(json);

  @override
  final int id;
  @override
  final String type;
  // 'user' or 'vendor'
  @override
  final String name;
  @override
  final String email;
  @override
  final String phone;

  @override
  String toString() {
    return 'ReferredEntity(id: $id, type: $type, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferredEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, name, email, phone);

  /// Create a copy of ReferredEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferredEntityImplCopyWith<_$ReferredEntityImpl> get copyWith =>
      __$$ReferredEntityImplCopyWithImpl<_$ReferredEntityImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      String type,
      String name,
      String email,
      String phone,
    )
    $default,
  ) {
    return $default(id, type, name, email, phone);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      String type,
      String name,
      String email,
      String phone,
    )?
    $default,
  ) {
    return $default?.call(id, type, name, email, phone);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      String type,
      String name,
      String email,
      String phone,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, type, name, email, phone);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferredEntity value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferredEntity value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferredEntity value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferredEntityImplToJson(this);
  }
}

abstract class _ReferredEntity implements ReferredEntity {
  const factory _ReferredEntity({
    required final int id,
    required final String type,
    required final String name,
    required final String email,
    required final String phone,
  }) = _$ReferredEntityImpl;

  factory _ReferredEntity.fromJson(Map<String, dynamic> json) =
      _$ReferredEntityImpl.fromJson;

  @override
  int get id;
  @override
  String get type; // 'user' or 'vendor'
  @override
  String get name;
  @override
  String get email;
  @override
  String get phone;

  /// Create a copy of ReferredEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferredEntityImplCopyWith<_$ReferredEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralListItem _$ReferralListItemFromJson(Map<String, dynamic> json) {
  return _ReferralListItem.fromJson(json);
}

/// @nodoc
mixin _$ReferralListItem {
  int get id => throw _privateConstructorUsedError;
  ReferrerVendor? get referrerVendor => throw _privateConstructorUsedError;
  ReferredEntity? get referred => throw _privateConstructorUsedError;
  String get referredType => throw _privateConstructorUsedError;
  ReferralStatus get status => throw _privateConstructorUsedError;
  String? get tier => throw _privateConstructorUsedError;
  int? get milestoneNumber => throw _privateConstructorUsedError;
  double? get bonusAmount => throw _privateConstructorUsedError;
  bool get milestoneAwarded => throw _privateConstructorUsedError;
  DateTime? get bonusAppliedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      ReferrerVendor? referrerVendor,
      ReferredEntity? referred,
      String referredType,
      ReferralStatus status,
      String? tier,
      int? milestoneNumber,
      double? bonusAmount,
      bool milestoneAwarded,
      DateTime? bonusAppliedAt,
      DateTime createdAt,
    )
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      ReferrerVendor? referrerVendor,
      ReferredEntity? referred,
      String referredType,
      ReferralStatus status,
      String? tier,
      int? milestoneNumber,
      double? bonusAmount,
      bool milestoneAwarded,
      DateTime? bonusAppliedAt,
      DateTime createdAt,
    )?
    $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      ReferrerVendor? referrerVendor,
      ReferredEntity? referred,
      String referredType,
      ReferralStatus status,
      String? tier,
      int? milestoneNumber,
      double? bonusAmount,
      bool milestoneAwarded,
      DateTime? bonusAppliedAt,
      DateTime createdAt,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferralListItem value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferralListItem value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferralListItem value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ReferralListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferralListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferralListItemCopyWith<ReferralListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralListItemCopyWith<$Res> {
  factory $ReferralListItemCopyWith(
    ReferralListItem value,
    $Res Function(ReferralListItem) then,
  ) = _$ReferralListItemCopyWithImpl<$Res, ReferralListItem>;
  @useResult
  $Res call({
    int id,
    ReferrerVendor? referrerVendor,
    ReferredEntity? referred,
    String referredType,
    ReferralStatus status,
    String? tier,
    int? milestoneNumber,
    double? bonusAmount,
    bool milestoneAwarded,
    DateTime? bonusAppliedAt,
    DateTime createdAt,
  });

  $ReferrerVendorCopyWith<$Res>? get referrerVendor;
  $ReferredEntityCopyWith<$Res>? get referred;
}

/// @nodoc
class _$ReferralListItemCopyWithImpl<$Res, $Val extends ReferralListItem>
    implements $ReferralListItemCopyWith<$Res> {
  _$ReferralListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferralListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? referrerVendor = freezed,
    Object? referred = freezed,
    Object? referredType = null,
    Object? status = null,
    Object? tier = freezed,
    Object? milestoneNumber = freezed,
    Object? bonusAmount = freezed,
    Object? milestoneAwarded = null,
    Object? bonusAppliedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            referrerVendor: freezed == referrerVendor
                ? _value.referrerVendor
                : referrerVendor // ignore: cast_nullable_to_non_nullable
                      as ReferrerVendor?,
            referred: freezed == referred
                ? _value.referred
                : referred // ignore: cast_nullable_to_non_nullable
                      as ReferredEntity?,
            referredType: null == referredType
                ? _value.referredType
                : referredType // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReferralStatus,
            tier: freezed == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String?,
            milestoneNumber: freezed == milestoneNumber
                ? _value.milestoneNumber
                : milestoneNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            bonusAmount: freezed == bonusAmount
                ? _value.bonusAmount
                : bonusAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            milestoneAwarded: null == milestoneAwarded
                ? _value.milestoneAwarded
                : milestoneAwarded // ignore: cast_nullable_to_non_nullable
                      as bool,
            bonusAppliedAt: freezed == bonusAppliedAt
                ? _value.bonusAppliedAt
                : bonusAppliedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of ReferralListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReferrerVendorCopyWith<$Res>? get referrerVendor {
    if (_value.referrerVendor == null) {
      return null;
    }

    return $ReferrerVendorCopyWith<$Res>(_value.referrerVendor!, (value) {
      return _then(_value.copyWith(referrerVendor: value) as $Val);
    });
  }

  /// Create a copy of ReferralListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReferredEntityCopyWith<$Res>? get referred {
    if (_value.referred == null) {
      return null;
    }

    return $ReferredEntityCopyWith<$Res>(_value.referred!, (value) {
      return _then(_value.copyWith(referred: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReferralListItemImplCopyWith<$Res>
    implements $ReferralListItemCopyWith<$Res> {
  factory _$$ReferralListItemImplCopyWith(
    _$ReferralListItemImpl value,
    $Res Function(_$ReferralListItemImpl) then,
  ) = __$$ReferralListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    ReferrerVendor? referrerVendor,
    ReferredEntity? referred,
    String referredType,
    ReferralStatus status,
    String? tier,
    int? milestoneNumber,
    double? bonusAmount,
    bool milestoneAwarded,
    DateTime? bonusAppliedAt,
    DateTime createdAt,
  });

  @override
  $ReferrerVendorCopyWith<$Res>? get referrerVendor;
  @override
  $ReferredEntityCopyWith<$Res>? get referred;
}

/// @nodoc
class __$$ReferralListItemImplCopyWithImpl<$Res>
    extends _$ReferralListItemCopyWithImpl<$Res, _$ReferralListItemImpl>
    implements _$$ReferralListItemImplCopyWith<$Res> {
  __$$ReferralListItemImplCopyWithImpl(
    _$ReferralListItemImpl _value,
    $Res Function(_$ReferralListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferralListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? referrerVendor = freezed,
    Object? referred = freezed,
    Object? referredType = null,
    Object? status = null,
    Object? tier = freezed,
    Object? milestoneNumber = freezed,
    Object? bonusAmount = freezed,
    Object? milestoneAwarded = null,
    Object? bonusAppliedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ReferralListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        referrerVendor: freezed == referrerVendor
            ? _value.referrerVendor
            : referrerVendor // ignore: cast_nullable_to_non_nullable
                  as ReferrerVendor?,
        referred: freezed == referred
            ? _value.referred
            : referred // ignore: cast_nullable_to_non_nullable
                  as ReferredEntity?,
        referredType: null == referredType
            ? _value.referredType
            : referredType // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReferralStatus,
        tier: freezed == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String?,
        milestoneNumber: freezed == milestoneNumber
            ? _value.milestoneNumber
            : milestoneNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        bonusAmount: freezed == bonusAmount
            ? _value.bonusAmount
            : bonusAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        milestoneAwarded: null == milestoneAwarded
            ? _value.milestoneAwarded
            : milestoneAwarded // ignore: cast_nullable_to_non_nullable
                  as bool,
        bonusAppliedAt: freezed == bonusAppliedAt
            ? _value.bonusAppliedAt
            : bonusAppliedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralListItemImpl implements _ReferralListItem {
  const _$ReferralListItemImpl({
    required this.id,
    this.referrerVendor,
    this.referred,
    required this.referredType,
    required this.status,
    this.tier,
    this.milestoneNumber,
    this.bonusAmount,
    required this.milestoneAwarded,
    this.bonusAppliedAt,
    required this.createdAt,
  });

  factory _$ReferralListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralListItemImplFromJson(json);

  @override
  final int id;
  @override
  final ReferrerVendor? referrerVendor;
  @override
  final ReferredEntity? referred;
  @override
  final String referredType;
  @override
  final ReferralStatus status;
  @override
  final String? tier;
  @override
  final int? milestoneNumber;
  @override
  final double? bonusAmount;
  @override
  final bool milestoneAwarded;
  @override
  final DateTime? bonusAppliedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ReferralListItem(id: $id, referrerVendor: $referrerVendor, referred: $referred, referredType: $referredType, status: $status, tier: $tier, milestoneNumber: $milestoneNumber, bonusAmount: $bonusAmount, milestoneAwarded: $milestoneAwarded, bonusAppliedAt: $bonusAppliedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.referrerVendor, referrerVendor) ||
                other.referrerVendor == referrerVendor) &&
            (identical(other.referred, referred) ||
                other.referred == referred) &&
            (identical(other.referredType, referredType) ||
                other.referredType == referredType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.milestoneNumber, milestoneNumber) ||
                other.milestoneNumber == milestoneNumber) &&
            (identical(other.bonusAmount, bonusAmount) ||
                other.bonusAmount == bonusAmount) &&
            (identical(other.milestoneAwarded, milestoneAwarded) ||
                other.milestoneAwarded == milestoneAwarded) &&
            (identical(other.bonusAppliedAt, bonusAppliedAt) ||
                other.bonusAppliedAt == bonusAppliedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    referrerVendor,
    referred,
    referredType,
    status,
    tier,
    milestoneNumber,
    bonusAmount,
    milestoneAwarded,
    bonusAppliedAt,
    createdAt,
  );

  /// Create a copy of ReferralListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralListItemImplCopyWith<_$ReferralListItemImpl> get copyWith =>
      __$$ReferralListItemImplCopyWithImpl<_$ReferralListItemImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int id,
      ReferrerVendor? referrerVendor,
      ReferredEntity? referred,
      String referredType,
      ReferralStatus status,
      String? tier,
      int? milestoneNumber,
      double? bonusAmount,
      bool milestoneAwarded,
      DateTime? bonusAppliedAt,
      DateTime createdAt,
    )
    $default,
  ) {
    return $default(
      id,
      referrerVendor,
      referred,
      referredType,
      status,
      tier,
      milestoneNumber,
      bonusAmount,
      milestoneAwarded,
      bonusAppliedAt,
      createdAt,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      int id,
      ReferrerVendor? referrerVendor,
      ReferredEntity? referred,
      String referredType,
      ReferralStatus status,
      String? tier,
      int? milestoneNumber,
      double? bonusAmount,
      bool milestoneAwarded,
      DateTime? bonusAppliedAt,
      DateTime createdAt,
    )?
    $default,
  ) {
    return $default?.call(
      id,
      referrerVendor,
      referred,
      referredType,
      status,
      tier,
      milestoneNumber,
      bonusAmount,
      milestoneAwarded,
      bonusAppliedAt,
      createdAt,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      int id,
      ReferrerVendor? referrerVendor,
      ReferredEntity? referred,
      String referredType,
      ReferralStatus status,
      String? tier,
      int? milestoneNumber,
      double? bonusAmount,
      bool milestoneAwarded,
      DateTime? bonusAppliedAt,
      DateTime createdAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
        id,
        referrerVendor,
        referred,
        referredType,
        status,
        tier,
        milestoneNumber,
        bonusAmount,
        milestoneAwarded,
        bonusAppliedAt,
        createdAt,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferralListItem value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferralListItem value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferralListItem value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralListItemImplToJson(this);
  }
}

abstract class _ReferralListItem implements ReferralListItem {
  const factory _ReferralListItem({
    required final int id,
    final ReferrerVendor? referrerVendor,
    final ReferredEntity? referred,
    required final String referredType,
    required final ReferralStatus status,
    final String? tier,
    final int? milestoneNumber,
    final double? bonusAmount,
    required final bool milestoneAwarded,
    final DateTime? bonusAppliedAt,
    required final DateTime createdAt,
  }) = _$ReferralListItemImpl;

  factory _ReferralListItem.fromJson(Map<String, dynamic> json) =
      _$ReferralListItemImpl.fromJson;

  @override
  int get id;
  @override
  ReferrerVendor? get referrerVendor;
  @override
  ReferredEntity? get referred;
  @override
  String get referredType;
  @override
  ReferralStatus get status;
  @override
  String? get tier;
  @override
  int? get milestoneNumber;
  @override
  double? get bonusAmount;
  @override
  bool get milestoneAwarded;
  @override
  DateTime? get bonusAppliedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of ReferralListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferralListItemImplCopyWith<_$ReferralListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReferralsFilters _$ReferralsFiltersFromJson(Map<String, dynamic> json) {
  return _ReferralsFilters.fromJson(json);
}

/// @nodoc
mixin _$ReferralsFilters {
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  int? get referrerId => throw _privateConstructorUsedError;
  int? get referredId => throw _privateConstructorUsedError;
  ReferralStatus? get status => throw _privateConstructorUsedError;
  String? get tier => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String get sortBy => throw _privateConstructorUsedError;
  String get sortOrder => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int page,
      int pageSize,
      int? referrerId,
      int? referredId,
      ReferralStatus? status,
      String? tier,
      String? search,
      DateTime? startDate,
      DateTime? endDate,
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
      int? referrerId,
      int? referredId,
      ReferralStatus? status,
      String? tier,
      String? search,
      DateTime? startDate,
      DateTime? endDate,
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
      int? referrerId,
      int? referredId,
      ReferralStatus? status,
      String? tier,
      String? search,
      DateTime? startDate,
      DateTime? endDate,
      String sortBy,
      String sortOrder,
    )?
    $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferralsFilters value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferralsFilters value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferralsFilters value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ReferralsFilters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferralsFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferralsFiltersCopyWith<ReferralsFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralsFiltersCopyWith<$Res> {
  factory $ReferralsFiltersCopyWith(
    ReferralsFilters value,
    $Res Function(ReferralsFilters) then,
  ) = _$ReferralsFiltersCopyWithImpl<$Res, ReferralsFilters>;
  @useResult
  $Res call({
    int page,
    int pageSize,
    int? referrerId,
    int? referredId,
    ReferralStatus? status,
    String? tier,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy,
    String sortOrder,
  });
}

/// @nodoc
class _$ReferralsFiltersCopyWithImpl<$Res, $Val extends ReferralsFilters>
    implements $ReferralsFiltersCopyWith<$Res> {
  _$ReferralsFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferralsFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? pageSize = null,
    Object? referrerId = freezed,
    Object? referredId = freezed,
    Object? status = freezed,
    Object? tier = freezed,
    Object? search = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
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
            referrerId: freezed == referrerId
                ? _value.referrerId
                : referrerId // ignore: cast_nullable_to_non_nullable
                      as int?,
            referredId: freezed == referredId
                ? _value.referredId
                : referredId // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReferralStatus?,
            tier: freezed == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String?,
            search: freezed == search
                ? _value.search
                : search // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ReferralsFiltersImplCopyWith<$Res>
    implements $ReferralsFiltersCopyWith<$Res> {
  factory _$$ReferralsFiltersImplCopyWith(
    _$ReferralsFiltersImpl value,
    $Res Function(_$ReferralsFiltersImpl) then,
  ) = __$$ReferralsFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int page,
    int pageSize,
    int? referrerId,
    int? referredId,
    ReferralStatus? status,
    String? tier,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy,
    String sortOrder,
  });
}

/// @nodoc
class __$$ReferralsFiltersImplCopyWithImpl<$Res>
    extends _$ReferralsFiltersCopyWithImpl<$Res, _$ReferralsFiltersImpl>
    implements _$$ReferralsFiltersImplCopyWith<$Res> {
  __$$ReferralsFiltersImplCopyWithImpl(
    _$ReferralsFiltersImpl _value,
    $Res Function(_$ReferralsFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferralsFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? pageSize = null,
    Object? referrerId = freezed,
    Object? referredId = freezed,
    Object? status = freezed,
    Object? tier = freezed,
    Object? search = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? sortBy = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _$ReferralsFiltersImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        pageSize: null == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int,
        referrerId: freezed == referrerId
            ? _value.referrerId
            : referrerId // ignore: cast_nullable_to_non_nullable
                  as int?,
        referredId: freezed == referredId
            ? _value.referredId
            : referredId // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReferralStatus?,
        tier: freezed == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String?,
        search: freezed == search
            ? _value.search
            : search // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
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
class _$ReferralsFiltersImpl extends _ReferralsFilters {
  const _$ReferralsFiltersImpl({
    this.page = 1,
    this.pageSize = 25,
    this.referrerId,
    this.referredId,
    this.status,
    this.tier,
    this.search,
    this.startDate,
    this.endDate,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
  }) : super._();

  factory _$ReferralsFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralsFiltersImplFromJson(json);

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int pageSize;
  @override
  final int? referrerId;
  @override
  final int? referredId;
  @override
  final ReferralStatus? status;
  @override
  final String? tier;
  @override
  final String? search;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final String sortBy;
  @override
  @JsonKey()
  final String sortOrder;

  @override
  String toString() {
    return 'ReferralsFilters(page: $page, pageSize: $pageSize, referrerId: $referrerId, referredId: $referredId, status: $status, tier: $tier, search: $search, startDate: $startDate, endDate: $endDate, sortBy: $sortBy, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralsFiltersImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.referrerId, referrerId) ||
                other.referrerId == referrerId) &&
            (identical(other.referredId, referredId) ||
                other.referredId == referredId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
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
    referrerId,
    referredId,
    status,
    tier,
    search,
    startDate,
    endDate,
    sortBy,
    sortOrder,
  );

  /// Create a copy of ReferralsFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralsFiltersImplCopyWith<_$ReferralsFiltersImpl> get copyWith =>
      __$$ReferralsFiltersImplCopyWithImpl<_$ReferralsFiltersImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      int page,
      int pageSize,
      int? referrerId,
      int? referredId,
      ReferralStatus? status,
      String? tier,
      String? search,
      DateTime? startDate,
      DateTime? endDate,
      String sortBy,
      String sortOrder,
    )
    $default,
  ) {
    return $default(
      page,
      pageSize,
      referrerId,
      referredId,
      status,
      tier,
      search,
      startDate,
      endDate,
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
      int? referrerId,
      int? referredId,
      ReferralStatus? status,
      String? tier,
      String? search,
      DateTime? startDate,
      DateTime? endDate,
      String sortBy,
      String sortOrder,
    )?
    $default,
  ) {
    return $default?.call(
      page,
      pageSize,
      referrerId,
      referredId,
      status,
      tier,
      search,
      startDate,
      endDate,
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
      int? referrerId,
      int? referredId,
      ReferralStatus? status,
      String? tier,
      String? search,
      DateTime? startDate,
      DateTime? endDate,
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
        referrerId,
        referredId,
        status,
        tier,
        search,
        startDate,
        endDate,
        sortBy,
        sortOrder,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReferralsFilters value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReferralsFilters value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReferralsFilters value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralsFiltersImplToJson(this);
  }
}

abstract class _ReferralsFilters extends ReferralsFilters {
  const factory _ReferralsFilters({
    final int page,
    final int pageSize,
    final int? referrerId,
    final int? referredId,
    final ReferralStatus? status,
    final String? tier,
    final String? search,
    final DateTime? startDate,
    final DateTime? endDate,
    final String sortBy,
    final String sortOrder,
  }) = _$ReferralsFiltersImpl;
  const _ReferralsFilters._() : super._();

  factory _ReferralsFilters.fromJson(Map<String, dynamic> json) =
      _$ReferralsFiltersImpl.fromJson;

  @override
  int get page;
  @override
  int get pageSize;
  @override
  int? get referrerId;
  @override
  int? get referredId;
  @override
  ReferralStatus? get status;
  @override
  String? get tier;
  @override
  String? get search;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  String get sortBy;
  @override
  String get sortOrder;

  /// Create a copy of ReferralsFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferralsFiltersImplCopyWith<_$ReferralsFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
