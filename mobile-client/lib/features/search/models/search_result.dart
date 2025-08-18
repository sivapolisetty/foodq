import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/business.dart';

part 'search_result.freezed.dart';
part 'search_result.g.dart';

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required List<Deal> deals,
    required List<Business> businesses,
    @Default(0) int totalCount,
    @Default(0) int dealsCount,
    @Default(0) int businessesCount,
    @Default(false) bool hasMore,
    @Default(null) String? nextPageToken,
    @Default(null) String? query,
    @Default(null) double? searchLatitude,
    @Default(null) double? searchLongitude,
    @Default(null) Duration? searchDuration,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);

  const SearchResult._();

  /// Check if there are any results
  bool get hasResults => deals.isNotEmpty || businesses.isNotEmpty;

  /// Check if search was empty
  bool get isEmpty => !hasResults;

  /// Get all results as a mixed list (for displaying in a single list)
  List<SearchResultItem> get allResults {
    final List<SearchResultItem> results = [];
    
    // Add deals first
    for (final deal in deals) {
      results.add(SearchResultItem.deal(deal));
    }
    
    // Add businesses
    for (final business in businesses) {
      results.add(SearchResultItem.business(business));
    }
    
    return results;
  }

  /// Get summary statistics
  String get summaryText {
    if (isEmpty) {
      return query != null && query!.isNotEmpty
          ? 'No results found for "$query"'
          : 'No results found';
    }
    
    final List<String> parts = [];
    if (dealsCount > 0) {
      parts.add('$dealsCount deal${dealsCount == 1 ? '' : 's'}');
    }
    if (businessesCount > 0) {
      parts.add('$businessesCount restaurant${businessesCount == 1 ? '' : 's'}');
    }
    
    return parts.join(' and ');
  }
}

/// Union type for search result items
@freezed
class SearchResultItem with _$SearchResultItem {
  const factory SearchResultItem.deal(Deal deal) = SearchResultDeal;
  const factory SearchResultItem.business(Business business) = SearchResultBusiness;

  const SearchResultItem._();

  /// Get the title for display
  String get title => when(
    deal: (deal) => deal.title,
    business: (business) => business.name,
  );

  /// Get the subtitle for display
  String get subtitle => when(
    deal: (deal) => deal.description ?? '',
    business: (business) => business.category ?? business.address,
  );

  /// Get the distance if available
  double? get distance => when(
    deal: (deal) => null, // Distance would be calculated from business location
    business: (business) => null, // Would be calculated from user location
  );
}

/// Pagination helper for search results
@freezed
class SearchPagination with _$SearchPagination {
  const factory SearchPagination({
    @Default(0) int page,
    @Default(20) int limit,
    @Default(0) int offset,
    @Default(false) bool hasMore,
    @Default(null) String? nextPageToken,
  }) = _SearchPagination;

  factory SearchPagination.fromJson(Map<String, dynamic> json) => _$SearchPaginationFromJson(json);

  const SearchPagination._();

  /// Get next page pagination
  SearchPagination get nextPage => copyWith(
    page: page + 1,
    offset: offset + limit,
  );

  /// Reset to first page
  SearchPagination get firstPage => copyWith(
    page: 0,
    offset: 0,
  );
}