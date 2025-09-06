// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderBusinessImpl _$$OrderBusinessImplFromJson(Map<String, dynamic> json) =>
    _$OrderBusinessImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$OrderBusinessImplToJson(_$OrderBusinessImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'image_url': instance.imageUrl,
    };

_$OrderCustomerImpl _$$OrderCustomerImplFromJson(Map<String, dynamic> json) =>
    _$OrderCustomerImpl(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['name'] as String?,
      fullName: json['full_name'] as String?,
    );

Map<String, dynamic> _$$OrderCustomerImplToJson(_$OrderCustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.displayName,
      'full_name': instance.fullName,
    };

_$OrderDealImpl _$$OrderDealImplFromJson(Map<String, dynamic> json) =>
    _$OrderDealImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$OrderDealImplToJson(_$OrderDealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image_url': instance.imageUrl,
    };

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      dealId: json['deal_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      deals: json['deals'] == null
          ? null
          : OrderDeal.fromJson(json['deals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'deal_id': instance.dealId,
      'quantity': instance.quantity,
      'price': instance.price,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'deals': instance.deals,
    };

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessId: json['business_id'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      deliveryAddress: json['delivery_address'] as String?,
      deliveryInstructions: json['delivery_instructions'] as String?,
      pickupTime: json['pickup_time'] == null
          ? null
          : DateTime.parse(json['pickup_time'] as String),
      paymentMethod:
          $enumDecode(_$PaymentMethodEnumMap, json['payment_method']),
      paymentStatus:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['payment_status']) ??
              PaymentStatus.pending,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      verificationCode: json['verification_code'] as String?,
      qrData: json['qr_data'] as String?,
      confirmedAt: json['confirmed_at'] == null
          ? null
          : DateTime.parse(json['confirmed_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      businesses: json['businesses'] == null
          ? null
          : OrderBusiness.fromJson(json['businesses'] as Map<String, dynamic>),
      customer: json['app_users'] == null
          ? null
          : OrderCustomer.fromJson(json['app_users'] as Map<String, dynamic>),
      orderItems: (json['order_items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'business_id': instance.businessId,
      'total_amount': instance.totalAmount,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'delivery_address': instance.deliveryAddress,
      'delivery_instructions': instance.deliveryInstructions,
      'pickup_time': instance.pickupTime?.toIso8601String(),
      'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'verification_code': instance.verificationCode,
      'qr_data': instance.qrData,
      'confirmed_at': instance.confirmedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'businesses': instance.businesses,
      'app_users': instance.customer,
      'order_items': instance.orderItems,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.digital: 'digital',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};

_$OrderWithDetailsImpl _$$OrderWithDetailsImplFromJson(
        Map<String, dynamic> json) =>
    _$OrderWithDetailsImpl(
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      dealTitle: json['dealTitle'] as String?,
      dealImageUrl: json['dealImageUrl'] as String?,
      businessName: json['businessName'] as String?,
      businessAddress: json['businessAddress'] as String?,
      businessPhone: json['businessPhone'] as String?,
    );

Map<String, dynamic> _$$OrderWithDetailsImplToJson(
        _$OrderWithDetailsImpl instance) =>
    <String, dynamic>{
      'order': instance.order,
      'dealTitle': instance.dealTitle,
      'dealImageUrl': instance.dealImageUrl,
      'businessName': instance.businessName,
      'businessAddress': instance.businessAddress,
      'businessPhone': instance.businessPhone,
    };
