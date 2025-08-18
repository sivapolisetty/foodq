// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusinessImpl _$$BusinessImplFromJson(Map<String, dynamic> json) =>
    _$BusinessImpl(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      businessLicense: json['business_license'] as String?,
      taxId: json['tax_id'] as String?,
      category: json['category'] as String?,
      website: json['website'] as String?,
      businessHours: json['business_hours'] as Map<String, dynamic>?,
      deliveryRadius: (json['delivery_radius'] as num?)?.toDouble() ?? 5.0,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      acceptsCash: json['accepts_cash'] as bool? ?? true,
      acceptsCards: json['accepts_cards'] as bool? ?? true,
      acceptsDigital: json['accepts_digital'] as bool? ?? false,
      isApproved: json['is_approved'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      country: json['country'] as String? ?? 'United States',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      totalDeals: (json['total_deals'] as num?)?.toInt() ?? 0,
      activeDeals: (json['active_deals'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$BusinessImplToJson(_$BusinessImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'email': instance.email,
      'logo_url': instance.logoUrl,
      'cover_image_url': instance.coverImageUrl,
      'business_license': instance.businessLicense,
      'tax_id': instance.taxId,
      'category': instance.category,
      'website': instance.website,
      'business_hours': instance.businessHours,
      'delivery_radius': instance.deliveryRadius,
      'min_order_amount': instance.minOrderAmount,
      'accepts_cash': instance.acceptsCash,
      'accepts_cards': instance.acceptsCards,
      'accepts_digital': instance.acceptsDigital,
      'is_approved': instance.isApproved,
      'is_active': instance.isActive,
      'onboarding_completed': instance.onboardingCompleted,
      'city': instance.city,
      'state': instance.state,
      'zip_code': instance.zipCode,
      'country': instance.country,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'total_deals': instance.totalDeals,
      'active_deals': instance.activeDeals,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
