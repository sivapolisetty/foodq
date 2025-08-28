// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_onboarding_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantOnboardingRequestImpl _$$RestaurantOnboardingRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantOnboardingRequestImpl(
      id: json['id'] as String,
      restaurantName: json['restaurant_name'] as String,
      cuisineType: json['cuisine_type'] as String,
      restaurantDescription: json['restaurant_description'] as String?,
      restaurantPhotoUrl: json['restaurant_photo_url'] as String?,
      ownerName: json['owner_name'] as String,
      ownerEmail: json['owner_email'] as String,
      ownerPhone: json['owner_phone'] as String,
      address: json['address'] as String,
      zipCode: json['zip_code'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      businessLicense: json['business_license'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      restaurantId: json['restaurant_id'] as String?,
    );

Map<String, dynamic> _$$RestaurantOnboardingRequestImplToJson(
        _$RestaurantOnboardingRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurant_name': instance.restaurantName,
      'cuisine_type': instance.cuisineType,
      'restaurant_description': instance.restaurantDescription,
      'restaurant_photo_url': instance.restaurantPhotoUrl,
      'owner_name': instance.ownerName,
      'owner_email': instance.ownerEmail,
      'owner_phone': instance.ownerPhone,
      'address': instance.address,
      'zip_code': instance.zipCode,
      'city': instance.city,
      'state': instance.state,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'business_license': instance.businessLicense,
      'status': instance.status,
      'admin_notes': instance.adminNotes,
      'onboarding_completed': instance.onboardingCompleted,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'restaurant_id': instance.restaurantId,
    };

_$RestaurantOnboardingFormDataImpl _$$RestaurantOnboardingFormDataImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantOnboardingFormDataImpl(
      restaurantName: json['restaurantName'] as String,
      cuisineType: json['cuisineType'] as String,
      restaurantDescription: json['restaurantDescription'] as String?,
      restaurantPhotoUrl: json['restaurantPhotoUrl'] as String?,
      ownerName: json['ownerName'] as String,
      ownerEmail: json['ownerEmail'] as String,
      ownerPhone: json['ownerPhone'] as String,
      address: json['address'] as String,
      zipCode: json['zipCode'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      businessLicense: json['businessLicense'] as String?,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$RestaurantOnboardingFormDataImplToJson(
        _$RestaurantOnboardingFormDataImpl instance) =>
    <String, dynamic>{
      'restaurantName': instance.restaurantName,
      'cuisineType': instance.cuisineType,
      'restaurantDescription': instance.restaurantDescription,
      'restaurantPhotoUrl': instance.restaurantPhotoUrl,
      'ownerName': instance.ownerName,
      'ownerEmail': instance.ownerEmail,
      'ownerPhone': instance.ownerPhone,
      'address': instance.address,
      'zipCode': instance.zipCode,
      'city': instance.city,
      'state': instance.state,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'businessLicense': instance.businessLicense,
      'userId': instance.userId,
    };
