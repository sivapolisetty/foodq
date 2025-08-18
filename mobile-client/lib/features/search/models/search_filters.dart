import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_filters.freezed.dart';
part 'search_filters.g.dart';

enum SearchSortBy {
  @JsonValue('relevance')
  relevance,
  @JsonValue('distance')
  distance,
  @JsonValue('discount')
  discount,
  @JsonValue('price_low_to_high')
  priceLowToHigh,
  @JsonValue('price_high_to_low')
  priceHighToLow,
  @JsonValue('newest')
  newest,
  @JsonValue('expiring_soon')
  expiringSoon;

  String get displayName {
    switch (this) {
      case SearchSortBy.relevance:
        return 'Relevance';
      case SearchSortBy.distance:
        return 'Distance';
      case SearchSortBy.discount:
        return 'Highest Discount';
      case SearchSortBy.priceLowToHigh:
        return 'Price: Low to High';
      case SearchSortBy.priceHighToLow:
        return 'Price: High to Low';
      case SearchSortBy.newest:
        return 'Newest First';
      case SearchSortBy.expiringSoon:
        return 'Expiring Soon';
    }
  }
}

@freezed
class SearchFilters with _$SearchFilters {
  const factory SearchFilters({
    @Default('') String query,
    @Default(null) double? maxDistance,
    @Default(null) double? minDiscount,
    @Default(null) double? maxPrice,
    @Default(null) double? minPrice,
    @Default([]) List<String> cuisineTypes,
    @Default(SearchSortBy.relevance) SearchSortBy sortBy,
    @Default(false) bool isVegetarian,
    @Default(false) bool isVegan,
    @Default(false) bool isGlutenFree,
    @Default(false) bool hasAllergenInfo,
    @Default(false) bool isExpiringSoon,
    @Default(false) bool isAlmostSoldOut,
  }) = _SearchFilters;

  factory SearchFilters.fromJson(Map<String, dynamic> json) => _$SearchFiltersFromJson(json);

  const SearchFilters._();

  /// Check if any filters are applied
  bool get hasActiveFilters {
    return query.isNotEmpty ||
           maxDistance != null ||
           minDiscount != null ||
           maxPrice != null ||
           minPrice != null ||
           cuisineTypes.isNotEmpty ||
           sortBy != SearchSortBy.relevance ||
           isVegetarian ||
           isVegan ||
           isGlutenFree ||
           hasAllergenInfo ||
           isExpiringSoon ||
           isAlmostSoldOut;
  }

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (query.isNotEmpty) count++;
    if (maxDistance != null) count++;
    if (minDiscount != null) count++;
    if (maxPrice != null) count++;
    if (minPrice != null) count++;
    if (cuisineTypes.isNotEmpty) count++;
    if (sortBy != SearchSortBy.relevance) count++;
    if (isVegetarian) count++;
    if (isVegan) count++;
    if (isGlutenFree) count++;
    if (hasAllergenInfo) count++;
    if (isExpiringSoon) count++;
    if (isAlmostSoldOut) count++;
    return count;
  }

  /// Clear all filters
  SearchFilters get cleared => const SearchFilters();

  /// Quick filters for common use cases
  static SearchFilters nearbyDeals({double? maxDistance}) => SearchFilters(
    maxDistance: maxDistance ?? 5.0,
    sortBy: SearchSortBy.distance,
  );

  static SearchFilters highDiscounts({double? minDiscount}) => SearchFilters(
    minDiscount: minDiscount ?? 30.0,
    sortBy: SearchSortBy.discount,
  );

  static SearchFilters expiringSoon() => const SearchFilters(
    isExpiringSoon: true,
    sortBy: SearchSortBy.expiringSoon,
  );

  static SearchFilters budget({double? maxPrice}) => SearchFilters(
    maxPrice: maxPrice ?? 10.0,
    sortBy: SearchSortBy.priceLowToHigh,
  );

  static SearchFilters vegetarian() => const SearchFilters(
    isVegetarian: true,
    sortBy: SearchSortBy.relevance,
  );
}