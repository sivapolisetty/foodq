import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deal.dart';
import '../models/deal_with_distance.dart';
import '../utils/location_utils.dart';

class DealService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all deals for a specific business
  Future<List<Deal>> getDealsForBusiness(String businessId) async {
    try {
      final response = await _supabase
          .from('deals')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((deal) => Deal.fromJson(deal))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch deals for business: $e');
    }
  }

  // Get all active deals (for customer view)
  Future<List<Deal>> getActiveDeals() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('deals')
          .select('''
            *,
            businesses!inner(
              id,
              name,
              image_url,
              address,
              is_active
            )
          ''')
          .eq('is_active', true)
          .eq('businesses.is_active', true)
          .lte('valid_from', now)
          .gte('valid_until', now)
          .order('created_at', ascending: false);

      return (response as List)
          .map((deal) => Deal.fromJson(deal))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active deals: $e');
    }
  }

  // Create a new deal
  Future<Deal> createDeal(Deal deal) async {
    try {
      final dealData = deal.toJson();
      dealData.remove('id'); // Let Supabase generate the ID
      dealData.remove('created_at'); // Let Supabase set the timestamp
      dealData.remove('current_redemptions'); // Default to 0

      final response = await _supabase
          .from('deals')
          .insert(dealData)
          .select()
          .single();

      return Deal.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create deal: $e');
    }
  }

  // Update an existing deal
  Future<Deal> updateDeal(Deal deal) async {
    try {
      final dealData = deal.toJson();
      dealData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('deals')
          .update(dealData)
          .eq('id', deal.id)
          .select()
          .single();

      return Deal.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update deal: $e');
    }
  }

  // Delete a deal
  Future<bool> deleteDeal(String dealId) async {
    try {
      await _supabase
          .from('deals')
          .delete()
          .eq('id', dealId);

      return true;
    } catch (e) {
      throw Exception('Failed to delete deal: $e');
    }
  }

  // Toggle deal status (active/inactive)
  Future<Deal> toggleDealStatus(String dealId, bool isActive) async {
    try {
      final response = await _supabase
          .from('deals')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', dealId)
          .select()
          .single();

      return Deal.fromJson(response);
    } catch (e) {
      throw Exception('Failed to toggle deal status: $e');
    }
  }

  // Get deal by ID
  Future<Deal?> getDealById(String dealId) async {
    try {
      final response = await _supabase
          .from('deals')
          .select('''
            *,
            businesses!inner(
              id,
              name,
              image_url,
              address,
              phone,
              email
            )
          ''')
          .eq('id', dealId)
          .single();

      return Deal.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Search deals
  Future<List<Deal>> searchDeals(String query) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('deals')
          .select('''
            *,
            businesses!inner(
              id,
              name,
              image_url,
              address,
              is_active
            )
          ''')
          .eq('is_active', true)
          .eq('businesses.is_active', true)
          .lte('valid_from', now)
          .gte('valid_until', now)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((deal) => Deal.fromJson(deal))
          .toList();
    } catch (e) {
      throw Exception('Failed to search deals: $e');
    }
  }

  // Get deals by category
  Future<List<Deal>> getDealsByCategory(String categoryId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('deals')
          .select('''
            *,
            businesses!inner(
              id,
              name,
              image_url,
              address,
              is_active
            ),
            deal_category_mapping!inner(
              category_id
            )
          ''')
          .eq('is_active', true)
          .eq('businesses.is_active', true)
          .eq('deal_category_mapping.category_id', categoryId)
          .lte('valid_from', now)
          .gte('valid_until', now)
          .order('created_at', ascending: false);

      return (response as List)
          .map((deal) => Deal.fromJson(deal))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch deals by category: $e');
    }
  }

  // Get featured deals (you can implement your own logic)
  Future<List<Deal>> getFeaturedDeals({int limit = 10}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('deals')
          .select('''
            *,
            businesses!inner(
              id,
              name,
              image_url,
              address,
              is_active
            )
          ''')
          .eq('is_active', true)
          .eq('businesses.is_active', true)
          .lte('valid_from', now)
          .gte('valid_until', now)
          .gte('discount_percentage', 20) // Featured deals have at least 20% off
          .order('discount_percentage', ascending: false)
          .limit(limit);

      return (response as List)
          .map((deal) => Deal.fromJson(deal))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured deals: $e');
    }
  }

  // Get deals expiring soon
  Future<List<Deal>> getDealsExpiringSoon({int daysAhead = 3}) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));
      
      final response = await _supabase
          .from('deals')
          .select('''
            *,
            businesses!inner(
              id,
              name,
              image_url,
              address,
              latitude,
              longitude,
              is_active
            )
          ''')
          .eq('is_active', true)
          .eq('businesses.is_active', true)
          .lte('valid_from', now.toIso8601String())
          .gte('valid_until', now.toIso8601String())
          .lte('valid_until', futureDate.toIso8601String())
          .order('valid_until', ascending: true);

      return (response as List)
          .map((deal) => Deal.fromJson(deal))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch deals expiring soon: $e');
    }
  }

  // Get deals near user location
  Future<List<DealWithDistance>> getDealsNearLocation(
    double userLatitude,
    double userLongitude, {
    double radiusKm = 10,
    int limit = 50,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // First get all active deals with business location info
      final response = await _supabase
          .from('deals')
          .select('''
            *,
            businesses!inner(
              id,
              name,
              image_url,
              address,
              latitude,
              longitude,
              phone,
              is_active
            )
          ''')
          .eq('is_active', true)
          .eq('businesses.is_active', true)
          .lte('valid_from', now)
          .gte('valid_until', now)
          .order('created_at', ascending: false);

      final allDeals = (response as List)
          .map((deal) => Deal.fromJson(deal))
          .toList();

      // Filter by distance and calculate distances
      final dealsWithDistance = <DealWithDistance>[];
      
      for (final deal in allDeals) {
        // Get business location from the joined data
        final businesses = deal.toJson()['businesses'];
        if (businesses != null) {
          final businessLat = businesses['latitude'] as double?;
          final businessLon = businesses['longitude'] as double?;
          
          if (businessLat != null && businessLon != null) {
            final distance = LocationUtils.calculateDistance(
              userLatitude, userLongitude,
              businessLat, businessLon,
            );
            
            if (distance <= radiusKm) {
              dealsWithDistance.add(DealWithDistance(
                deal: deal,
                distanceKm: distance,
                businessLatitude: businessLat,
                businessLongitude: businessLon,
                businessName: businesses['name'] as String,
                businessAddress: businesses['address'] as String?,
              ));
            }
          }
        }
      }
      
      // Sort by distance
      dealsWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      
      return dealsWithDistance.take(limit).toList();
      
    } catch (e) {
      throw Exception('Failed to fetch deals near location: $e');
    }
  }

  // Get deals by area/locality
  Future<List<Deal>> getDealsByArea(String areaName) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from('deals')
          .select('''
            *,
            businesses!inner(
              id,
              name,
              image_url,
              address,
              latitude,
              longitude,
              is_active
            )
          ''')
          .eq('is_active', true)
          .eq('businesses.is_active', true)
          .lte('valid_from', now)
          .gte('valid_until', now)
          .like('businesses.address', '%$areaName%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((deal) => Deal.fromJson(deal))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch deals by area: $e');
    }
  }

  // Get deals with delivery available to user location
  Future<List<DealWithDistance>> getDealsWithDelivery(
    double userLatitude,
    double userLongitude, {
    double maxDeliveryDistance = 10,
  }) async {
    try {
      final dealsNearby = await getDealsNearLocation(
        userLatitude, 
        userLongitude,
        radiusKm: maxDeliveryDistance,
      );
      
      // Filter only deals that offer delivery
      return dealsNearby.where((dealWithDistance) {
        final deliveryZone = LocationUtils.getDeliveryZone(dealWithDistance.distanceKm);
        return deliveryZone != DeliveryZone.notAvailable;
      }).toList();
      
    } catch (e) {
      throw Exception('Failed to fetch deals with delivery: $e');
    }
  }

  // Get popular deals in specific locations
  Future<Map<String, List<Deal>>> getPopularDealsByLocation({
    List<String>? locations,
  }) async {
    try {
      final popularLocations = locations ?? LocationUtils.popularLocations.keys.toList();
      final dealsByLocation = <String, List<Deal>>{};
      
      for (final location in popularLocations) {
        final deals = await getDealsByArea(location);
        if (deals.isNotEmpty) {
          dealsByLocation[location] = deals.take(5).toList(); // Top 5 per area
        }
      }
      
      return dealsByLocation;
    } catch (e) {
      throw Exception('Failed to fetch popular deals by location: $e');
    }
  }

  // Upload deal image (if using Supabase storage)
  Future<String?> uploadDealImage(String dealId, String filePath) async {
    try {
      final fileName = 'deal_${dealId}_${DateTime.now().millisecondsSinceEpoch}';
      
      // In a real app, you would pass a File object or bytes
      // For now, we'll simulate the upload and return a URL
      final imageUrl = _supabase.storage
          .from('deals')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload deal image: $e');
    }
  }

  // Delete deal image
  Future<bool> deleteDealImage(String imageUrl) async {
    try {
      // Extract file name from URL
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;
      
      await _supabase.storage
          .from('deals')
          .remove([fileName]);

      return true;
    } catch (e) {
      return false;
    }
  }
}