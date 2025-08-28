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
}