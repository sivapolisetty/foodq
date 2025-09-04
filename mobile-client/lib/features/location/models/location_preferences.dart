class LocationPreferences {
  final double searchRadiusMiles;
  final String lastKnownAddress;
  final double? lastKnownLatitude;
  final double? lastKnownLongitude;
  final bool autoDetectLocation;

  const LocationPreferences({
    this.searchRadiusMiles = 30.0, // Default 30 miles
    this.lastKnownAddress = '',
    this.lastKnownLatitude,
    this.lastKnownLongitude,
    this.autoDetectLocation = true,
  });

  LocationPreferences copyWith({
    double? searchRadiusMiles,
    String? lastKnownAddress,
    double? lastKnownLatitude,
    double? lastKnownLongitude,
    bool? autoDetectLocation,
  }) {
    return LocationPreferences(
      searchRadiusMiles: searchRadiusMiles ?? this.searchRadiusMiles,
      lastKnownAddress: lastKnownAddress ?? this.lastKnownAddress,
      lastKnownLatitude: lastKnownLatitude ?? this.lastKnownLatitude,
      lastKnownLongitude: lastKnownLongitude ?? this.lastKnownLongitude,
      autoDetectLocation: autoDetectLocation ?? this.autoDetectLocation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'searchRadiusMiles': searchRadiusMiles,
      'lastKnownAddress': lastKnownAddress,
      'lastKnownLatitude': lastKnownLatitude,
      'lastKnownLongitude': lastKnownLongitude,
      'autoDetectLocation': autoDetectLocation,
    };
  }

  factory LocationPreferences.fromJson(Map<String, dynamic> json) {
    return LocationPreferences(
      searchRadiusMiles: (json['searchRadiusMiles'] as num?)?.toDouble() ?? 30.0,
      lastKnownAddress: json['lastKnownAddress'] as String? ?? '',
      lastKnownLatitude: (json['lastKnownLatitude'] as num?)?.toDouble(),
      lastKnownLongitude: (json['lastKnownLongitude'] as num?)?.toDouble(),
      autoDetectLocation: json['autoDetectLocation'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'LocationPreferences(searchRadiusMiles: $searchRadiusMiles, '
           'lastKnownAddress: $lastKnownAddress, autoDetectLocation: $autoDetectLocation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationPreferences &&
        other.searchRadiusMiles == searchRadiusMiles &&
        other.lastKnownAddress == lastKnownAddress &&
        other.lastKnownLatitude == lastKnownLatitude &&
        other.lastKnownLongitude == lastKnownLongitude &&
        other.autoDetectLocation == autoDetectLocation;
  }

  @override
  int get hashCode {
    return searchRadiusMiles.hashCode ^
        lastKnownAddress.hashCode ^
        lastKnownLatitude.hashCode ^
        lastKnownLongitude.hashCode ^
        autoDetectLocation.hashCode;
  }
}