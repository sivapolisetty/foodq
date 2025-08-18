import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kravekart/models/deal.dart';
import 'package:kravekart/models/business.dart';
import 'package:kravekart/services/deal_service.dart';
import 'package:kravekart/services/business_service.dart';
import '../config/test_config.dart';
import '../utils/test_data_manager.dart';

/// End-to-End API Tests with Real Supabase Cloud Database
/// 
/// These tests perform actual CRUD operations against Supabase cloud
/// and verify that data is correctly stored, updated, and retrieved.
/// 
/// SETUP REQUIRED:
/// 1. Set environment variables:
///    - SUPABASE_TEST_URL=https://your-project.supabase.co
///    - SUPABASE_TEST_ANON_KEY=your-anon-key
///    - SUPABASE_TEST_SERVICE_KEY=your-service-key
/// 2. Ensure test database schema is deployed
/// 3. Use a dedicated test Supabase project (not production!)
void main() {
  late SupabaseClient supabase;
  late DealService dealService;
  late BusinessService businessService;
  late TestDataManager testDataManager;
  
  setUpAll(() async {
    TestConfig.validateConfig();
    
    // Initialize Supabase with test credentials
    await Supabase.initialize(
      url: TestConfig.supabaseUrl,
      anonKey: TestConfig.supabaseAnonKey,
    );
    
    supabase = Supabase.instance.client;
    dealService = DealService();
    businessService = BusinessService();
    testDataManager = TestDataManager(supabase);
    
    await testDataManager.initialize();
  });
  
  tearDownAll(() async {
    // Clean up all test data
    await testDataManager.cleanup(force: true);
  });

  group('🏪 Business E2E API Tests', () {
    test('CREATE: Should create business in Supabase and return valid ID', () async {
      final businessData = testDataManager.createTestBusinessData(
        nameSuffix: 'create_test',
      );
      
      // Create business via service
      final business = Business.fromJson(businessData);
      final createdBusiness = await businessService.createBusiness(business);
      
      // Register for cleanup
      testDataManager.registerBusiness(createdBusiness.id);
      
      // Verify response
      expect(createdBusiness.id.isNotEmpty, true);
      expect(createdBusiness.name, businessData['name']);
      expect(createdBusiness.ownerId, TestConfig.testUserId);
      
      // Wait for database consistency
      await testDataManager.waitForConsistency();
      
      // Verify data exists in database
      final existsInDb = await testDataManager.verifyBusinessExists(createdBusiness.id);
      expect(existsInDb, true);
      
      // Fetch fresh data from database and verify
      final dbData = await testDataManager.getBusinessFromDb(createdBusiness.id);
      expect(dbData, isNotNull);
      expect(dbData!['name'], businessData['name']);
      expect(dbData['is_active'], true);
      
      print('✅ Business created with ID: ${createdBusiness.id}');
    });
    
    test('READ: Should fetch business by ID from Supabase', () async {
      // Create test business first
      final businessData = testDataManager.createTestBusinessData(
        nameSuffix: 'read_test',
      );
      
      final business = Business.fromJson(businessData);
      final createdBusiness = await businessService.createBusiness(business);
      testDataManager.registerBusiness(createdBusiness.id);
      
      await testDataManager.waitForConsistency();
      
      // Fetch business by ID
      final fetchedBusiness = await businessService.getBusinessById(createdBusiness.id);
      
      expect(fetchedBusiness, isNotNull);
      expect(fetchedBusiness!.id, createdBusiness.id);
      expect(fetchedBusiness.name, businessData['name']);
      expect(fetchedBusiness.ownerId, TestConfig.testUserId);
      
      print('✅ Business fetched successfully: ${fetchedBusiness.name}');
    });
    
    test('UPDATE: Should update business in Supabase and persist changes', () async {
      // Create test business
      final businessData = testDataManager.createTestBusinessData(
        nameSuffix: 'update_test',
      );
      
      final business = Business.fromJson(businessData);
      final createdBusiness = await businessService.createBusiness(business);
      testDataManager.registerBusiness(createdBusiness.id);
      
      await testDataManager.waitForConsistency();
      
      // Update business
      final updatedName = '${TestConfig.testBusinessPrefix}Updated_${DateTime.now().millisecondsSinceEpoch}';
      final updatedDescription = 'Updated description at ${DateTime.now()}';
      
      final updatedBusiness = createdBusiness.copyWith(
        name: updatedName,
        description: updatedDescription,
      );
      
      final result = await businessService.updateBusiness(updatedBusiness);
      
      // Verify service response
      expect(result.name, updatedName);
      expect(result.description, updatedDescription);
      
      await testDataManager.waitForConsistency();
      
      // Verify changes persisted in database
      final dbData = await testDataManager.getBusinessFromDb(createdBusiness.id);
      expect(dbData!['name'], updatedName);
      expect(dbData['description'], updatedDescription);
      
      print('✅ Business updated successfully: $updatedName');
    });
    
    test('DELETE: Should delete business from Supabase', () async {
      // Create test business
      final businessData = testDataManager.createTestBusinessData(
        nameSuffix: 'delete_test',
      );
      
      final business = Business.fromJson(businessData);
      final createdBusiness = await businessService.createBusiness(business);
      
      await testDataManager.waitForConsistency();
      
      // Verify it exists
      expect(await testDataManager.verifyBusinessExists(createdBusiness.id), true);
      
      // Delete business
      final deleteResult = await businessService.deleteBusiness(createdBusiness.id);
      expect(deleteResult, true);
      
      await testDataManager.waitForConsistency();
      
      // Verify it's deleted from database
      expect(await testDataManager.verifyBusinessExists(createdBusiness.id), false);
      
      // Verify service returns null for deleted business
      final deletedBusiness = await businessService.getBusinessById(createdBusiness.id);
      expect(deletedBusiness, null);
      
      print('✅ Business deleted successfully');
    });
    
    test('SEARCH: Should search businesses in Supabase', () async {
      // Create multiple test businesses with searchable names
      final businesses = <Business>[];
      
      for (int i = 0; i < 3; i++) {
        final businessData = testDataManager.createTestBusinessData(
          nameSuffix: 'search_pizza_$i',
        );
        businessData['name'] = '${TestConfig.testBusinessPrefix}Pizza_Palace_$i';
        
        final business = Business.fromJson(businessData);
        final created = await businessService.createBusiness(business);
        businesses.add(created);
        testDataManager.registerBusiness(created.id);
      }
      
      await testDataManager.waitForConsistency();
      
      // Search for businesses
      final searchResults = await businessService.searchBusinesses('Pizza_Palace');
      
      expect(searchResults.length, greaterThanOrEqualTo(3));
      
      final testBusinessResults = searchResults
          .where((b) => b.name.contains(TestConfig.testBusinessPrefix))
          .toList();
      
      expect(testBusinessResults.length, 3);
      
      print('✅ Search returned ${searchResults.length} businesses');
    });
  });

  group('🏷️ Deal E2E API Tests', () {
    late String testBusinessId;
    
    setUp(() async {
      // Create a test business for deal tests
      final businessData = testDataManager.createTestBusinessData(
        nameSuffix: 'deal_tests',
      );
      
      final business = Business.fromJson(businessData);
      final createdBusiness = await businessService.createBusiness(business);
      testBusinessId = createdBusiness.id;
      
      testDataManager.registerBusiness(testBusinessId);
      await testDataManager.waitForConsistency();
    });
    
    test('CREATE: Should create deal in Supabase and return valid ID', () async {
      final dealData = testDataManager.createTestDealData(
        businessId: testBusinessId,
        titleSuffix: 'create_test',
      );
      
      // Create deal via service
      final deal = Deal.fromJson(dealData);
      final createdDeal = await dealService.createDeal(deal);
      
      testDataManager.registerDeal(createdDeal.id);
      
      // Verify response
      expect(createdDeal.id.isNotEmpty, true);
      expect(createdDeal.title, dealData['title']);
      expect(createdDeal.businessId, testBusinessId);
      expect(createdDeal.originalPrice, 100.0);
      expect(createdDeal.discountPercentage, 30);
      
      await testDataManager.waitForConsistency();
      
      // Verify data exists in database
      final existsInDb = await testDataManager.verifyDealExists(createdDeal.id);
      expect(existsInDb, true);
      
      // Fetch fresh data from database
      final dbData = await testDataManager.getDealFromDb(createdDeal.id);
      expect(dbData!['title'], dealData['title']);
      expect(dbData['business_id'], testBusinessId);
      
      print('✅ Deal created with ID: ${createdDeal.id}');
    });
    
    test('READ: Should fetch deals for business from Supabase', () async {
      // Create multiple deals for the business
      final dealIds = <String>[];
      
      for (int i = 0; i < 3; i++) {
        final dealData = testDataManager.createTestDealData(
          businessId: testBusinessId,
          titleSuffix: 'read_test_$i',
        );
        
        final deal = Deal.fromJson(dealData);
        final created = await dealService.createDeal(deal);
        dealIds.add(created.id);
        testDataManager.registerDeal(created.id);
      }
      
      await testDataManager.waitForConsistency();
      
      // Fetch deals for business
      final deals = await dealService.getDealsForBusiness(testBusinessId);
      
      expect(deals.length, greaterThanOrEqualTo(3));
      
      // Verify all deals belong to the business
      for (final deal in deals) {
        expect(deal.businessId, testBusinessId);
      }
      
      // Verify our test deals are included
      final testDeals = deals.where((d) => d.title.contains(TestConfig.testDealPrefix)).toList();
      expect(testDeals.length, greaterThanOrEqualTo(3));
      
      print('✅ Fetched ${deals.length} deals for business');
    });
    
    test('UPDATE: Should update deal in Supabase and persist changes', () async {
      // Create test deal
      final dealData = testDataManager.createTestDealData(
        businessId: testBusinessId,
        titleSuffix: 'update_test',
      );
      
      final deal = Deal.fromJson(dealData);
      final createdDeal = await dealService.createDeal(deal);
      testDataManager.registerDeal(createdDeal.id);
      
      await testDataManager.waitForConsistency();
      
      // Update deal
      final updatedTitle = '${TestConfig.testDealPrefix}Updated_${DateTime.now().millisecondsSinceEpoch}';
      const updatedPrice = 150.0;
      const updatedDiscount = 90.0;
      const updatedPercentage = 40;
      
      final updatedDeal = createdDeal.copyWith(
        title: updatedTitle,
        originalPrice: updatedPrice,
        discountedPrice: updatedDiscount,
        discountPercentage: updatedPercentage,
      );
      
      final result = await dealService.updateDeal(updatedDeal);
      
      // Verify service response
      expect(result.title, updatedTitle);
      expect(result.originalPrice, updatedPrice);
      expect(result.discountedPrice, updatedDiscount);
      expect(result.discountPercentage, updatedPercentage);
      
      await testDataManager.waitForConsistency();
      
      // Verify changes persisted in database
      final dbData = await testDataManager.getDealFromDb(createdDeal.id);
      expect(dbData!['title'], updatedTitle);
      expect(dbData['original_price'], updatedPrice);
      expect(dbData['discounted_price'], updatedDiscount);
      expect(dbData['discount_percentage'], updatedPercentage);
      
      print('✅ Deal updated successfully: $updatedTitle');
    });
    
    test('DELETE: Should delete deal from Supabase', () async {
      // Create test deal
      final dealData = testDataManager.createTestDealData(
        businessId: testBusinessId,
        titleSuffix: 'delete_test',
      );
      
      final deal = Deal.fromJson(dealData);
      final createdDeal = await dealService.createDeal(deal);
      
      await testDataManager.waitForConsistency();
      
      // Verify it exists
      expect(await testDataManager.verifyDealExists(createdDeal.id), true);
      
      // Delete deal
      final deleteResult = await dealService.deleteDeal(createdDeal.id);
      expect(deleteResult, true);
      
      await testDataManager.waitForConsistency();
      
      // Verify it's deleted from database
      expect(await testDataManager.verifyDealExists(createdDeal.id), false);
      
      // Verify service returns null for deleted deal
      final deletedDeal = await dealService.getDealById(createdDeal.id);
      expect(deletedDeal, null);
      
      print('✅ Deal deleted successfully');
    });
    
    test('TOGGLE STATUS: Should toggle deal active status in Supabase', () async {
      // Create test deal
      final dealData = testDataManager.createTestDealData(
        businessId: testBusinessId,
        titleSuffix: 'toggle_test',
      );
      
      final deal = Deal.fromJson(dealData);
      final createdDeal = await dealService.createDeal(deal);
      testDataManager.registerDeal(createdDeal.id);
      
      await testDataManager.waitForConsistency();
      
      // Initially should be active
      expect(createdDeal.isActive, true);
      
      // Toggle to inactive
      final inactiveDeal = await dealService.toggleDealStatus(createdDeal.id, false);
      expect(inactiveDeal.isActive, false);
      
      await testDataManager.waitForConsistency();
      
      // Verify in database
      var dbData = await testDataManager.getDealFromDb(createdDeal.id);
      expect(dbData!['is_active'], false);
      
      // Toggle back to active
      final activeDeal = await dealService.toggleDealStatus(createdDeal.id, true);
      expect(activeDeal.isActive, true);
      
      await testDataManager.waitForConsistency();
      
      // Verify in database
      dbData = await testDataManager.getDealFromDb(createdDeal.id);
      expect(dbData!['is_active'], true);
      
      print('✅ Deal status toggled successfully');
    });
  });

  group('🔍 Advanced API Tests', () {
    late String testBusinessId;
    
    setUp(() async {
      // Create test business
      final businessData = testDataManager.createTestBusinessData(
        nameSuffix: 'advanced_tests',
      );
      
      final business = Business.fromJson(businessData);
      final createdBusiness = await businessService.createBusiness(business);
      testBusinessId = createdBusiness.id;
      
      testDataManager.registerBusiness(testBusinessId);
      await testDataManager.waitForConsistency();
    });
    
    test('ACTIVE DEALS: Should fetch only active deals from Supabase', () async {
      // Create active and inactive deals
      final activeDeals = <String>[];
      final inactiveDeals = <String>[];
      
      // Create 2 active deals
      for (int i = 0; i < 2; i++) {
        final dealData = testDataManager.createTestDealData(
          businessId: testBusinessId,
          titleSuffix: 'active_$i',
        );
        dealData['is_active'] = true;
        
        final deal = Deal.fromJson(dealData);
        final created = await dealService.createDeal(deal);
        activeDeals.add(created.id);
        testDataManager.registerDeal(created.id);
      }
      
      // Create 1 inactive deal
      final inactiveDealData = testDataManager.createTestDealData(
        businessId: testBusinessId,
        titleSuffix: 'inactive',
      );
      inactiveDealData['is_active'] = false;
      
      final inactiveDeal = Deal.fromJson(inactiveDealData);
      final createdInactive = await dealService.createDeal(inactiveDeal);
      inactiveDeals.add(createdInactive.id);
      testDataManager.registerDeal(createdInactive.id);
      
      // Toggle it to inactive via service
      await dealService.toggleDealStatus(createdInactive.id, false);
      
      await testDataManager.waitForConsistency();
      
      // Fetch active deals
      final fetchedActiveDeals = await dealService.getActiveDeals();
      
      // Filter to only our test deals
      final testActiveDeals = fetchedActiveDeals
          .where((d) => d.title.contains(TestConfig.testDealPrefix) && d.businessId == testBusinessId)
          .toList();
      
      // Should find 2 active deals, not the inactive one
      expect(testActiveDeals.length, 2);
      expect(testActiveDeals.every((d) => d.isActive), true);
      
      // Verify inactive deal is not in the results
      final inactiveDealIds = testActiveDeals.map((d) => d.id).toSet();
      expect(inactiveDealIds.contains(createdInactive.id), false);
      
      print('✅ Active deals filtered correctly: ${testActiveDeals.length} active deals found');
    });
    
    test('SEARCH DEALS: Should search deals by title in Supabase', () async {
      // Create deals with searchable titles
      final searchTerm = 'PIZZA_SPECIAL';
      
      for (int i = 0; i < 2; i++) {
        final dealData = testDataManager.createTestDealData(
          businessId: testBusinessId,
          titleSuffix: '${searchTerm}_$i',
        );
        dealData['title'] = '${TestConfig.testDealPrefix}${searchTerm}_$i';
        
        final deal = Deal.fromJson(dealData);
        final created = await dealService.createDeal(deal);
        testDataManager.registerDeal(created.id);
      }
      
      // Create a deal that shouldn't match
      final nonMatchingData = testDataManager.createTestDealData(
        businessId: testBusinessId,
        titleSuffix: 'BURGER_DEAL',
      );
      nonMatchingData['title'] = '${TestConfig.testDealPrefix}BURGER_DEAL';
      
      final nonMatchingDeal = Deal.fromJson(nonMatchingData);
      final createdNonMatching = await dealService.createDeal(nonMatchingDeal);
      testDataManager.registerDeal(createdNonMatching.id);
      
      await testDataManager.waitForConsistency();
      
      // Search for pizza deals
      final searchResults = await dealService.searchDeals('PIZZA_SPECIAL');
      
      // Filter to our test deals
      final testResults = searchResults
          .where((d) => d.title.contains(TestConfig.testDealPrefix))
          .toList();
      
      expect(testResults.length, 2);
      expect(testResults.every((d) => d.title.contains(searchTerm)), true);
      
      print('✅ Search returned ${testResults.length} matching deals');
    });
    
    test('BUSINESS STATS: Should calculate correct statistics from Supabase', () async {
      // Create deals with known quantities
      const totalDeals = 5;
      const activeDeals = 3;
      
      final dealIds = <String>[];
      
      // Create active deals
      for (int i = 0; i < activeDeals; i++) {
        final dealData = testDataManager.createTestDealData(
          businessId: testBusinessId,
          titleSuffix: 'stats_active_$i',
        );
        
        final deal = Deal.fromJson(dealData);
        final created = await dealService.createDeal(deal);
        dealIds.add(created.id);
        testDataManager.registerDeal(created.id);
      }
      
      // Create inactive deals
      for (int i = 0; i < (totalDeals - activeDeals); i++) {
        final dealData = testDataManager.createTestDealData(
          businessId: testBusinessId,
          titleSuffix: 'stats_inactive_$i',
        );
        
        final deal = Deal.fromJson(dealData);
        final created = await dealService.createDeal(deal);
        await dealService.toggleDealStatus(created.id, false); // Make inactive
        dealIds.add(created.id);
        testDataManager.registerDeal(created.id);
      }
      
      await testDataManager.waitForConsistency();
      
      // Get business statistics
      final stats = await businessService.getBusinessStats(testBusinessId);
      
      // Verify statistics
      expect(stats['total_deals'], greaterThanOrEqualTo(totalDeals));
      expect(stats['active_deals'], greaterThanOrEqualTo(activeDeals));
      expect(stats['active_deals'] <= stats['total_deals'], true);
      
      // Verify with direct database counts
      final dbTotalCount = await testDataManager.countDealsForBusiness(testBusinessId);
      final dbActiveCount = await testDataManager.countActiveDealsForBusiness(testBusinessId);
      
      expect(stats['total_deals'], dbTotalCount);
      expect(stats['active_deals'], dbActiveCount);
      
      print('✅ Business stats: ${stats['total_deals']} total, ${stats['active_deals']} active');
    });
  });

  group('⚡ Performance and Reliability Tests', () {
    test('CONCURRENT OPERATIONS: Should handle multiple simultaneous API calls', () async {
      // Create test business
      final businessData = testDataManager.createTestBusinessData(
        nameSuffix: 'concurrent_test',
      );
      
      final business = Business.fromJson(businessData);
      final createdBusiness = await businessService.createBusiness(business);
      testDataManager.registerBusiness(createdBusiness.id);
      
      await testDataManager.waitForConsistency();
      
      // Create multiple deals concurrently
      const concurrentDeals = 5;
      final futures = <Future<Deal>>[];
      
      for (int i = 0; i < concurrentDeals; i++) {
        final dealData = testDataManager.createTestDealData(
          businessId: createdBusiness.id,
          titleSuffix: 'concurrent_$i',
        );
        
        final deal = Deal.fromJson(dealData);
        futures.add(dealService.createDeal(deal));
      }
      
      // Wait for all deals to be created
      final results = await Future.wait(futures);
      
      // Register all for cleanup
      for (final deal in results) {
        testDataManager.registerDeal(deal.id);
      }
      
      // Verify all were created successfully
      expect(results.length, concurrentDeals);
      expect(results.every((d) => d.id.isNotEmpty), true);
      
      await testDataManager.waitForConsistency();
      
      // Verify in database
      final dbDeals = await dealService.getDealsForBusiness(createdBusiness.id);
      final testDeals = dbDeals.where((d) => d.title.contains(TestConfig.testDealPrefix)).toList();
      expect(testDeals.length, greaterThanOrEqualTo(concurrentDeals));
      
      print('✅ Created $concurrentDeals deals concurrently');
    });
    
    test('ERROR HANDLING: Should handle non-existent resource gracefully', () async {
      const fakeId = 'non-existent-id-12345';
      
      // Try to fetch non-existent business
      final business = await businessService.getBusinessById(fakeId);
      expect(business, null);
      
      // Try to fetch non-existent deal
      final deal = await dealService.getDealById(fakeId);
      expect(deal, null);
      
      // Try to delete non-existent business (should not throw)
      final deleteResult = await businessService.deleteBusiness(fakeId);
      expect(deleteResult, false); // or handle as per your service implementation
      
      print('✅ Non-existent resources handled gracefully');
    });
  });
}