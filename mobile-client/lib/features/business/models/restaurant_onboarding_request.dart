import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_onboarding_request.freezed.dart';
part 'restaurant_onboarding_request.g.dart';

/// Restaurant Onboarding Request Model
/// Represents a restaurant partnership application
@freezed
class RestaurantOnboardingRequest with _$RestaurantOnboardingRequest {
  const factory RestaurantOnboardingRequest({
    required String id,
    
    // Restaurant Information
    @JsonKey(name: 'restaurant_name') required String restaurantName,
    @JsonKey(name: 'cuisine_type') required String cuisineType,
    @JsonKey(name: 'restaurant_description') String? restaurantDescription,
    @JsonKey(name: 'restaurant_photo_url') String? restaurantPhotoUrl,
    
    // Owner Information
    @JsonKey(name: 'owner_name') required String ownerName,
    @JsonKey(name: 'owner_email') required String ownerEmail,
    @JsonKey(name: 'owner_phone') required String ownerPhone,
    
    // Location Information
    required String address,
    @JsonKey(name: 'zip_code') required String zipCode,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    
    // Business Information
    @JsonKey(name: 'business_license') String? businessLicense,
    
    // Application Status
    @Default('pending') String status,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    @JsonKey(name: 'onboarding_completed') @Default(false) bool onboardingCompleted,
    
    // User Reference
    @JsonKey(name: 'user_id') required String userId,
    
    // Timestamps
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'reviewed_at') DateTime? reviewedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    
    // Restaurant reference (populated when approved)
    @JsonKey(name: 'restaurant_id') String? restaurantId,
  }) = _RestaurantOnboardingRequest;

  factory RestaurantOnboardingRequest.fromJson(Map<String, dynamic> json) =>
      _$RestaurantOnboardingRequestFromJson(json);
}

/// Restaurant Onboarding Request Form Data
/// Used for creating new applications
@freezed
class RestaurantOnboardingFormData with _$RestaurantOnboardingFormData {
  const factory RestaurantOnboardingFormData({
    // Restaurant Information
    required String restaurantName,
    required String cuisineType,
    String? restaurantDescription,
    String? restaurantPhotoUrl,
    
    // Owner Information
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
    
    // Location Information
    required String address,
    required String zipCode,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    
    // Business Information
    String? businessLicense,
    
    // User Reference
    required String userId,
  }) = _RestaurantOnboardingFormData;

  factory RestaurantOnboardingFormData.fromJson(Map<String, dynamic> json) =>
      _$RestaurantOnboardingFormDataFromJson(json);
}