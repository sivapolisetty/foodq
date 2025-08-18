// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchResultImpl _$$SearchResultImplFromJson(Map<String, dynamic> json) =>
    _$SearchResultImpl(
      deals: (json['deals'] as List<dynamic>)
          .map((e) => Deal.fromJson(e as Map<String, dynamic>))
          .toList(),
      businesses: (json['businesses'] as List<dynamic>)
          .map((e) => Business.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      dealsCount: (json['dealsCount'] as num?)?.toInt() ?? 0,
      businessesCount: (json['businessesCount'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      nextPageToken: json['nextPageToken'] as String? ?? null,
      query: json['query'] as String? ?? null,
      searchLatitude: (json['searchLatitude'] as num?)?.toDouble() ?? null,
      searchLongitude: (json['searchLongitude'] as num?)?.toDouble() ?? null,
      searchDuration: json['searchDuration'] == null
          ? null
          : Duration(microseconds: (json['searchDuration'] as num).toInt()),
    );

Map<String, dynamic> _$$SearchResultImplToJson(_$SearchResultImpl instance) =>
    <String, dynamic>{
      'deals': instance.deals,
      'businesses': instance.businesses,
      'totalCount': instance.totalCount,
      'dealsCount': instance.dealsCount,
      'businessesCount': instance.businessesCount,
      'hasMore': instance.hasMore,
      'nextPageToken': instance.nextPageToken,
      'query': instance.query,
      'searchLatitude': instance.searchLatitude,
      'searchLongitude': instance.searchLongitude,
      'searchDuration': instance.searchDuration?.inMicroseconds,
    };

_$SearchPaginationImpl _$$SearchPaginationImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchPaginationImpl(
      page: (json['page'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
      nextPageToken: json['nextPageToken'] as String? ?? null,
    );

Map<String, dynamic> _$$SearchPaginationImplToJson(
        _$SearchPaginationImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'offset': instance.offset,
      'hasMore': instance.hasMore,
      'nextPageToken': instance.nextPageToken,
    };
