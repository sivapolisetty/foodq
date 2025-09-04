import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/location_preferences.dart';

/// Provider for location preferences management with persistent storage
class LocationPreferencesNotifier extends StateNotifier<LocationPreferences> {
  static const String _prefsKey = 'location_preferences';
  
  LocationPreferencesNotifier() : super(const LocationPreferences()) {
    _loadPreferences();
  }

  /// Load preferences from persistent storage
  Future<void> _loadPreferences() async {
    try {
      print('📍 LocationPreferences: Loading preferences from storage...');
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString(_prefsKey);
      
      if (prefsJson != null) {
        final prefsMap = json.decode(prefsJson) as Map<String, dynamic>;
        final preferences = LocationPreferences.fromJson(prefsMap);
        
        print('📍 LocationPreferences: Loaded - radius: ${preferences.searchRadiusMiles} miles');
        print('📍 LocationPreferences: Last address: ${preferences.lastKnownAddress}');
        
        state = preferences;
      } else {
        print('📍 LocationPreferences: No saved preferences, using defaults');
        // Save default preferences
        await _savePreferences(state);
      }
    } catch (e) {
      print('❌ LocationPreferences: Error loading preferences: $e');
      // Use default preferences if loading fails
    }
  }

  /// Save preferences to persistent storage
  Future<void> _savePreferences(LocationPreferences preferences) async {
    try {
      print('📍 LocationPreferences: Saving preferences to storage...');
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = json.encode(preferences.toJson());
      await prefs.setString(_prefsKey, prefsJson);
      print('✅ LocationPreferences: Preferences saved successfully');
    } catch (e) {
      print('❌ LocationPreferences: Error saving preferences: $e');
    }
  }

  /// Update search radius (30-50 miles)
  Future<void> updateSearchRadius(double radiusMiles) async {
    print('📍 LocationPreferences: Updating search radius to $radiusMiles miles');
    
    // Validate radius is within allowed range
    final clampedRadius = radiusMiles.clamp(30.0, 50.0);
    if (clampedRadius != radiusMiles) {
      print('⚠️ LocationPreferences: Radius clamped from $radiusMiles to $clampedRadius miles');
    }
    
    final newPreferences = state.copyWith(searchRadiusMiles: clampedRadius);
    state = newPreferences;
    await _savePreferences(newPreferences);
  }

  /// Update last known location
  Future<void> updateLastKnownLocation({
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    print('📍 LocationPreferences: Updating last known location');
    print('   Address: $address');
    print('   Coordinates: ${latitude ?? 'null'}, ${longitude ?? 'null'}');
    
    final newPreferences = state.copyWith(
      lastKnownAddress: address,
      lastKnownLatitude: latitude,
      lastKnownLongitude: longitude,
    );
    
    state = newPreferences;
    await _savePreferences(newPreferences);
  }

  /// Update auto-detect location setting
  Future<void> updateAutoDetectLocation(bool autoDetect) async {
    print('📍 LocationPreferences: Updating auto-detect location to $autoDetect');
    
    final newPreferences = state.copyWith(autoDetectLocation: autoDetect);
    state = newPreferences;
    await _savePreferences(newPreferences);
  }

  /// Reset to default preferences
  Future<void> resetToDefaults() async {
    print('📍 LocationPreferences: Resetting to default preferences');
    
    const defaultPreferences = LocationPreferences();
    state = defaultPreferences;
    await _savePreferences(defaultPreferences);
  }

  /// Get current search radius
  double get currentSearchRadius => state.searchRadiusMiles;

  /// Check if location preferences have been set
  bool get hasLastKnownLocation => 
      state.lastKnownAddress.isNotEmpty && 
      state.lastKnownLatitude != null && 
      state.lastKnownLongitude != null;

  /// Get formatted radius text for UI
  String get radiusDisplayText {
    final radius = state.searchRadiusMiles;
    if (radius == radius.toInt().toDouble()) {
      return '${radius.toInt()} miles';
    }
    return '${radius.toStringAsFixed(1)} miles';
  }
}

/// Provider for location preferences
final locationPreferencesProvider = 
    StateNotifierProvider<LocationPreferencesNotifier, LocationPreferences>(
  (ref) => LocationPreferencesNotifier(),
);

/// Computed provider for current search radius
final currentSearchRadiusProvider = Provider<double>((ref) {
  return ref.watch(locationPreferencesProvider).searchRadiusMiles;
});

/// Computed provider for auto-detect location setting
final autoDetectLocationProvider = Provider<bool>((ref) {
  return ref.watch(locationPreferencesProvider).autoDetectLocation;
});