// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Deal _$DealFromJson(Map<String, dynamic> json) {
  return _Deal.fromJson(json);
}

/// @nodoc
mixin _$Deal {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_id')
  String get businessId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_price')
  double get originalPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'discounted_price')
  double get discountedPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_percentage')
  int? get apiDiscountPercentage =>
      throw _privateConstructorUsedError; // From API response
  @JsonKey(name: 'quantity_available')
  int get quantityAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'quantity_sold')
  int get quantitySold => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'allergen_info')
  String? get allergenInfo => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt => throw _privateConstructorUsedError;
  DealStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'businesses')
  Restaurant? get restaurant => throw _privateConstructorUsedError;

  /// Serializes this Deal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealCopyWith<Deal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealCopyWith<$Res> {
  factory $DealCopyWith(Deal value, $Res Function(Deal) then) =
      _$DealCopyWithImpl<$Res, Deal>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'business_id') String businessId,
      String title,
      String? description,
      @JsonKey(name: 'original_price') double originalPrice,
      @JsonKey(name: 'discounted_price') double discountedPrice,
      @JsonKey(name: 'discount_percentage') int? apiDiscountPercentage,
      @JsonKey(name: 'quantity_available') int quantityAvailable,
      @JsonKey(name: 'quantity_sold') int quantitySold,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'allergen_info') String? allergenInfo,
      @JsonKey(name: 'expires_at') DateTime expiresAt,
      DealStatus status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'businesses') Restaurant? restaurant});

  $RestaurantCopyWith<$Res>? get restaurant;
}

/// @nodoc
class _$DealCopyWithImpl<$Res, $Val extends Deal>
    implements $DealCopyWith<$Res> {
  _$DealCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? businessId = null,
    Object? title = null,
    Object? description = freezed,
    Object? originalPrice = null,
    Object? discountedPrice = null,
    Object? apiDiscountPercentage = freezed,
    Object? quantityAvailable = null,
    Object? quantitySold = null,
    Object? imageUrl = freezed,
    Object? allergenInfo = freezed,
    Object? expiresAt = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? restaurant = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      businessId: null == businessId
          ? _value.businessId
          : businessId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      originalPrice: null == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      discountedPrice: null == discountedPrice
          ? _value.discountedPrice
          : discountedPrice // ignore: cast_nullable_to_non_nullable
              as double,
      apiDiscountPercentage: freezed == apiDiscountPercentage
          ? _value.apiDiscountPercentage
          : apiDiscountPercentage // ignore: cast_nullable_to_non_nullable
              as int?,
      quantityAvailable: null == quantityAvailable
          ? _value.quantityAvailable
          : quantityAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      quantitySold: null == quantitySold
          ? _value.quantitySold
          : quantitySold // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      allergenInfo: freezed == allergenInfo
          ? _value.allergenInfo
          : allergenInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DealStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      restaurant: freezed == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as Restaurant?,
    ) as $Val);
  }

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RestaurantCopyWith<$Res>? get restaurant {
    if (_value.restaurant == null) {
      return null;
    }

    return $RestaurantCopyWith<$Res>(_value.restaurant!, (value) {
      return _then(_value.copyWith(restaurant: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DealImplCopyWith<$Res> implements $DealCopyWith<$Res> {
  factory _$$DealImplCopyWith(
          _$DealImpl value, $Res Function(_$DealImpl) then) =
      __$$DealImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'business_id') String businessId,
      String title,
      String? description,
      @JsonKey(name: 'original_price') double originalPrice,
      @JsonKey(name: 'discounted_price') double discountedPrice,
      @JsonKey(name: 'discount_percentage') int? apiDiscountPercentage,
      @JsonKey(name: 'quantity_available') int quantityAvailable,
      @JsonKey(name: 'quantity_sold') int quantitySold,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'allergen_info') String? allergenInfo,
      @JsonKey(name: 'expires_at') DateTime expiresAt,
      DealStatus status,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'businesses') Restaurant? restaurant});

  @override
  $RestaurantCopyWith<$Res>? get restaurant;
}

/// @nodoc
class __$$DealImplCopyWithImpl<$Res>
    extends _$DealCopyWithImpl<$Res, _$DealImpl>
    implements _$$DealImplCopyWith<$Res> {
  __$$DealImplCopyWithImpl(_$DealImpl _value, $Res Function(_$DealImpl) _then)
      : super(_value, _then);

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? businessId = null,
    Object? title = null,
    Object? description = freezed,
    Object? originalPrice = null,
    Object? discountedPrice = null,
    Object? apiDiscountPercentage = freezed,
    Object? quantityAvailable = null,
    Object? quantitySold = null,
    Object? imageUrl = freezed,
    Object? allergenInfo = freezed,
    Object? expiresAt = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? restaurant = freezed,
  }) {
    return _then(_$DealImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      businessId: null == businessId
          ? _value.businessId
          : businessId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      originalPrice: null == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      discountedPrice: null == discountedPrice
          ? _value.discountedPrice
          : discountedPrice // ignore: cast_nullable_to_non_nullable
              as double,
      apiDiscountPercentage: freezed == apiDiscountPercentage
          ? _value.apiDiscountPercentage
          : apiDiscountPercentage // ignore: cast_nullable_to_non_nullable
              as int?,
      quantityAvailable: null == quantityAvailable
          ? _value.quantityAvailable
          : quantityAvailable // ignore: cast_nullable_to_non_nullable
              as int,
      quantitySold: null == quantitySold
          ? _value.quantitySold
          : quantitySold // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      allergenInfo: freezed == allergenInfo
          ? _value.allergenInfo
          : allergenInfo // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DealStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      restaurant: freezed == restaurant
          ? _value.restaurant
          : restaurant // ignore: cast_nullable_to_non_nullable
              as Restaurant?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DealImpl extends _Deal {
  const _$DealImpl(
      {required this.id,
      @JsonKey(name: 'business_id') required this.businessId,
      required this.title,
      this.description,
      @JsonKey(name: 'original_price') required this.originalPrice,
      @JsonKey(name: 'discounted_price') required this.discountedPrice,
      @JsonKey(name: 'discount_percentage') this.apiDiscountPercentage,
      @JsonKey(name: 'quantity_available') required this.quantityAvailable,
      @JsonKey(name: 'quantity_sold') this.quantitySold = 0,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'allergen_info') this.allergenInfo,
      @JsonKey(name: 'expires_at') required this.expiresAt,
      this.status = DealStatus.active,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'businesses') this.restaurant})
      : super._();

  factory _$DealImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'business_id')
  final String businessId;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'original_price')
  final double originalPrice;
  @override
  @JsonKey(name: 'discounted_price')
  final double discountedPrice;
  @override
  @JsonKey(name: 'discount_percentage')
  final int? apiDiscountPercentage;
// From API response
  @override
  @JsonKey(name: 'quantity_available')
  final int quantityAvailable;
  @override
  @JsonKey(name: 'quantity_sold')
  final int quantitySold;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'allergen_info')
  final String? allergenInfo;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  @override
  @JsonKey()
  final DealStatus status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'businesses')
  final Restaurant? restaurant;

  @override
  String toString() {
    return 'Deal(id: $id, businessId: $businessId, title: $title, description: $description, originalPrice: $originalPrice, discountedPrice: $discountedPrice, apiDiscountPercentage: $apiDiscountPercentage, quantityAvailable: $quantityAvailable, quantitySold: $quantitySold, imageUrl: $imageUrl, allergenInfo: $allergenInfo, expiresAt: $expiresAt, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, restaurant: $restaurant)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.businessId, businessId) ||
                other.businessId == businessId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.discountedPrice, discountedPrice) ||
                other.discountedPrice == discountedPrice) &&
            (identical(other.apiDiscountPercentage, apiDiscountPercentage) ||
                other.apiDiscountPercentage == apiDiscountPercentage) &&
            (identical(other.quantityAvailable, quantityAvailable) ||
                other.quantityAvailable == quantityAvailable) &&
            (identical(other.quantitySold, quantitySold) ||
                other.quantitySold == quantitySold) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.allergenInfo, allergenInfo) ||
                other.allergenInfo == allergenInfo) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.restaurant, restaurant) ||
                other.restaurant == restaurant));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      businessId,
      title,
      description,
      originalPrice,
      discountedPrice,
      apiDiscountPercentage,
      quantityAvailable,
      quantitySold,
      imageUrl,
      allergenInfo,
      expiresAt,
      status,
      createdAt,
      updatedAt,
      restaurant);

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealImplCopyWith<_$DealImpl> get copyWith =>
      __$$DealImplCopyWithImpl<_$DealImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealImplToJson(
      this,
    );
  }
}

abstract class _Deal extends Deal {
  const factory _Deal(
      {required final String id,
      @JsonKey(name: 'business_id') required final String businessId,
      required final String title,
      final String? description,
      @JsonKey(name: 'original_price') required final double originalPrice,
      @JsonKey(name: 'discounted_price') required final double discountedPrice,
      @JsonKey(name: 'discount_percentage') final int? apiDiscountPercentage,
      @JsonKey(name: 'quantity_available') required final int quantityAvailable,
      @JsonKey(name: 'quantity_sold') final int quantitySold,
      @JsonKey(name: 'image_url') final String? imageUrl,
      @JsonKey(name: 'allergen_info') final String? allergenInfo,
      @JsonKey(name: 'expires_at') required final DateTime expiresAt,
      final DealStatus status,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(name: 'businesses') final Restaurant? restaurant}) = _$DealImpl;
  const _Deal._() : super._();

  factory _Deal.fromJson(Map<String, dynamic> json) = _$DealImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'business_id')
  String get businessId;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'original_price')
  double get originalPrice;
  @override
  @JsonKey(name: 'discounted_price')
  double get discountedPrice;
  @override
  @JsonKey(name: 'discount_percentage')
  int? get apiDiscountPercentage; // From API response
  @override
  @JsonKey(name: 'quantity_available')
  int get quantityAvailable;
  @override
  @JsonKey(name: 'quantity_sold')
  int get quantitySold;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'allergen_info')
  String? get allergenInfo;
  @override
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt;
  @override
  DealStatus get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'businesses')
  Restaurant? get restaurant;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealImplCopyWith<_$DealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
