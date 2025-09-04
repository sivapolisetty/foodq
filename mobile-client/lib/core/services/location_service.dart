import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

/// Service for handling location operations including
/// current location detection and address geocoding
class LocationService {
  /// Get current position with proper permission handling
  static Future<Position?> getCurrentPosition() async {
    try {
      print('🌍 LocationService: Starting getCurrentPosition()');
      print('🌐 LocationService: Platform: ${kIsWeb ? 'WEB' : 'MOBILE'}');
      
      if (kIsWeb) {
        print('⚠️ LocationService: WEB DETECTED - Location access requires HTTPS in production');
        print('⚠️ LocationService: Development server (HTTP) may have limited location access');
      }
      
      print('🔍 LocationService: Checking if location services are enabled...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('🔍 LocationService: Location services enabled = $serviceEnabled');
      if (!serviceEnabled) {
        print('❌ LocationService: Location services are disabled');
        if (kIsWeb) {
          print('❌ LocationService: On web, this usually means browser blocked location or HTTPS required');
        }
        return null;
      }

      print('🔐 LocationService: Checking current permission status...');
      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔐 LocationService: Current permission = $permission');
      
      if (permission == LocationPermission.denied) {
        print('🔐 LocationService: Permission denied, requesting permission...');
        if (kIsWeb) {
          print('🔐 LocationService: WEB - Browser will show permission dialog');
        }
        permission = await Geolocator.requestPermission();
        print('🔐 LocationService: Permission after request = $permission');
        if (permission == LocationPermission.denied) {
          print('❌ LocationService: Location permissions are denied after request');
          if (kIsWeb) {
            print('❌ LocationService: WEB - User likely clicked "Block" or "Don\'t allow"');
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ LocationService: Location permissions are permanently denied');
        if (kIsWeb) {
          print('❌ LocationService: WEB - User must manually enable location in browser settings');
        }
        return null;
      }

      print('✅ LocationService: Permission granted, getting current position...');
      print('📡 LocationService: Calling Geolocator.getCurrentPosition() with extended timeout...');
      
      // Use longer timeout for web and better error handling
      final timeout = kIsWeb ? const Duration(seconds: 30) : const Duration(seconds: 15);
      print('📡 LocationService: Timeout set to: ${timeout.inSeconds}s');
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: kIsWeb ? LocationAccuracy.best : LocationAccuracy.high,
        timeLimit: timeout,
      );
      
      print('📍 LocationService: SUCCESS - Current position: ${position.latitude}, ${position.longitude}');
      print('⏰ LocationService: Position timestamp: ${position.timestamp}');
      print('🎯 LocationService: Position accuracy: ${position.accuracy}m');
      return position;
      
    } catch (e, stackTrace) {
      print('💥 LocationService: ERROR getting current position: $e');
      print('📚 LocationService: Stack trace: $stackTrace');
      
      if (kIsWeb) {
        print('🌐 LocationService: WEB ERROR ANALYSIS:');
        if (e.toString().contains('Network')) {
          print('   - Network error: Check internet connection');
        } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
          print('   - Timeout: Location detection took too long');
        } else if (e.toString().contains('denied') || e.toString().contains('permission')) {
          print('   - Permission: Browser blocked location access');
        } else if (e.toString().contains('unavailable')) {
          print('   - Unavailable: Location services not available');
        } else {
          print('   - Unknown web error: $e');
        }
      }
      
      return null;
    }
  }

  /// Convert coordinates to address using reverse geocoding
  /// Uses platform geocoding enhanced with Google Maps API key for better accuracy
  static Future<LocationAddress?> getAddressFromCoordinates(
    double latitude, 
    double longitude,
  ) async {
    try {
      print('🔄 Getting address for: $latitude, $longitude');
      print('📍 Using enhanced geocoding with Google API key...');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude,
      );
      
      if (placemarks.isEmpty) {
        print('❌ No address found for coordinates');
        return null;
      }
      
      final placemark = placemarks.first;
      print('🏠 Address found: ${placemark.street}, ${placemark.locality}');
      
      return LocationAddress(
        street: placemark.street ?? '',
        locality: placemark.locality ?? '',
        subLocality: placemark.subLocality ?? '',
        administrativeArea: placemark.administrativeArea ?? '',
        postalCode: placemark.postalCode ?? '',
        country: placemark.country ?? '',
        latitude: latitude,
        longitude: longitude,
        formattedAddress: _formatAddress(placemark),
      );
      
    } catch (e) {
      print('💥 Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address using forward geocoding
  static Future<LocationCoordinates?> getCoordinatesFromAddress(String address) async {
    try {
      print('🔄 Getting coordinates for address: $address');
      
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isEmpty) {
        print('❌ No coordinates found for address');
        return null;
      }
      
      final location = locations.first;
      print('📍 Coordinates found: ${location.latitude}, ${location.longitude}');
      
      return LocationCoordinates(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      
    } catch (e) {
      print('💥 Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Format placemark into readable address
  static String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];
    
    if (placemark.street?.isNotEmpty == true) {
      addressParts.add(placemark.street!);
    }
    
    if (placemark.subLocality?.isNotEmpty == true) {
      addressParts.add(placemark.subLocality!);
    }
    
    if (placemark.locality?.isNotEmpty == true) {
      addressParts.add(placemark.locality!);
    }
    
    if (placemark.administrativeArea?.isNotEmpty == true) {
      addressParts.add(placemark.administrativeArea!);
    }
    
    if (placemark.postalCode?.isNotEmpty == true) {
      addressParts.add(placemark.postalCode!);
    }
    
    if (placemark.country?.isNotEmpty == true) {
      addressParts.add(placemark.country!);
    }
    
    return addressParts.join(', ');
  }

  /// Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Open app settings for location permissions
  static Future<void> openLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Test method to debug location services
  static Future<void> testLocationServices() async {
    print('🧪 Testing location services...');
    
    // Test 1: Check permissions
    final hasPermission = await hasLocationPermission();
    print('✅ Has location permission: $hasPermission');
    
    // Test 2: Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('✅ Location services enabled: $serviceEnabled');
    
    // Test 3: Try to get position
    final position = await getCurrentPosition();
    if (position != null) {
      print('✅ Got position: ${position.latitude}, ${position.longitude}');
      
      // Test 4: Try geocoding
      final address = await getAddressFromCoordinates(position.latitude, position.longitude);
      if (address != null) {
        print('✅ Got address: ${address.formattedAddress}');
        print('   City: ${address.city}');
        print('   State: ${address.state}');
        print('   ZIP: ${address.postalCode}');
      } else {
        print('❌ Failed to get address');
      }
    } else {
      print('❌ Failed to get position');
    }
  }

}

/// Model for location address data
class LocationAddress {
  final String street;
  final String locality;
  final String subLocality;
  final String administrativeArea;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final String formattedAddress;

  LocationAddress({
    required this.street,
    required this.locality,
    required this.subLocality,
    required this.administrativeArea,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  /// Get city name (locality or sub-locality)
  String get city => locality.isNotEmpty ? locality : subLocality;
  
  /// Get state name
  String get state => administrativeArea;
  
  /// Get street address
  String get streetAddress => street;
}

/// Model for location coordinates
class LocationCoordinates {
  final double latitude;
  final double longitude;

  LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });
}