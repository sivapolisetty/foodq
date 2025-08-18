import '../core/services/api_service.dart';
import '../shared/models/business.dart';

class BusinessService {
  // Get business by ID
  Future<Business?> getBusinessById(String businessId) async {
    try {
      final response = await ApiService.get<dynamic>(
        '/api/businesses/$businessId',
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

  Future<Business> updateBusiness(Business business) async {
    throw UnimplementedError('Not yet implemented with ApiService');
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

  Future<String?> uploadBusinessImage(String businessId, String filePath) async {
    return null;
  }

  Future<bool> deleteBusinessImage(String imageUrl) async {
    return false;
  }

  Future<bool> isBusinessOwner(String businessId, String userId) async {
    return false;
  }
}