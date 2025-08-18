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
    
    // Application Status
    @Default('pending') String status,
    String? adminNotes,
    @Default(false) bool onboardingCompleted,
    
    // User Reference
    required String userId,
    
    // Timestamps
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? reviewedAt,
    DateTime? completedAt,
    
    // Restaurant reference (populated when approved)
    String? restaurantId,
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