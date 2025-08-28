import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/test_config.dart';

/// Manages test data lifecycle for E2E tests
/// Ensures test isolation and cleanup
class TestDataManager {
  final SupabaseClient _supabase;
  final List<String> _createdBusinessIds = [];
  final List<String> _createdDealIds = [];
  final List<String> _createdRedemptionIds = [];
  
  TestDataManager(this._supabase);
  
  /// Initialize test environment
  Future<void> initialize() async {
    TestConfig.validateConfig();
    TestConfig.printTestInfo();
    
    // Clean any leftover test data from previous failed runs
    await _cleanupLeftoverTestData();
  }
  
  /// Register a business ID for cleanup
  void registerBusiness(String businessId) {
    _createdBusinessIds.add(businessId);
  }
  
  /// Register a deal ID for cleanup
  void registerDeal(String dealId) {
    _createdDealIds.add(dealId);
  }
  
  /// Register a redemption ID for cleanup
  void registerRedemption(String redemptionId) {
    _createdRedemptionIds.add(redemptionId);
  }
  
  /// Clean up all test data created during this test run
  Future<void> cleanup({bool force = false}) async {
    if (!TestConfig.cleanupAfterTests && !force) {
      print('⚠️  Skipping cleanup (cleanupAfterTests = false)');
      return;
    }
    
    print('🧹 Cleaning up test data...');
    
    try {
      // Clean up redemptions first (foreign key constraints)
      for (final redemptionId in _createdRedemptionIds) {
        await _safeDelete('deal_redemptions', redemptionId);
      }
      
      // Clean up deals
      for (final dealId in _createdDealIds) {
        await _safeDelete('deals', dealId);
      }
      
      // Clean up businesses (this will cascade delete remaining deals)
      for (final businessId in _createdBusinessIds) {
        await _safeDelete('businesses', businessId);
      }
      
      print('✅ Test data cleanup completed');
      
    } catch (e) {
      print('❌ Error during cleanup: $e');
      if (!TestConfig.skipCleanupOnFailure) {
        rethrow;
      }
    }
    
    // Clear the lists
    _createdBusinessIds.clear();
    _createdDealIds.clear();
    _createdRedemptionIds.clear();
  }
  
  /// Clean up any leftover test data from previous runs
  Future<void> _cleanupLeftoverTestData() async {
    print('🔍 Checking for leftover test data...');
    
    try {
      // Find and delete leftover test businesses
      final businesses = await _supabase
          .from('businesses')
          .select('id, name')
          .like('name', '${TestConfig.testDataPrefix}%');
      
      for (final business in businesses) {
        await _safeDelete('businesses', business['id']);
        print('   Cleaned up leftover business: ${business['name']}');
      }
      
      // Find and delete leftover test deals
      final deals = await _supabase
          .from('deals')
          .select('id, title')
          .like('title', '${TestConfig.testDataPrefix}%');
      
      for (final deal in deals) {
        await _safeDelete('deals', deal['id']);
        print('   Cleaned up leftover deal: ${deal['title']}');
      }
      
      if (businesses.isEmpty && deals.isEmpty) {
        print('✅ No leftover test data found');
      }
      
    } catch (e) {
      print('⚠️  Error cleaning leftover data: $e');
    }
  }
  
  /// Safely delete a record by ID
  Future<void> _safeDelete(String table, String id) async {
    try {
      await _supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      // Don't fail the test if cleanup fails
      print('⚠️  Failed to delete $table[$id]: $e');
    }
  }
  
  /// Verify data exists in database
  Future<bool> verifyBusinessExists(String businessId) async {
    try {
      final result = await _supabase
          .from('businesses')
          .select('id')
          .eq('id', businessId)
          .maybeSingle();
      
      return result != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Verify deal exists in database
  Future<bool> verifyDealExists(String dealId) async {
    try {
      final result = await _supabase
          .from('deals')
          .select('id')
          .eq('id', dealId)
          .maybeSingle();
      
      return result != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Get fresh data from database to verify updates
  Future<Map<String, dynamic>?> getBusinessFromDb(String businessId) async {
    try {
      return await _supabase
          .from('businesses')
          .select()
          .eq('id', businessId)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }
  
  /// Get fresh deal data from database
  Future<Map<String, dynamic>?> getDealFromDb(String dealId) async {
    try {
      return await _supabase
          .from('deals')
          .select()
          .eq('id', dealId)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }
  
  /// Count deals for a business
  Future<int> countDealsForBusiness(String businessId) async {
    try {
      final result = await _supabase
          .from('deals')
          .select('id')
          .eq('business_id', businessId);
      
      return (result as List).length;
    } catch (e) {
      return 0;
    }
  }
  
  /// Count active deals for a business
  Future<int> countActiveDealsForBusiness(String businessId) async {
    try {
      final result = await _supabase
          .from('deals')
          .select('id')
          .eq('business_id', businessId)
          .eq('is_active', true);
      
      return (result as List).length;
    } catch (e) {
      return 0;
    }
  }
  
  /// Wait for database operation to complete (eventual consistency)
  Future<void> waitForConsistency({Duration delay = const Duration(milliseconds: 100)}) async {
    await Future.delayed(delay);
  }
  
  /// Create a test business with unique name
  Map<String, dynamic> createTestBusinessData({
    String? ownerId,
    String? nameSuffix,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = nameSuffix ?? timestamp.toString();
    
    return {
      'name': '${TestConfig.testBusinessPrefix}Restaurant_$suffix',
      'description': 'E2E test restaurant created at ${DateTime.now()}',
      'owner_id': ownerId ?? TestConfig.testUserId,
      'address': '123 Test Street, Test City',
      'phone': '+1234567890',
      'email': 'test$suffix@grabeat-e2e.com',
      'latitude': 12.9716,
      'longitude': 77.5946,
      'is_active': true,
    };
  }
  
  /// Create a test deal with unique title
  Map<String, dynamic> createTestDealData({
    required String businessId,
    String? titleSuffix,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = titleSuffix ?? timestamp.toString();
    
    return {
      'title': '${TestConfig.testDealPrefix}Deal_$suffix',
      'description': 'E2E test deal created at ${DateTime.now()}',
      'original_price': 100.0,
      'discounted_price': 70.0,
      'discount_percentage': 30,
      'business_id': businessId,
      'image_url': 'https://example.com/test-image.jpg',
      'is_active': true,
      'valid_from': DateTime.now().toIso8601String(),
      'valid_until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'terms_conditions': 'E2E test terms and conditions',
      'max_redemptions': 0,
      'current_redemptions': 0,
    };
  }
}