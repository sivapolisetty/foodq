import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/services/search_service.dart';
import '../../location/providers/location_provider.dart';
import '../../location/providers/location_preferences_provider.dart';
import '../../../shared/services/expired_deals_api_service.dart';
import '../../../shared/models/api_models.dart' hide DealWithDistance;

/// State for enhanced home with location-based content
class EnhancedHomeState {
  final List<DealWithDistance> nearbyDeals;
  final List<BusinessWithDistance> nearbyBusinesses;
  final List<ExpiredDeal> expiredDeals;
  final EnhancedSearchResult? searchResults;
  final bool isLoadingDeals;
  final bool isLoadingBusinesses;
  final bool isLoadingExpiredDeals;
  final bool isSearching;
  final String? error;
  final String? searchQuery;

  const EnhancedHomeState({
    this.nearbyDeals = const [],
    this.nearbyBusinesses = const [],
    this.expiredDeals = const [],
    this.searchResults,
    this.isLoadingDeals = false,
    this.isLoadingBusinesses = false,
    this.isLoadingExpiredDeals = false,
    this.isSearching = false,
    this.error,
    this.searchQuery,
  });

  EnhancedHomeState copyWith({
    List<DealWithDistance>? nearbyDeals,
    List<BusinessWithDistance>? nearbyBusinesses,
    List<ExpiredDeal>? expiredDeals,
    EnhancedSearchResult? searchResults,
    bool? isLoadingDeals,
    bool? isLoadingBusinesses,
    bool? isLoadingExpiredDeals,
    bool? isSearching,
    String? error,
    String? searchQuery,
  }) {
    return EnhancedHomeState(
      nearbyDeals: nearbyDeals ?? this.nearbyDeals,
      nearbyBusinesses: nearbyBusinesses ?? this.nearbyBusinesses,
      expiredDeals: expiredDeals ?? this.expiredDeals,
      searchResults: searchResults ?? this.searchResults,
      isLoadingDeals: isLoadingDeals ?? this.isLoadingDeals,
      isLoadingBusinesses: isLoadingBusinesses ?? this.isLoadingBusinesses,
      isLoadingExpiredDeals: isLoadingExpiredDeals ?? this.isLoadingExpiredDeals,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for enhanced home functionality
class EnhancedHomeNotifier extends StateNotifier<EnhancedHomeState> {
  final SearchService _searchService;
  final LocationNotifier _locationNotifier;
  final Ref _ref;

  EnhancedHomeNotifier(this._searchService, this._locationNotifier, this._ref) 
      : super(const EnhancedHomeState());

  /// Load nearby content based on user location
  Future<void> loadNearbyContent() async {
    var coordinates = _locationNotifier.coordinates;
    
    // If no current location, check for stored preferences first
    if (coordinates == null) {
      print('📍 No current location, checking stored preferences...');
      
      // Give the preferences provider a moment to load if needed
      await Future.delayed(const Duration(milliseconds: 200));
      
      final locationPrefs = _ref.read(locationPreferencesProvider);
      
      if (locationPrefs.lastKnownLatitude != null && 
          locationPrefs.lastKnownLongitude != null &&
          locationPrefs.lastKnownAddress.isNotEmpty) {
        print('📍 Using stored location: ${locationPrefs.lastKnownAddress}');
        print('📍 Coordinates: ${locationPrefs.lastKnownLatitude}, ${locationPrefs.lastKnownLongitude}');
        coordinates = (locationPrefs.lastKnownLatitude!, locationPrefs.lastKnownLongitude!);
        
        // Update location provider with stored preferences
        _locationNotifier.setManualAddress(
          locationPrefs.lastKnownAddress, 
          locationPrefs.lastKnownLatitude, 
          locationPrefs.lastKnownLongitude
        );
      } else {
        print('📍 No stored location found, requesting current location...');
        print('📍 Address: "${locationPrefs.lastKnownAddress}", Lat: ${locationPrefs.lastKnownLatitude}, Lng: ${locationPrefs.lastKnownLongitude}');
        await _locationNotifier.getCurrentLocation();
        coordinates = _locationNotifier.coordinates;
        
        // If still no location after requesting, use fallback
        if (coordinates == null) {
          print('📍 Still no location available, using default location');
          coordinates = (40.7128, -74.0060); // Default NYC coordinates
        }
      }
    }

    final (latitude, longitude) = coordinates;
    
    // Get user's preferred search radius
    final searchRadius = _ref.read(currentSearchRadiusProvider);
    
    print('📍 Loading nearby content for: $latitude, $longitude');
    print('📏 Using search radius: ${searchRadius} miles');

    state = state.copyWith(
      isLoadingDeals: true,
      isLoadingBusinesses: true,
      isLoadingExpiredDeals: true,
      error: null,
    );

    try {
      // Load nearby deals, businesses, and expired deals in parallel
      final results = await Future.wait([
        _searchService.getNearbyDealsWithDistance(
          userLatitude: latitude,
          userLongitude: longitude,
          radiusMiles: searchRadius,
          limit: 10,
        ),
        _searchService.getNearbyBusinessesWithDistance(
          userLatitude: latitude,
          userLongitude: longitude,
          radiusMiles: searchRadius,
          limit: 10,
        ),
        ExpiredDealsApiService.getExpiredDeals(),
      ]);

      final nearbyDeals = results[0] as List<DealWithDistance>;
      final nearbyBusinesses = results[1] as List<BusinessWithDistance>;
      final expiredDeals = results[2] as List<ExpiredDeal>;

      state = state.copyWith(
        nearbyDeals: nearbyDeals,
        nearbyBusinesses: nearbyBusinesses,
        expiredDeals: expiredDeals.take(10).toList(), // Limit to 10 for horizontal scroll
        isLoadingDeals: false,
        isLoadingBusinesses: false,
        isLoadingExpiredDeals: false,
        error: null,
      );

      print('✅ Loaded ${nearbyDeals.length} nearby deals, ${nearbyBusinesses.length} businesses, and ${expiredDeals.length} expired deals');

    } catch (e) {
      print('❌ Error loading nearby content: $e');
      state = state.copyWith(
        isLoadingDeals: false,
        isLoadingBusinesses: false,
        isLoadingExpiredDeals: false,
        error: 'Failed to load nearby content: $e',
      );
    }
  }

  /// Search for deals and restaurants
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      // Clear search results
      state = state.copyWith(
        searchResults: null,
        searchQuery: null,
        isSearching: false,
      );
      return;
    }

    print('🔍 Searching for: $query');
    
    // Get user's preferred search radius
    final searchRadius = _ref.read(currentSearchRadiusProvider);
    print('📏 Search using radius: ${searchRadius} miles');
    
    state = state.copyWith(
      isSearching: true,
      searchQuery: query,
      error: null,
    );

    try {
      final coordinates = _locationNotifier.coordinates;
      
      final searchResults = await _searchService.searchAll(
        query: query,
        userLatitude: coordinates?.$1,
        userLongitude: coordinates?.$2,
        radiusMiles: searchRadius,
        limit: 20,
      );

      state = state.copyWith(
        searchResults: searchResults,
        isSearching: false,
        error: null,
      );

      print('✅ Search completed: ${searchResults.totalResults} total results within ${searchRadius} miles');

    } catch (e) {
      print('❌ Search error: $e');
      state = state.copyWith(
        isSearching: false,
        error: 'Search failed: $e',
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    state = state.copyWith(
      searchResults: null,
      searchQuery: null,
      isSearching: false,
    );
  }

  /// Refresh all content
  Future<void> refresh() async {
    await loadNearbyContent();
  }

  /// Check if we're showing search results
  bool get isShowingSearchResults => 
      state.searchResults != null && 
      state.searchQuery?.isNotEmpty == true;

  /// Get display content - either search results or nearby content
  List<DealWithDistance> get displayDeals {
    if (isShowingSearchResults) {
      return state.searchResults!.deals;
    }
    return state.nearbyDeals;
  }

  List<BusinessWithDistance> get displayBusinesses {
    if (isShowingSearchResults) {
      return state.searchResults!.businesses;
    }
    return state.nearbyBusinesses;
  }

  String get sectionTitle {
    if (isShowingSearchResults) {
      return 'Search Results for "${state.searchQuery}"';
    }
    return 'Near You';
  }
}

/// Provider for enhanced home functionality
final enhancedHomeProvider = StateNotifierProvider<EnhancedHomeNotifier, EnhancedHomeState>((ref) {
  final searchService = SearchService();
  final locationNotifier = ref.watch(locationProvider.notifier);
  return EnhancedHomeNotifier(searchService, locationNotifier, ref);
});