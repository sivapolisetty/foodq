import 'dart:math';
import '../../../shared/models/deal.dart';
import '../../../shared/models/business.dart';
import '../models/search_result.dart';
import '../models/search_filters.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';

class SearchService {
  SearchService();

  /// Search for deals by query string
  Future<List<Deal>> searchDeals(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: {
          'search': query,
          'limit': '50',
        },
      );

      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        return dealsData
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to search deals: ${e.toString()}');
    }
  }

  /// Search for deals near a specific location
  Future<List<Deal>> searchNearbyDeals({
    required double latitude,
    required double longitude,
    double radiusInKm = 10.0,
    int limit = 50,
    String? businessId,
  }) async {
    try {
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: {
          'filter': 'nearby',
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radiusInKm.toString(),
          'limit': limit.toString(),
          if (businessId != null) 'business_id': businessId,
        },
      );

      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        return dealsData
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to search nearby deals: ${e.toString()}');
    }
  }

  /// Search for businesses by query string
  Future<List<Business>> searchBusinesses(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await ApiService.get<dynamic>(
        ApiConfig.businessesEndpoint,
        queryParameters: {
          'search': query,
          'limit': '50',
        },
      );

      if (response.success && response.data != null) {
        final businessesData = response.data as List<dynamic>;
        return businessesData
            .map((json) => Business.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to search businesses: ${e.toString()}');
    }
  }

  /// Search for deals by cuisine type
  Future<List<Deal>> searchByCuisine(String cuisineType) async {
    try {
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: {
          'cuisine': cuisineType,
          'limit': '50',
        },
      );

      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        return dealsData
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to search by cuisine: ${e.toString()}');
    }
  }

  /// Search deals with filters
  Future<List<Deal>> searchWithFilters(SearchFilters filters) async {
    try {
      final queryParams = <String, String>{};
      
      if (filters.query.isNotEmpty) {
        queryParams['search'] = filters.query;
      }
      
      if (filters.minPrice != null) {
        queryParams['min_price'] = filters.minPrice.toString();
      }
      
      if (filters.maxPrice != null) {
        queryParams['max_price'] = filters.maxPrice.toString();
      }
      
      if (filters.cuisineTypes.isNotEmpty) {
        queryParams['cuisine'] = filters.cuisineTypes.join(',');
      }
      
      if (filters.sortBy != SearchSortBy.relevance) {
        queryParams['sort'] = filters.sortBy.name;
      }
      
      queryParams['limit'] = '50';
      queryParams['offset'] = '0';

      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        return dealsData
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to search with filters: ${e.toString()}');
    }
  }

  /// Get recent searches (could be stored locally)
  Future<List<String>> getRecentSearches() async {
    // This would typically be stored in local storage
    // For now, return empty list
    return [];
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    // Clear from local storage
  }

  /// Advanced search with multiple filters
  Future<SearchResult> advancedSearch({
    required SearchFilters filters,
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      final deals = await searchWithFilters(filters);
      return SearchResult(
        deals: deals,
        businesses: const [],
        totalCount: deals.length,
        dealsCount: deals.length,
        businessesCount: 0,
        query: filters.query,
        searchLatitude: userLatitude,
        searchLongitude: userLongitude,
      );
    } catch (e) {
      throw Exception('Failed to perform advanced search: ${e.toString()}');
    }
  }

  /// Get trending deals
  Future<List<Deal>> getTrendingDeals() async {
    try {
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: {
          'filter': 'trending',
          'limit': '20',
        },
      );

      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        return dealsData
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get trending deals: ${e.toString()}');
    }
  }

  /// Get deals expiring soon
  Future<List<Deal>> getExpiringSoonDeals() async {
    try {
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: {
          'filter': 'expiring_soon',
          'limit': '20',
        },
      );

      if (response.success && response.data != null) {
        final dealsData = response.data as List<dynamic>;
        return dealsData
            .map((json) => Deal.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to get expiring soon deals: ${e.toString()}');
    }
  }

  /// Calculate distance between two coordinates
  double _calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Search both deals and businesses with location support
  Future<EnhancedSearchResult> searchAll({
    required String query,
    double? userLatitude,
    double? userLongitude,
    double radiusMiles = 50.0,
    int limit = 20,
  }) async {
    try {
      print('🔍 SearchService: Enhanced search for "$query"');
      print('📍 User location: ${userLatitude ?? 'unknown'}, ${userLongitude ?? 'unknown'}');
      
      // Search deals and businesses in parallel
      final results = await Future.wait([
        _searchDealsWithDistance(
          query: query,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          radiusMiles: radiusMiles,
          limit: limit,
        ),
        _searchBusinessesWithDistance(
          query: query,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
          radiusMiles: radiusMiles,
          limit: limit,
        ),
      ]);

      final deals = results[0] as List<DealWithDistance>;
      final businesses = results[1] as List<BusinessWithDistance>;

      return EnhancedSearchResult(
        deals: deals,
        businesses: businesses,
        query: query,
      );

    } catch (e) {
      print('❌ Error in enhanced searchAll: $e');
      return EnhancedSearchResult(deals: [], businesses: [], query: query);
    }
  }

  /// Search deals with distance calculation
  Future<List<DealWithDistance>> _searchDealsWithDistance({
    required String query,
    double? userLatitude,
    double? userLongitude,
    double radiusMiles = 50.0,
    int limit = 20,
  }) async {
    try {
      // Use existing search method
      final deals = await searchDeals(query);
      
      // Convert to DealWithDistance and calculate distances
      final dealsWithDistance = <DealWithDistance>[];
      
      for (final deal in deals.take(limit)) {
        double? distance;
        
        // Calculate distance if we have both user location and business location
        if (userLatitude != null && 
            userLongitude != null && 
            deal.restaurant?.latitude != null && 
            deal.restaurant?.longitude != null) {
          
          distance = _calculateDistanceInMiles(
            userLatitude,
            userLongitude,
            deal.restaurant!.latitude!,
            deal.restaurant!.longitude!,
          );
          
          // Filter by radius if distance is available
          if (distance > radiusMiles) {
            continue; // Skip deals outside radius
          }
        }
        
        dealsWithDistance.add(DealWithDistance(
          deal: deal,
          distanceInMiles: distance,
        ));
      }
      
      // Sort by distance (nearest first)
      dealsWithDistance.sort((a, b) {
        if (a.distanceInMiles == null && b.distanceInMiles == null) return 0;
        if (a.distanceInMiles == null) return 1;
        if (b.distanceInMiles == null) return -1;
        return a.distanceInMiles!.compareTo(b.distanceInMiles!);
      });
      
      return dealsWithDistance;
      
    } catch (e) {
      print('❌ Error searching deals with distance: $e');
      return [];
    }
  }

  /// Search businesses with distance calculation
  Future<List<BusinessWithDistance>> _searchBusinessesWithDistance({
    required String query,
    double? userLatitude,
    double? userLongitude,
    double radiusMiles = 50.0,
    int limit = 20,
  }) async {
    try {
      // Use existing search method
      final businesses = await searchBusinesses(query);
      
      final businessesWithDistance = <BusinessWithDistance>[];
      
      for (final business in businesses.take(limit)) {
        double? distance;
        
        // Calculate distance if we have coordinates
        if (userLatitude != null && 
            userLongitude != null && 
            business.hasLocation) {
          
          distance = _calculateDistanceInMiles(
            userLatitude,
            userLongitude,
            business.latitude!,
            business.longitude!,
          );
          
          // Filter by radius
          if (distance > radiusMiles) {
            continue;
          }
        }
        
        businessesWithDistance.add(BusinessWithDistance(
          business: business,
          distanceInMiles: distance,
        ));
      }
      
      // Sort by distance (nearest first)
      businessesWithDistance.sort((a, b) {
        if (a.distanceInMiles == null && b.distanceInMiles == null) return 0;
        if (a.distanceInMiles == null) return 1;
        if (b.distanceInMiles == null) return -1;
        return a.distanceInMiles!.compareTo(b.distanceInMiles!);
      });
      
      return businessesWithDistance.take(limit).toList();
      
    } catch (e) {
      print('❌ Error searching businesses with distance: $e');
      return [];
    }
  }

  /// Get nearby deals without search query
  Future<List<DealWithDistance>> getNearbyDealsWithDistance({
    required double userLatitude,
    required double userLongitude,
    double radiusMiles = 50.0,
    int limit = 20,
    String? businessId,
  }) async {
    try {
      print('📍 Getting nearby deals with distance for: $userLatitude, $userLongitude');
      
      // Convert radius from miles to km for API
      final radiusKm = radiusMiles * 1.60934;
      
      final deals = await searchNearbyDeals(
        latitude: userLatitude,
        longitude: userLongitude,
        radiusInKm: radiusKm,
        limit: limit,
        businessId: businessId,
      );
      
      final dealsWithDistance = <DealWithDistance>[];
      
      for (final deal in deals) {
        double? distance;
        
        if (deal.restaurant?.latitude != null && deal.restaurant?.longitude != null) {
          distance = _calculateDistanceInMiles(
            userLatitude,
            userLongitude,
            deal.restaurant!.latitude!,
            deal.restaurant!.longitude!,
          );
        }
        
        dealsWithDistance.add(DealWithDistance(
          deal: deal,
          distanceInMiles: distance,
        ));
      }
      
      // Sort by distance
      dealsWithDistance.sort((a, b) {
        if (a.distanceInMiles == null && b.distanceInMiles == null) return 0;
        if (a.distanceInMiles == null) return 1;
        if (b.distanceInMiles == null) return -1;
        return a.distanceInMiles!.compareTo(b.distanceInMiles!);
      });
      
      return dealsWithDistance;
      
    } catch (e) {
      print('❌ Error getting nearby deals with distance: $e');
      return [];
    }
  }

  /// Get nearby restaurants
  Future<List<BusinessWithDistance>> getNearbyBusinessesWithDistance({
    required double userLatitude,
    required double userLongitude,
    double radiusMiles = 50.0,
    int limit = 20,
  }) async {
    try {
      print('📍 Getting nearby businesses for: $userLatitude, $userLongitude');
      
      final queryParams = {
        'filter': 'nearby',
        'lat': userLatitude.toString(),
        'lng': userLongitude.toString(),
        'radius': (radiusMiles * 1.60934).toString(), // Convert to km
        'limit': limit.toString(),
      };

      final response = await ApiService.get<dynamic>(
        ApiConfig.businessesEndpoint,
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final businessesData = response.data as List<dynamic>;
        final businessesWithDistance = <BusinessWithDistance>[];
        
        for (final businessJson in businessesData) {
          final business = Business.fromJson(businessJson as Map<String, dynamic>);
          
          double? distance;
          if (business.hasLocation) {
            distance = _calculateDistanceInMiles(
              userLatitude,
              userLongitude,
              business.latitude!,
              business.longitude!,
            );
          }
          
          businessesWithDistance.add(BusinessWithDistance(
            business: business,
            distanceInMiles: distance,
          ));
        }
        
        // Sort by distance
        businessesWithDistance.sort((a, b) {
          if (a.distanceInMiles == null && b.distanceInMiles == null) return 0;
          if (a.distanceInMiles == null) return 1;
          if (b.distanceInMiles == null) return -1;
          return a.distanceInMiles!.compareTo(b.distanceInMiles!);
        });
        
        return businessesWithDistance;
      }
      
      return [];
      
    } catch (e) {
      print('❌ Error getting nearby businesses: $e');
      return [];
    }
  }

  /// Calculate distance between two points in miles
  double _calculateDistanceInMiles(
    double lat1, double lng1, 
    double lat2, double lng2
  ) {
    const double earthRadiusMiles = 3958.756;
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    
    final a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * 
        sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * asin(sqrt(a));
    
    return earthRadiusMiles * c;
  }
}

/// Enhanced search result containing deals and businesses with distance
class EnhancedSearchResult {
  final List<DealWithDistance> deals;
  final List<BusinessWithDistance> businesses;
  final String query;

  EnhancedSearchResult({
    required this.deals,
    required this.businesses,
    required this.query,
  });

  bool get isEmpty => deals.isEmpty && businesses.isEmpty;
  int get totalResults => deals.length + businesses.length;
}

/// Deal with calculated distance
class DealWithDistance {
  final Deal deal;
  final double? distanceInMiles;

  DealWithDistance({
    required this.deal,
    this.distanceInMiles,
  });

  String get formattedDistance {
    if (distanceInMiles == null) return '';
    if (distanceInMiles! < 1.0) {
      return '${(distanceInMiles! * 5280).round()} ft away';
    }
    return '${distanceInMiles!.toStringAsFixed(1)} miles away';
  }
}

/// Business with calculated distance
class BusinessWithDistance {
  final Business business;
  final double? distanceInMiles;

  BusinessWithDistance({
    required this.business,
    this.distanceInMiles,
  });

  String get formattedDistance {
    if (distanceInMiles == null) return '';
    if (distanceInMiles! < 1.0) {
      return '${(distanceInMiles! * 5280).round()} ft away';
    }
    return '${distanceInMiles!.toStringAsFixed(1)} miles away';
  }
}