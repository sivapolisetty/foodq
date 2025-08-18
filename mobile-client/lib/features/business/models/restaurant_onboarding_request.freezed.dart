// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_onboarding_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RestaurantOnboardingRequest _$RestaurantOnboardingRequestFromJson(
    Map<String, dynamic> json) {
  return _RestaurantOnboardingRequest.fromJson(json);
}

/// @nodoc
mixin _$RestaurantOnboardingRequest {
  String get id => throw _privateConstructorUsedError; // Restaurant Information
  String get restaurantName => throw _privateConstructorUsedError;
  String get cuisineType => throw _privateConstructorUsedError;
  String? get restaurantDescription => throw _privateConstructorUsedError;
  String? get restaurantPhotoUrl =>
      throw _privateConstructorUsedError; // Owner Information
  String get ownerName => throw _privateConstructorUsedError;
  String get ownerEmail => throw _privateConstructorUsedError;
  String get ownerPhone =>
      throw _privateConstructorUsedError; // Location Information
  String get address => throw _privateConstructorUsedError;
  String get zipCode => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude =>
      throw _privateConstructorUsedError; // Business Information
  String? get businessLicense =>
      throw _privateConstructorUsedError; // Application Status
  String get status => throw _privateConstructorUsedError;
  String? get adminNotes => throw _privateConstructorUsedError;
  bool get onboardingCompleted =>
      throw _privateConstructorUsedError; // User Reference
  String get userId => throw _privateConstructorUsedError; // Timestamps
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt =>
      throw _privateConstructorUsedError; // Restaurant reference (populated when approved)
  String? get restaurantId => throw _privateConstructorUsedError;

  /// Serializes this RestaurantOnboardingRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RestaurantOnboardingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestaurantOnboardingRequestCopyWith<RestaurantOnboardingRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantOnboardingRequestCopyWith<$Res> {
  factory $RestaurantOnboardingRequestCopyWith(
          RestaurantOnboardingRequest value,
          $Res Function(RestaurantOnboardingRequest) then) =
      _$RestaurantOnboardingRequestCopyWithImpl<$Res,
          RestaurantOnboardingRequest>;
  @useResult
  $Res call(
      {String id,
      String restaurantName,
      String cuisineType,
      String? restaurantDescription,
      String? restaurantPhotoUrl,
      String ownerName,
      String ownerEmail,
      String ownerPhone,
      String address,
      String zipCode,
      String? city,
      String? state,
      double? latitude,
      double? longitude,
      String? businessLicense,
      String status,
      String? adminNotes,
      bool onboardingCompleted,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? reviewedAt,
      DateTime? completedAt,
      String? restaurantId});
}

/// @nodoc
class _$RestaurantOnboardingRequestCopyWithImpl<$Res,
        $Val extends RestaurantOnboardingRequest>
    implements $RestaurantOnboardingRequestCopyWith<$Res> {
  _$RestaurantOnboardingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestaurantOnboardingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantName = null,
    Object? cuisineType = null,
    Object? restaurantDescription = freezed,
    Object? restaurantPhotoUrl = freezed,
    Object? ownerName = null,
    Object? ownerEmail = null,
    Object? ownerPhone = null,
    Object? address = null,
    Object? zipCode = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? businessLicense = freezed,
    Object? status = null,
    Object? adminNotes = freezed,
    Object? onboardingCompleted = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? reviewedAt = freezed,
    Object? completedAt = freezed,
    Object? restaurantId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantName: null == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String,
      cuisineType: null == cuisineType
          ? _value.cuisineType
          : cuisineType // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantDescription: freezed == restaurantDescription
          ? _value.restaurantDescription
          : restaurantDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantPhotoUrl: freezed == restaurantPhotoUrl
          ? _value.restaurantPhotoUrl
          : restaurantPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerEmail: null == ownerEmail
          ? _value.ownerEmail
          : ownerEmail // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPhone: null == ownerPhone
          ? _value.ownerPhone
          : ownerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      zipCode: null == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      businessLicense: freezed == businessLicense
          ? _value.businessLicense
          : businessLicense // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      restaurantId: freezed == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RestaurantOnboardingRequestImplCopyWith<$Res>
    implements $RestaurantOnboardingRequestCopyWith<$Res> {
  factory _$$RestaurantOnboardingRequestImplCopyWith(
          _$RestaurantOnboardingRequestImpl value,
          $Res Function(_$RestaurantOnboardingRequestImpl) then) =
      __$$RestaurantOnboardingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String restaurantName,
      String cuisineType,
      String? restaurantDescription,
      String? restaurantPhotoUrl,
      String ownerName,
      String ownerEmail,
      String ownerPhone,
      String address,
      String zipCode,
      String? city,
      String? state,
      double? latitude,
      double? longitude,
      String? businessLicense,
      String status,
      String? adminNotes,
      bool onboardingCompleted,
      String userId,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? reviewedAt,
      DateTime? completedAt,
      String? restaurantId});
}

/// @nodoc
class __$$RestaurantOnboardingRequestImplCopyWithImpl<$Res>
    extends _$RestaurantOnboardingRequestCopyWithImpl<$Res,
        _$RestaurantOnboardingRequestImpl>
    implements _$$RestaurantOnboardingRequestImplCopyWith<$Res> {
  __$$RestaurantOnboardingRequestImplCopyWithImpl(
      _$RestaurantOnboardingRequestImpl _value,
      $Res Function(_$RestaurantOnboardingRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestaurantOnboardingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? restaurantName = null,
    Object? cuisineType = null,
    Object? restaurantDescription = freezed,
    Object? restaurantPhotoUrl = freezed,
    Object? ownerName = null,
    Object? ownerEmail = null,
    Object? ownerPhone = null,
    Object? address = null,
    Object? zipCode = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? businessLicense = freezed,
    Object? status = null,
    Object? adminNotes = freezed,
    Object? onboardingCompleted = null,
    Object? userId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? reviewedAt = freezed,
    Object? completedAt = freezed,
    Object? restaurantId = freezed,
  }) {
    return _then(_$RestaurantOnboardingRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantName: null == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String,
      cuisineType: null == cuisineType
          ? _value.cuisineType
          : cuisineType // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantDescription: freezed == restaurantDescription
          ? _value.restaurantDescription
          : restaurantDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantPhotoUrl: freezed == restaurantPhotoUrl
          ? _value.restaurantPhotoUrl
          : restaurantPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerEmail: null == ownerEmail
          ? _value.ownerEmail
          : ownerEmail // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPhone: null == ownerPhone
          ? _value.ownerPhone
          : ownerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      zipCode: null == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      businessLicense: freezed == businessLicense
          ? _value.businessLicense
          : businessLicense // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      adminNotes: freezed == adminNotes
          ? _value.adminNotes
          : adminNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      restaurantId: freezed == restaurantId
          ? _value.restaurantId
          : restaurantId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestaurantOnboardingRequestImpl
    implements _RestaurantOnboardingRequest {
  const _$RestaurantOnboardingRequestImpl(
      {required this.id,
      required this.restaurantName,
      required this.cuisineType,
      this.restaurantDescription,
      this.restaurantPhotoUrl,
      required this.ownerName,
      required this.ownerEmail,
      required this.ownerPhone,
      required this.address,
      required this.zipCode,
      this.city,
      this.state,
      this.latitude,
      this.longitude,
      this.businessLicense,
      this.status = 'pending',
      this.adminNotes,
      this.onboardingCompleted = false,
      required this.userId,
      required this.createdAt,
      required this.updatedAt,
      this.reviewedAt,
      this.completedAt,
      this.restaurantId});

  factory _$RestaurantOnboardingRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$RestaurantOnboardingRequestImplFromJson(json);

  @override
  final String id;
// Restaurant Information
  @override
  final String restaurantName;
  @override
  final String cuisineType;
  @override
  final String? restaurantDescription;
  @override
  final String? restaurantPhotoUrl;
// Owner Information
  @override
  final String ownerName;
  @override
  final String ownerEmail;
  @override
  final String ownerPhone;
// Location Information
  @override
  final String address;
  @override
  final String zipCode;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final double? latitude;
  @override
  final double? longitude;
// Business Information
  @override
  final String? businessLicense;
// Application Status
  @override
  @JsonKey()
  final String status;
  @override
  final String? adminNotes;
  @override
  @JsonKey()
  final bool onboardingCompleted;
// User Reference
  @override
  final String userId;
// Timestamps
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? reviewedAt;
  @override
  final DateTime? completedAt;
// Restaurant reference (populated when approved)
  @override
  final String? restaurantId;

  @override
  String toString() {
    return 'RestaurantOnboardingRequest(id: $id, restaurantName: $restaurantName, cuisineType: $cuisineType, restaurantDescription: $restaurantDescription, restaurantPhotoUrl: $restaurantPhotoUrl, ownerName: $ownerName, ownerEmail: $ownerEmail, ownerPhone: $ownerPhone, address: $address, zipCode: $zipCode, city: $city, state: $state, latitude: $latitude, longitude: $longitude, businessLicense: $businessLicense, status: $status, adminNotes: $adminNotes, onboardingCompleted: $onboardingCompleted, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, reviewedAt: $reviewedAt, completedAt: $completedAt, restaurantId: $restaurantId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantOnboardingRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.restaurantName, restaurantName) ||
                other.restaurantName == restaurantName) &&
            (identical(other.cuisineType, cuisineType) ||
                other.cuisineType == cuisineType) &&
            (identical(other.restaurantDescription, restaurantDescription) ||
                other.restaurantDescription == restaurantDescription) &&
            (identical(other.restaurantPhotoUrl, restaurantPhotoUrl) ||
                other.restaurantPhotoUrl == restaurantPhotoUrl) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.ownerEmail, ownerEmail) ||
                other.ownerEmail == ownerEmail) &&
            (identical(other.ownerPhone, ownerPhone) ||
                other.ownerPhone == ownerPhone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.businessLicense, businessLicense) ||
                other.businessLicense == businessLicense) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.adminNotes, adminNotes) ||
                other.adminNotes == adminNotes) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.restaurantId, restaurantId) ||
                other.restaurantId == restaurantId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        restaurantName,
        cuisineType,
        restaurantDescription,
        restaurantPhotoUrl,
        ownerName,
        ownerEmail,
        ownerPhone,
        address,
        zipCode,
        city,
        state,
        latitude,
        longitude,
        businessLicense,
        status,
        adminNotes,
        onboardingCompleted,
        userId,
        createdAt,
        updatedAt,
        reviewedAt,
        completedAt,
        restaurantId
      ]);

  /// Create a copy of RestaurantOnboardingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantOnboardingRequestImplCopyWith<_$RestaurantOnboardingRequestImpl>
      get copyWith => __$$RestaurantOnboardingRequestImplCopyWithImpl<
          _$RestaurantOnboardingRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestaurantOnboardingRequestImplToJson(
      this,
    );
  }
}

abstract class _RestaurantOnboardingRequest
    implements RestaurantOnboardingRequest {
  const factory _RestaurantOnboardingRequest(
      {required final String id,
      required final String restaurantName,
      required final String cuisineType,
      final String? restaurantDescription,
      final String? restaurantPhotoUrl,
      required final String ownerName,
      required final String ownerEmail,
      required final String ownerPhone,
      required final String address,
      required final String zipCode,
      final String? city,
      final String? state,
      final double? latitude,
      final double? longitude,
      final String? businessLicense,
      final String status,
      final String? adminNotes,
      final bool onboardingCompleted,
      required final String userId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? reviewedAt,
      final DateTime? completedAt,
      final String? restaurantId}) = _$RestaurantOnboardingRequestImpl;

  factory _RestaurantOnboardingRequest.fromJson(Map<String, dynamic> json) =
      _$RestaurantOnboardingRequestImpl.fromJson;

  @override
  String get id; // Restaurant Information
  @override
  String get restaurantName;
  @override
  String get cuisineType;
  @override
  String? get restaurantDescription;
  @override
  String? get restaurantPhotoUrl; // Owner Information
  @override
  String get ownerName;
  @override
  String get ownerEmail;
  @override
  String get ownerPhone; // Location Information
  @override
  String get address;
  @override
  String get zipCode;
  @override
  String? get city;
  @override
  String? get state;
  @override
  double? get latitude;
  @override
  double? get longitude; // Business Information
  @override
  String? get businessLicense; // Application Status
  @override
  String get status;
  @override
  String? get adminNotes;
  @override
  bool get onboardingCompleted; // User Reference
  @override
  String get userId; // Timestamps
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get reviewedAt;
  @override
  DateTime? get completedAt; // Restaurant reference (populated when approved)
  @override
  String? get restaurantId;

  /// Create a copy of RestaurantOnboardingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestaurantOnboardingRequestImplCopyWith<_$RestaurantOnboardingRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RestaurantOnboardingFormData _$RestaurantOnboardingFormDataFromJson(
    Map<String, dynamic> json) {
  return _RestaurantOnboardingFormData.fromJson(json);
}

/// @nodoc
mixin _$RestaurantOnboardingFormData {
// Restaurant Information
  String get restaurantName => throw _privateConstructorUsedError;
  String get cuisineType => throw _privateConstructorUsedError;
  String? get restaurantDescription => throw _privateConstructorUsedError;
  String? get restaurantPhotoUrl =>
      throw _privateConstructorUsedError; // Owner Information
  String get ownerName => throw _privateConstructorUsedError;
  String get ownerEmail => throw _privateConstructorUsedError;
  String get ownerPhone =>
      throw _privateConstructorUsedError; // Location Information
  String get address => throw _privateConstructorUsedError;
  String get zipCode => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude =>
      throw _privateConstructorUsedError; // Business Information
  String? get businessLicense =>
      throw _privateConstructorUsedError; // User Reference
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this RestaurantOnboardingFormData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RestaurantOnboardingFormData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestaurantOnboardingFormDataCopyWith<RestaurantOnboardingFormData>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantOnboardingFormDataCopyWith<$Res> {
  factory $RestaurantOnboardingFormDataCopyWith(
          RestaurantOnboardingFormData value,
          $Res Function(RestaurantOnboardingFormData) then) =
      _$RestaurantOnboardingFormDataCopyWithImpl<$Res,
          RestaurantOnboardingFormData>;
  @useResult
  $Res call(
      {String restaurantName,
      String cuisineType,
      String? restaurantDescription,
      String? restaurantPhotoUrl,
      String ownerName,
      String ownerEmail,
      String ownerPhone,
      String address,
      String zipCode,
      String? city,
      String? state,
      double? latitude,
      double? longitude,
      String? businessLicense,
      String userId});
}

/// @nodoc
class _$RestaurantOnboardingFormDataCopyWithImpl<$Res,
        $Val extends RestaurantOnboardingFormData>
    implements $RestaurantOnboardingFormDataCopyWith<$Res> {
  _$RestaurantOnboardingFormDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RestaurantOnboardingFormData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurantName = null,
    Object? cuisineType = null,
    Object? restaurantDescription = freezed,
    Object? restaurantPhotoUrl = freezed,
    Object? ownerName = null,
    Object? ownerEmail = null,
    Object? ownerPhone = null,
    Object? address = null,
    Object? zipCode = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? businessLicense = freezed,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      restaurantName: null == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String,
      cuisineType: null == cuisineType
          ? _value.cuisineType
          : cuisineType // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantDescription: freezed == restaurantDescription
          ? _value.restaurantDescription
          : restaurantDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantPhotoUrl: freezed == restaurantPhotoUrl
          ? _value.restaurantPhotoUrl
          : restaurantPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerEmail: null == ownerEmail
          ? _value.ownerEmail
          : ownerEmail // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPhone: null == ownerPhone
          ? _value.ownerPhone
          : ownerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      zipCode: null == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      businessLicense: freezed == businessLicense
          ? _value.businessLicense
          : businessLicense // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RestaurantOnboardingFormDataImplCopyWith<$Res>
    implements $RestaurantOnboardingFormDataCopyWith<$Res> {
  factory _$$RestaurantOnboardingFormDataImplCopyWith(
          _$RestaurantOnboardingFormDataImpl value,
          $Res Function(_$RestaurantOnboardingFormDataImpl) then) =
      __$$RestaurantOnboardingFormDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String restaurantName,
      String cuisineType,
      String? restaurantDescription,
      String? restaurantPhotoUrl,
      String ownerName,
      String ownerEmail,
      String ownerPhone,
      String address,
      String zipCode,
      String? city,
      String? state,
      double? latitude,
      double? longitude,
      String? businessLicense,
      String userId});
}

/// @nodoc
class __$$RestaurantOnboardingFormDataImplCopyWithImpl<$Res>
    extends _$RestaurantOnboardingFormDataCopyWithImpl<$Res,
        _$RestaurantOnboardingFormDataImpl>
    implements _$$RestaurantOnboardingFormDataImplCopyWith<$Res> {
  __$$RestaurantOnboardingFormDataImplCopyWithImpl(
      _$RestaurantOnboardingFormDataImpl _value,
      $Res Function(_$RestaurantOnboardingFormDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of RestaurantOnboardingFormData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurantName = null,
    Object? cuisineType = null,
    Object? restaurantDescription = freezed,
    Object? restaurantPhotoUrl = freezed,
    Object? ownerName = null,
    Object? ownerEmail = null,
    Object? ownerPhone = null,
    Object? address = null,
    Object? zipCode = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? businessLicense = freezed,
    Object? userId = null,
  }) {
    return _then(_$RestaurantOnboardingFormDataImpl(
      restaurantName: null == restaurantName
          ? _value.restaurantName
          : restaurantName // ignore: cast_nullable_to_non_nullable
              as String,
      cuisineType: null == cuisineType
          ? _value.cuisineType
          : cuisineType // ignore: cast_nullable_to_non_nullable
              as String,
      restaurantDescription: freezed == restaurantDescription
          ? _value.restaurantDescription
          : restaurantDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      restaurantPhotoUrl: freezed == restaurantPhotoUrl
          ? _value.restaurantPhotoUrl
          : restaurantPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerEmail: null == ownerEmail
          ? _value.ownerEmail
          : ownerEmail // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPhone: null == ownerPhone
          ? _value.ownerPhone
          : ownerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      zipCode: null == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      businessLicense: freezed == businessLicense
          ? _value.businessLicense
          : businessLicense // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestaurantOnboardingFormDataImpl
    implements _RestaurantOnboardingFormData {
  const _$RestaurantOnboardingFormDataImpl(
      {required this.restaurantName,
      required this.cuisineType,
      this.restaurantDescription,
      this.restaurantPhotoUrl,
      required this.ownerName,
      required this.ownerEmail,
      required this.ownerPhone,
      required this.address,
      required this.zipCode,
      this.city,
      this.state,
      this.latitude,
      this.longitude,
      this.businessLicense,
      required this.userId});

  factory _$RestaurantOnboardingFormDataImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$RestaurantOnboardingFormDataImplFromJson(json);

// Restaurant Information
  @override
  final String restaurantName;
  @override
  final String cuisineType;
  @override
  final String? restaurantDescription;
  @override
  final String? restaurantPhotoUrl;
// Owner Information
  @override
  final String ownerName;
  @override
  final String ownerEmail;
  @override
  final String ownerPhone;
// Location Information
  @override
  final String address;
  @override
  final String zipCode;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final double? latitude;
  @override
  final double? longitude;
// Business Information
  @override
  final String? businessLicense;
// User Reference
  @override
  final String userId;

  @override
  String toString() {
    return 'RestaurantOnboardingFormData(restaurantName: $restaurantName, cuisineType: $cuisineType, restaurantDescription: $restaurantDescription, restaurantPhotoUrl: $restaurantPhotoUrl, ownerName: $ownerName, ownerEmail: $ownerEmail, ownerPhone: $ownerPhone, address: $address, zipCode: $zipCode, city: $city, state: $state, latitude: $latitude, longitude: $longitude, businessLicense: $businessLicense, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantOnboardingFormDataImpl &&
            (identical(other.restaurantName, restaurantName) ||
                other.restaurantName == restaurantName) &&
            (identical(other.cuisineType, cuisineType) ||
                other.cuisineType == cuisineType) &&
            (identical(other.restaurantDescription, restaurantDescription) ||
                other.restaurantDescription == restaurantDescription) &&
            (identical(other.restaurantPhotoUrl, restaurantPhotoUrl) ||
                other.restaurantPhotoUrl == restaurantPhotoUrl) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.ownerEmail, ownerEmail) ||
                other.ownerEmail == ownerEmail) &&
            (identical(other.ownerPhone, ownerPhone) ||
                other.ownerPhone == ownerPhone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.businessLicense, businessLicense) ||
                other.businessLicense == businessLicense) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      restaurantName,
      cuisineType,
      restaurantDescription,
      restaurantPhotoUrl,
      ownerName,
      ownerEmail,
      ownerPhone,
      address,
      zipCode,
      city,
      state,
      latitude,
      longitude,
      businessLicense,
      userId);

  /// Create a copy of RestaurantOnboardingFormData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantOnboardingFormDataImplCopyWith<
          _$RestaurantOnboardingFormDataImpl>
      get copyWith => __$$RestaurantOnboardingFormDataImplCopyWithImpl<
          _$RestaurantOnboardingFormDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestaurantOnboardingFormDataImplToJson(
      this,
    );
  }
}

abstract class _RestaurantOnboardingFormData
    implements RestaurantOnboardingFormData {
  const factory _RestaurantOnboardingFormData(
      {required final String restaurantName,
      required final String cuisineType,
      final String? restaurantDescription,
      final String? restaurantPhotoUrl,
      required final String ownerName,
      required final String ownerEmail,
      required final String ownerPhone,
      required final String address,
      required final String zipCode,
      final String? city,
      final String? state,
      final double? latitude,
      final double? longitude,
      final String? businessLicense,
      required final String userId}) = _$RestaurantOnboardingFormDataImpl;

  factory _RestaurantOnboardingFormData.fromJson(Map<String, dynamic> json) =
      _$RestaurantOnboardingFormDataImpl.fromJson;

// Restaurant Information
  @override
  String get restaurantName;
  @override
  String get cuisineType;
  @override
  String? get restaurantDescription;
  @override
  String? get restaurantPhotoUrl; // Owner Information
  @override
  String get ownerName;
  @override
  String get ownerEmail;
  @override
  String get ownerPhone; // Location Information
  @override
  String get address;
  @override
  String get zipCode;
  @override
  String? get city;
  @override
  String? get state;
  @override
  double? get latitude;
  @override
  double? get longitude; // Business Information
  @override
  String? get businessLicense; // User Reference
  @override
  String get userId;

  /// Create a copy of RestaurantOnboardingFormData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestaurantOnboardingFormDataImplCopyWith<
          _$RestaurantOnboardingFormDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
