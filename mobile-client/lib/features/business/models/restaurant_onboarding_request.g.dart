// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_onboarding_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantOnboardingRequestImpl _$$RestaurantOnboardingRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$RestaurantOnboardingRequestImpl(
      id: json['id'] as String,
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
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['adminNotes'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      restaurantId: json['restaurantId'] as String?,
    );

Map<String, dynamic> _$$RestaurantOnboardingRequestImplToJson(
        _$RestaurantOnboardingRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
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
      'status': instance.status,
      'adminNotes': instance.adminNotes,
      'onboardingCompleted': instance.onboardingCompleted,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'restaurantId': instance.restaurantId,
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
