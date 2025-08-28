import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grabeat/models/business.dart';
import 'package:grabeat/services/business_service.dart';
import '../utils/test_helpers.dart';

void main() {
  late SupabaseClient supabase;
  late BusinessService businessService;
  
  setUpAll(() async {
    try {
      supabase = await TestHelpers.initializeTestSupabase();
      businessService = BusinessService();
    } catch (e) {
      print('Supabase not available for testing: $e');
    }
  });

  group('Business API Integration Tests with Seed Data', () {
    test('should fetch all 5 seeded restaurants for demo owner', () async {
      final businesses = await businessService.getBusinessesForOwner(
        TestHelpers.testOwnerId,
      );
      
      expect(businesses.length, 5);
      
      // Verify all restaurant names
      final businessNames = businesses.map((b) => b.name).toSet();
      expect(businessNames, containsAll(TestData.restaurantNames));
      
      // Verify all belong to same owner
      expect(
        businesses.every((b) => b.ownerId == TestHelpers.testOwnerId), 
        true,
      );
      
      // Verify all are active
      expect(businesses.every((b) => b.isActive), true);
    });

    test('should fetch specific restaurant by ID', () async {
      final spiceGarden = await businessService.getBusinessById(
        TestHelpers.spiceGardenId,
      );
      
      expect(spiceGarden, isNotNull);
      expect(spiceGarden!.name, 'Spice Garden Restaurant');
      expect(spiceGarden.description, contains('Indian cuisine'));
      expect(spiceGarden.address, contains('MG Road'));
      expect(spiceGarden.phone, '+91 80 2222 1111');
    });

    test('should search restaurants by cuisine type', () async {
      // Search for Italian
      final italianResults = await businessService.searchBusinesses('Italian');
      expect(italianResults.any((b) => b.name == 'Bella Vista Pizzeria'), true);
      
      // Search for Chinese
      final chineseResults = await businessService.searchBusinesses('Chinese');
      expect(chineseResults.any((b) => b.name == 'Dragon Palace'), true);
      
      // Search for Cafe
      final cafeResults = await businessService.searchBusinesses('Cafe');
      expect(cafeResults.any((b) => b.name == 'The Urban Cafe'), true);
    });

    test('should get business statistics for each restaurant', () async {
      final restaurants = [
        TestHelpers.spiceGardenId,
        TestHelpers.bellaVistaId,
        TestHelpers.dragonPalaceId,
        TestHelpers.urbanCafeId,
        TestHelpers.quickBitesId,
      ];
      
      for (final restaurantId in restaurants) {
        final stats = await businessService.getBusinessStats(restaurantId);
        
        TestHelpers.verifyBusinessStatistics(
          stats,
          minTotalDeals: 3, // Each restaurant has at least 3 deals
          minActiveDeals: 2, // At least 2 active deals
        );
        
        // Spice Garden should have some redemptions
        if (restaurantId == TestHelpers.spiceGardenId) {
          expect(stats['total_redemptions'] > 0, true);
        }
      }
    });

    test('should validate business ownership', () async {
      // Valid owner
      final isOwner = await businessService.isBusinessOwner(
        TestHelpers.spiceGardenId,
        TestHelpers.testOwnerId,
      );
      expect(isOwner, true);
      
      // Invalid owner
      final isNotOwner = await businessService.isBusinessOwner(
        TestHelpers.spiceGardenId,
        'different-owner-id',
      );
      expect(isNotOwner, false);
    });

    test('should update restaurant information', () async {
      // Get Quick Bites Express
      final quickBites = await businessService.getBusinessById(
        TestHelpers.quickBitesId,
      );
      
      expect(quickBites, isNotNull);
      
      // Update description
      final updated = quickBites!.copyWith(
        description: quickBites.description! + ' Now with 24/7 delivery!',
      );
      
      final result = await businessService.updateBusiness(updated);
      expect(result.description, contains('24/7 delivery'));
      
      // Restore original
      await businessService.updateBusiness(quickBites);
    });

    test('should handle location-based queries', () async {
      // Test with Bangalore coordinates
      final nearbyBusinesses = await businessService.getBusinessesNearLocation(
        12.9716, // Bangalore latitude
        77.5946, // Bangalore longitude
        radiusKm: 20,
      );
      
      // Should return all 5 restaurants as they're all in Bangalore
      expect(nearbyBusinesses.length >= 5, true);
    });
  });

  group('Business Creation and Management Tests', () {
    String? testBusinessId;

    setUp(() {
      testBusinessId = null;
    });

    tearDown(() async {
      if (testBusinessId != null) {
        await TestHelpers.cleanupTestData(supabase, businessId: testBusinessId);
      }
    });

    test('should create new business for existing owner', () async {
      final newBusiness = TestHelpers.createTestBusiness(
        name: 'New Test Restaurant',
        ownerId: TestHelpers.testOwnerId,
      );
      
      final created = await businessService.createBusiness(newBusiness);
      testBusinessId = created.id;
      
      expect(created.id.isNotEmpty, true);
      expect(created.name, 'New Test Restaurant');
      expect(created.ownerId, TestHelpers.testOwnerId);
      
      // Verify owner now has 6 businesses
      final allBusinesses = await businessService.getBusinessesForOwner(
        TestHelpers.testOwnerId,
      );
      expect(allBusinesses.length, 6);
    });

    test('should toggle business active status', () async {
      // Create a test business
      final business = await businessService.createBusiness(
        TestHelpers.createTestBusiness(),
      );
      testBusinessId = business.id;
      
      // Toggle to inactive
      final inactive = await businessService.toggleBusinessStatus(
        business.id,
        false,
      );
      expect(inactive.isActive, false);
      
      // Verify it doesn't appear in active businesses
      final activeBusinesses = await businessService.getActiveBusinesses();
      expect(activeBusinesses.any((b) => b.id == business.id), false);
      
      // Toggle back to active
      final active = await businessService.toggleBusinessStatus(
        business.id,
        true,
      );
      expect(active.isActive, true);
    });
  });

  group('Performance and Edge Case Tests', () {
    test('should handle concurrent requests efficiently', () async {
      final stopwatch = Stopwatch()..start();
      
      // Make 5 concurrent requests
      final futures = <Future<List<Business>>>[];
      for (int i = 0; i < 5; i++) {
        futures.add(businessService.getBusinessesForOwner(TestHelpers.testOwnerId));
      }
      
      final results = await Future.wait(futures);
      stopwatch.stop();
      
      // All should return same 5 businesses
      for (final result in results) {
        expect(result.length, 5);
      }
      
      // Should complete within reasonable time (adjust based on network)
      expect(stopwatch.elapsedMilliseconds < 5000, true,
          reason: 'Concurrent requests took too long');
    });

    test('should handle non-existent business gracefully', () async {
      final business = await businessService.getBusinessById(
        'non-existent-id',
      );
      expect(business, isNull);
    });

    test('should handle empty search results', () async {
      final results = await businessService.searchBusinesses(
        'XYZ123NonExistentSearch',
      );
      expect(results, isEmpty);
    });
  });
}