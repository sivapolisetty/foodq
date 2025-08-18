// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchFiltersImpl _$$SearchFiltersImplFromJson(Map<String, dynamic> json) =>
    _$SearchFiltersImpl(
      query: json['query'] as String? ?? '',
      maxDistance: (json['maxDistance'] as num?)?.toDouble() ?? null,
      minDiscount: (json['minDiscount'] as num?)?.toDouble() ?? null,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? null,
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? null,
      cuisineTypes: (json['cuisineTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sortBy: $enumDecodeNullable(_$SearchSortByEnumMap, json['sortBy']) ??
          SearchSortBy.relevance,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
      isGlutenFree: json['isGlutenFree'] as bool? ?? false,
      hasAllergenInfo: json['hasAllergenInfo'] as bool? ?? false,
      isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
      isAlmostSoldOut: json['isAlmostSoldOut'] as bool? ?? false,
    );

Map<String, dynamic> _$$SearchFiltersImplToJson(_$SearchFiltersImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'maxDistance': instance.maxDistance,
      'minDiscount': instance.minDiscount,
      'maxPrice': instance.maxPrice,
      'minPrice': instance.minPrice,
      'cuisineTypes': instance.cuisineTypes,
      'sortBy': _$SearchSortByEnumMap[instance.sortBy]!,
      'isVegetarian': instance.isVegetarian,
      'isVegan': instance.isVegan,
      'isGlutenFree': instance.isGlutenFree,
      'hasAllergenInfo': instance.hasAllergenInfo,
      'isExpiringSoon': instance.isExpiringSoon,
      'isAlmostSoldOut': instance.isAlmostSoldOut,
    };

const _$SearchSortByEnumMap = {
  SearchSortBy.relevance: 'relevance',
  SearchSortBy.distance: 'distance',
  SearchSortBy.discount: 'discount',
  SearchSortBy.priceLowToHigh: 'price_low_to_high',
  SearchSortBy.priceHighToLow: 'price_high_to_low',
  SearchSortBy.newest: 'newest',
  SearchSortBy.expiringSoon: 'expiring_soon',
};
