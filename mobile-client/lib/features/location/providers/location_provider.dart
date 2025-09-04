import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';

/// State for location functionality
class LocationState {
  final Position? position;
  final LocationAddress? address;
  final bool isLoading;
  final bool hasPermission;
  final String? error;

  const LocationState({
    this.position,
    this.address,
    this.isLoading = false,
    this.hasPermission = false,
    this.error,
  });

  LocationState copyWith({
    Position? position,
    LocationAddress? address,
    bool? isLoading,
    bool? hasPermission,
    String? error,
  }) {
    return LocationState(
      position: position ?? this.position,
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error ?? this.error,
    );
  }
}

/// Notifier for managing user location
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  /// Get user's current location
  Future<void> getCurrentLocation() async {
    print('📍 LocationProvider: ===== STARTING getCurrentLocation() =====');
    print('📍 LocationProvider: Setting state to loading...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('📍 LocationProvider: Directly calling LocationService.getCurrentPosition() (which handles permissions internally)...');
      
      // Let LocationService handle the permission flow internally
      final position = await LocationService.getCurrentPosition();
      print('📍 LocationProvider: LocationService.getCurrentPosition() returned: ${position?.toString() ?? 'NULL'}');
      
      if (position == null) {
        print('❌ LocationProvider: Position is null - checking if it\'s a permission issue...');
        
        // Check if we have permission after the attempt
        final hasPermissionNow = await LocationService.hasLocationPermission();
        print('📍 LocationProvider: Permission status after attempt: $hasPermissionNow');
        
        final errorMessage = hasPermissionNow 
            ? 'Unable to get current location - GPS may be disabled or unavailable'
            : 'Location permission is required to detect your current location';
            
        state = state.copyWith(
          isLoading: false,
          hasPermission: hasPermissionNow,
          error: errorMessage,
        );
        return;
      }

      print('📍 LocationProvider: Position obtained - getting address from coordinates...');
      print('📍 LocationProvider: Coordinates: ${position.latitude}, ${position.longitude}');
      
      // Get address from coordinates
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      print('📍 LocationProvider: Address obtained: ${address?.formattedAddress ?? 'NULL'}');

      print('📍 LocationProvider: Updating state with final location data...');
      state = state.copyWith(
        position: position,
        address: address,
        isLoading: false,
        hasPermission: true,
        error: null,
      );

      print('✅ LocationProvider: SUCCESS - Location obtained: ${position.latitude}, ${position.longitude}');
      print('🏠 LocationProvider: Address: ${address?.formattedAddress ?? 'Unknown'}');
      print('📍 LocationProvider: ===== COMPLETED getCurrentLocation() =====');

    } catch (e, stackTrace) {
      print('❌ LocationProvider: EXCEPTION in getCurrentLocation(): $e');
      print('📚 LocationProvider: Stack trace: $stackTrace');
      
      // Provide more specific error messages
      String errorMessage = 'Failed to get location: $e';
      if (e.toString().toLowerCase().contains('permission')) {
        errorMessage = 'Location permission denied. Please allow location access in your browser.';
      } else if (e.toString().toLowerCase().contains('timeout')) {
        errorMessage = 'Location detection timed out. Please try again or enter your address manually.';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  /// Request location permission
  Future<void> requestLocationPermission() async {
    print('🔐 LocationProvider: Requesting location permission...');
    state = state.copyWith(isLoading: true);

    try {
      final position = await LocationService.getCurrentPosition();
      final hasPermission = position != null;

      if (hasPermission && position != null) {
        // Get address from coordinates
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        state = state.copyWith(
          position: position,
          address: address,
          isLoading: false,
          hasPermission: true,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasPermission: false,
          error: 'Location permission denied',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasPermission: false,
        error: 'Permission request failed: $e',
      );
    }
  }

  /// Set manual address and coordinates
  void setManualAddress(String formattedAddress, double? lat, double? lng) {
    print('📍 LocationProvider: Setting manual address: $formattedAddress');
    
    Position? position;
    LocationAddress? address;
    
    if (lat != null && lng != null) {
      // Create a position object from coordinates
      position = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    
    // Create address object
    address = LocationAddress(
      formattedAddress: formattedAddress,
      street: '',
      locality: '',
      subLocality: '',
      administrativeArea: '',
      postalCode: '',
      country: '',
      latitude: lat ?? 0.0,
      longitude: lng ?? 0.0,
    );
    
    state = state.copyWith(
      position: position,
      address: address,
      isLoading: false,
      hasPermission: true,
      error: null,
    );
    
    print('✅ Manual address set: $formattedAddress');
  }

  /// Clear location data
  void clearLocation() {
    state = const LocationState();
  }

  /// Check if location is available
  bool get hasLocation => state.position != null;

  /// Get current coordinates
  (double, double)? get coordinates {
    if (state.position == null) return null;
    return (state.position!.latitude, state.position!.longitude);
  }

  /// Calculate distance to a point in miles
  double? distanceToPoint(double latitude, double longitude) {
    if (state.position == null) return null;
    
    // Calculate distance in meters and convert to miles
    final distanceInMeters = Geolocator.distanceBetween(
      state.position!.latitude,
      state.position!.longitude,
      latitude,
      longitude,
    );
    
    return distanceInMeters * 0.000621371; // Convert meters to miles
  }

  /// Check if a point is within radius (miles)
  bool isWithinRadius(double latitude, double longitude, double radiusMiles) {
    final distance = distanceToPoint(latitude, longitude);
    if (distance == null) return false;
    return distance <= radiusMiles;
  }
}

/// Provider for location functionality
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

/// Helper provider to get current coordinates
final currentCoordinatesProvider = Provider<(double, double)?>(
  (ref) => ref.watch(locationProvider.notifier).coordinates,
);