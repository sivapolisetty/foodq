// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_type')
  UserType get userType => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_id')
  String? get businessId => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_name')
  String? get businessName => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image_url')
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get phone =>
      throw _privateConstructorUsedError; // Address fields (required for both customers and businesses)
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'postal_code')
  String? get postalCode => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude =>
      throw _privateConstructorUsedError; // Customer preferences
  @JsonKey(name: 'dietary_preferences')
  List<String>? get dietaryPreferences => throw _privateConstructorUsedError;
  @JsonKey(name: 'favorite_cuisines')
  List<String>? get favoriteCuisines => throw _privateConstructorUsedError;
  @JsonKey(name: 'notification_preferences')
  Map<String, dynamic>? get notificationPreferences =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      @JsonKey(name: 'user_type') UserType userType,
      @JsonKey(name: 'business_id') String? businessId,
      @JsonKey(name: 'business_name') String? businessName,
      @JsonKey(name: 'profile_image_url') String? profileImageUrl,
      String? phone,
      String? address,
      String? city,
      String? state,
      @JsonKey(name: 'postal_code') String? postalCode,
      String country,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'dietary_preferences') List<String>? dietaryPreferences,
      @JsonKey(name: 'favorite_cuisines') List<String>? favoriteCuisines,
      @JsonKey(name: 'notification_preferences')
      Map<String, dynamic>? notificationPreferences,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? userType = null,
    Object? businessId = freezed,
    Object? businessName = freezed,
    Object? profileImageUrl = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? postalCode = freezed,
    Object? country = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? dietaryPreferences = freezed,
    Object? favoriteCuisines = freezed,
    Object? notificationPreferences = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      userType: null == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as UserType,
      businessId: freezed == businessId
          ? _value.businessId
          : businessId // ignore: cast_nullable_to_non_nullable
              as String?,
      businessName: freezed == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      dietaryPreferences: freezed == dietaryPreferences
          ? _value.dietaryPreferences
          : dietaryPreferences // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      favoriteCuisines: freezed == favoriteCuisines
          ? _value.favoriteCuisines
          : favoriteCuisines // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notificationPreferences: freezed == notificationPreferences
          ? _value.notificationPreferences
          : notificationPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      @JsonKey(name: 'user_type') UserType userType,
      @JsonKey(name: 'business_id') String? businessId,
      @JsonKey(name: 'business_name') String? businessName,
      @JsonKey(name: 'profile_image_url') String? profileImageUrl,
      String? phone,
      String? address,
      String? city,
      String? state,
      @JsonKey(name: 'postal_code') String? postalCode,
      String country,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'dietary_preferences') List<String>? dietaryPreferences,
      @JsonKey(name: 'favorite_cuisines') List<String>? favoriteCuisines,
      @JsonKey(name: 'notification_preferences')
      Map<String, dynamic>? notificationPreferences,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? userType = null,
    Object? businessId = freezed,
    Object? businessName = freezed,
    Object? profileImageUrl = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? postalCode = freezed,
    Object? country = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? dietaryPreferences = freezed,
    Object? favoriteCuisines = freezed,
    Object? notificationPreferences = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AppUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      userType: null == userType
          ? _value.userType
          : userType // ignore: cast_nullable_to_non_nullable
              as UserType,
      businessId: freezed == businessId
          ? _value.businessId
          : businessId // ignore: cast_nullable_to_non_nullable
              as String?,
      businessName: freezed == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      dietaryPreferences: freezed == dietaryPreferences
          ? _value._dietaryPreferences
          : dietaryPreferences // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      favoriteCuisines: freezed == favoriteCuisines
          ? _value._favoriteCuisines
          : favoriteCuisines // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notificationPreferences: freezed == notificationPreferences
          ? _value._notificationPreferences
          : notificationPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl extends _AppUser {
  const _$AppUserImpl(
      {required this.id,
      required this.name,
      required this.email,
      @JsonKey(name: 'user_type') required this.userType,
      @JsonKey(name: 'business_id') this.businessId,
      @JsonKey(name: 'business_name') this.businessName,
      @JsonKey(name: 'profile_image_url') this.profileImageUrl,
      this.phone,
      this.address,
      this.city,
      this.state,
      @JsonKey(name: 'postal_code') this.postalCode,
      this.country = 'United States',
      this.latitude,
      this.longitude,
      @JsonKey(name: 'dietary_preferences')
      final List<String>? dietaryPreferences,
      @JsonKey(name: 'favorite_cuisines') final List<String>? favoriteCuisines,
      @JsonKey(name: 'notification_preferences')
      final Map<String, dynamic>? notificationPreferences,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _dietaryPreferences = dietaryPreferences,
        _favoriteCuisines = favoriteCuisines,
        _notificationPreferences = notificationPreferences,
        super._();

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  @JsonKey(name: 'user_type')
  final UserType userType;
  @override
  @JsonKey(name: 'business_id')
  final String? businessId;
  @override
  @JsonKey(name: 'business_name')
  final String? businessName;
  @override
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  @override
  final String? phone;
// Address fields (required for both customers and businesses)
  @override
  final String? address;
  @override
  final String? city;
  @override
  final String? state;
  @override
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  @override
  @JsonKey()
  final String country;
  @override
  final double? latitude;
  @override
  final double? longitude;
// Customer preferences
  final List<String>? _dietaryPreferences;
// Customer preferences
  @override
  @JsonKey(name: 'dietary_preferences')
  List<String>? get dietaryPreferences {
    final value = _dietaryPreferences;
    if (value == null) return null;
    if (_dietaryPreferences is EqualUnmodifiableListView)
      return _dietaryPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _favoriteCuisines;
  @override
  @JsonKey(name: 'favorite_cuisines')
  List<String>? get favoriteCuisines {
    final value = _favoriteCuisines;
    if (value == null) return null;
    if (_favoriteCuisines is EqualUnmodifiableListView)
      return _favoriteCuisines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _notificationPreferences;
  @override
  @JsonKey(name: 'notification_preferences')
  Map<String, dynamic>? get notificationPreferences {
    final value = _notificationPreferences;
    if (value == null) return null;
    if (_notificationPreferences is EqualUnmodifiableMapView)
      return _notificationPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AppUser(id: $id, name: $name, email: $email, userType: $userType, businessId: $businessId, businessName: $businessName, profileImageUrl: $profileImageUrl, phone: $phone, address: $address, city: $city, state: $state, postalCode: $postalCode, country: $country, latitude: $latitude, longitude: $longitude, dietaryPreferences: $dietaryPreferences, favoriteCuisines: $favoriteCuisines, notificationPreferences: $notificationPreferences, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            (identical(other.businessId, businessId) ||
                other.businessId == businessId) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality()
                .equals(other._dietaryPreferences, _dietaryPreferences) &&
            const DeepCollectionEquality()
                .equals(other._favoriteCuisines, _favoriteCuisines) &&
            const DeepCollectionEquality().equals(
                other._notificationPreferences, _notificationPreferences) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        email,
        userType,
        businessId,
        businessName,
        profileImageUrl,
        phone,
        address,
        city,
        state,
        postalCode,
        country,
        latitude,
        longitude,
        const DeepCollectionEquality().hash(_dietaryPreferences),
        const DeepCollectionEquality().hash(_favoriteCuisines),
        const DeepCollectionEquality().hash(_notificationPreferences),
        createdAt,
        updatedAt
      ]);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser extends AppUser {
  const factory _AppUser(
      {required final String id,
      required final String name,
      required final String email,
      @JsonKey(name: 'user_type') required final UserType userType,
      @JsonKey(name: 'business_id') final String? businessId,
      @JsonKey(name: 'business_name') final String? businessName,
      @JsonKey(name: 'profile_image_url') final String? profileImageUrl,
      final String? phone,
      final String? address,
      final String? city,
      final String? state,
      @JsonKey(name: 'postal_code') final String? postalCode,
      final String country,
      final double? latitude,
      final double? longitude,
      @JsonKey(name: 'dietary_preferences')
      final List<String>? dietaryPreferences,
      @JsonKey(name: 'favorite_cuisines') final List<String>? favoriteCuisines,
      @JsonKey(name: 'notification_preferences')
      final Map<String, dynamic>? notificationPreferences,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$AppUserImpl;
  const _AppUser._() : super._();

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  @JsonKey(name: 'user_type')
  UserType get userType;
  @override
  @JsonKey(name: 'business_id')
  String? get businessId;
  @override
  @JsonKey(name: 'business_name')
  String? get businessName;
  @override
  @JsonKey(name: 'profile_image_url')
  String? get profileImageUrl;
  @override
  String?
      get phone; // Address fields (required for both customers and businesses)
  @override
  String? get address;
  @override
  String? get city;
  @override
  String? get state;
  @override
  @JsonKey(name: 'postal_code')
  String? get postalCode;
  @override
  String get country;
  @override
  double? get latitude;
  @override
  double? get longitude; // Customer preferences
  @override
  @JsonKey(name: 'dietary_preferences')
  List<String>? get dietaryPreferences;
  @override
  @JsonKey(name: 'favorite_cuisines')
  List<String>? get favoriteCuisines;
  @override
  @JsonKey(name: 'notification_preferences')
  Map<String, dynamic>? get notificationPreferences;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
