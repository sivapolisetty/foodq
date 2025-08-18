// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SearchFilters _$SearchFiltersFromJson(Map<String, dynamic> json) {
  return _SearchFilters.fromJson(json);
}

/// @nodoc
mixin _$SearchFilters {
  String get query => throw _privateConstructorUsedError;
  double? get maxDistance => throw _privateConstructorUsedError;
  double? get minDiscount => throw _privateConstructorUsedError;
  double? get maxPrice => throw _privateConstructorUsedError;
  double? get minPrice => throw _privateConstructorUsedError;
  List<String> get cuisineTypes => throw _privateConstructorUsedError;
  SearchSortBy get sortBy => throw _privateConstructorUsedError;
  bool get isVegetarian => throw _privateConstructorUsedError;
  bool get isVegan => throw _privateConstructorUsedError;
  bool get isGlutenFree => throw _privateConstructorUsedError;
  bool get hasAllergenInfo => throw _privateConstructorUsedError;
  bool get isExpiringSoon => throw _privateConstructorUsedError;
  bool get isAlmostSoldOut => throw _privateConstructorUsedError;

  /// Serializes this SearchFilters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchFiltersCopyWith<SearchFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchFiltersCopyWith<$Res> {
  factory $SearchFiltersCopyWith(
          SearchFilters value, $Res Function(SearchFilters) then) =
      _$SearchFiltersCopyWithImpl<$Res, SearchFilters>;
  @useResult
  $Res call(
      {String query,
      double? maxDistance,
      double? minDiscount,
      double? maxPrice,
      double? minPrice,
      List<String> cuisineTypes,
      SearchSortBy sortBy,
      bool isVegetarian,
      bool isVegan,
      bool isGlutenFree,
      bool hasAllergenInfo,
      bool isExpiringSoon,
      bool isAlmostSoldOut});
}

/// @nodoc
class _$SearchFiltersCopyWithImpl<$Res, $Val extends SearchFilters>
    implements $SearchFiltersCopyWith<$Res> {
  _$SearchFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? maxDistance = freezed,
    Object? minDiscount = freezed,
    Object? maxPrice = freezed,
    Object? minPrice = freezed,
    Object? cuisineTypes = null,
    Object? sortBy = null,
    Object? isVegetarian = null,
    Object? isVegan = null,
    Object? isGlutenFree = null,
    Object? hasAllergenInfo = null,
    Object? isExpiringSoon = null,
    Object? isAlmostSoldOut = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      maxDistance: freezed == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double?,
      minDiscount: freezed == minDiscount
          ? _value.minDiscount
          : minDiscount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      cuisineTypes: null == cuisineTypes
          ? _value.cuisineTypes
          : cuisineTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SearchSortBy,
      isVegetarian: null == isVegetarian
          ? _value.isVegetarian
          : isVegetarian // ignore: cast_nullable_to_non_nullable
              as bool,
      isVegan: null == isVegan
          ? _value.isVegan
          : isVegan // ignore: cast_nullable_to_non_nullable
              as bool,
      isGlutenFree: null == isGlutenFree
          ? _value.isGlutenFree
          : isGlutenFree // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAllergenInfo: null == hasAllergenInfo
          ? _value.hasAllergenInfo
          : hasAllergenInfo // ignore: cast_nullable_to_non_nullable
              as bool,
      isExpiringSoon: null == isExpiringSoon
          ? _value.isExpiringSoon
          : isExpiringSoon // ignore: cast_nullable_to_non_nullable
              as bool,
      isAlmostSoldOut: null == isAlmostSoldOut
          ? _value.isAlmostSoldOut
          : isAlmostSoldOut // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchFiltersImplCopyWith<$Res>
    implements $SearchFiltersCopyWith<$Res> {
  factory _$$SearchFiltersImplCopyWith(
          _$SearchFiltersImpl value, $Res Function(_$SearchFiltersImpl) then) =
      __$$SearchFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      double? maxDistance,
      double? minDiscount,
      double? maxPrice,
      double? minPrice,
      List<String> cuisineTypes,
      SearchSortBy sortBy,
      bool isVegetarian,
      bool isVegan,
      bool isGlutenFree,
      bool hasAllergenInfo,
      bool isExpiringSoon,
      bool isAlmostSoldOut});
}

/// @nodoc
class __$$SearchFiltersImplCopyWithImpl<$Res>
    extends _$SearchFiltersCopyWithImpl<$Res, _$SearchFiltersImpl>
    implements _$$SearchFiltersImplCopyWith<$Res> {
  __$$SearchFiltersImplCopyWithImpl(
      _$SearchFiltersImpl _value, $Res Function(_$SearchFiltersImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? maxDistance = freezed,
    Object? minDiscount = freezed,
    Object? maxPrice = freezed,
    Object? minPrice = freezed,
    Object? cuisineTypes = null,
    Object? sortBy = null,
    Object? isVegetarian = null,
    Object? isVegan = null,
    Object? isGlutenFree = null,
    Object? hasAllergenInfo = null,
    Object? isExpiringSoon = null,
    Object? isAlmostSoldOut = null,
  }) {
    return _then(_$SearchFiltersImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      maxDistance: freezed == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double?,
      minDiscount: freezed == minDiscount
          ? _value.minDiscount
          : minDiscount // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      cuisineTypes: null == cuisineTypes
          ? _value._cuisineTypes
          : cuisineTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SearchSortBy,
      isVegetarian: null == isVegetarian
          ? _value.isVegetarian
          : isVegetarian // ignore: cast_nullable_to_non_nullable
              as bool,
      isVegan: null == isVegan
          ? _value.isVegan
          : isVegan // ignore: cast_nullable_to_non_nullable
              as bool,
      isGlutenFree: null == isGlutenFree
          ? _value.isGlutenFree
          : isGlutenFree // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAllergenInfo: null == hasAllergenInfo
          ? _value.hasAllergenInfo
          : hasAllergenInfo // ignore: cast_nullable_to_non_nullable
              as bool,
      isExpiringSoon: null == isExpiringSoon
          ? _value.isExpiringSoon
          : isExpiringSoon // ignore: cast_nullable_to_non_nullable
              as bool,
      isAlmostSoldOut: null == isAlmostSoldOut
          ? _value.isAlmostSoldOut
          : isAlmostSoldOut // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchFiltersImpl extends _SearchFilters {
  const _$SearchFiltersImpl(
      {this.query = '',
      this.maxDistance = null,
      this.minDiscount = null,
      this.maxPrice = null,
      this.minPrice = null,
      final List<String> cuisineTypes = const [],
      this.sortBy = SearchSortBy.relevance,
      this.isVegetarian = false,
      this.isVegan = false,
      this.isGlutenFree = false,
      this.hasAllergenInfo = false,
      this.isExpiringSoon = false,
      this.isAlmostSoldOut = false})
      : _cuisineTypes = cuisineTypes,
        super._();

  factory _$SearchFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchFiltersImplFromJson(json);

  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final double? maxDistance;
  @override
  @JsonKey()
  final double? minDiscount;
  @override
  @JsonKey()
  final double? maxPrice;
  @override
  @JsonKey()
  final double? minPrice;
  final List<String> _cuisineTypes;
  @override
  @JsonKey()
  List<String> get cuisineTypes {
    if (_cuisineTypes is EqualUnmodifiableListView) return _cuisineTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cuisineTypes);
  }

  @override
  @JsonKey()
  final SearchSortBy sortBy;
  @override
  @JsonKey()
  final bool isVegetarian;
  @override
  @JsonKey()
  final bool isVegan;
  @override
  @JsonKey()
  final bool isGlutenFree;
  @override
  @JsonKey()
  final bool hasAllergenInfo;
  @override
  @JsonKey()
  final bool isExpiringSoon;
  @override
  @JsonKey()
  final bool isAlmostSoldOut;

  @override
  String toString() {
    return 'SearchFilters(query: $query, maxDistance: $maxDistance, minDiscount: $minDiscount, maxPrice: $maxPrice, minPrice: $minPrice, cuisineTypes: $cuisineTypes, sortBy: $sortBy, isVegetarian: $isVegetarian, isVegan: $isVegan, isGlutenFree: $isGlutenFree, hasAllergenInfo: $hasAllergenInfo, isExpiringSoon: $isExpiringSoon, isAlmostSoldOut: $isAlmostSoldOut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchFiltersImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.maxDistance, maxDistance) ||
                other.maxDistance == maxDistance) &&
            (identical(other.minDiscount, minDiscount) ||
                other.minDiscount == minDiscount) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            const DeepCollectionEquality()
                .equals(other._cuisineTypes, _cuisineTypes) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.isVegetarian, isVegetarian) ||
                other.isVegetarian == isVegetarian) &&
            (identical(other.isVegan, isVegan) || other.isVegan == isVegan) &&
            (identical(other.isGlutenFree, isGlutenFree) ||
                other.isGlutenFree == isGlutenFree) &&
            (identical(other.hasAllergenInfo, hasAllergenInfo) ||
                other.hasAllergenInfo == hasAllergenInfo) &&
            (identical(other.isExpiringSoon, isExpiringSoon) ||
                other.isExpiringSoon == isExpiringSoon) &&
            (identical(other.isAlmostSoldOut, isAlmostSoldOut) ||
                other.isAlmostSoldOut == isAlmostSoldOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      maxDistance,
      minDiscount,
      maxPrice,
      minPrice,
      const DeepCollectionEquality().hash(_cuisineTypes),
      sortBy,
      isVegetarian,
      isVegan,
      isGlutenFree,
      hasAllergenInfo,
      isExpiringSoon,
      isAlmostSoldOut);

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchFiltersImplCopyWith<_$SearchFiltersImpl> get copyWith =>
      __$$SearchFiltersImplCopyWithImpl<_$SearchFiltersImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchFiltersImplToJson(
      this,
    );
  }
}

abstract class _SearchFilters extends SearchFilters {
  const factory _SearchFilters(
      {final String query,
      final double? maxDistance,
      final double? minDiscount,
      final double? maxPrice,
      final double? minPrice,
      final List<String> cuisineTypes,
      final SearchSortBy sortBy,
      final bool isVegetarian,
      final bool isVegan,
      final bool isGlutenFree,
      final bool hasAllergenInfo,
      final bool isExpiringSoon,
      final bool isAlmostSoldOut}) = _$SearchFiltersImpl;
  const _SearchFilters._() : super._();

  factory _SearchFilters.fromJson(Map<String, dynamic> json) =
      _$SearchFiltersImpl.fromJson;

  @override
  String get query;
  @override
  double? get maxDistance;
  @override
  double? get minDiscount;
  @override
  double? get maxPrice;
  @override
  double? get minPrice;
  @override
  List<String> get cuisineTypes;
  @override
  SearchSortBy get sortBy;
  @override
  bool get isVegetarian;
  @override
  bool get isVegan;
  @override
  bool get isGlutenFree;
  @override
  bool get hasAllergenInfo;
  @override
  bool get isExpiringSoon;
  @override
  bool get isAlmostSoldOut;

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchFiltersImplCopyWith<_$SearchFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
