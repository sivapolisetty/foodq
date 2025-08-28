import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../models/restaurant_onboarding_request.dart';

/// Restaurant Onboarding Service
/// Handles all API calls related to restaurant onboarding
class RestaurantOnboardingService {
  final String _baseUrl = ApiConfig.baseUrl;

  /// Get user's restaurant onboarding application
  Future<RestaurantOnboardingRequest?> getUserApplication(String userId) async {
    try {
      // Use the specific user endpoint to get user's applications
      final response = await http.get(
        Uri.parse('$_baseUrl/api/restaurant-onboarding-requests/user/$userId'),
        headers: ApiConfig.headersWithOptionalAuth,
      );

      print('Get user application response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          final List<dynamic> applications = data['data'];
          
          if (applications.isNotEmpty) {
            // Return the most recent application (API already sorts by created_at DESC)
            return RestaurantOnboardingRequest.fromJson(_convertDatesFromApi(applications.first));
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting user application: $e');
      throw Exception('Failed to get application: $e');
    }
  }

  /// Submit a new restaurant onboarding application
  Future<RestaurantOnboardingRequest> submitApplication(
    RestaurantOnboardingFormData formData,
  ) async {
    try {
      final requestBody = {
        'restaurant_name': formData.restaurantName,
        'cuisine_type': formData.cuisineType,
        'restaurant_description': formData.restaurantDescription,
        'restaurant_photo_url': formData.restaurantPhotoUrl,
        'owner_name': formData.ownerName,
        'owner_email': formData.ownerEmail,
        'owner_phone': formData.ownerPhone,
        'address': formData.address,
        'zip_code': formData.zipCode,
        'latitude': formData.latitude,
        'longitude': formData.longitude,
        'business_license': formData.businessLicense,
        'user_id': formData.userId,
      };

      print('Submitting application: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/restaurant-onboarding-requests'),
        headers: ApiConfig.headersWithOptionalAuth,
        body: json.encode(requestBody),
      );

      print('Submit application response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          return RestaurantOnboardingRequest.fromJson(_convertDatesFromApi(data['data']));
        }
      }

      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to submit application');
    } catch (e) {
      print('Error submitting application: $e');
      throw Exception('Failed to submit application: $e');
    }
  }

  /// Get application by ID
  Future<RestaurantOnboardingRequest?> getApplicationById(String applicationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/restaurant-onboarding-requests/$applicationId'),
        headers: ApiConfig.headers,
      );

      print('Get application by ID response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return RestaurantOnboardingRequest.fromJson(_convertDatesFromApi(data['data']));
        }
      }

      return null;
    } catch (e) {
      print('Error getting application by ID: $e');
      throw Exception('Failed to get application: $e');
    }
  }

  /// Get all restaurant onboarding applications (admin only)
  Future<List<RestaurantOnboardingRequest>> getAllApplications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/restaurant-onboarding-requests'),
        headers: ApiConfig.headers,
      );

      print('Get all applications response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final List<dynamic> applicationsData = data['data'];
          return applicationsData
              .map((app) => RestaurantOnboardingRequest.fromJson(_convertDatesFromApi(app)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error getting all applications: $e');
      throw Exception('Failed to get applications: $e');
    }
  }

  /// Check if user has completed restaurant onboarding
  Future<bool> isOnboardingCompleted(String userId) async {
    try {
      final application = await getUserApplication(userId);
      return application?.status == 'approved';
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Update application status (admin only)
  Future<bool> updateApplicationStatus(
    String applicationId,
    String status, {
    String? adminNotes,
  }) async {
    try {
      final requestBody = {
        if (adminNotes != null) 'admin_notes': adminNotes,
      };

      String endpoint;
      if (status == 'approved') {
        endpoint = '$_baseUrl/api/restaurant-onboarding-requests/$applicationId/approve';
      } else if (status == 'rejected') {
        endpoint = '$_baseUrl/api/restaurant-onboarding-requests/$applicationId/reject';
      } else {
        throw Exception('Invalid status: $status');
      }

      final response = await http.put(
        Uri.parse(endpoint),
        headers: ApiConfig.headers,
        body: json.encode(requestBody),
      );

      print('Update application status response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }

      return false;
    } catch (e) {
      print('Error updating application status: $e');
      throw Exception('Failed to update status: $e');
    }
  }

  // Note: Delete application functionality is not implemented in the Workers API

  /// Convert API date fields to DateTime objects  
  /// Note: Field mapping is now handled by @JsonKey annotations in the model
  Map<String, dynamic> _convertDatesFromApi(Map<String, dynamic> data) {
    // No field conversion needed - @JsonKey annotations handle snake_case mapping
    // Just return the original data for the model to handle
    return data;
  }
}