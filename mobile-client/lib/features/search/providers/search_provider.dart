import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/business.dart';
import '../services/search_service.dart';
import '../models/search_result.dart';
import '../models/search_filters.dart';

part 'search_provider.g.dart';

@riverpod
SearchService searchService(SearchServiceRef ref) {
  return SearchService();
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  SearchResult build() {
    return const SearchResult(
      deals: [],
      businesses: [],
    );
  }

  /// Search for deals by query
  Future<void> searchDeals({
    required String query,
    SearchFilters? filters,
    double? userLatitude,
    double? userLongitude,
  }) async {
    if (query.trim().isEmpty && (filters == null || !filters.hasActiveFilters)) {
      state = const SearchResult(deals: [], businesses: []);
      return;
    }

    try {
      final searchService = ref.read(searchServiceProvider);
      
      List<Deal> deals;
      if (filters != null && filters.hasActiveFilters) {
        // Use advanced search with filters
        final searchFilters = filters.copyWith(query: query);
        final result = await searchService.advancedSearch(
          filters: searchFilters,
          userLatitude: userLatitude,
          userLongitude: userLongitude,
        );
        deals = result.deals;
      } else {
        // Simple text search
        deals = await searchService.searchDeals(query);
      }

      state = SearchResult(
        deals: deals,
        businesses: const [],
        totalCount: deals.length,
        dealsCount: deals.length,
        businessesCount: 0,
        query: query.isEmpty ? null : query,
        searchLatitude: userLatitude,
        searchLongitude: userLongitude,
      );
    } catch (e) {
      // Handle error - could emit error state or show snackbar
      state = SearchResult(
        deals: const [],
        businesses: const [],
        query: query.isEmpty ? null : query,
      );
      rethrow;
    }
  }

  /// Search for nearby deals
  Future<void> searchNearbyDeals({
    required double latitude,
    required double longitude,
    double radiusInKm = 10.0,
  }) async {
    try {
      final searchService = ref.read(searchServiceProvider);
      final deals = await searchService.searchNearbyDeals(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
      );

      state = SearchResult(
        deals: deals,
        businesses: const [],
        totalCount: deals.length,
        dealsCount: deals.length,
        businessesCount: 0,
        searchLatitude: latitude,
        searchLongitude: longitude,
      );
    } catch (e) {
      state = const SearchResult(deals: [], businesses: []);
      rethrow;
    }
  }

  /// Search for businesses
  Future<void> searchBusinesses(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchResult(deals: [], businesses: []);
      return;
    }

    try {
      final searchService = ref.read(searchServiceProvider);
      final businesses = await searchService.searchBusinesses(query);

      state = SearchResult(
        deals: const [],
        businesses: businesses,
        totalCount: businesses.length,
        dealsCount: 0,
        businessesCount: businesses.length,
        query: query,
      );
    } catch (e) {
      state = SearchResult(
        deals: const [],
        businesses: const [],
        query: query,
      );
      rethrow;
    }
  }

  /// Get trending deals
  Future<void> getTrendingDeals() async {
    try {
      final searchService = ref.read(searchServiceProvider);
      final deals = await searchService.getTrendingDeals();

      state = SearchResult(
        deals: deals,
        businesses: const [],
        totalCount: deals.length,
        dealsCount: deals.length,
        businessesCount: 0,
      );
    } catch (e) {
      state = const SearchResult(deals: [], businesses: []);
      rethrow;
    }
  }

  /// Get expiring soon deals
  Future<void> getExpiringSoonDeals() async {
    try {
      final searchService = ref.read(searchServiceProvider);
      final deals = await searchService.getExpiringSoonDeals();

      state = SearchResult(
        deals: deals,
        businesses: const [],
        totalCount: deals.length,
        dealsCount: deals.length,
        businessesCount: 0,
      );
    } catch (e) {
      state = const SearchResult(deals: [], businesses: []);
      rethrow;
    }
  }

  /// Clear search results
  void clearResults() {
    state = const SearchResult(deals: [], businesses: []);
  }
}

@riverpod
class SearchFiltersNotifier extends _$SearchFiltersNotifier {
  @override
  SearchFilters build() {
    return const SearchFilters();
  }

  void updateFilters(SearchFilters filters) {
    state = filters;
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void updateSortBy(SearchSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void updateMaxDistance(double? distance) {
    state = state.copyWith(maxDistance: distance);
  }

  void updatePriceRange({double? minPrice, double? maxPrice}) {
    state = state.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  void updateCuisineTypes(List<String> cuisineTypes) {
    state = state.copyWith(cuisineTypes: cuisineTypes);
  }

  void updateDietaryPreferences({
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
  }) {
    state = state.copyWith(
      isVegetarian: isVegetarian ?? state.isVegetarian,
      isVegan: isVegan ?? state.isVegan,
      isGlutenFree: isGlutenFree ?? state.isGlutenFree,
    );
  }

  void clearFilters() {
    state = const SearchFilters();
  }
}

/// Quick access providers for commonly used searches
@riverpod
Future<List<Deal>> trendingDeals(TrendingDealsRef ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.getTrendingDeals();
}

@riverpod
Future<List<Deal>> expiringSoonDeals(ExpiringSoonDealsRef ref) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.getExpiringSoonDeals();
}

@riverpod
Future<List<Deal>> nearbyDeals(NearbyDealsRef ref, {
  required double latitude,
  required double longitude,
  double radiusInKm = 5.0,
}) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchNearbyDeals(
    latitude: latitude,
    longitude: longitude,
    radiusInKm: radiusInKm,
  );
}