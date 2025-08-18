// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchServiceHash() => r'fe447c2c5f127d3dd35ace144b30f71c2b2d2f67';

/// See also [searchService].
@ProviderFor(searchService)
final searchServiceProvider = AutoDisposeProvider<SearchService>.internal(
  searchService,
  name: r'searchServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchServiceRef = AutoDisposeProviderRef<SearchService>;
String _$trendingDealsHash() => r'616657aa647cd84b8f8974d10085bdc1b5e8fb63';

/// Quick access providers for commonly used searches
///
/// Copied from [trendingDeals].
@ProviderFor(trendingDeals)
final trendingDealsProvider = AutoDisposeFutureProvider<List<Deal>>.internal(
  trendingDeals,
  name: r'trendingDealsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trendingDealsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrendingDealsRef = AutoDisposeFutureProviderRef<List<Deal>>;
String _$expiringSoonDealsHash() => r'0a69c444d042f6c3e2c550c86fba44e2496438ba';

/// See also [expiringSoonDeals].
@ProviderFor(expiringSoonDeals)
final expiringSoonDealsProvider =
    AutoDisposeFutureProvider<List<Deal>>.internal(
  expiringSoonDeals,
  name: r'expiringSoonDealsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expiringSoonDealsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpiringSoonDealsRef = AutoDisposeFutureProviderRef<List<Deal>>;
String _$nearbyDealsHash() => r'f90a37957c07d5eca5aecf235c567bf462bbfdc1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [nearbyDeals].
@ProviderFor(nearbyDeals)
const nearbyDealsProvider = NearbyDealsFamily();

/// See also [nearbyDeals].
class NearbyDealsFamily extends Family<AsyncValue<List<Deal>>> {
  /// See also [nearbyDeals].
  const NearbyDealsFamily();

  /// See also [nearbyDeals].
  NearbyDealsProvider call({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) {
    return NearbyDealsProvider(
      latitude: latitude,
      longitude: longitude,
      radiusInKm: radiusInKm,
    );
  }

  @override
  NearbyDealsProvider getProviderOverride(
    covariant NearbyDealsProvider provider,
  ) {
    return call(
      latitude: provider.latitude,
      longitude: provider.longitude,
      radiusInKm: provider.radiusInKm,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'nearbyDealsProvider';
}

/// See also [nearbyDeals].
class NearbyDealsProvider extends AutoDisposeFutureProvider<List<Deal>> {
  /// See also [nearbyDeals].
  NearbyDealsProvider({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) : this._internal(
          (ref) => nearbyDeals(
            ref as NearbyDealsRef,
            latitude: latitude,
            longitude: longitude,
            radiusInKm: radiusInKm,
          ),
          from: nearbyDealsProvider,
          name: r'nearbyDealsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$nearbyDealsHash,
          dependencies: NearbyDealsFamily._dependencies,
          allTransitiveDependencies:
              NearbyDealsFamily._allTransitiveDependencies,
          latitude: latitude,
          longitude: longitude,
          radiusInKm: radiusInKm,
        );

  NearbyDealsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
  }) : super.internal();

  final double latitude;
  final double longitude;
  final double radiusInKm;

  @override
  Override overrideWith(
    FutureOr<List<Deal>> Function(NearbyDealsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NearbyDealsProvider._internal(
        (ref) => create(ref as NearbyDealsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Deal>> createElement() {
    return _NearbyDealsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyDealsProvider &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radiusInKm == radiusInKm;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, latitude.hashCode);
    hash = _SystemHash.combine(hash, longitude.hashCode);
    hash = _SystemHash.combine(hash, radiusInKm.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NearbyDealsRef on AutoDisposeFutureProviderRef<List<Deal>> {
  /// The parameter `latitude` of this provider.
  double get latitude;

  /// The parameter `longitude` of this provider.
  double get longitude;

  /// The parameter `radiusInKm` of this provider.
  double get radiusInKm;
}

class _NearbyDealsProviderElement
    extends AutoDisposeFutureProviderElement<List<Deal>> with NearbyDealsRef {
  _NearbyDealsProviderElement(super.provider);

  @override
  double get latitude => (origin as NearbyDealsProvider).latitude;
  @override
  double get longitude => (origin as NearbyDealsProvider).longitude;
  @override
  double get radiusInKm => (origin as NearbyDealsProvider).radiusInKm;
}

String _$searchNotifierHash() => r'84fd93444b700a13cd830471c1ab3764bfacf916';

/// See also [SearchNotifier].
@ProviderFor(SearchNotifier)
final searchNotifierProvider =
    AutoDisposeNotifierProvider<SearchNotifier, SearchResult>.internal(
  SearchNotifier.new,
  name: r'searchNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchNotifier = AutoDisposeNotifier<SearchResult>;
String _$searchFiltersNotifierHash() =>
    r'f590bdd28a77956dda4c5b4ea4e5284ad2df44e2';

/// See also [SearchFiltersNotifier].
@ProviderFor(SearchFiltersNotifier)
final searchFiltersNotifierProvider =
    AutoDisposeNotifierProvider<SearchFiltersNotifier, SearchFilters>.internal(
  SearchFiltersNotifier.new,
  name: r'searchFiltersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchFiltersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchFiltersNotifier = AutoDisposeNotifier<SearchFilters>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
