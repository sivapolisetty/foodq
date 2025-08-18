import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kravekart/models/deal.dart';
import 'package:kravekart/models/business.dart';
import 'package:kravekart/services/deal_service.dart';
import 'package:kravekart/services/business_service.dart';

void main() {
  late SupabaseClient supabase;
  late DealService dealService;
  late BusinessService businessService;
  
  // Test data
  const testOwnerId = 'test-owner-123';
  const testBusinessId = 'test-business-456';
  
  setUpAll(() async {
    // Initialize Supabase test client
    try {
      await Supabase.initialize(
        url: 'http://localhost:54321', // Default local Supabase URL
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0', // Default anon key
      );
      
      supabase = Supabase.instance.client;
      dealService = DealService();
      businessService = BusinessService();
    } catch (e) {
      // Skip tests if Supabase is not available
      print('Supabase not available for testing: $e');
    }
  });

  group('Business API Tests', () {
    test('should create a new business', () async {
      final business = Business(
        id: '',
        name: 'Test Restaurant',
        description: 'A test restaurant for API testing',
        ownerId: testOwnerId,
        address: '123 Test Street, Test City',
        phone: '+1234567890',
        email: 'test@restaurant.com',
        latitude: 12.9716,
        longitude: 77.5946,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final createdBusiness = await businessService.createBusiness(business);

      expect(createdBusiness.id.isNotEmpty, true);
      expect(createdBusiness.name, 'Test Restaurant');
      expect(createdBusiness.ownerId, testOwnerId);
    });

    test('should fetch all businesses for owner', () async {
      final businesses = await businessService.getBusinessesForOwner(testOwnerId);
      
      expect(businesses.isNotEmpty, true);
      expect(businesses.every((b) => b.ownerId == testOwnerId), true);
    });

    test('should update business information', () async {
      final businesses = await businessService.getBusinessesForOwner(testOwnerId);
      if (businesses.isEmpty) return;

      final business = businesses.first;
      final updatedBusiness = business.copyWith(
        name: 'Updated Restaurant Name',
        description: 'Updated description',
      );

      final result = await businessService.updateBusiness(updatedBusiness);

      expect(result.name, 'Updated Restaurant Name');
      expect(result.description, 'Updated description');
    });

    test('should toggle business active status', () async {
      final businesses = await businessService.getBusinessesForOwner(testOwnerId);
      if (businesses.isEmpty) return;

      final business = businesses.first;
      final updatedBusiness = await businessService.toggleBusinessStatus(
        business.id, 
        !business.isActive,
      );

      expect(updatedBusiness.isActive, !business.isActive);
    });

    test('should search businesses by name', () async {
      final results = await businessService.searchBusinesses('Restaurant');
      
      expect(results.isNotEmpty, true);
      expect(
        results.every((b) => 
          b.name.toLowerCase().contains('restaurant') || 
          (b.description?.toLowerCase().contains('restaurant') ?? false)
        ), 
        true,
      );
    });
  });

  group('Deal API Tests', () {
    late String businessId;

    setUpAll(() async {
      // Get or create a test business
      final businesses = await businessService.getBusinessesForOwner(testOwnerId);
      if (businesses.isNotEmpty) {
        businessId = businesses.first.id;
      } else {
        final business = await businessService.createBusiness(Business(
          id: '',
          name: 'Test Restaurant for Deals',
          ownerId: testOwnerId,
          createdAt: DateTime.now(),
        ));
        businessId = business.id;
      }
    });

    test('should create a new deal', () async {
      final deal = Deal(
        id: '',
        title: 'Test Deal - 50% Off Pizza',
        description: 'Get 50% off on all pizzas',
        originalPrice: 500.0,
        discountedPrice: 250.0,
        discountPercentage: 50,
        businessId: businessId,
        imageUrl: 'https://example.com/pizza.jpg',
        isActive: true,
        validFrom: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 30)),
        termsConditions: 'Valid for dine-in only',
        maxRedemptions: 100,
        currentRedemptions: 0,
        createdAt: DateTime.now(),
      );

      final createdDeal = await dealService.createDeal(deal);

      expect(createdDeal.id.isNotEmpty, true);
      expect(createdDeal.title, 'Test Deal - 50% Off Pizza');
      expect(createdDeal.discountPercentage, 50);
      expect(createdDeal.businessId, businessId);
    });

    test('should fetch all deals for a business', () async {
      final deals = await dealService.getDealsForBusiness(businessId);
      
      expect(deals.isNotEmpty, true);
      expect(deals.every((d) => d.businessId == businessId), true);
    });

    test('should fetch only active deals', () async {
      final activeDeals = await dealService.getActiveDeals();
      
      expect(activeDeals.isNotEmpty, true);
      expect(activeDeals.every((d) => d.isActive && d.isValid), true);
    });

    test('should update deal information', () async {
      final deals = await dealService.getDealsForBusiness(businessId);
      if (deals.isEmpty) return;

      final deal = deals.first;
      final updatedDeal = deal.copyWith(
        title: 'Updated Deal Title',
        discountedPrice: 200.0,
        discountPercentage: 60,
      );

      final result = await dealService.updateDeal(updatedDeal);

      expect(result.title, 'Updated Deal Title');
      expect(result.discountedPrice, 200.0);
      expect(result.discountPercentage, 60);
    });

    test('should toggle deal active status', () async {
      final deals = await dealService.getDealsForBusiness(businessId);
      if (deals.isEmpty) return;

      final deal = deals.first;
      final updatedDeal = await dealService.toggleDealStatus(
        deal.id,
        !deal.isActive,
      );

      expect(updatedDeal.isActive, !deal.isActive);
    });

    test('should search deals by keyword', () async {
      final results = await dealService.searchDeals('pizza');
      
      expect(results.isNotEmpty, true);
      expect(
        results.every((d) => 
          d.title.toLowerCase().contains('pizza') || 
          (d.description?.toLowerCase().contains('pizza') ?? false)
        ),
        true,
      );
    });

    test('should fetch featured deals with high discount', () async {
      final featuredDeals = await dealService.getFeaturedDeals(limit: 5);
      
      expect(featuredDeals.length <= 5, true);
      expect(featuredDeals.every((d) => d.discountPercentage >= 20), true);
      
      // Verify deals are sorted by discount percentage (descending)
      for (int i = 0; i < featuredDeals.length - 1; i++) {
        expect(
          featuredDeals[i].discountPercentage >= 
          featuredDeals[i + 1].discountPercentage,
          true,
        );
      }
    });

    test('should fetch deals expiring soon', () async {
      final expiringSoon = await dealService.getDealsExpiringSoon(daysAhead: 3);
      
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));
      
      expect(
        expiringSoon.every((d) => 
          d.validUntil.isAfter(now) &&
          d.validUntil.isBefore(threeDaysFromNow) &&
          d.isActive
        ),
        true,
      );
    });

    test('should delete a deal', () async {
      // Create a deal to delete
      final dealToDelete = await dealService.createDeal(Deal(
        id: '',
        title: 'Deal to Delete',
        description: 'This deal will be deleted',
        originalPrice: 100.0,
        discountedPrice: 50.0,
        discountPercentage: 50,
        businessId: businessId,
        isActive: true,
        validFrom: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      ));

      // Delete the deal
      final deleteResult = await dealService.deleteDeal(dealToDelete.id);
      expect(deleteResult, true);

      // Verify it's deleted
      final deletedDeal = await dealService.getDealById(dealToDelete.id);
      expect(deletedDeal, null);
    });

    test('should handle deal image upload', () async {
      final deals = await dealService.getDealsForBusiness(businessId);
      if (deals.isEmpty) return;

      final deal = deals.first;
      
      // In a real test, you would provide an actual file path
      // For now, we'll test the URL generation
      const testImagePath = '/path/to/test/image.jpg';
      
      try {
        final imageUrl = await dealService.uploadDealImage(deal.id, testImagePath);
        
        if (imageUrl != null) {
          expect(imageUrl.contains('deals'), true);
          expect(imageUrl.contains(deal.id), true);
        }
      } catch (e) {
        // Expected to fail without actual file
        expect(e.toString().contains('upload'), true);
      }
    });
  });

  group('Business Statistics API Tests', () {
    test('should fetch business statistics', () async {
      final businesses = await businessService.getBusinessesForOwner(testOwnerId);
      if (businesses.isEmpty) return;

      final business = businesses.first;
      final stats = await businessService.getBusinessStats(business.id);

      expect(stats.containsKey('total_deals'), true);
      expect(stats.containsKey('active_deals'), true);
      expect(stats.containsKey('total_redemptions'), true);
      
      expect(stats['total_deals'] >= 0, true);
      expect(stats['active_deals'] >= 0, true);
      expect(stats['active_deals'] <= stats['total_deals'], true);
    });
  });

  group('Deal Validation Tests', () {
    test('should correctly identify valid deals', () async {
      final deal = Deal(
        id: 'test-deal-1',
        title: 'Valid Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: testBusinessId,
        isActive: true,
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        maxRedemptions: 10,
        currentRedemptions: 5,
        createdAt: DateTime.now(),
      );

      expect(deal.isValid, true);
      expect(deal.isExpired, false);
    });

    test('should correctly identify expired deals', () async {
      final expiredDeal = Deal(
        id: 'test-deal-2',
        title: 'Expired Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: testBusinessId,
        isActive: true,
        validFrom: DateTime.now().subtract(const Duration(days: 10)),
        validUntil: DateTime.now().subtract(const Duration(days: 1)),
        maxRedemptions: 10,
        currentRedemptions: 5,
        createdAt: DateTime.now(),
      );

      expect(expiredDeal.isValid, false);
      expect(expiredDeal.isExpired, true);
    });

    test('should correctly identify sold out deals', () async {
      final soldOutDeal = Deal(
        id: 'test-deal-3',
        title: 'Sold Out Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: testBusinessId,
        isActive: true,
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        maxRedemptions: 10,
        currentRedemptions: 10,
        createdAt: DateTime.now(),
      );

      expect(soldOutDeal.isValid, false);
    });

    test('should calculate savings amount correctly', () async {
      final deal = Deal(
        id: 'test-deal-4',
        title: 'Savings Deal',
        originalPrice: 1000.0,
        discountedPrice: 750.0,
        discountPercentage: 25,
        businessId: testBusinessId,
        isActive: true,
        validFrom: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      expect(deal.savingsAmount, 250.0);
    });
  });
}