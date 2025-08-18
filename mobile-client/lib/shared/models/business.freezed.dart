// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Business _$BusinessFromJson(Map<String, dynamic> json) {
  return _Business.fromJson(json);
}

/// @nodoc
mixin _$Business {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_url')
  String? get logoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl =>
      throw _privateConstructorUsedError; // Business license and legal info
  @JsonKey(name: 'business_license')
  String? get businessLicense => throw _privateConstructorUsedError;
  @JsonKey(name: 'tax_id')
  String? get taxId => throw _privateConstructorUsedError;
  String? get category =>
      throw _privateConstructorUsedError; // Business category (replaces cuisine_type)
  String? get website => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_hours')
  Map<String, dynamic>? get businessHours =>
      throw _privateConstructorUsedError; // Service preferences
  @JsonKey(name: 'delivery_radius')
  double get deliveryRadius => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_order_amount')
  double get minOrderAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'accepts_cash')
  bool get acceptsCash => throw _privateConstructorUsedError;
  @JsonKey(name: 'accepts_cards')
  bool get acceptsCards => throw _privateConstructorUsedError;
  @JsonKey(name: 'accepts_digital')
  bool get acceptsDigital =>
      throw _privateConstructorUsedError; // Administrative fields
  @JsonKey(name: 'is_approved')
  bool get isApproved => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'onboarding_completed')
  bool get onboardingCompleted =>
      throw _privateConstructorUsedError; // Location details
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'zip_code')
  String? get zipCode => throw _privateConstructorUsedError;
  String get country =>
      throw _privateConstructorUsedError; // Stats (computed fields)
  double get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'review_count')
  int get reviewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_deals')
  int get totalDeals => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_deals')
  int get activeDeals => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Business to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Business
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessCopyWith<Business> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessCopyWith<$Res> {
  factory $BusinessCopyWith(Business value, $Res Function(Business) then) =
      _$BusinessCopyWithImpl<$Res, Business>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'owner_id') String ownerId,
      String name,
      String? description,
      String address,
      double? latitude,
      double? longitude,
      String? phone,
      String? email,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'cover_image_url') String? coverImageUrl,
      @JsonKey(name: 'business_license') String? businessLicense,
      @JsonKey(name: 'tax_id') String? taxId,
      String? category,
      String? website,
      @JsonKey(name: 'business_hours') Map<String, dynamic>? businessHours,
      @JsonKey(name: 'delivery_radius') double deliveryRadius,
      @JsonKey(name: 'min_order_amount') double minOrderAmount,
      @JsonKey(name: 'accepts_cash') bool acceptsCash,
      @JsonKey(name: 'accepts_cards') bool acceptsCards,
      @JsonKey(name: 'accepts_digital') bool acceptsDigital,
      @JsonKey(name: 'is_approved') bool isApproved,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'onboarding_completed') bool onboardingCompleted,
      String? city,
      String? state,
      @JsonKey(name: 'zip_code') String? zipCode,
      String country,
      double rating,
      @JsonKey(name: 'review_count') int reviewCount,
      @JsonKey(name: 'total_deals') int totalDeals,
      @JsonKey(name: 'active_deals') int activeDeals,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$BusinessCopyWithImpl<$Res, $Val extends Business>
    implements $BusinessCopyWith<$Res> {
  _$BusinessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Business
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? description = freezed,
    Object? address = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? logoUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? businessLicense = freezed,
    Object? taxId = freezed,
    Object? category = freezed,
    Object? website = freezed,
    Object? businessHours = freezed,
    Object? deliveryRadius = null,
    Object? minOrderAmount = null,
    Object? acceptsCash = null,
    Object? acceptsCards = null,
    Object? acceptsDigital = null,
    Object? isApproved = null,
    Object? isActive = null,
    Object? onboardingCompleted = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? zipCode = freezed,
    Object? country = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? totalDeals = null,
    Object? activeDeals = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      businessLicense: freezed == businessLicense
          ? _value.businessLicense
          : businessLicense // ignore: cast_nullable_to_non_nullable
              as String?,
      taxId: freezed == taxId
          ? _value.taxId
          : taxId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      businessHours: freezed == businessHours
          ? _value.businessHours
          : businessHours // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      deliveryRadius: null == deliveryRadius
          ? _value.deliveryRadius
          : deliveryRadius // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderAmount: null == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as double,
      acceptsCash: null == acceptsCash
          ? _value.acceptsCash
          : acceptsCash // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptsCards: null == acceptsCards
          ? _value.acceptsCards
          : acceptsCards // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptsDigital: null == acceptsDigital
          ? _value.acceptsDigital
          : acceptsDigital // ignore: cast_nullable_to_non_nullable
              as bool,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      zipCode: freezed == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String?,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDeals: null == totalDeals
          ? _value.totalDeals
          : totalDeals // ignore: cast_nullable_to_non_nullable
              as int,
      activeDeals: null == activeDeals
          ? _value.activeDeals
          : activeDeals // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$BusinessImplCopyWith<$Res>
    implements $BusinessCopyWith<$Res> {
  factory _$$BusinessImplCopyWith(
          _$BusinessImpl value, $Res Function(_$BusinessImpl) then) =
      __$$BusinessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'owner_id') String ownerId,
      String name,
      String? description,
      String address,
      double? latitude,
      double? longitude,
      String? phone,
      String? email,
      @JsonKey(name: 'logo_url') String? logoUrl,
      @JsonKey(name: 'cover_image_url') String? coverImageUrl,
      @JsonKey(name: 'business_license') String? businessLicense,
      @JsonKey(name: 'tax_id') String? taxId,
      String? category,
      String? website,
      @JsonKey(name: 'business_hours') Map<String, dynamic>? businessHours,
      @JsonKey(name: 'delivery_radius') double deliveryRadius,
      @JsonKey(name: 'min_order_amount') double minOrderAmount,
      @JsonKey(name: 'accepts_cash') bool acceptsCash,
      @JsonKey(name: 'accepts_cards') bool acceptsCards,
      @JsonKey(name: 'accepts_digital') bool acceptsDigital,
      @JsonKey(name: 'is_approved') bool isApproved,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'onboarding_completed') bool onboardingCompleted,
      String? city,
      String? state,
      @JsonKey(name: 'zip_code') String? zipCode,
      String country,
      double rating,
      @JsonKey(name: 'review_count') int reviewCount,
      @JsonKey(name: 'total_deals') int totalDeals,
      @JsonKey(name: 'active_deals') int activeDeals,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$BusinessImplCopyWithImpl<$Res>
    extends _$BusinessCopyWithImpl<$Res, _$BusinessImpl>
    implements _$$BusinessImplCopyWith<$Res> {
  __$$BusinessImplCopyWithImpl(
      _$BusinessImpl _value, $Res Function(_$BusinessImpl) _then)
      : super(_value, _then);

  /// Create a copy of Business
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? description = freezed,
    Object? address = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? logoUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? businessLicense = freezed,
    Object? taxId = freezed,
    Object? category = freezed,
    Object? website = freezed,
    Object? businessHours = freezed,
    Object? deliveryRadius = null,
    Object? minOrderAmount = null,
    Object? acceptsCash = null,
    Object? acceptsCards = null,
    Object? acceptsDigital = null,
    Object? isApproved = null,
    Object? isActive = null,
    Object? onboardingCompleted = null,
    Object? city = freezed,
    Object? state = freezed,
    Object? zipCode = freezed,
    Object? country = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? totalDeals = null,
    Object? activeDeals = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BusinessImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      businessLicense: freezed == businessLicense
          ? _value.businessLicense
          : businessLicense // ignore: cast_nullable_to_non_nullable
              as String?,
      taxId: freezed == taxId
          ? _value.taxId
          : taxId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      businessHours: freezed == businessHours
          ? _value._businessHours
          : businessHours // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      deliveryRadius: null == deliveryRadius
          ? _value.deliveryRadius
          : deliveryRadius // ignore: cast_nullable_to_non_nullable
              as double,
      minOrderAmount: null == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as double,
      acceptsCash: null == acceptsCash
          ? _value.acceptsCash
          : acceptsCash // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptsCards: null == acceptsCards
          ? _value.acceptsCards
          : acceptsCards // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptsDigital: null == acceptsDigital
          ? _value.acceptsDigital
          : acceptsDigital // ignore: cast_nullable_to_non_nullable
              as bool,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      zipCode: freezed == zipCode
          ? _value.zipCode
          : zipCode // ignore: cast_nullable_to_non_nullable
              as String?,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDeals: null == totalDeals
          ? _value.totalDeals
          : totalDeals // ignore: cast_nullable_to_non_nullable
              as int,
      activeDeals: null == activeDeals
          ? _value.activeDeals
          : activeDeals // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$BusinessImpl extends _Business {
  const _$BusinessImpl(
      {required this.id,
      @JsonKey(name: 'owner_id') required this.ownerId,
      required this.name,
      this.description,
      required this.address,
      this.latitude,
      this.longitude,
      this.phone,
      this.email,
      @JsonKey(name: 'logo_url') this.logoUrl,
      @JsonKey(name: 'cover_image_url') this.coverImageUrl,
      @JsonKey(name: 'business_license') this.businessLicense,
      @JsonKey(name: 'tax_id') this.taxId,
      this.category,
      this.website,
      @JsonKey(name: 'business_hours')
      final Map<String, dynamic>? businessHours,
      @JsonKey(name: 'delivery_radius') this.deliveryRadius = 5.0,
      @JsonKey(name: 'min_order_amount') this.minOrderAmount = 0.0,
      @JsonKey(name: 'accepts_cash') this.acceptsCash = true,
      @JsonKey(name: 'accepts_cards') this.acceptsCards = true,
      @JsonKey(name: 'accepts_digital') this.acceptsDigital = false,
      @JsonKey(name: 'is_approved') this.isApproved = false,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'onboarding_completed') this.onboardingCompleted = false,
      this.city,
      this.state,
      @JsonKey(name: 'zip_code') this.zipCode,
      this.country = 'United States',
      this.rating = 0.0,
      @JsonKey(name: 'review_count') this.reviewCount = 0,
      @JsonKey(name: 'total_deals') this.totalDeals = 0,
      @JsonKey(name: 'active_deals') this.activeDeals = 0,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _businessHours = businessHours,
        super._();

  factory _$BusinessImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'owner_id')
  final String ownerId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @override
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
// Business license and legal info
  @override
  @JsonKey(name: 'business_license')
  final String? businessLicense;
  @override
  @JsonKey(name: 'tax_id')
  final String? taxId;
  @override
  final String? category;
// Business category (replaces cuisine_type)
  @override
  final String? website;
  final Map<String, dynamic>? _businessHours;
  @override
  @JsonKey(name: 'business_hours')
  Map<String, dynamic>? get businessHours {
    final value = _businessHours;
    if (value == null) return null;
    if (_businessHours is EqualUnmodifiableMapView) return _businessHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Service preferences
  @override
  @JsonKey(name: 'delivery_radius')
  final double deliveryRadius;
  @override
  @JsonKey(name: 'min_order_amount')
  final double minOrderAmount;
  @override
  @JsonKey(name: 'accepts_cash')
  final bool acceptsCash;
  @override
  @JsonKey(name: 'accepts_cards')
  final bool acceptsCards;
  @override
  @JsonKey(name: 'accepts_digital')
  final bool acceptsDigital;
// Administrative fields
  @override
  @JsonKey(name: 'is_approved')
  final bool isApproved;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'onboarding_completed')
  final bool onboardingCompleted;
// Location details
  @override
  final String? city;
  @override
  final String? state;
  @override
  @JsonKey(name: 'zip_code')
  final String? zipCode;
  @override
  @JsonKey()
  final String country;
// Stats (computed fields)
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey(name: 'review_count')
  final int reviewCount;
  @override
  @JsonKey(name: 'total_deals')
  final int totalDeals;
  @override
  @JsonKey(name: 'active_deals')
  final int activeDeals;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Business(id: $id, ownerId: $ownerId, name: $name, description: $description, address: $address, latitude: $latitude, longitude: $longitude, phone: $phone, email: $email, logoUrl: $logoUrl, coverImageUrl: $coverImageUrl, businessLicense: $businessLicense, taxId: $taxId, category: $category, website: $website, businessHours: $businessHours, deliveryRadius: $deliveryRadius, minOrderAmount: $minOrderAmount, acceptsCash: $acceptsCash, acceptsCards: $acceptsCards, acceptsDigital: $acceptsDigital, isApproved: $isApproved, isActive: $isActive, onboardingCompleted: $onboardingCompleted, city: $city, state: $state, zipCode: $zipCode, country: $country, rating: $rating, reviewCount: $reviewCount, totalDeals: $totalDeals, activeDeals: $activeDeals, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.businessLicense, businessLicense) ||
                other.businessLicense == businessLicense) &&
            (identical(other.taxId, taxId) || other.taxId == taxId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.website, website) || other.website == website) &&
            const DeepCollectionEquality()
                .equals(other._businessHours, _businessHours) &&
            (identical(other.deliveryRadius, deliveryRadius) ||
                other.deliveryRadius == deliveryRadius) &&
            (identical(other.minOrderAmount, minOrderAmount) ||
                other.minOrderAmount == minOrderAmount) &&
            (identical(other.acceptsCash, acceptsCash) ||
                other.acceptsCash == acceptsCash) &&
            (identical(other.acceptsCards, acceptsCards) ||
                other.acceptsCards == acceptsCards) &&
            (identical(other.acceptsDigital, acceptsDigital) ||
                other.acceptsDigital == acceptsDigital) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.zipCode, zipCode) || other.zipCode == zipCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.totalDeals, totalDeals) ||
                other.totalDeals == totalDeals) &&
            (identical(other.activeDeals, activeDeals) ||
                other.activeDeals == activeDeals) &&
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
        ownerId,
        name,
        description,
        address,
        latitude,
        longitude,
        phone,
        email,
        logoUrl,
        coverImageUrl,
        businessLicense,
        taxId,
        category,
        website,
        const DeepCollectionEquality().hash(_businessHours),
        deliveryRadius,
        minOrderAmount,
        acceptsCash,
        acceptsCards,
        acceptsDigital,
        isApproved,
        isActive,
        onboardingCompleted,
        city,
        state,
        zipCode,
        country,
        rating,
        reviewCount,
        totalDeals,
        activeDeals,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of Business
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessImplCopyWith<_$BusinessImpl> get copyWith =>
      __$$BusinessImplCopyWithImpl<_$BusinessImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessImplToJson(
      this,
    );
  }
}

abstract class _Business extends Business {
  const factory _Business(
      {required final String id,
      @JsonKey(name: 'owner_id') required final String ownerId,
      required final String name,
      final String? description,
      required final String address,
      final double? latitude,
      final double? longitude,
      final String? phone,
      final String? email,
      @JsonKey(name: 'logo_url') final String? logoUrl,
      @JsonKey(name: 'cover_image_url') final String? coverImageUrl,
      @JsonKey(name: 'business_license') final String? businessLicense,
      @JsonKey(name: 'tax_id') final String? taxId,
      final String? category,
      final String? website,
      @JsonKey(name: 'business_hours')
      final Map<String, dynamic>? businessHours,
      @JsonKey(name: 'delivery_radius') final double deliveryRadius,
      @JsonKey(name: 'min_order_amount') final double minOrderAmount,
      @JsonKey(name: 'accepts_cash') final bool acceptsCash,
      @JsonKey(name: 'accepts_cards') final bool acceptsCards,
      @JsonKey(name: 'accepts_digital') final bool acceptsDigital,
      @JsonKey(name: 'is_approved') final bool isApproved,
      @JsonKey(name: 'is_active') final bool isActive,
      @JsonKey(name: 'onboarding_completed') final bool onboardingCompleted,
      final String? city,
      final String? state,
      @JsonKey(name: 'zip_code') final String? zipCode,
      final String country,
      final double rating,
      @JsonKey(name: 'review_count') final int reviewCount,
      @JsonKey(name: 'total_deals') final int totalDeals,
      @JsonKey(name: 'active_deals') final int activeDeals,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$BusinessImpl;
  const _Business._() : super._();

  factory _Business.fromJson(Map<String, dynamic> json) =
      _$BusinessImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  @JsonKey(name: 'logo_url')
  String? get logoUrl;
  @override
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl; // Business license and legal info
  @override
  @JsonKey(name: 'business_license')
  String? get businessLicense;
  @override
  @JsonKey(name: 'tax_id')
  String? get taxId;
  @override
  String? get category; // Business category (replaces cuisine_type)
  @override
  String? get website;
  @override
  @JsonKey(name: 'business_hours')
  Map<String, dynamic>? get businessHours; // Service preferences
  @override
  @JsonKey(name: 'delivery_radius')
  double get deliveryRadius;
  @override
  @JsonKey(name: 'min_order_amount')
  double get minOrderAmount;
  @override
  @JsonKey(name: 'accepts_cash')
  bool get acceptsCash;
  @override
  @JsonKey(name: 'accepts_cards')
  bool get acceptsCards;
  @override
  @JsonKey(name: 'accepts_digital')
  bool get acceptsDigital; // Administrative fields
  @override
  @JsonKey(name: 'is_approved')
  bool get isApproved;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'onboarding_completed')
  bool get onboardingCompleted; // Location details
  @override
  String? get city;
  @override
  String? get state;
  @override
  @JsonKey(name: 'zip_code')
  String? get zipCode;
  @override
  String get country; // Stats (computed fields)
  @override
  double get rating;
  @override
  @JsonKey(name: 'review_count')
  int get reviewCount;
  @override
  @JsonKey(name: 'total_deals')
  int get totalDeals;
  @override
  @JsonKey(name: 'active_deals')
  int get activeDeals;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Business
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessImplCopyWith<_$BusinessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
