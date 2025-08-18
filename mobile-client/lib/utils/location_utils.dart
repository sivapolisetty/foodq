import 'dart:math';

/// Utility class for location-based calculations and operations
class LocationUtils {
  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert degrees to radians
    final double lat1Rad = lat1 * (pi / 180);
    final double lon1Rad = lon1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double lon2Rad = lon2 * (pi / 180);
    
    // Calculate differences
    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;
    
    // Apply Haversine formula
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m away';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km away';
    } else {
      return '${distanceKm.round()}km away';
    }
  }
  
  /// Check if a location is within a specified radius
  static bool isLocationWithinRadius(
    double userLat,
    double userLon,
    double businessLat,
    double businessLon,
    double radiusKm,
  ) {
    final distance = calculateDistance(userLat, userLon, businessLat, businessLon);
    return distance <= radiusKm;
  }
  
  /// Get delivery zones based on distance
  static DeliveryZone getDeliveryZone(double distanceKm) {
    if (distanceKm <= 2) {
      return DeliveryZone.express;
    } else if (distanceKm <= 5) {
      return DeliveryZone.standard;
    } else if (distanceKm <= 10) {
      return DeliveryZone.extended;
    } else {
      return DeliveryZone.notAvailable;
    }
  }
  
  /// Get delivery fee based on distance
  static double getDeliveryFee(double distanceKm) {
    final zone = getDeliveryZone(distanceKm);
    switch (zone) {
      case DeliveryZone.express:
        return 0.0; // Free delivery within 2km
      case DeliveryZone.standard:
        return 20.0; // ₹20 for 2-5km
      case DeliveryZone.extended:
        return 40.0; // ₹40 for 5-10km
      case DeliveryZone.notAvailable:
        return -1; // Not available
    }
  }
  
  /// Parse location from string format "lat,lon"
  static LocationCoordinates? parseLocationString(String? locationString) {
    if (locationString == null || locationString.isEmpty) {
      return null;
    }
    
    final parts = locationString.split(',');
    if (parts.length != 2) {
      return null;
    }
    
    try {
      final lat = double.parse(parts[0].trim());
      final lon = double.parse(parts[1].trim());
      return LocationCoordinates(latitude: lat, longitude: lon);
    } catch (e) {
      return null;
    }
  }
  
  /// Format coordinates to string
  static String formatLocationString(double lat, double lon) {
    return '${lat.toStringAsFixed(6)},${lon.toStringAsFixed(6)}';
  }
  
  /// Bangalore city boundaries (approximate)
  static const LocationBounds bangaloreBounds = LocationBounds(
    northEast: LocationCoordinates(latitude: 13.1394, longitude: 77.7109),
    southWest: LocationCoordinates(latitude: 12.7343, longitude: 77.4279),
  );
  
  /// Check if coordinates are within Bangalore city limits
  static bool isWithinBangalore(double lat, double lon) {
    return lat >= bangaloreBounds.southWest.latitude &&
           lat <= bangaloreBounds.northEast.latitude &&
           lon >= bangaloreBounds.southWest.longitude &&
           lon <= bangaloreBounds.northEast.longitude;
  }
  
  /// Get nearby area name based on coordinates (simplified mapping)
  static String getAreaName(double lat, double lon) {
    // This is a simplified mapping - in production, you'd use a geocoding service
    
    // Central Bangalore
    if (lat >= 12.95 && lat <= 13.05 && lon >= 77.55 && lon <= 77.65) {
      if (lat >= 12.97 && lon >= 77.59) return 'Indiranagar';
      if (lat >= 12.96 && lon <= 77.58) return 'MG Road';
      if (lat <= 12.96 && lon >= 77.60) return 'Koramangala';
      return 'Central Bangalore';
    }
    
    // South Bangalore
    if (lat >= 12.85 && lat <= 12.95) {
      if (lon >= 77.60) return 'HSR Layout';
      if (lon >= 77.55) return 'Jayanagar';
      return 'South Bangalore';
    }
    
    // North Bangalore
    if (lat >= 13.05) {
      return 'North Bangalore';
    }
    
    // East Bangalore
    if (lon >= 77.65) {
      return 'East Bangalore';
    }
    
    // West Bangalore
    if (lon <= 77.50) {
      return 'West Bangalore';
    }
    
    return 'Bangalore';
  }
  
  /// Popular locations in Bangalore for testing/demo
  static const Map<String, LocationCoordinates> popularLocations = {
    'MG Road': LocationCoordinates(latitude: 12.9716, longitude: 77.5946),
    'Koramangala': LocationCoordinates(latitude: 12.9352, longitude: 77.6245),
    'Indiranagar': LocationCoordinates(latitude: 12.9784, longitude: 77.6408),
    'HSR Layout': LocationCoordinates(latitude: 12.9150, longitude: 77.6380),
    'Jayanagar': LocationCoordinates(latitude: 12.9254, longitude: 77.5834),
    'Whitefield': LocationCoordinates(latitude: 12.9698, longitude: 77.7500),
    'Electronic City': LocationCoordinates(latitude: 12.8456, longitude: 77.6603),
    'Malleshwaram': LocationCoordinates(latitude: 13.0067, longitude: 77.5667),
    'Brigade Road': LocationCoordinates(latitude: 12.9688, longitude: 77.6099),
    'Commercial Street': LocationCoordinates(latitude: 12.9852, longitude: 77.6103),
  };
  
  /// Get the nearest popular location
  static String getNearestPopularLocation(double lat, double lon) {
    String nearestLocation = 'Bangalore';
    double minDistance = double.infinity;
    
    for (final entry in popularLocations.entries) {
      final distance = calculateDistance(
        lat, lon,
        entry.value.latitude, entry.value.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        nearestLocation = entry.key;
      }
    }
    
    return nearestLocation;
  }
}

/// Represents geographical coordinates
class LocationCoordinates {
  final double latitude;
  final double longitude;
  
  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });
  
  @override
  String toString() => 'LocationCoordinates($latitude, $longitude)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationCoordinates &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }
  
  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Represents geographical bounds (rectangle)
class LocationBounds {
  final LocationCoordinates northEast;
  final LocationCoordinates southWest;
  
  const LocationBounds({
    required this.northEast,
    required this.southWest,
  });
}

/// Delivery zones based on distance
enum DeliveryZone {
  express,     // 0-2km: Free delivery
  standard,    // 2-5km: Standard fee
  extended,    // 5-10km: Higher fee
  notAvailable // >10km: No delivery
}

/// Extension to add location utilities to business model
extension BusinessLocationExtension on dynamic {
  /// Calculate distance from user location to business
  double? distanceFromUser(double? userLat, double? userLon) {
    if (userLat == null || userLon == null) return null;
    
    // Assuming the object has latitude and longitude properties
    final businessLat = this.latitude as double?;
    final businessLon = this.longitude as double?;
    
    if (businessLat == null || businessLon == null) return null;
    
    return LocationUtils.calculateDistance(
      userLat, userLon,
      businessLat, businessLon,
    );
  }
  
  /// Get formatted distance string
  String? formattedDistanceFromUser(double? userLat, double? userLon) {
    final distance = distanceFromUser(userLat, userLon);
    return distance != null ? LocationUtils.formatDistance(distance) : null;
  }
  
  /// Check if business is within delivery radius
  bool isWithinDeliveryRadius(double? userLat, double? userLon, {double radiusKm = 10}) {
    final distance = distanceFromUser(userLat, userLon);
    return distance != null && distance <= radiusKm;
  }
}