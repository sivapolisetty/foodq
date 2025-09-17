import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../core/services/api_service.dart';
import '../../core/config/api_config.dart';
import '../models/api_models.dart';
import '../models/deal.dart';

/// Clean API-driven service for location-based deal discovery
/// All distance calculations and filtering happen on the backend
class LocationDealsApiService {
  
  /// Get deals near user's location with server-calculated distances
  static Future<List<DealWithDistance>> getDealsNearUser({
    Position? userLocation,
    double radiusKm = 5.0,
    int limit = 20,
  }) async {
    try {
      // Get user location if not provided
      userLocation ??= await _getCurrentLocation();
      
      final queryParams = {
        'filter': 'nearby',
        'lat': userLocation.latitude.toString(),
        'lng': userLocation.longitude.toString(),
        'radius': radiusKm.toString(),  // Changed from radius_km to radius to match working API
        'limit': limit.toString(),
      };
      
      print('🌍 LOCATION_API: Making nearby deals request with params: $queryParams');
      
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,  // Use main deals endpoint instead of nearby-specific
        queryParameters: queryParams,
      );
      
      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        print('🌍 LOCATION_API: Received ${dealsData.length} deals from API');
        
        // Parse as regular deals and calculate distances client-side
        // This is temporary until backend provides distance calculations
        final dealsWithDistance = <DealWithDistance>[];
        
        for (final json in dealsData) {
          final deal = Deal.fromJson(json as Map<String, dynamic>);
          
          // Calculate distance using device location and business coordinates
          double distanceKm = 0.0;
          String formattedDistance = 'Distance unavailable';
          String walkingTimeEstimate = 'Time unknown';
          String urgencyLevel = 'medium';
          
          // Only calculate if we have restaurant coordinates
          if (deal.restaurant != null && 
              deal.restaurant!.latitude != 0.0 && 
              deal.restaurant!.longitude != 0.0) {
            distanceKm = Geolocator.distanceBetween(
              userLocation.latitude,
              userLocation.longitude,
              deal.restaurant!.latitude,
              deal.restaurant!.longitude,
            ) / 1000; // Convert to km
            
            formattedDistance = distanceKm < 1 
                ? '${(distanceKm * 1000).round()}m away'
                : '${distanceKm.toStringAsFixed(1)}km away';
                
            walkingTimeEstimate = '${(distanceKm * 12).round()} min walk';
            urgencyLevel = distanceKm < 0.5 ? 'high' : distanceKm < 2 ? 'medium' : 'low';
          }
          
          dealsWithDistance.add(DealWithDistance(
            deal: deal,
            distanceKm: distanceKm,
            formattedDistance: formattedDistance,
            walkingTimeEstimate: walkingTimeEstimate,
            urgencyLevel: urgencyLevel,
          ));
        }
        
        // Sort by distance
        dealsWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        
        return dealsWithDistance;
      } else {
        print('🌍 LOCATION_API: Failed to fetch nearby deals: ${response.error}');
        return [];
      }
    } catch (e) {
      print('Error fetching nearby deals: $e');
      return [];
    }
  }
  
  /// Get deals grouped by distance ranges (server-calculated)
  static Future<LocationDealsGroup> getGroupedNearbyDeals({
    Position? userLocation,
    double maxRadiusKm = 10.0,
  }) async {
    try {
      userLocation ??= await _getCurrentLocation();
      
      final queryParams = {
        'filter': 'nearby',
        'lat': userLocation.latitude.toString(),
        'lng': userLocation.longitude.toString(),
        'radius': maxRadiusKm.toString(),
        'grouped': 'true',
        'limit': '50', // Get more deals for grouping
      };
      
      print('🌍 LOCATION_API: Making grouped nearby deals request with params: $queryParams');
      
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,  // Use main deals endpoint instead of nearby-specific
        queryParameters: queryParams,
      );
      
      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        print('🌍 LOCATION_API: Received ${dealsData.length} deals for grouping');
        
        // Get all deals with calculated distances using the main method
        final allDealsWithDistance = await getDealsNearUser(
          userLocation: userLocation,
          radiusKm: maxRadiusKm,
          limit: 50,
        );
        
        // Group deals by distance ranges
        final veryNear = allDealsWithDistance.where((d) => d.distanceKm <= 1).toList();
        final near = allDealsWithDistance.where((d) => d.distanceKm > 1 && d.distanceKm <= 3).toList();  
        final nearby = allDealsWithDistance.where((d) => d.distanceKm > 3).toList();
        
        return LocationDealsGroup(
          veryNear: veryNear,
          near: near,
          nearby: nearby,
        );
      } else {
        print('🌍 LOCATION_API: Failed to fetch grouped nearby deals: ${response.error}');
        return LocationDealsGroup.empty();
      }
    } catch (e) {
      print('Error fetching grouped nearby deals: $e');
      return LocationDealsGroup.empty();
    }
  }
  
  /// Get deals along a route (for future implementation)
  static Future<List<DealWithDistance>> getDealsAlongRoute({
    required Position start,
    required Position end,
    double corridorWidthKm = 2.0,
  }) async {
    try {
      final queryParams = {
        'start_lat': start.latitude.toString(),
        'start_lng': start.longitude.toString(),
        'end_lat': end.latitude.toString(),
        'end_lng': end.longitude.toString(),
        'corridor_width_km': corridorWidthKm.toString(),
      };
      
      final response = await ApiService.get<dynamic>(
        '${ApiConfig.nearbyDealsEndpoint}/route',
        queryParameters: queryParams,
      );
      
      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        return dealsData
            .map((json) => DealWithDistance.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('Failed to fetch route deals: ${response.error}');
        return [];
      }
    } catch (e) {
      print('Error fetching route deals: $e');
      return [];
    }
  }
  
  /// Get location permission status for UI decisions
  static Future<LocationPermissionStatus> getLocationPermissionStatus() async {
    final permission = await Geolocator.checkPermission();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }
    
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied; // Treat as denied for safety
    }
  }
  
  /// Request location permission with user-friendly messaging
  static Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse ||
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }
  
  // Private helper methods
  
  /// Get current location with proper error handling
  static Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
  }
}

/// Grouped deals by distance ranges (from server response)
class LocationDealsGroup {
  final List<DealWithDistance> veryNear; // < 1km
  final List<DealWithDistance> near;     // 1-3km
  final List<DealWithDistance> nearby;   // 3-10km
  
  const LocationDealsGroup({
    required this.veryNear,
    required this.near,
    required this.nearby,
  });
  
  factory LocationDealsGroup.fromJson(Map<String, dynamic> json) {
    return LocationDealsGroup(
      veryNear: (json['very_near'] as List<dynamic>)
          .map((deal) => DealWithDistance.fromJson(deal as Map<String, dynamic>))
          .toList(),
      near: (json['near'] as List<dynamic>)
          .map((deal) => DealWithDistance.fromJson(deal as Map<String, dynamic>))
          .toList(),
      nearby: (json['nearby'] as List<dynamic>)
          .map((deal) => DealWithDistance.fromJson(deal as Map<String, dynamic>))
          .toList(),
    );
  }
  
  factory LocationDealsGroup.empty() {
    return const LocationDealsGroup(
      veryNear: [],
      near: [],
      nearby: [],
    );
  }
  
  /// Get total count of all deals
  int get totalCount => veryNear.length + near.length + nearby.length;
  
  /// Check if there are any deals
  bool get hasAnyDeals => totalCount > 0;
  
  /// Get the closest deals across all groups
  List<DealWithDistance> get closestDeals {
    final allDeals = [...veryNear, ...near, ...nearby];
    allDeals.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return allDeals.take(5).toList();
  }
}

/// Location permission status for UI decisions
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}