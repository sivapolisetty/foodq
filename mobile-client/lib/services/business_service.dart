import '../core/services/api_service.dart';
import '../shared/models/business.dart';

class BusinessService {
  // Get business by ID
  Future<Business?> getBusinessById(String businessId) async {
    try {
      final response = await ApiService.get<dynamic>(
        '/businesses/$businessId',
      );

      if (response.success && response.data != null) {
        return Business.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Placeholder methods - TODO: Implement with ApiService
  Future<List<Business>> getBusinessesForOwner(String ownerId) async {
    return <Business>[];
  }

  Future<List<Business>> getActiveBusinesses() async {
    return <Business>[];
  }

  Future<Business> createBusiness(Business business) async {
    throw UnimplementedError('Not yet implemented with ApiService');
  }

  Future<Business?> updateBusiness(Business business) async {
    try {
      final response = await ApiService.put<dynamic>(
        '/businesses/${business.id}',
        body: business.toJson(),
      );

      if (response.success && response.data != null) {
        return Business.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error updating business: $e');
      return null;
    }
  }

  Future<bool> deleteBusiness(String businessId) async {
    return false;
  }

  Future<Business> toggleBusinessStatus(String businessId, bool isActive) async {
    throw UnimplementedError('Not yet implemented with ApiService');
  }

  Future<List<Business>> searchBusinesses(String query) async {
    return <Business>[];
  }

  Future<List<Business>> getBusinessesNearLocation(
    double latitude, 
    double longitude, 
    {double radiusKm = 10}
  ) async {
    return <Business>[];
  }

  Future<Map<String, dynamic>> getBusinessStats(String businessId) async {
    return {
      'total_deals': 0,
      'active_deals': 0,
      'total_redemptions': 0,
    };
  }

  /// Upload banner image for business and return the public URL
  Future<String?> uploadBusinessBanner(String filePath) async {
    try {
      final response = await ApiService.uploadFile<dynamic>(
        '/upload',
        filePath,
        'file',
        fromJson: (data) => data,
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update business banner URL after upload
  Future<Business?> updateBusinessBanner(String businessId, String bannerUrl) async {
    try {
      final response = await ApiService.put<dynamic>(
        '/businesses/$businessId',
        body: {'cover_image_url': bannerUrl},
      );

      if (response.success && response.data != null) {
        return Business.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadBusinessImage(String businessId, String filePath) async {
    return uploadBusinessBanner(filePath);
  }

  Future<bool> deleteBusinessImage(String imageUrl) async {
    return false;
  }

  Future<bool> isBusinessOwner(String businessId, String userId) async {
    return false;
  }
}