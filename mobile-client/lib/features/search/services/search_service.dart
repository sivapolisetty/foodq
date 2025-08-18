import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/business.dart';
import '../models/search_result.dart';
import '../models/search_filters.dart';

class SearchService {
  final SupabaseClient _supabaseClient;

  SearchService({required SupabaseClient supabaseClient}) 
    : _supabaseClient = supabaseClient;

  /// Search for deals by query string
  Future<List<Deal>> searchDeals(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final escapedQuery = _escapeSearchQuery(query);
      
      final response = await _supabaseClient
          .from('deals')
          .select('''
            *,
            businesses!deals_business_id_fkey(
              id, name, address, latitude, longitude, cuisine_type
            )
          ''')
          .eq('status', 'active')
          .gt('expires_at', DateTime.now().toIso8601String())
          .gt('quantity_available', 0)
          .or('title.ilike.%$escapedQuery%,description.ilike.%$escapedQuery%')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Deal.fromJson(json as Map<String, dynamic>))
          .toList();
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
      // For now, we'll do a simple query and filter in-memory
      // In production, you'd use PostGIS for proper geographic queries
      final response = await _supabaseClient
          .from('deals')
          .select('''
            *,
            businesses!deals_business_id_fkey(
              id, name, address, latitude, longitude, cuisine_type
            )
          ''')
          .eq('status', 'active')
          .gt('expires_at', DateTime.now().toIso8601String())
          .gt('quantity_available', 0)
          .order('created_at', ascending: false)
          .limit(limit);

      final deals = (response as List<dynamic>)
          .map((json) => Deal.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter by distance in-memory (simplified approach)
      return _filterDealsByDistance(deals, latitude, longitude, radiusInKm);
    } catch (e) {
      throw Exception('Failed to search nearby deals: ${e.toString()}');
    }
  }

  /// Search for businesses by query string
  Future<List<Business>> searchBusinesses(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final escapedQuery = _escapeSearchQuery(query);
      
      final response = await _supabaseClient
          .from('businesses')
          .select('*')
          .eq('is_active', true)
          .eq('is_approved', true)
          .or('name.ilike.%$escapedQuery%,cuisine_type.ilike.%$escapedQuery%,address.ilike.%$escapedQuery%,description.ilike.%$escapedQuery%')
          .order('name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => Business.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search businesses: ${e.toString()}');
    }
  }

  /// Advanced search with filters
  Future<SearchResult> advancedSearch({
    required SearchFilters filters,
    double? userLatitude,
    double? userLongitude,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Build query with filters
      var query = _supabaseClient
          .from('deals')
          .select('''
            *,
            businesses!deals_business_id_fkey(
              id, name, address, latitude, longitude, cuisine_type
            )
          ''')
          .eq('status', 'active')
          .gt('expires_at', DateTime.now().toIso8601String())
          .gt('quantity_available', 0);

      // Apply text search filter
      if (filters.query.isNotEmpty) {
        final escapedQuery = _escapeSearchQuery(filters.query);
        query = query.or('title.ilike.%$escapedQuery%,description.ilike.%$escapedQuery%');
      }

      // Apply price filters
      if (filters.maxPrice != null) {
        query = query.lte('discounted_price', filters.maxPrice!);
      }
      if (filters.minPrice != null) {
        query = query.gte('discounted_price', filters.minPrice!);
      }

      // Apply sorting
      query = _applySorting(query, filters.sortBy);

      // Execute query with pagination
      final response = await query
          .range(offset, offset + limit - 1);

      var deals = (response as List<dynamic>)
          .map((json) => Deal.fromJson(json as Map<String, dynamic>))
          .toList();

      // Apply client-side filters
      deals = _applyClientSideFilters(deals, filters, userLatitude, userLongitude);

      return SearchResult(
        deals: deals,
        businesses: [], // For now, focusing on deals
        totalCount: deals.length,
        dealsCount: deals.length,
        businessesCount: 0,
        hasMore: deals.length == limit,
        query: filters.query.isEmpty ? null : filters.query,
        searchLatitude: userLatitude,
        searchLongitude: userLongitude,
      );
    } catch (e) {
      throw Exception('Failed to perform advanced search: ${e.toString()}');
    }
  }

  /// Get trending deals (most popular/recent)
  Future<List<Deal>> getTrendingDeals({int limit = 10}) async {
    try {
      final response = await _supabaseClient
          .from('deals')
          .select('''
            *,
            businesses!deals_business_id_fkey(
              id, name, address, latitude, longitude, cuisine_type
            )
          ''')
          .eq('status', 'active')
          .gt('expires_at', DateTime.now().toIso8601String())
          .gt('quantity_available', 0)
          .order('quantity_sold', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Deal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get trending deals: ${e.toString()}');
    }
  }

  /// Get expiring soon deals
  Future<List<Deal>> getExpiringSoonDeals({
    int hoursThreshold = 6,
    int limit = 20,
  }) async {
    try {
      final now = DateTime.now();
      final threshold = now.add(Duration(hours: hoursThreshold));

      final response = await _supabaseClient
          .from('deals')
          .select('''
            *,
            businesses!deals_business_id_fkey(
              id, name, address, latitude, longitude, cuisine_type
            )
          ''')
          .eq('status', 'active')
          .gt('expires_at', now.toIso8601String())
          .lt('expires_at', threshold.toIso8601String())
          .gt('quantity_available', 0)
          .order('expires_at', ascending: true)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Deal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expiring deals: ${e.toString()}');
    }
  }

  /// Get deals by cuisine type
  Future<List<Deal>> getDealsByCuisine(String cuisineType, {int limit = 20}) async {
    try {
      final response = await _supabaseClient
          .from('deals')
          .select('''
            *,
            businesses!deals_business_id_fkey(
              id, name, address, latitude, longitude, cuisine_type
            )
          ''')
          .eq('status', 'active')
          .gt('expires_at', DateTime.now().toIso8601String())
          .gt('quantity_available', 0)
          .eq('businesses.cuisine_type', cuisineType)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Deal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get deals by cuisine: ${e.toString()}');
    }
  }

  // Private helper methods

  /// Escape special characters in search query
  String _escapeSearchQuery(String query) {
    return query.replaceAll(RegExp(r'[%_\\]'), r'\$&');
  }

  /// Apply sorting to query
  dynamic _applySorting(dynamic query, SearchSortBy sortBy) {
    switch (sortBy) {
      case SearchSortBy.newest:
        return query.order('created_at', ascending: false);
      case SearchSortBy.expiringSoon:
        return query.order('expires_at', ascending: true);
      case SearchSortBy.priceLowToHigh:
        return query.order('discounted_price', ascending: true);
      case SearchSortBy.priceHighToLow:
        return query.order('discounted_price', ascending: false);
      case SearchSortBy.discount:
        // Calculate discount percentage on client side and sort
        return query.order('created_at', ascending: false);
      case SearchSortBy.distance:
        // Distance sorting would be done client-side after location calculation
        return query.order('created_at', ascending: false);
      case SearchSortBy.relevance:
      default:
        return query.order('created_at', ascending: false);
    }
  }

  /// Apply client-side filters that can't be done in the database
  List<Deal> _applyClientSideFilters(
    List<Deal> deals,
    SearchFilters filters,
    double? userLatitude,
    double? userLongitude,
  ) {
    var filteredDeals = deals;

    // Apply discount filter
    if (filters.minDiscount != null) {
      filteredDeals = filteredDeals.where((deal) {
        return deal.discountPercentage >= filters.minDiscount!;
      }).toList();
    }

    // Apply expiring soon filter
    if (filters.isExpiringSoon) {
      filteredDeals = filteredDeals.where((deal) => deal.isExpiringSoon).toList();
    }

    // Apply almost sold out filter
    if (filters.isAlmostSoldOut) {
      filteredDeals = filteredDeals.where((deal) => deal.isAlmostSoldOut).toList();
    }

    // Apply distance filter if user location is provided
    if (filters.maxDistance != null && userLatitude != null && userLongitude != null) {
      filteredDeals = _filterDealsByDistance(
        filteredDeals,
        userLatitude,
        userLongitude,
        filters.maxDistance!,
      );
    }

    // Apply final sorting for client-side sorts
    if (filters.sortBy == SearchSortBy.discount) {
      filteredDeals.sort((a, b) => b.discountPercentage.compareTo(a.discountPercentage));
    }

    return filteredDeals;
  }

  /// Filter deals by distance from user location
  List<Deal> _filterDealsByDistance(
    List<Deal> deals,
    double userLatitude,
    double userLongitude,
    double maxDistanceKm,
  ) {
    return deals.where((deal) {
      // This would normally come from the business relationship
      // For now, using mock coordinates or skip deals without location
      final businessLat = 40.7128; // Mock latitude
      final businessLng = -74.0060; // Mock longitude
      
      final distance = _calculateDistance(
        userLatitude,
        userLongitude,
        businessLat,
        businessLng,
      );
      
      return distance <= maxDistanceKm;
    }).toList();
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    
    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLon = (lon2 - lon1) * (pi / 180);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusKm * c;
  }
}