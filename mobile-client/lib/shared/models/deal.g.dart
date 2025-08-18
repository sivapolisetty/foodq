// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DealImpl _$$DealImplFromJson(Map<String, dynamic> json) => _$DealImpl(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      originalPrice: (json['original_price'] as num).toDouble(),
      discountedPrice: (json['discounted_price'] as num).toDouble(),
      apiDiscountPercentage: (json['discount_percentage'] as num?)?.toInt(),
      quantityAvailable: (json['quantity_available'] as num).toInt(),
      quantitySold: (json['quantity_sold'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String?,
      allergenInfo: json['allergen_info'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      status: $enumDecodeNullable(_$DealStatusEnumMap, json['status']) ??
          DealStatus.active,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      restaurant: json['businesses'] == null
          ? null
          : Restaurant.fromJson(json['businesses'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DealImplToJson(_$DealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business_id': instance.businessId,
      'title': instance.title,
      'description': instance.description,
      'original_price': instance.originalPrice,
      'discounted_price': instance.discountedPrice,
      'discount_percentage': instance.apiDiscountPercentage,
      'quantity_available': instance.quantityAvailable,
      'quantity_sold': instance.quantitySold,
      'image_url': instance.imageUrl,
      'allergen_info': instance.allergenInfo,
      'expires_at': instance.expiresAt.toIso8601String(),
      'status': _$DealStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'businesses': instance.restaurant,
    };

const _$DealStatusEnumMap = {
  DealStatus.active: 'active',
  DealStatus.expired: 'expired',
  DealStatus.soldOut: 'sold_out',
};
