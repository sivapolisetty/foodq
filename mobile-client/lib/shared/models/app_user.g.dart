// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      userType: $enumDecode(_$UserTypeEnumMap, json['user_type']),
      businessId: json['business_id'] as String?,
      businessName: json['business_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String? ?? 'United States',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      dietaryPreferences: (json['dietary_preferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      favoriteCuisines: (json['favorite_cuisines'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notificationPreferences:
          json['notification_preferences'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'user_type': _$UserTypeEnumMap[instance.userType]!,
      'business_id': instance.businessId,
      'business_name': instance.businessName,
      'profile_image_url': instance.profileImageUrl,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'postal_code': instance.postalCode,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'dietary_preferences': instance.dietaryPreferences,
      'favorite_cuisines': instance.favoriteCuisines,
      'notification_preferences': instance.notificationPreferences,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$UserTypeEnumMap = {
  UserType.business: 'business',
  UserType.customer: 'customer',
};
