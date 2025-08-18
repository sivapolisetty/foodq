import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/user_type.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Application User model for MVP user switching system
/// Represents both business and customer users without authentication
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'user_type') required UserType userType,
    @JsonKey(name: 'business_id') String? businessId,
    @JsonKey(name: 'business_name') String? businessName,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    String? phone,
    
    // Address fields (required for both customers and businesses)
    String? address,
    String? city,
    String? state,
    @JsonKey(name: 'postal_code') String? postalCode,
    @Default('United States') String country,
    double? latitude,
    double? longitude,
    
    
    // Customer preferences
    @JsonKey(name: 'dietary_preferences') List<String>? dietaryPreferences,
    @JsonKey(name: 'favorite_cuisines') List<String>? favoriteCuisines,
    @JsonKey(name: 'notification_preferences') Map<String, dynamic>? notificationPreferences,
    
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  const AppUser._();

  /// Get user initials for avatar display
  String get initials {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return '?';
  }

  /// Get display name with user type indicator
  String get displayNameWithType {
    return '$name (${userType.displayName})';
  }

  /// Check if user is a business owner
  bool get isBusiness => userType == UserType.business;

  /// Check if user is a customer
  bool get isCustomer => userType == UserType.customer;

  /// Check if user has a profile image
  bool get hasProfileImage => 
      profileImageUrl != null && profileImageUrl!.isNotEmpty;

  /// Get formatted phone number
  String get formattedPhone {
    if (phone == null || phone!.isEmpty) return '';
    
    // Simple US phone formatting (for demo)
    final digits = phone!.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone!;
  }

  /// Get user role description
  String get roleDescription {
    switch (userType) {
      case UserType.business:
        return 'Manage deals, orders, and business analytics';
      case UserType.customer:
        return 'Browse deals, place orders, and track favorites';
    }
  }

  /// Get full address as a single string
  String get fullAddress {
    final parts = [
      address,
      city,
      state,
      postalCode,
    ].where((part) => part != null && part.isNotEmpty).toList();
    
    if (parts.isEmpty) return '';
    
    // Format as: "123 Main St, City, State 12345"
    return parts.join(', ');
  }

  /// Check if user has a complete address
  bool get hasCompleteAddress {
    return address != null && address!.isNotEmpty &&
           city != null && city!.isNotEmpty &&
           state != null && state!.isNotEmpty &&
           postalCode != null && postalCode!.isNotEmpty;
  }

  /// Check if user has location coordinates
  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  /// Check if business profile is complete (now checks if user has business_id)
  bool get isBusinessProfileComplete {
    if (!isBusiness) return false;
    
    return hasCompleteAddress &&
           businessId != null && businessId!.isNotEmpty;
  }

  /// Check if customer profile is complete
  bool get isCustomerProfileComplete {
    if (!isCustomer) return false;
    
    return hasCompleteAddress;
  }

  /// Get profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 5; // Basic user fields
    
    if (name.isNotEmpty) completedFields++;
    if (email.isNotEmpty) completedFields++;
    if (phone != null && phone!.isNotEmpty) completedFields++;
    if (hasCompleteAddress) completedFields++;
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) completedFields++;
    
    return completedFields / totalFields;
  }

  /// Get navigation features available to this user type
  List<String> get availableFeatures {
    switch (userType) {
      case UserType.business:
        return [
          'Dashboard',
          'Deal Management',
          'Order Management',
          'Analytics',
          'Business Settings',
        ];
      case UserType.customer:
        return [
          'Browse Deals',
          'Search Restaurants',
          'Order History',
          'Favorites',
          'Profile Settings',
        ];
    }
  }

  /// Create a business user (user information only)
  factory AppUser.business({
    required String id,
    required String name,
    required String email,
    required String businessId,
    String? businessName,
    String? profileImageUrl,
    String? phone,
    // Address fields
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String country = 'United States',
    double? latitude,
    double? longitude,
  }) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      userType: UserType.business,
      businessId: businessId,
      businessName: businessName,
      profileImageUrl: profileImageUrl,
      phone: phone,
      address: address,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a customer user with address and preferences
  factory AppUser.customer({
    required String id,
    required String name,
    required String email,
    String? profileImageUrl,
    String? phone,
    // Address fields
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String country = 'United States',
    double? latitude,
    double? longitude,
    // Customer preferences
    List<String>? dietaryPreferences,
    List<String>? favoriteCuisines,
    Map<String, dynamic>? notificationPreferences,
  }) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      userType: UserType.customer,
      businessId: null,
      businessName: null,
      profileImageUrl: profileImageUrl,
      phone: phone,
      address: address,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      latitude: latitude,
      longitude: longitude,
      dietaryPreferences: dietaryPreferences,
      favoriteCuisines: favoriteCuisines,
      notificationPreferences: notificationPreferences,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}