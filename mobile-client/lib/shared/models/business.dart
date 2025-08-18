import 'package:freezed_annotation/freezed_annotation.dart';

part 'business.freezed.dart';
part 'business.g.dart';

@freezed
class Business with _$Business {
  const factory Business({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    String? description,
    required String address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    
    // Business license and legal info
    @JsonKey(name: 'business_license') String? businessLicense,
    @JsonKey(name: 'tax_id') String? taxId,
    String? category, // Business category (replaces cuisine_type)
    String? website,
    @JsonKey(name: 'business_hours') Map<String, dynamic>? businessHours,
    
    // Service preferences
    @JsonKey(name: 'delivery_radius') @Default(5.0) double deliveryRadius,
    @JsonKey(name: 'min_order_amount') @Default(0.0) double minOrderAmount,
    @JsonKey(name: 'accepts_cash') @Default(true) bool acceptsCash,
    @JsonKey(name: 'accepts_cards') @Default(true) bool acceptsCards,
    @JsonKey(name: 'accepts_digital') @Default(false) bool acceptsDigital,
    
    // Administrative fields
    @JsonKey(name: 'is_approved') @Default(false) bool isApproved,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'onboarding_completed') @Default(false) bool onboardingCompleted,
    
    // Location details
    String? city,
    String? state,
    @JsonKey(name: 'zip_code') String? zipCode,
    @Default('United States') String country,
    
    // Stats (computed fields)
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'total_deals') @Default(0) int totalDeals,
    @JsonKey(name: 'active_deals') @Default(0) int activeDeals,
    
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Business;

  factory Business.fromJson(Map<String, dynamic> json) => _$BusinessFromJson(json);

  const Business._();

  String get displayAddress => address.split(',').first;
  
  bool get hasLocation => latitude != null && longitude != null;
  
  String get statusText {
    if (!isActive) return 'Inactive';
    if (!isApproved) return 'Pending Approval';
    return 'Active';
  }

  bool get canReceiveOrders => isApproved && isActive;
  
  String get displayPhone => phone?.replaceAllMapped(
    RegExp(r'(\d{3})(\d{3})(\d{4})'),
    (match) => '(${match[1]}) ${match[2]}-${match[3]}',
  ) ?? '';

  /// Get display name with category
  String get displayName {
    if (category != null && category!.isNotEmpty) {
      return '$name • $category';
    }
    return name;
  }

  /// Get rating as formatted string
  String get formattedRating {
    if (rating <= 0) return 'No rating';
    return '${rating.toStringAsFixed(1)} ⭐';
  }

  /// Get review count text
  String get reviewText {
    if (reviewCount <= 0) return 'No reviews';
    return '$reviewCount review${reviewCount == 1 ? '' : 's'}';
  }

  /// Get business summary for search results
  String get searchSummary {
    final parts = <String>[];
    if (category != null && category!.isNotEmpty) {
      parts.add(category!);
    }
    if (activeDeals > 0) {
      parts.add('$activeDeals active deal${activeDeals == 1 ? '' : 's'}');
    }
    if (rating > 0) {
      parts.add(formattedRating);
    }
    return parts.join(' • ');
  }

  /// Check if business matches search criteria
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    
    final searchTerm = query.toLowerCase();
    return name.toLowerCase().contains(searchTerm) ||
           (category?.toLowerCase().contains(searchTerm) ?? false) ||
           address.toLowerCase().contains(searchTerm) ||
           (description?.toLowerCase().contains(searchTerm) ?? false);
  }

  /// Get distance from user location (to be calculated externally)
  String formatDistance(double? distanceInKm) {
    if (distanceInKm == null) return '';
    if (distanceInKm < 1.0) {
      return '${(distanceInKm * 1000).round()}m away';
    }
    return '${distanceInKm.toStringAsFixed(1)}km away';
  }
}