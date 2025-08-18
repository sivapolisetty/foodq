// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) {
  return _SearchResult.fromJson(json);
}

/// @nodoc
mixin _$SearchResult {
  List<Deal> get deals => throw _privateConstructorUsedError;
  List<Business> get businesses => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get dealsCount => throw _privateConstructorUsedError;
  int get businessesCount => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String? get nextPageToken => throw _privateConstructorUsedError;
  String? get query => throw _privateConstructorUsedError;
  double? get searchLatitude => throw _privateConstructorUsedError;
  double? get searchLongitude => throw _privateConstructorUsedError;
  Duration? get searchDuration => throw _privateConstructorUsedError;

  /// Serializes this SearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultCopyWith<SearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultCopyWith<$Res> {
  factory $SearchResultCopyWith(
          SearchResult value, $Res Function(SearchResult) then) =
      _$SearchResultCopyWithImpl<$Res, SearchResult>;
  @useResult
  $Res call(
      {List<Deal> deals,
      List<Business> businesses,
      int totalCount,
      int dealsCount,
      int businessesCount,
      bool hasMore,
      String? nextPageToken,
      String? query,
      double? searchLatitude,
      double? searchLongitude,
      Duration? searchDuration});
}

/// @nodoc
class _$SearchResultCopyWithImpl<$Res, $Val extends SearchResult>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deals = null,
    Object? businesses = null,
    Object? totalCount = null,
    Object? dealsCount = null,
    Object? businessesCount = null,
    Object? hasMore = null,
    Object? nextPageToken = freezed,
    Object? query = freezed,
    Object? searchLatitude = freezed,
    Object? searchLongitude = freezed,
    Object? searchDuration = freezed,
  }) {
    return _then(_value.copyWith(
      deals: null == deals
          ? _value.deals
          : deals // ignore: cast_nullable_to_non_nullable
              as List<Deal>,
      businesses: null == businesses
          ? _value.businesses
          : businesses // ignore: cast_nullable_to_non_nullable
              as List<Business>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      dealsCount: null == dealsCount
          ? _value.dealsCount
          : dealsCount // ignore: cast_nullable_to_non_nullable
              as int,
      businessesCount: null == businessesCount
          ? _value.businessesCount
          : businessesCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextPageToken: freezed == nextPageToken
          ? _value.nextPageToken
          : nextPageToken // ignore: cast_nullable_to_non_nullable
              as String?,
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      searchLatitude: freezed == searchLatitude
          ? _value.searchLatitude
          : searchLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      searchLongitude: freezed == searchLongitude
          ? _value.searchLongitude
          : searchLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      searchDuration: freezed == searchDuration
          ? _value.searchDuration
          : searchDuration // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchResultImplCopyWith<$Res>
    implements $SearchResultCopyWith<$Res> {
  factory _$$SearchResultImplCopyWith(
          _$SearchResultImpl value, $Res Function(_$SearchResultImpl) then) =
      __$$SearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Deal> deals,
      List<Business> businesses,
      int totalCount,
      int dealsCount,
      int businessesCount,
      bool hasMore,
      String? nextPageToken,
      String? query,
      double? searchLatitude,
      double? searchLongitude,
      Duration? searchDuration});
}

/// @nodoc
class __$$SearchResultImplCopyWithImpl<$Res>
    extends _$SearchResultCopyWithImpl<$Res, _$SearchResultImpl>
    implements _$$SearchResultImplCopyWith<$Res> {
  __$$SearchResultImplCopyWithImpl(
      _$SearchResultImpl _value, $Res Function(_$SearchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deals = null,
    Object? businesses = null,
    Object? totalCount = null,
    Object? dealsCount = null,
    Object? businessesCount = null,
    Object? hasMore = null,
    Object? nextPageToken = freezed,
    Object? query = freezed,
    Object? searchLatitude = freezed,
    Object? searchLongitude = freezed,
    Object? searchDuration = freezed,
  }) {
    return _then(_$SearchResultImpl(
      deals: null == deals
          ? _value._deals
          : deals // ignore: cast_nullable_to_non_nullable
              as List<Deal>,
      businesses: null == businesses
          ? _value._businesses
          : businesses // ignore: cast_nullable_to_non_nullable
              as List<Business>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      dealsCount: null == dealsCount
          ? _value.dealsCount
          : dealsCount // ignore: cast_nullable_to_non_nullable
              as int,
      businessesCount: null == businessesCount
          ? _value.businessesCount
          : businessesCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextPageToken: freezed == nextPageToken
          ? _value.nextPageToken
          : nextPageToken // ignore: cast_nullable_to_non_nullable
              as String?,
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      searchLatitude: freezed == searchLatitude
          ? _value.searchLatitude
          : searchLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      searchLongitude: freezed == searchLongitude
          ? _value.searchLongitude
          : searchLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      searchDuration: freezed == searchDuration
          ? _value.searchDuration
          : searchDuration // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResultImpl extends _SearchResult {
  const _$SearchResultImpl(
      {required final List<Deal> deals,
      required final List<Business> businesses,
      this.totalCount = 0,
      this.dealsCount = 0,
      this.businessesCount = 0,
      this.hasMore = false,
      this.nextPageToken = null,
      this.query = null,
      this.searchLatitude = null,
      this.searchLongitude = null,
      this.searchDuration = null})
      : _deals = deals,
        _businesses = businesses,
        super._();

  factory _$SearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResultImplFromJson(json);

  final List<Deal> _deals;
  @override
  List<Deal> get deals {
    if (_deals is EqualUnmodifiableListView) return _deals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deals);
  }

  final List<Business> _businesses;
  @override
  List<Business> get businesses {
    if (_businesses is EqualUnmodifiableListView) return _businesses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_businesses);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final int dealsCount;
  @override
  @JsonKey()
  final int businessesCount;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final String? nextPageToken;
  @override
  @JsonKey()
  final String? query;
  @override
  @JsonKey()
  final double? searchLatitude;
  @override
  @JsonKey()
  final double? searchLongitude;
  @override
  @JsonKey()
  final Duration? searchDuration;

  @override
  String toString() {
    return 'SearchResult(deals: $deals, businesses: $businesses, totalCount: $totalCount, dealsCount: $dealsCount, businessesCount: $businessesCount, hasMore: $hasMore, nextPageToken: $nextPageToken, query: $query, searchLatitude: $searchLatitude, searchLongitude: $searchLongitude, searchDuration: $searchDuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultImpl &&
            const DeepCollectionEquality().equals(other._deals, _deals) &&
            const DeepCollectionEquality()
                .equals(other._businesses, _businesses) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.dealsCount, dealsCount) ||
                other.dealsCount == dealsCount) &&
            (identical(other.businessesCount, businessesCount) ||
                other.businessesCount == businessesCount) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.nextPageToken, nextPageToken) ||
                other.nextPageToken == nextPageToken) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.searchLatitude, searchLatitude) ||
                other.searchLatitude == searchLatitude) &&
            (identical(other.searchLongitude, searchLongitude) ||
                other.searchLongitude == searchLongitude) &&
            (identical(other.searchDuration, searchDuration) ||
                other.searchDuration == searchDuration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_deals),
      const DeepCollectionEquality().hash(_businesses),
      totalCount,
      dealsCount,
      businessesCount,
      hasMore,
      nextPageToken,
      query,
      searchLatitude,
      searchLongitude,
      searchDuration);

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      __$$SearchResultImplCopyWithImpl<_$SearchResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResultImplToJson(
      this,
    );
  }
}

abstract class _SearchResult extends SearchResult {
  const factory _SearchResult(
      {required final List<Deal> deals,
      required final List<Business> businesses,
      final int totalCount,
      final int dealsCount,
      final int businessesCount,
      final bool hasMore,
      final String? nextPageToken,
      final String? query,
      final double? searchLatitude,
      final double? searchLongitude,
      final Duration? searchDuration}) = _$SearchResultImpl;
  const _SearchResult._() : super._();

  factory _SearchResult.fromJson(Map<String, dynamic> json) =
      _$SearchResultImpl.fromJson;

  @override
  List<Deal> get deals;
  @override
  List<Business> get businesses;
  @override
  int get totalCount;
  @override
  int get dealsCount;
  @override
  int get businessesCount;
  @override
  bool get hasMore;
  @override
  String? get nextPageToken;
  @override
  String? get query;
  @override
  double? get searchLatitude;
  @override
  double? get searchLongitude;
  @override
  Duration? get searchDuration;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchResultItem {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Deal deal) deal,
    required TResult Function(Business business) business,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Deal deal)? deal,
    TResult? Function(Business business)? business,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Deal deal)? deal,
    TResult Function(Business business)? business,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchResultDeal value) deal,
    required TResult Function(SearchResultBusiness value) business,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchResultDeal value)? deal,
    TResult? Function(SearchResultBusiness value)? business,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchResultDeal value)? deal,
    TResult Function(SearchResultBusiness value)? business,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultItemCopyWith<$Res> {
  factory $SearchResultItemCopyWith(
          SearchResultItem value, $Res Function(SearchResultItem) then) =
      _$SearchResultItemCopyWithImpl<$Res, SearchResultItem>;
}

/// @nodoc
class _$SearchResultItemCopyWithImpl<$Res, $Val extends SearchResultItem>
    implements $SearchResultItemCopyWith<$Res> {
  _$SearchResultItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SearchResultDealImplCopyWith<$Res> {
  factory _$$SearchResultDealImplCopyWith(_$SearchResultDealImpl value,
          $Res Function(_$SearchResultDealImpl) then) =
      __$$SearchResultDealImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Deal deal});

  $DealCopyWith<$Res> get deal;
}

/// @nodoc
class __$$SearchResultDealImplCopyWithImpl<$Res>
    extends _$SearchResultItemCopyWithImpl<$Res, _$SearchResultDealImpl>
    implements _$$SearchResultDealImplCopyWith<$Res> {
  __$$SearchResultDealImplCopyWithImpl(_$SearchResultDealImpl _value,
      $Res Function(_$SearchResultDealImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deal = null,
  }) {
    return _then(_$SearchResultDealImpl(
      null == deal
          ? _value.deal
          : deal // ignore: cast_nullable_to_non_nullable
              as Deal,
    ));
  }

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DealCopyWith<$Res> get deal {
    return $DealCopyWith<$Res>(_value.deal, (value) {
      return _then(_value.copyWith(deal: value));
    });
  }
}

/// @nodoc

class _$SearchResultDealImpl extends SearchResultDeal {
  const _$SearchResultDealImpl(this.deal) : super._();

  @override
  final Deal deal;

  @override
  String toString() {
    return 'SearchResultItem.deal(deal: $deal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultDealImpl &&
            (identical(other.deal, deal) || other.deal == deal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deal);

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultDealImplCopyWith<_$SearchResultDealImpl> get copyWith =>
      __$$SearchResultDealImplCopyWithImpl<_$SearchResultDealImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Deal deal) deal,
    required TResult Function(Business business) business,
  }) {
    return deal(this.deal);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Deal deal)? deal,
    TResult? Function(Business business)? business,
  }) {
    return deal?.call(this.deal);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Deal deal)? deal,
    TResult Function(Business business)? business,
    required TResult orElse(),
  }) {
    if (deal != null) {
      return deal(this.deal);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchResultDeal value) deal,
    required TResult Function(SearchResultBusiness value) business,
  }) {
    return deal(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchResultDeal value)? deal,
    TResult? Function(SearchResultBusiness value)? business,
  }) {
    return deal?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchResultDeal value)? deal,
    TResult Function(SearchResultBusiness value)? business,
    required TResult orElse(),
  }) {
    if (deal != null) {
      return deal(this);
    }
    return orElse();
  }
}

abstract class SearchResultDeal extends SearchResultItem {
  const factory SearchResultDeal(final Deal deal) = _$SearchResultDealImpl;
  const SearchResultDeal._() : super._();

  Deal get deal;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultDealImplCopyWith<_$SearchResultDealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SearchResultBusinessImplCopyWith<$Res> {
  factory _$$SearchResultBusinessImplCopyWith(_$SearchResultBusinessImpl value,
          $Res Function(_$SearchResultBusinessImpl) then) =
      __$$SearchResultBusinessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Business business});

  $BusinessCopyWith<$Res> get business;
}

/// @nodoc
class __$$SearchResultBusinessImplCopyWithImpl<$Res>
    extends _$SearchResultItemCopyWithImpl<$Res, _$SearchResultBusinessImpl>
    implements _$$SearchResultBusinessImplCopyWith<$Res> {
  __$$SearchResultBusinessImplCopyWithImpl(_$SearchResultBusinessImpl _value,
      $Res Function(_$SearchResultBusinessImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? business = null,
  }) {
    return _then(_$SearchResultBusinessImpl(
      null == business
          ? _value.business
          : business // ignore: cast_nullable_to_non_nullable
              as Business,
    ));
  }

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BusinessCopyWith<$Res> get business {
    return $BusinessCopyWith<$Res>(_value.business, (value) {
      return _then(_value.copyWith(business: value));
    });
  }
}

/// @nodoc

class _$SearchResultBusinessImpl extends SearchResultBusiness {
  const _$SearchResultBusinessImpl(this.business) : super._();

  @override
  final Business business;

  @override
  String toString() {
    return 'SearchResultItem.business(business: $business)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultBusinessImpl &&
            (identical(other.business, business) ||
                other.business == business));
  }

  @override
  int get hashCode => Object.hash(runtimeType, business);

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultBusinessImplCopyWith<_$SearchResultBusinessImpl>
      get copyWith =>
          __$$SearchResultBusinessImplCopyWithImpl<_$SearchResultBusinessImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Deal deal) deal,
    required TResult Function(Business business) business,
  }) {
    return business(this.business);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Deal deal)? deal,
    TResult? Function(Business business)? business,
  }) {
    return business?.call(this.business);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Deal deal)? deal,
    TResult Function(Business business)? business,
    required TResult orElse(),
  }) {
    if (business != null) {
      return business(this.business);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchResultDeal value) deal,
    required TResult Function(SearchResultBusiness value) business,
  }) {
    return business(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchResultDeal value)? deal,
    TResult? Function(SearchResultBusiness value)? business,
  }) {
    return business?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchResultDeal value)? deal,
    TResult Function(SearchResultBusiness value)? business,
    required TResult orElse(),
  }) {
    if (business != null) {
      return business(this);
    }
    return orElse();
  }
}

abstract class SearchResultBusiness extends SearchResultItem {
  const factory SearchResultBusiness(final Business business) =
      _$SearchResultBusinessImpl;
  const SearchResultBusiness._() : super._();

  Business get business;

  /// Create a copy of SearchResultItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultBusinessImplCopyWith<_$SearchResultBusinessImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SearchPagination _$SearchPaginationFromJson(Map<String, dynamic> json) {
  return _SearchPagination.fromJson(json);
}

/// @nodoc
mixin _$SearchPagination {
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get offset => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String? get nextPageToken => throw _privateConstructorUsedError;

  /// Serializes this SearchPagination to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchPagination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchPaginationCopyWith<SearchPagination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchPaginationCopyWith<$Res> {
  factory $SearchPaginationCopyWith(
          SearchPagination value, $Res Function(SearchPagination) then) =
      _$SearchPaginationCopyWithImpl<$Res, SearchPagination>;
  @useResult
  $Res call(
      {int page, int limit, int offset, bool hasMore, String? nextPageToken});
}

/// @nodoc
class _$SearchPaginationCopyWithImpl<$Res, $Val extends SearchPagination>
    implements $SearchPaginationCopyWith<$Res> {
  _$SearchPaginationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchPagination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? limit = null,
    Object? offset = null,
    Object? hasMore = null,
    Object? nextPageToken = freezed,
  }) {
    return _then(_value.copyWith(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextPageToken: freezed == nextPageToken
          ? _value.nextPageToken
          : nextPageToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchPaginationImplCopyWith<$Res>
    implements $SearchPaginationCopyWith<$Res> {
  factory _$$SearchPaginationImplCopyWith(_$SearchPaginationImpl value,
          $Res Function(_$SearchPaginationImpl) then) =
      __$$SearchPaginationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int page, int limit, int offset, bool hasMore, String? nextPageToken});
}

/// @nodoc
class __$$SearchPaginationImplCopyWithImpl<$Res>
    extends _$SearchPaginationCopyWithImpl<$Res, _$SearchPaginationImpl>
    implements _$$SearchPaginationImplCopyWith<$Res> {
  __$$SearchPaginationImplCopyWithImpl(_$SearchPaginationImpl _value,
      $Res Function(_$SearchPaginationImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchPagination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? limit = null,
    Object? offset = null,
    Object? hasMore = null,
    Object? nextPageToken = freezed,
  }) {
    return _then(_$SearchPaginationImpl(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      nextPageToken: freezed == nextPageToken
          ? _value.nextPageToken
          : nextPageToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchPaginationImpl extends _SearchPagination {
  const _$SearchPaginationImpl(
      {this.page = 0,
      this.limit = 20,
      this.offset = 0,
      this.hasMore = false,
      this.nextPageToken = null})
      : super._();

  factory _$SearchPaginationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchPaginationImplFromJson(json);

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final int offset;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final String? nextPageToken;

  @override
  String toString() {
    return 'SearchPagination(page: $page, limit: $limit, offset: $offset, hasMore: $hasMore, nextPageToken: $nextPageToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchPaginationImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.nextPageToken, nextPageToken) ||
                other.nextPageToken == nextPageToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, page, limit, offset, hasMore, nextPageToken);

  /// Create a copy of SearchPagination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchPaginationImplCopyWith<_$SearchPaginationImpl> get copyWith =>
      __$$SearchPaginationImplCopyWithImpl<_$SearchPaginationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchPaginationImplToJson(
      this,
    );
  }
}

abstract class _SearchPagination extends SearchPagination {
  const factory _SearchPagination(
      {final int page,
      final int limit,
      final int offset,
      final bool hasMore,
      final String? nextPageToken}) = _$SearchPaginationImpl;
  const _SearchPagination._() : super._();

  factory _SearchPagination.fromJson(Map<String, dynamic> json) =
      _$SearchPaginationImpl.fromJson;

  @override
  int get page;
  @override
  int get limit;
  @override
  int get offset;
  @override
  bool get hasMore;
  @override
  String? get nextPageToken;

  /// Create a copy of SearchPagination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchPaginationImplCopyWith<_$SearchPaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
