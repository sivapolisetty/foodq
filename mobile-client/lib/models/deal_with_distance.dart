import 'deal.dart';
import '../utils/location_utils.dart';

/// Deal model enhanced with distance and location information
class DealWithDistance {
  final Deal deal;
  final double distanceKm;
  final double businessLatitude;
  final double businessLongitude;
  final String businessName;
  final String? businessAddress;

  DealWithDistance({
    required this.deal,
    required this.distanceKm,
    required this.businessLatitude,
    required this.businessLongitude,
    required this.businessName,
    this.businessAddress,
  });

  /// Get formatted distance string
  String get formattedDistance => LocationUtils.formatDistance(distanceKm);

  /// Get delivery zone for this distance
  DeliveryZone get deliveryZone => LocationUtils.getDeliveryZone(distanceKm);

  /// Get delivery fee for this distance
  double get deliveryFee => LocationUtils.getDeliveryFee(distanceKm);

  /// Check if delivery is available
  bool get isDeliveryAvailable => deliveryZone != DeliveryZone.notAvailable;

  /// Get delivery status text
  String get deliveryStatus {
    switch (deliveryZone) {
      case DeliveryZone.express:
        return 'Free Delivery';
      case DeliveryZone.standard:
        return 'Delivery ₹${deliveryFee.toInt()}';
      case DeliveryZone.extended:
        return 'Delivery ₹${deliveryFee.toInt()}';
      case DeliveryZone.notAvailable:
        return 'Delivery Not Available';
    }
  }

  /// Get area name based on business location
  String get areaName => LocationUtils.getAreaName(businessLatitude, businessLongitude);

  /// Get nearest popular location
  String get nearestPopularLocation => 
      LocationUtils.getNearestPopularLocation(businessLatitude, businessLongitude);

  /// Check if business is within Bangalore
  bool get isWithinBangalore => 
      LocationUtils.isWithinBangalore(businessLatitude, businessLongitude);

  /// Convert to JSON for API responses
  Map<String, dynamic> toJson() {
    return {
      'deal': deal.toJson(),
      'distance_km': distanceKm,
      'formatted_distance': formattedDistance,
      'business_latitude': businessLatitude,
      'business_longitude': businessLongitude,
      'business_name': businessName,
      'business_address': businessAddress,
      'delivery_zone': deliveryZone.name,
      'delivery_fee': deliveryFee,
      'is_delivery_available': isDeliveryAvailable,
      'delivery_status': deliveryStatus,
      'area_name': areaName,
      'nearest_popular_location': nearestPopularLocation,
    };
  }

  /// Create from JSON
  factory DealWithDistance.fromJson(Map<String, dynamic> json) {
    return DealWithDistance(
      deal: Deal.fromJson(json['deal']),
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      businessLatitude: (json['business_latitude'] ?? 0.0).toDouble(),
      businessLongitude: (json['business_longitude'] ?? 0.0).toDouble(),
      businessName: json['business_name'] ?? '',
      businessAddress: json['business_address'],
    );
  }

  @override
  String toString() {
    return 'DealWithDistance{deal: ${deal.title}, distance: ${formattedDistance}, area: $areaName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DealWithDistance &&
        other.deal.id == deal.id &&
        other.distanceKm == distanceKm;
  }

  @override
  int get hashCode => deal.id.hashCode ^ distanceKm.hashCode;
}