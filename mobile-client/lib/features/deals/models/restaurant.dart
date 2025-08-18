import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:math' show sin, cos, sqrt, atan2, pi;

part 'restaurant.freezed.dart';
part 'restaurant.g.dart';

@freezed
class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String id,
    required String name,
    required String description,
    @JsonKey(name: 'owner_id') String? ownerId, // Added missing field from API
    String? address,
    String? phone,
    String? email,
    String? website,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'cuisine_type') String? cuisineType,
    @JsonKey(name: 'opening_hours') dynamic openingHours,
    @Default(0.0) double rating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Restaurant;

  factory Restaurant.fromJson(Map<String, dynamic> json) => _$RestaurantFromJson(json);
}

extension RestaurantExtensions on Restaurant {
  /// Calculate distance from user location
  double distanceFromUser(double userLat, double userLng) {
    // Haversine formula for calculating distance between two points
    const double earthRadius = 6371; // Earth radius in kilometers
    
    final double dLat = _degreesToRadians(latitude - userLat);
    final double dLng = _degreesToRadians(longitude - userLng);
    
    final double a = 
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(userLat)) * cos(_degreesToRadians(latitude)) *
        (sin(dLng / 2) * sin(dLng / 2));
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Check if restaurant is nearby within radius
  bool isNearby(double userLat, double userLng, double radiusKm) {
    return distanceFromUser(userLat, userLng) <= radiusKm;
  }

  /// Get formatted distance string
  String getFormattedDistance(double userLat, double userLng) {
    final distance = distanceFromUser(userLat, userLng);
    if (distance < 1) {
      return '${(distance * 1000).round()}m away';
    } else {
      return '${distance.toStringAsFixed(1)}km away';
    }
  }
}