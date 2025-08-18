import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/deal.dart';
import '../models/deal_with_distance.dart';
import '../models/business.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException: $message';
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;
  final DateTime timestamp;
  final Map<String, dynamic>? pagination;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    required this.timestamp,
    this.pagination,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? dataParser) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && dataParser != null ? dataParser(json['data']) : json['data'],
      error: json['error'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      pagination: json['pagination'],
    );
  }
}

class ApiService {
  static const String _baseUrl = 'https://your-worker-domain.workers.dev'; // Update with your deployed worker URL
  static const String _localUrl = 'http://localhost:8787'; // For local development
  
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiService({
    String? baseUrl,
    http.Client? client,
  }) : baseUrl = baseUrl ?? _localUrl,
       _client = client ?? http.Client();

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get headers with authentication
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Generic API request method
  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(dynamic)? dataParser,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: _headers);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: _headers);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      final responseBody = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(responseBody, dataParser);
      } else {
        throw ApiException(
          responseBody['error'] ?? 'Request failed',
          statusCode: response.statusCode,
          details: responseBody,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _request<Map<String, dynamic>>(
      'GET',
      '/api/health',
      dataParser: (data) => data as Map<String, dynamic>,
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Health check failed');
    }
    
    return response.data!;
  }

  // Deal endpoints
  Future<List<DealWithDistance>> getNearbyDeals({
    required double latitude,
    required double longitude,
    double radius = 10.0,
    int limit = 20,
    String? categoryId,
    int? minDiscount,
    double? maxPrice,
  }) async {
    final queryParams = <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': radius.toString(),
      'limit': limit.toString(),
    };
    
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (minDiscount != null) queryParams['min_discount'] = minDiscount.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

    final response = await _request<List<DealWithDistance>>(
      'GET',
      '/api/deals/nearby',
      queryParams: queryParams,
      dataParser: (data) => (data as List)
          .map((item) => DealWithDistance.fromJson(item))
          .toList(),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch nearby deals');
    }
    
    return response.data!;
  }

  Future<List<Deal>> getFeaturedDeals({int limit = 10}) async {
    final response = await _request<List<Deal>>(
      'GET',
      '/api/deals/featured',
      queryParams: {'limit': limit.toString()},
      dataParser: (data) => (data as List)
          .map((item) => Deal.fromJson(item))
          .toList(),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch featured deals');
    }
    
    return response.data!;
  }

  Future<List<Deal>> getDealsExpiringSoon({int days = 3}) async {
    final response = await _request<List<Deal>>(
      'GET',
      '/api/deals/expiring-soon',
      queryParams: {'days': days.toString()},
      dataParser: (data) => (data as List)
          .map((item) => Deal.fromJson(item))
          .toList(),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch expiring deals');
    }
    
    return response.data!;
  }

  Future<List<Deal>> getDeals({
    int page = 1,
    int limit = 20,
    String? businessId,
    String? categoryId,
    bool? isActive,
    int? minDiscount,
    double? maxPrice,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (businessId != null) queryParams['business_id'] = businessId;
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (isActive != null) queryParams['is_active'] = isActive.toString();
    if (minDiscount != null) queryParams['min_discount'] = minDiscount.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (search != null) queryParams['search'] = search;

    final response = await _request<List<Deal>>(
      'GET',
      '/api/deals',
      queryParams: queryParams,
      dataParser: (data) => (data as List)
          .map((item) => Deal.fromJson(item))
          .toList(),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch deals');
    }
    
    return response.data!;
  }

  Future<Deal> getDealById(String id) async {
    final response = await _request<Deal>(
      'GET',
      '/api/deals/$id',
      dataParser: (data) => Deal.fromJson(data),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch deal');
    }
    
    return response.data!;
  }

  Future<Deal> createDeal(Map<String, dynamic> dealData) async {
    final response = await _request<Deal>(
      'POST',
      '/api/deals',
      body: dealData,
      dataParser: (data) => Deal.fromJson(data),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to create deal');
    }
    
    return response.data!;
  }

  Future<Deal> updateDeal(String id, Map<String, dynamic> updates) async {
    final response = await _request<Deal>(
      'PUT',
      '/api/deals/$id',
      body: updates,
      dataParser: (data) => Deal.fromJson(data),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to update deal');
    }
    
    return response.data!;
  }

  Future<void> deleteDeal(String id) async {
    final response = await _request<void>(
      'DELETE',
      '/api/deals/$id',
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to delete deal');
    }
  }

  // Business endpoints
  Future<List<Business>> getMyBusinesses() async {
    final response = await _request<List<Business>>(
      'GET',
      '/api/business/my',
      dataParser: (data) => (data as List)
          .map((item) => Business.fromJson(item))
          .toList(),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch businesses');
    }
    
    return response.data!;
  }

  Future<Business> getBusinessById(String id) async {
    final response = await _request<Business>(
      'GET',
      '/api/business/$id',
      dataParser: (data) => Business.fromJson(data),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch business');
    }
    
    return response.data!;
  }

  Future<List<Deal>> getBusinessDeals(String businessId, {
    int page = 1,
    int limit = 20,
    bool? isActive,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (isActive != null) queryParams['is_active'] = isActive.toString();

    final response = await _request<List<Deal>>(
      'GET',
      '/api/business/$businessId/deals',
      queryParams: queryParams,
      dataParser: (data) => (data as List)
          .map((item) => Deal.fromJson(item))
          .toList(),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch business deals');
    }
    
    return response.data!;
  }

  Future<Map<String, dynamic>> getBusinessStats(String businessId) async {
    final response = await _request<Map<String, dynamic>>(
      'GET',
      '/api/business/$businessId/stats',
      dataParser: (data) => data as Map<String, dynamic>,
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to fetch business stats');
    }
    
    return response.data!;
  }

  Future<Business> createBusiness(Map<String, dynamic> businessData) async {
    final response = await _request<Business>(
      'POST',
      '/api/business',
      body: businessData,
      dataParser: (data) => Business.fromJson(data),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to create business');
    }
    
    return response.data!;
  }

  Future<Business> updateBusiness(String id, Map<String, dynamic> updates) async {
    final response = await _request<Business>(
      'PUT',
      '/api/business/$id',
      body: updates,
      dataParser: (data) => Business.fromJson(data),
    );
    
    if (!response.success) {
      throw ApiException(response.error ?? 'Failed to update business');
    }
    
    return response.data!;
  }

  // Search deals
  Future<List<Deal>> searchDeals(String query, {
    int page = 1,
    int limit = 20,
  }) async {
    return getDeals(
      page: page,
      limit: limit,
      search: query,
    );
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}