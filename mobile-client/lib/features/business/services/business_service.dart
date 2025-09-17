import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../shared/models/business.dart';
import '../../../shared/models/business_result.dart';

class BusinessService {
  final String _baseUrl = ApiConfig.baseUrl;

  /// Enroll a new business (creates restaurant onboarding request)
  Future<BusinessResult> enrollBusiness({
    required String ownerId,
    required String name,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
    String? email,
  }) async {
    try {
      // Validate required fields
      if (ownerId.isEmpty || name.isEmpty || address.isEmpty) {
        return const BusinessResult.failure('All required fields must be filled');
      }

      final requestData = {
        'restaurant_name': name,
        'restaurant_description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'owner_phone': phone ?? '',
        'owner_email': email ?? '',
        'owner_name': name, // Using restaurant name as owner name for now
      };

      print('🏢 Creating restaurant onboarding request via Workers API: ${json.encode(requestData)}');

      final response = await http.post(
        Uri.parse(ApiConfig.restaurantOnboardingRequestsUrl),
        headers: ApiConfig.headers,
        body: json.encode(requestData),
      );

      print('📋 Restaurant onboarding response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          // Create a mock business object to satisfy the UI flow
          // The actual business will be created when approved
          final mockBusiness = Business(
            id: data['data']['id'] ?? 'pending',
            ownerId: ownerId,
            name: name,
            description: description,
            address: address,
            phone: phone ?? '',
            email: email ?? '',
            latitude: latitude,
            longitude: longitude,
            isActive: false, // Not yet approved
            isApproved: false, // Pending approval
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          return BusinessResult.success(mockBusiness);
        }
      }

      final errorData = json.decode(response.body);
      return BusinessResult.failure(errorData['error'] ?? 'Failed to submit restaurant onboarding request');
    } catch (e) {
      print('💥 Error enrolling business: $e');
      return BusinessResult.failure('Failed to enroll business: ${e.toString()}');
    }
  }

  /// Get business by owner ID
  Future<Business?> getBusinessByOwnerId(String ownerId) async {
    try {
      print('🔍 Getting business by owner ID via Workers API: $ownerId');

      final response = await http.get(
        Uri.parse(ApiConfig.businessByOwnerUrl(ownerId)),
        headers: ApiConfig.headers,
      );

      print('📋 Get business by owner response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          return Business.fromJson(data['data']);
        }
      } else if (response.statusCode == 404) {
        return null; // No business found for this owner
      }

      return null;
    } catch (e) {
      print('💥 Error getting business by owner: $e');
      return null;
    }
  }

  /// Update business information
  Future<BusinessResult> updateBusiness(
    String businessId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('🔄 Updating business via Workers API: $businessId');

      final response = await http.put(
        Uri.parse(ApiConfig.businessByIdUrl(businessId)),
        headers: ApiConfig.headers,
        body: json.encode(updates),
      );

      print('📋 Update business response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final business = Business.fromJson(data['data']);
          return BusinessResult.success(business);
        }
      }

      final errorData = json.decode(response.body);
      return BusinessResult.failure(errorData['error'] ?? 'Failed to update business');
    } catch (e) {
      print('💥 Error updating business: $e');
      return BusinessResult.failure('Failed to update business: ${e.toString()}');
    }
  }

  /// Upload business logo
  /// TODO: Implement image upload via Workers API
  Future<ImageUploadResult> uploadBusinessLogo(
    String businessId,
    String imageData,
  ) async {
    print('📸 Image upload not yet implemented via Workers API');
    return const ImageUploadResult.failure('Image upload not yet implemented via Workers API');
  }

  /// Upload business cover image
  /// TODO: Implement image upload via Workers API
  Future<ImageUploadResult> uploadBusinessCoverImage(
    String businessId,
    String imageData,
  ) async {
    print('📸 Cover image upload not yet implemented via Workers API');
    return const ImageUploadResult.failure('Cover image upload not yet implemented via Workers API');
  }

  /// Search businesses by name or description
  /// TODO: Implement via Workers API
  Future<List<Business>> searchBusinesses(String query) async {
    print('🔍 Business search not yet implemented via Workers API');
    return [];
  }

  /// Get nearby businesses
  /// TODO: Implement via Workers API
  Future<List<Business>> getNearbyBusinesses({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    print('📍 Nearby businesses not yet implemented via Workers API');
    return [];
  }

  /// Get all businesses (admin only)
  /// TODO: Implement via Workers API
  Future<List<Business>> getAllBusinesses({
    bool? isApproved,
    bool? isActive,
    int limit = 50,
    int offset = 0,
  }) async {
    print('📋 Get all businesses not yet implemented via Workers API');
    return [];
  }

  /// Approve business (admin only)
  /// TODO: Implement via Workers API
  Future<BusinessResult> approveBusiness(String businessId) async {
    print('✅ Business approval not yet implemented via Workers API');
    return const BusinessResult.failure('Business approval not yet implemented via Workers API');
  }

  /// Reject business (admin only)
  /// TODO: Implement via Workers API
  Future<BusinessResult> rejectBusiness(String businessId, String reason) async {
    print('❌ Business rejection not yet implemented via Workers API');
    return const BusinessResult.failure('Business rejection not yet implemented via Workers API');
  }

  /// Delete business
  /// TODO: Implement via Workers API
  Future<bool> deleteBusiness(String businessId) async {
    print('🗑️ Business deletion not yet implemented via Workers API');
    return false;
  }
}