// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderBusiness _$OrderBusinessFromJson(Map<String, dynamic> json) {
  return _OrderBusiness.fromJson(json);
}

/// @nodoc
mixin _$OrderBusiness {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this OrderBusiness to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderBusiness
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderBusinessCopyWith<OrderBusiness> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderBusinessCopyWith<$Res> {
  factory $OrderBusinessCopyWith(
          OrderBusiness value, $Res Function(OrderBusiness) then) =
      _$OrderBusinessCopyWithImpl<$Res, OrderBusiness>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? address,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class _$OrderBusinessCopyWithImpl<$Res, $Val extends OrderBusiness>
    implements $OrderBusinessCopyWith<$Res> {
  _$OrderBusinessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderBusiness
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? address = freezed,
    Object? imageUrl = freezed,
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
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderBusinessImplCopyWith<$Res>
    implements $OrderBusinessCopyWith<$Res> {
  factory _$$OrderBusinessImplCopyWith(
          _$OrderBusinessImpl value, $Res Function(_$OrderBusinessImpl) then) =
      __$$OrderBusinessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? phone,
      String? address,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class __$$OrderBusinessImplCopyWithImpl<$Res>
    extends _$OrderBusinessCopyWithImpl<$Res, _$OrderBusinessImpl>
    implements _$$OrderBusinessImplCopyWith<$Res> {
  __$$OrderBusinessImplCopyWithImpl(
      _$OrderBusinessImpl _value, $Res Function(_$OrderBusinessImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderBusiness
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? address = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_$OrderBusinessImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderBusinessImpl implements _OrderBusiness {
  const _$OrderBusinessImpl(
      {required this.id,
      required this.name,
      this.phone,
      this.address,
      @JsonKey(name: 'image_url') this.imageUrl});

  factory _$OrderBusinessImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderBusinessImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? address;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @override
  String toString() {
    return 'OrderBusiness(id: $id, name: $name, phone: $phone, address: $address, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderBusinessImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, phone, address, imageUrl);

  /// Create a copy of OrderBusiness
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderBusinessImplCopyWith<_$OrderBusinessImpl> get copyWith =>
      __$$OrderBusinessImplCopyWithImpl<_$OrderBusinessImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderBusinessImplToJson(
      this,
    );
  }
}

abstract class _OrderBusiness implements OrderBusiness {
  const factory _OrderBusiness(
          {required final String id,
          required final String name,
          final String? phone,
          final String? address,
          @JsonKey(name: 'image_url') final String? imageUrl}) =
      _$OrderBusinessImpl;

  factory _OrderBusiness.fromJson(Map<String, dynamic> json) =
      _$OrderBusinessImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String? get address;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;

  /// Create a copy of OrderBusiness
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderBusinessImplCopyWith<_$OrderBusinessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderCustomer _$OrderCustomerFromJson(Map<String, dynamic> json) {
  return _OrderCustomer.fromJson(json);
}

/// @nodoc
mixin _$OrderCustomer {
  String get id => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String? get fullName => throw _privateConstructorUsedError;

  /// Serializes this OrderCustomer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCustomerCopyWith<OrderCustomer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCustomerCopyWith<$Res> {
  factory $OrderCustomerCopyWith(
          OrderCustomer value, $Res Function(OrderCustomer) then) =
      _$OrderCustomerCopyWithImpl<$Res, OrderCustomer>;
  @useResult
  $Res call(
      {String id,
      String? email,
      @JsonKey(name: 'name') String? displayName,
      @JsonKey(name: 'full_name') String? fullName});
}

/// @nodoc
class _$OrderCustomerCopyWithImpl<$Res, $Val extends OrderCustomer>
    implements $OrderCustomerCopyWith<$Res> {
  _$OrderCustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? displayName = freezed,
    Object? fullName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderCustomerImplCopyWith<$Res>
    implements $OrderCustomerCopyWith<$Res> {
  factory _$$OrderCustomerImplCopyWith(
          _$OrderCustomerImpl value, $Res Function(_$OrderCustomerImpl) then) =
      __$$OrderCustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? email,
      @JsonKey(name: 'name') String? displayName,
      @JsonKey(name: 'full_name') String? fullName});
}

/// @nodoc
class __$$OrderCustomerImplCopyWithImpl<$Res>
    extends _$OrderCustomerCopyWithImpl<$Res, _$OrderCustomerImpl>
    implements _$$OrderCustomerImplCopyWith<$Res> {
  __$$OrderCustomerImplCopyWithImpl(
      _$OrderCustomerImpl _value, $Res Function(_$OrderCustomerImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? displayName = freezed,
    Object? fullName = freezed,
  }) {
    return _then(_$OrderCustomerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderCustomerImpl implements _OrderCustomer {
  const _$OrderCustomerImpl(
      {required this.id,
      this.email,
      @JsonKey(name: 'name') this.displayName,
      @JsonKey(name: 'full_name') this.fullName});

  factory _$OrderCustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderCustomerImplFromJson(json);

  @override
  final String id;
  @override
  final String? email;
  @override
  @JsonKey(name: 'name')
  final String? displayName;
  @override
  @JsonKey(name: 'full_name')
  final String? fullName;

  @override
  String toString() {
    return 'OrderCustomer(id: $id, email: $email, displayName: $displayName, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderCustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, email, displayName, fullName);

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderCustomerImplCopyWith<_$OrderCustomerImpl> get copyWith =>
      __$$OrderCustomerImplCopyWithImpl<_$OrderCustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderCustomerImplToJson(
      this,
    );
  }
}

abstract class _OrderCustomer implements OrderCustomer {
  const factory _OrderCustomer(
          {required final String id,
          final String? email,
          @JsonKey(name: 'name') final String? displayName,
          @JsonKey(name: 'full_name') final String? fullName}) =
      _$OrderCustomerImpl;

  factory _OrderCustomer.fromJson(Map<String, dynamic> json) =
      _$OrderCustomerImpl.fromJson;

  @override
  String get id;
  @override
  String? get email;
  @override
  @JsonKey(name: 'name')
  String? get displayName;
  @override
  @JsonKey(name: 'full_name')
  String? get fullName;

  /// Create a copy of OrderCustomer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderCustomerImplCopyWith<_$OrderCustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderDeal _$OrderDealFromJson(Map<String, dynamic> json) {
  return _OrderDeal.fromJson(json);
}

/// @nodoc
mixin _$OrderDeal {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this OrderDeal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderDeal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderDealCopyWith<OrderDeal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderDealCopyWith<$Res> {
  factory $OrderDealCopyWith(OrderDeal value, $Res Function(OrderDeal) then) =
      _$OrderDealCopyWithImpl<$Res, OrderDeal>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class _$OrderDealCopyWithImpl<$Res, $Val extends OrderDeal>
    implements $OrderDealCopyWith<$Res> {
  _$OrderDealCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderDeal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderDealImplCopyWith<$Res>
    implements $OrderDealCopyWith<$Res> {
  factory _$$OrderDealImplCopyWith(
          _$OrderDealImpl value, $Res Function(_$OrderDealImpl) then) =
      __$$OrderDealImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class __$$OrderDealImplCopyWithImpl<$Res>
    extends _$OrderDealCopyWithImpl<$Res, _$OrderDealImpl>
    implements _$$OrderDealImplCopyWith<$Res> {
  __$$OrderDealImplCopyWithImpl(
      _$OrderDealImpl _value, $Res Function(_$OrderDealImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderDeal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_$OrderDealImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderDealImpl implements _OrderDeal {
  const _$OrderDealImpl(
      {required this.id,
      required this.title,
      this.description,
      @JsonKey(name: 'image_url') this.imageUrl});

  factory _$OrderDealImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderDealImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @override
  String toString() {
    return 'OrderDeal(id: $id, title: $title, description: $description, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderDealImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, description, imageUrl);

  /// Create a copy of OrderDeal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderDealImplCopyWith<_$OrderDealImpl> get copyWith =>
      __$$OrderDealImplCopyWithImpl<_$OrderDealImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderDealImplToJson(
      this,
    );
  }
}

abstract class _OrderDeal implements OrderDeal {
  const factory _OrderDeal(
      {required final String id,
      required final String title,
      final String? description,
      @JsonKey(name: 'image_url') final String? imageUrl}) = _$OrderDealImpl;

  factory _OrderDeal.fromJson(Map<String, dynamic> json) =
      _$OrderDealImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;

  /// Create a copy of OrderDeal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderDealImplCopyWith<_$OrderDealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'deal_id')
  String get dealId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  OrderDeal? get deals => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'deal_id') String dealId,
      int quantity,
      double price,
      String? notes,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      OrderDeal? deals});

  $OrderDealCopyWith<$Res>? get deals;
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? dealId = null,
    Object? quantity = null,
    Object? price = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? deals = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      dealId: null == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deals: freezed == deals
          ? _value.deals
          : deals // ignore: cast_nullable_to_non_nullable
              as OrderDeal?,
    ) as $Val);
  }

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderDealCopyWith<$Res>? get deals {
    if (_value.deals == null) {
      return null;
    }

    return $OrderDealCopyWith<$Res>(_value.deals!, (value) {
      return _then(_value.copyWith(deals: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
          _$OrderItemImpl value, $Res Function(_$OrderItemImpl) then) =
      __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'deal_id') String dealId,
      int quantity,
      double price,
      String? notes,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      OrderDeal? deals});

  @override
  $OrderDealCopyWith<$Res>? get deals;
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
      _$OrderItemImpl _value, $Res Function(_$OrderItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? dealId = null,
    Object? quantity = null,
    Object? price = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? deals = freezed,
  }) {
    return _then(_$OrderItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      dealId: null == dealId
          ? _value.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deals: freezed == deals
          ? _value.deals
          : deals // ignore: cast_nullable_to_non_nullable
              as OrderDeal?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl implements _OrderItem {
  const _$OrderItemImpl(
      {required this.id,
      @JsonKey(name: 'order_id') required this.orderId,
      @JsonKey(name: 'deal_id') required this.dealId,
      required this.quantity,
      required this.price,
      this.notes,
      @JsonKey(name: 'created_at') this.createdAt,
      this.deals});

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'deal_id')
  final String dealId;
  @override
  final int quantity;
  @override
  final double price;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  final OrderDeal? deals;

  @override
  String toString() {
    return 'OrderItem(id: $id, orderId: $orderId, dealId: $dealId, quantity: $quantity, price: $price, notes: $notes, createdAt: $createdAt, deals: $deals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deals, deals) || other.deals == deals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, orderId, dealId, quantity,
      price, notes, createdAt, deals);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(
      this,
    );
  }
}

abstract class _OrderItem implements OrderItem {
  const factory _OrderItem(
      {required final String id,
      @JsonKey(name: 'order_id') required final String orderId,
      @JsonKey(name: 'deal_id') required final String dealId,
      required final int quantity,
      required final double price,
      final String? notes,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      final OrderDeal? deals}) = _$OrderItemImpl;

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'deal_id')
  String get dealId;
  @override
  int get quantity;
  @override
  double get price;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  OrderDeal? get deals;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'business_id')
  String get businessId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  double get totalAmount => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_address')
  String? get deliveryAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_instructions')
  String? get deliveryInstructions => throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_time')
  DateTime? get pickupTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  PaymentMethod get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  PaymentStatus get paymentStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // New verification fields for simplified flow
  @JsonKey(name: 'verification_code')
  String? get verificationCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'qr_data')
  String? get qrData => throw _privateConstructorUsedError;
  @JsonKey(name: 'confirmed_at')
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt =>
      throw _privateConstructorUsedError; // Nested data from API
  OrderBusiness? get businesses => throw _privateConstructorUsedError;
  @JsonKey(name: 'app_users')
  OrderCustomer? get customer => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_items')
  List<OrderItem> get orderItems => throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'business_id') String businessId,
      @JsonKey(name: 'total_amount') double totalAmount,
      OrderStatus status,
      @JsonKey(name: 'delivery_address') String? deliveryAddress,
      @JsonKey(name: 'delivery_instructions') String? deliveryInstructions,
      @JsonKey(name: 'pickup_time') DateTime? pickupTime,
      @JsonKey(name: 'payment_method') PaymentMethod paymentMethod,
      @JsonKey(name: 'payment_status') PaymentStatus paymentStatus,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'verification_code') String? verificationCode,
      @JsonKey(name: 'qr_data') String? qrData,
      @JsonKey(name: 'confirmed_at') DateTime? confirmedAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      OrderBusiness? businesses,
      @JsonKey(name: 'app_users') OrderCustomer? customer,
      @JsonKey(name: 'order_items') List<OrderItem> orderItems});

  $OrderBusinessCopyWith<$Res>? get businesses;
  $OrderCustomerCopyWith<$Res>? get customer;
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? businessId = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? deliveryAddress = freezed,
    Object? deliveryInstructions = freezed,
    Object? pickupTime = freezed,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? verificationCode = freezed,
    Object? qrData = freezed,
    Object? confirmedAt = freezed,
    Object? completedAt = freezed,
    Object? businesses = freezed,
    Object? customer = freezed,
    Object? orderItems = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      businessId: null == businessId
          ? _value.businessId
          : businessId // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryInstructions: freezed == deliveryInstructions
          ? _value.deliveryInstructions
          : deliveryInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
      pickupTime: freezed == pickupTime
          ? _value.pickupTime
          : pickupTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verificationCode: freezed == verificationCode
          ? _value.verificationCode
          : verificationCode // ignore: cast_nullable_to_non_nullable
              as String?,
      qrData: freezed == qrData
          ? _value.qrData
          : qrData // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      businesses: freezed == businesses
          ? _value.businesses
          : businesses // ignore: cast_nullable_to_non_nullable
              as OrderBusiness?,
      customer: freezed == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as OrderCustomer?,
      orderItems: null == orderItems
          ? _value.orderItems
          : orderItems // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
    ) as $Val);
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderBusinessCopyWith<$Res>? get businesses {
    if (_value.businesses == null) {
      return null;
    }

    return $OrderBusinessCopyWith<$Res>(_value.businesses!, (value) {
      return _then(_value.copyWith(businesses: value) as $Val);
    });
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCustomerCopyWith<$Res>? get customer {
    if (_value.customer == null) {
      return null;
    }

    return $OrderCustomerCopyWith<$Res>(_value.customer!, (value) {
      return _then(_value.copyWith(customer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
          _$OrderImpl value, $Res Function(_$OrderImpl) then) =
      __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'business_id') String businessId,
      @JsonKey(name: 'total_amount') double totalAmount,
      OrderStatus status,
      @JsonKey(name: 'delivery_address') String? deliveryAddress,
      @JsonKey(name: 'delivery_instructions') String? deliveryInstructions,
      @JsonKey(name: 'pickup_time') DateTime? pickupTime,
      @JsonKey(name: 'payment_method') PaymentMethod paymentMethod,
      @JsonKey(name: 'payment_status') PaymentStatus paymentStatus,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'verification_code') String? verificationCode,
      @JsonKey(name: 'qr_data') String? qrData,
      @JsonKey(name: 'confirmed_at') DateTime? confirmedAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      OrderBusiness? businesses,
      @JsonKey(name: 'app_users') OrderCustomer? customer,
      @JsonKey(name: 'order_items') List<OrderItem> orderItems});

  @override
  $OrderBusinessCopyWith<$Res>? get businesses;
  @override
  $OrderCustomerCopyWith<$Res>? get customer;
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
      _$OrderImpl _value, $Res Function(_$OrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? businessId = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? deliveryAddress = freezed,
    Object? deliveryInstructions = freezed,
    Object? pickupTime = freezed,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? verificationCode = freezed,
    Object? qrData = freezed,
    Object? confirmedAt = freezed,
    Object? completedAt = freezed,
    Object? businesses = freezed,
    Object? customer = freezed,
    Object? orderItems = null,
  }) {
    return _then(_$OrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      businessId: null == businessId
          ? _value.businessId
          : businessId // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryInstructions: freezed == deliveryInstructions
          ? _value.deliveryInstructions
          : deliveryInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
      pickupTime: freezed == pickupTime
          ? _value.pickupTime
          : pickupTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as PaymentMethod,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verificationCode: freezed == verificationCode
          ? _value.verificationCode
          : verificationCode // ignore: cast_nullable_to_non_nullable
              as String?,
      qrData: freezed == qrData
          ? _value.qrData
          : qrData // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      businesses: freezed == businesses
          ? _value.businesses
          : businesses // ignore: cast_nullable_to_non_nullable
              as OrderBusiness?,
      customer: freezed == customer
          ? _value.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as OrderCustomer?,
      orderItems: null == orderItems
          ? _value._orderItems
          : orderItems // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl extends _Order {
  const _$OrderImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'business_id') required this.businessId,
      @JsonKey(name: 'total_amount') required this.totalAmount,
      required this.status,
      @JsonKey(name: 'delivery_address') this.deliveryAddress,
      @JsonKey(name: 'delivery_instructions') this.deliveryInstructions,
      @JsonKey(name: 'pickup_time') this.pickupTime,
      @JsonKey(name: 'payment_method') required this.paymentMethod,
      @JsonKey(name: 'payment_status')
      this.paymentStatus = PaymentStatus.pending,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'verification_code') this.verificationCode,
      @JsonKey(name: 'qr_data') this.qrData,
      @JsonKey(name: 'confirmed_at') this.confirmedAt,
      @JsonKey(name: 'completed_at') this.completedAt,
      this.businesses,
      @JsonKey(name: 'app_users') this.customer,
      @JsonKey(name: 'order_items')
      final List<OrderItem> orderItems = const []})
      : _orderItems = orderItems,
        super._();

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'business_id')
  final String businessId;
  @override
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @override
  final OrderStatus status;
  @override
  @JsonKey(name: 'delivery_address')
  final String? deliveryAddress;
  @override
  @JsonKey(name: 'delivery_instructions')
  final String? deliveryInstructions;
  @override
  @JsonKey(name: 'pickup_time')
  final DateTime? pickupTime;
  @override
  @JsonKey(name: 'payment_method')
  final PaymentMethod paymentMethod;
  @override
  @JsonKey(name: 'payment_status')
  final PaymentStatus paymentStatus;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
// New verification fields for simplified flow
  @override
  @JsonKey(name: 'verification_code')
  final String? verificationCode;
  @override
  @JsonKey(name: 'qr_data')
  final String? qrData;
  @override
  @JsonKey(name: 'confirmed_at')
  final DateTime? confirmedAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
// Nested data from API
  @override
  final OrderBusiness? businesses;
  @override
  @JsonKey(name: 'app_users')
  final OrderCustomer? customer;
  final List<OrderItem> _orderItems;
  @override
  @JsonKey(name: 'order_items')
  List<OrderItem> get orderItems {
    if (_orderItems is EqualUnmodifiableListView) return _orderItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orderItems);
  }

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, businessId: $businessId, totalAmount: $totalAmount, status: $status, deliveryAddress: $deliveryAddress, deliveryInstructions: $deliveryInstructions, pickupTime: $pickupTime, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, createdAt: $createdAt, updatedAt: $updatedAt, verificationCode: $verificationCode, qrData: $qrData, confirmedAt: $confirmedAt, completedAt: $completedAt, businesses: $businesses, customer: $customer, orderItems: $orderItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.businessId, businessId) ||
                other.businessId == businessId) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.deliveryInstructions, deliveryInstructions) ||
                other.deliveryInstructions == deliveryInstructions) &&
            (identical(other.pickupTime, pickupTime) ||
                other.pickupTime == pickupTime) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.verificationCode, verificationCode) ||
                other.verificationCode == verificationCode) &&
            (identical(other.qrData, qrData) || other.qrData == qrData) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.businesses, businesses) ||
                other.businesses == businesses) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            const DeepCollectionEquality()
                .equals(other._orderItems, _orderItems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        businessId,
        totalAmount,
        status,
        deliveryAddress,
        deliveryInstructions,
        pickupTime,
        paymentMethod,
        paymentStatus,
        createdAt,
        updatedAt,
        verificationCode,
        qrData,
        confirmedAt,
        completedAt,
        businesses,
        customer,
        const DeepCollectionEquality().hash(_orderItems)
      ]);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(
      this,
    );
  }
}

abstract class _Order extends Order {
  const factory _Order(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'business_id') required final String businessId,
          @JsonKey(name: 'total_amount') required final double totalAmount,
          required final OrderStatus status,
          @JsonKey(name: 'delivery_address') final String? deliveryAddress,
          @JsonKey(name: 'delivery_instructions')
          final String? deliveryInstructions,
          @JsonKey(name: 'pickup_time') final DateTime? pickupTime,
          @JsonKey(name: 'payment_method')
          required final PaymentMethod paymentMethod,
          @JsonKey(name: 'payment_status') final PaymentStatus paymentStatus,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt,
          @JsonKey(name: 'verification_code') final String? verificationCode,
          @JsonKey(name: 'qr_data') final String? qrData,
          @JsonKey(name: 'confirmed_at') final DateTime? confirmedAt,
          @JsonKey(name: 'completed_at') final DateTime? completedAt,
          final OrderBusiness? businesses,
          @JsonKey(name: 'app_users') final OrderCustomer? customer,
          @JsonKey(name: 'order_items') final List<OrderItem> orderItems}) =
      _$OrderImpl;
  const _Order._() : super._();

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'business_id')
  String get businessId;
  @override
  @JsonKey(name: 'total_amount')
  double get totalAmount;
  @override
  OrderStatus get status;
  @override
  @JsonKey(name: 'delivery_address')
  String? get deliveryAddress;
  @override
  @JsonKey(name: 'delivery_instructions')
  String? get deliveryInstructions;
  @override
  @JsonKey(name: 'pickup_time')
  DateTime? get pickupTime;
  @override
  @JsonKey(name: 'payment_method')
  PaymentMethod get paymentMethod;
  @override
  @JsonKey(name: 'payment_status')
  PaymentStatus get paymentStatus;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt; // New verification fields for simplified flow
  @override
  @JsonKey(name: 'verification_code')
  String? get verificationCode;
  @override
  @JsonKey(name: 'qr_data')
  String? get qrData;
  @override
  @JsonKey(name: 'confirmed_at')
  DateTime? get confirmedAt;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt; // Nested data from API
  @override
  OrderBusiness? get businesses;
  @override
  @JsonKey(name: 'app_users')
  OrderCustomer? get customer;
  @override
  @JsonKey(name: 'order_items')
  List<OrderItem> get orderItems;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderWithDetails _$OrderWithDetailsFromJson(Map<String, dynamic> json) {
  return _OrderWithDetails.fromJson(json);
}

/// @nodoc
mixin _$OrderWithDetails {
  Order get order => throw _privateConstructorUsedError;
  String? get dealTitle => throw _privateConstructorUsedError;
  String? get dealImageUrl => throw _privateConstructorUsedError;
  String? get businessName => throw _privateConstructorUsedError;
  String? get businessAddress => throw _privateConstructorUsedError;
  String? get businessPhone => throw _privateConstructorUsedError;

  /// Serializes this OrderWithDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderWithDetailsCopyWith<OrderWithDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderWithDetailsCopyWith<$Res> {
  factory $OrderWithDetailsCopyWith(
          OrderWithDetails value, $Res Function(OrderWithDetails) then) =
      _$OrderWithDetailsCopyWithImpl<$Res, OrderWithDetails>;
  @useResult
  $Res call(
      {Order order,
      String? dealTitle,
      String? dealImageUrl,
      String? businessName,
      String? businessAddress,
      String? businessPhone});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class _$OrderWithDetailsCopyWithImpl<$Res, $Val extends OrderWithDetails>
    implements $OrderWithDetailsCopyWith<$Res> {
  _$OrderWithDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? dealTitle = freezed,
    Object? dealImageUrl = freezed,
    Object? businessName = freezed,
    Object? businessAddress = freezed,
    Object? businessPhone = freezed,
  }) {
    return _then(_value.copyWith(
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      dealImageUrl: freezed == dealImageUrl
          ? _value.dealImageUrl
          : dealImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      businessName: freezed == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      businessAddress: freezed == businessAddress
          ? _value.businessAddress
          : businessAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      businessPhone: freezed == businessPhone
          ? _value.businessPhone
          : businessPhone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of OrderWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res> get order {
    return $OrderCopyWith<$Res>(_value.order, (value) {
      return _then(_value.copyWith(order: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderWithDetailsImplCopyWith<$Res>
    implements $OrderWithDetailsCopyWith<$Res> {
  factory _$$OrderWithDetailsImplCopyWith(_$OrderWithDetailsImpl value,
          $Res Function(_$OrderWithDetailsImpl) then) =
      __$$OrderWithDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Order order,
      String? dealTitle,
      String? dealImageUrl,
      String? businessName,
      String? businessAddress,
      String? businessPhone});

  @override
  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$OrderWithDetailsImplCopyWithImpl<$Res>
    extends _$OrderWithDetailsCopyWithImpl<$Res, _$OrderWithDetailsImpl>
    implements _$$OrderWithDetailsImplCopyWith<$Res> {
  __$$OrderWithDetailsImplCopyWithImpl(_$OrderWithDetailsImpl _value,
      $Res Function(_$OrderWithDetailsImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? dealTitle = freezed,
    Object? dealImageUrl = freezed,
    Object? businessName = freezed,
    Object? businessAddress = freezed,
    Object? businessPhone = freezed,
  }) {
    return _then(_$OrderWithDetailsImpl(
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
      dealTitle: freezed == dealTitle
          ? _value.dealTitle
          : dealTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      dealImageUrl: freezed == dealImageUrl
          ? _value.dealImageUrl
          : dealImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      businessName: freezed == businessName
          ? _value.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      businessAddress: freezed == businessAddress
          ? _value.businessAddress
          : businessAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      businessPhone: freezed == businessPhone
          ? _value.businessPhone
          : businessPhone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderWithDetailsImpl implements _OrderWithDetails {
  const _$OrderWithDetailsImpl(
      {required this.order,
      this.dealTitle,
      this.dealImageUrl,
      this.businessName,
      this.businessAddress,
      this.businessPhone});

  factory _$OrderWithDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderWithDetailsImplFromJson(json);

  @override
  final Order order;
  @override
  final String? dealTitle;
  @override
  final String? dealImageUrl;
  @override
  final String? businessName;
  @override
  final String? businessAddress;
  @override
  final String? businessPhone;

  @override
  String toString() {
    return 'OrderWithDetails(order: $order, dealTitle: $dealTitle, dealImageUrl: $dealImageUrl, businessName: $businessName, businessAddress: $businessAddress, businessPhone: $businessPhone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderWithDetailsImpl &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.dealTitle, dealTitle) ||
                other.dealTitle == dealTitle) &&
            (identical(other.dealImageUrl, dealImageUrl) ||
                other.dealImageUrl == dealImageUrl) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.businessAddress, businessAddress) ||
                other.businessAddress == businessAddress) &&
            (identical(other.businessPhone, businessPhone) ||
                other.businessPhone == businessPhone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, order, dealTitle, dealImageUrl,
      businessName, businessAddress, businessPhone);

  /// Create a copy of OrderWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderWithDetailsImplCopyWith<_$OrderWithDetailsImpl> get copyWith =>
      __$$OrderWithDetailsImplCopyWithImpl<_$OrderWithDetailsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderWithDetailsImplToJson(
      this,
    );
  }
}

abstract class _OrderWithDetails implements OrderWithDetails {
  const factory _OrderWithDetails(
      {required final Order order,
      final String? dealTitle,
      final String? dealImageUrl,
      final String? businessName,
      final String? businessAddress,
      final String? businessPhone}) = _$OrderWithDetailsImpl;

  factory _OrderWithDetails.fromJson(Map<String, dynamic> json) =
      _$OrderWithDetailsImpl.fromJson;

  @override
  Order get order;
  @override
  String? get dealTitle;
  @override
  String? get dealImageUrl;
  @override
  String? get businessName;
  @override
  String? get businessAddress;
  @override
  String? get businessPhone;

  /// Create a copy of OrderWithDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderWithDetailsImplCopyWith<_$OrderWithDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
