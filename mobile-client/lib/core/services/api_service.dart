import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/api_config.dart';
import 'network_logger.dart';

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? code;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.code,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : json['data'],
      error: json['error'],
      code: json['code'],
    );
  }

  bool get isError => !success;
}

/// HTTP API service for making requests to Cloudflare Worker
class ApiService {
  static final http.Client _client = LoggingHttpClient();

  /// GET request
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final uriWithQuery = queryParameters != null 
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      final response = await _client.get(
        uriWithQuery,
        headers: ApiConfig.headersWithOptionalAuth,
      ).timeout(ApiConfig.defaultTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Network error: ${e.toString()}',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// POST request
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';

      final response = await _client.post(
        Uri.parse(url),
        headers: ApiConfig.headersWithOptionalAuth,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.defaultTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Network error: ${e.toString()}',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// PUT request
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: ApiConfig.headersWithOptionalAuth,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.defaultTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Network error: ${e.toString()}',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// DELETE request
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: ApiConfig.headersWithOptionalAuth,
      ).timeout(ApiConfig.defaultTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Network error: ${e.toString()}',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// Handle HTTP response and parse JSON
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final dynamic decodedData = jsonDecode(response.body);
      
      // Check if the API returned an error status
      if (response.statusCode >= 400) {
        // For error responses, we expect a map with error details
        if (decodedData is Map<String, dynamic>) {
          return ApiResponse<T>(
            success: false,
            error: decodedData['error'] ?? 'HTTP ${response.statusCode} error',
            code: decodedData['code'] ?? 'HTTP_ERROR',
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<T>(
            success: false,
            error: 'HTTP ${response.statusCode} error',
            code: 'HTTP_ERROR',
            statusCode: response.statusCode,
          );
        }
      }

      // Handle both object and array responses
      if (decodedData is Map<String, dynamic>) {
        // Response is already wrapped in success/error format
        final apiResponse = ApiResponse.fromJson(decodedData, fromJson);
        // Add status code to the response
        return ApiResponse<T>(
          success: apiResponse.success,
          data: apiResponse.data,
          error: apiResponse.error,
          code: apiResponse.code,
          statusCode: response.statusCode,
        );
      } else if (decodedData is List) {
        // Response is a direct array, wrap it in success format
        return ApiResponse<T>(
          success: true,
          data: fromJson != null ? fromJson(decodedData) : decodedData as T,
          statusCode: response.statusCode,
        );
      } else {
        // Unknown response format
        return ApiResponse<T>(
          success: false,
          error: 'Unexpected response format',
          code: 'PARSE_ERROR',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: ${e.toString()}',
        code: 'PARSE_ERROR',
      );
    }
  }

  /// Get current authentication token
  static Future<String?> getAuthToken() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      return null;
    }
  }

  /// Parse HTTP response body as JSON
  static Map<String, dynamic> parseResponse(String body) {
    try {
      final dynamic decodedData = jsonDecode(body);
      if (decodedData is Map<String, dynamic>) {
        return decodedData;
      } else {
        return {
          'success': false,
          'error': 'Unexpected response format',
          'code': 'PARSE_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to parse response: ${e.toString()}',
        'code': 'PARSE_ERROR',
      };
    }
  }

  /// Dispose of the HTTP client
  static void dispose() {
    _client.close();
  }
}