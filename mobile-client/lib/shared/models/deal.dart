import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/deals/models/restaurant.dart';

part 'deal.freezed.dart';
part 'deal.g.dart';

enum DealStatus {
  @JsonValue('active')
  active,
  @JsonValue('expired')
  expired,
  @JsonValue('sold_out')
  soldOut;

  String get displayName {
    switch (this) {
      case DealStatus.active:
        return 'Active';
      case DealStatus.expired:
        return 'Expired';
      case DealStatus.soldOut:
        return 'Sold Out';
    }
  }

  bool get isAvailable => this == DealStatus.active;
}

@freezed
class Deal with _$Deal {
  const factory Deal({
    required String id,
    @JsonKey(name: 'business_id') required String businessId,
    required String title,
    String? description,
    @JsonKey(name: 'original_price') required double originalPrice,
    @JsonKey(name: 'discounted_price') required double discountedPrice,
    @JsonKey(name: 'discount_percentage') int? apiDiscountPercentage, // From API response
    @JsonKey(name: 'quantity_available') required int quantityAvailable,
    @JsonKey(name: 'quantity_sold') @Default(0) int quantitySold,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'allergen_info') String? allergenInfo,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @Default(DealStatus.active) DealStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'businesses') Restaurant? restaurant,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);

  const Deal._();

  /// Calculate discount percentage
  double get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100);
  }

  /// Calculate savings amount
  double get savingsAmount => originalPrice - discountedPrice;

  /// Check if deal is still available for purchase
  bool get isAvailable {
    return status.isAvailable && 
           quantityAvailable > 0 && 
           expiresAt.isAfter(DateTime.now());
  }

  /// Get remaining quantity
  int get remainingQuantity => quantityAvailable - quantitySold;

  /// Check if deal has expired
  bool get isExpired => expiresAt.isBefore(DateTime.now());

  /// Check if deal is expiring soon (within 1 hour)
  bool get isExpiringSoon {
    final now = DateTime.now();
    final timeUntilExpiry = expiresAt.difference(now);
    return timeUntilExpiry.inHours <= 1 && timeUntilExpiry.inMinutes > 0;
  }

  /// Check if deal is almost sold out (less than 20% remaining)
  bool get isAlmostSoldOut {
    if (quantityAvailable <= 0) return false;
    final remainingPercentage = (remainingQuantity / quantityAvailable) * 100;
    return remainingPercentage <= 20 && remainingQuantity > 0;
  }

  /// Get time remaining until expiry
  Duration get timeUntilExpiry {
    final now = DateTime.now();
    if (expiresAt.isBefore(now)) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// Format time remaining as human readable string
  String get timeRemainingText {
    final duration = timeUntilExpiry;
    
    if (duration <= Duration.zero) {
      return 'Expired';
    }
    
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  /// Get deal urgency level for UI styling
  DealUrgency get urgency {
    if (!isAvailable) return DealUrgency.expired;
    if (isExpiringSoon || isAlmostSoldOut) return DealUrgency.urgent;
    if (timeUntilExpiry.inHours <= 6) return DealUrgency.moderate;
    return DealUrgency.normal;
  }

  /// Format price with currency
  String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  /// Get formatted original price
  String get formattedOriginalPrice => formatPrice(originalPrice);
  
  /// Get formatted discounted price
  String get formattedDiscountedPrice => formatPrice(discountedPrice);
  
  /// Get formatted savings amount
  String get formattedSavingsAmount => formatPrice(savingsAmount);

  /// Get discount percentage as formatted string
  String get formattedDiscountPercentage => '${discountPercentage.round()}%';
}

enum DealUrgency {
  normal,
  moderate,
  urgent,
  expired;

  String get displayName {
    switch (this) {
      case DealUrgency.normal:
        return 'Available';
      case DealUrgency.moderate:
        return 'Limited Time';
      case DealUrgency.urgent:
        return 'Act Fast!';
      case DealUrgency.expired:
        return 'Expired';
    }
  }
}