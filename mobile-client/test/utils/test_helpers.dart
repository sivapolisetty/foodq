import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grabeat/models/deal.dart';
import 'package:grabeat/models/business.dart';

/// Test helper utilities for API testing
class TestHelpers {
  static const String testOwnerId = '11111111-1111-1111-1111-111111111111';
  
  // Test business IDs from seed data
  static const String spiceGardenId = '22222222-2222-2222-2222-222222222221';
  static const String bellaVistaId = '22222222-2222-2222-2222-222222222222';
  static const String dragonPalaceId = '22222222-2222-2222-2222-222222222223';
  static const String urbanCafeId = '22222222-2222-2222-2222-222222222224';
  static const String quickBitesId = '22222222-2222-2222-2222-222222222225';

  /// Initialize test environment
  static Future<SupabaseClient> initializeTestSupabase() async {
    // Use test environment variables
    const testUrl = String.fromEnvironment('SUPABASE_TEST_URL', 
        defaultValue: 'http://localhost:54321');
    const testAnonKey = String.fromEnvironment('SUPABASE_TEST_ANON_KEY',
        defaultValue: 'your-test-anon-key');
    
    await Supabase.initialize(
      url: testUrl,
      anonKey: testAnonKey,
    );
    
    return Supabase.instance.client;
  }

  /// Create a test business
  static Business createTestBusiness({
    String? id,
    String? name,
    String? ownerId,
    bool isActive = true,
  }) {
    return Business(
      id: id ?? '',
      name: name ?? 'Test Restaurant ${DateTime.now().millisecondsSinceEpoch}',
      description: 'A test restaurant for API testing',
      ownerId: ownerId ?? testOwnerId,
      address: '123 Test Street, Test City',
      phone: '+1234567890',
      email: 'test${DateTime.now().millisecondsSinceEpoch}@restaurant.com',
      latitude: 12.9716,
      longitude: 77.5946,
      isActive: isActive,
      createdAt: DateTime.now(),
    );
  }

  /// Create a test deal
  static Deal createTestDeal({
    String? id,
    String? title,
    required String businessId,
    double? originalPrice,
    double? discountedPrice,
    int? discountPercentage,
    bool isActive = true,
    DateTime? validFrom,
    DateTime? validUntil,
    int maxRedemptions = 0,
    int currentRedemptions = 0,
  }) {
    final original = originalPrice ?? 500.0;
    final discounted = discountedPrice ?? 350.0;
    final discount = discountPercentage ?? 
        ((original - discounted) / original * 100).round();
    
    return Deal(
      id: id ?? '',
      title: title ?? 'Test Deal ${DateTime.now().millisecondsSinceEpoch}',
      description: 'Test deal description',
      originalPrice: original,
      discountedPrice: discounted,
      discountPercentage: discount,
      businessId: businessId,
      imageUrl: 'https://example.com/test-image.jpg',
      isActive: isActive,
      validFrom: validFrom ?? DateTime.now(),
      validUntil: validUntil ?? DateTime.now().add(const Duration(days: 30)),
      termsConditions: 'Test terms and conditions',
      maxRedemptions: maxRedemptions,
      currentRedemptions: currentRedemptions,
      createdAt: DateTime.now(),
    );
  }

  /// Create multiple test deals
  static List<Deal> createTestDeals({
    required String businessId,
    int count = 5,
    bool mixActiveInactive = false,
    bool includeExpired = false,
    bool includeExpiringSoon = false,
  }) {
    final deals = <Deal>[];
    
    for (int i = 0; i < count; i++) {
      bool isActive = mixActiveInactive ? i % 2 == 0 : true;
      
      DateTime? validFrom;
      DateTime? validUntil;
      
      if (includeExpired && i == 0) {
        validFrom = DateTime.now().subtract(const Duration(days: 60));
        validUntil = DateTime.now().subtract(const Duration(days: 1));
      } else if (includeExpiringSoon && i == 1) {
        validFrom = DateTime.now().subtract(const Duration(days: 10));
        validUntil = DateTime.now().add(const Duration(days: 2));
      } else {
        validFrom = DateTime.now().subtract(Duration(days: i));
        validUntil = DateTime.now().add(Duration(days: 30 + i * 10));
      }
      
      deals.add(createTestDeal(
        title: 'Test Deal ${i + 1}',
        businessId: businessId,
        originalPrice: 100.0 * (i + 1),
        discountedPrice: 70.0 * (i + 1),
        discountPercentage: 20 + (i * 5), // 20%, 25%, 30%, etc.
        isActive: isActive,
        validFrom: validFrom,
        validUntil: validUntil,
        maxRedemptions: i == 2 ? 10 : 0, // One deal with limited redemptions
        currentRedemptions: i == 2 ? 8 : 0, // Almost sold out
      ));
    }
    
    return deals;
  }

  /// Clean up test data
  static Future<void> cleanupTestData(SupabaseClient supabase, {
    String? businessId,
    String? dealId,
  }) async {
    try {
      if (dealId != null) {
        await supabase.from('deals').delete().eq('id', dealId);
      }
      
      if (businessId != null) {
        // This will cascade delete all deals
        await supabase.from('businesses').delete().eq('id', businessId);
      }
    } catch (e) {
      debugPrint('Cleanup error (might be expected): $e');
    }
  }

  /// Verify deal statistics
  static void verifyDealStatistics(List<Deal> deals, {
    required int expectedTotal,
    required int expectedActive,
    required int expectedExpired,
    required int expectedExpiringSoon,
  }) {
    expect(deals.length, expectedTotal, reason: 'Total deals count mismatch');
    
    final activeDeals = deals.where((d) => d.isActive && d.isValid).toList();
    expect(activeDeals.length, expectedActive, reason: 'Active deals count mismatch');
    
    final expiredDeals = deals.where((d) => d.isExpired).toList();
    expect(expiredDeals.length, expectedExpired, reason: 'Expired deals count mismatch');
    
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));
    final expiringSoonDeals = deals.where((d) => 
      d.validUntil.isAfter(now) && 
      d.validUntil.isBefore(threeDaysFromNow) &&
      d.isActive
    ).toList();
    expect(expiringSoonDeals.length, expectedExpiringSoon, 
        reason: 'Expiring soon deals count mismatch');
  }

  /// Verify business statistics
  static void verifyBusinessStatistics(
    Map<String, dynamic> stats, {
    int? minTotalDeals,
    int? minActiveDeals,
    int? minRedemptions,
  }) {
    expect(stats.containsKey('total_deals'), true);
    expect(stats.containsKey('active_deals'), true);
    expect(stats.containsKey('total_redemptions'), true);
    
    if (minTotalDeals != null) {
      expect(stats['total_deals'] >= minTotalDeals, true,
          reason: 'Total deals less than minimum expected');
    }
    
    if (minActiveDeals != null) {
      expect(stats['active_deals'] >= minActiveDeals, true,
          reason: 'Active deals less than minimum expected');
    }
    
    if (minRedemptions != null) {
      expect(stats['total_redemptions'] >= minRedemptions, true,
          reason: 'Total redemptions less than minimum expected');
    }
    
    // Active deals should never exceed total deals
    expect(stats['active_deals'] <= stats['total_deals'], true,
        reason: 'Active deals exceed total deals');
  }

  /// Create a widget for testing
  static Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Wait for async operations with timeout
  static Future<void> waitForAsync({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Mock Supabase responses for unit testing
  static Map<String, dynamic> createMockDealResponse({
    String? id,
    String? businessId,
  }) {
    return {
      'id': id ?? 'mock-deal-id',
      'title': 'Mock Deal',
      'description': 'Mock deal description',
      'original_price': 100.0,
      'discounted_price': 70.0,
      'discount_percentage': 30,
      'business_id': businessId ?? 'mock-business-id',
      'image_url': 'https://example.com/mock.jpg',
      'is_active': true,
      'valid_from': DateTime.now().toIso8601String(),
      'valid_until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'terms_conditions': 'Mock terms',
      'max_redemptions': 0,
      'current_redemptions': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Mock Supabase responses for business
  static Map<String, dynamic> createMockBusinessResponse({
    String? id,
    String? ownerId,
  }) {
    return {
      'id': id ?? 'mock-business-id',
      'name': 'Mock Restaurant',
      'description': 'Mock restaurant description',
      'image_url': 'https://example.com/mock-restaurant.jpg',
      'owner_id': ownerId ?? 'mock-owner-id',
      'address': '123 Mock Street',
      'phone': '+1234567890',
      'email': 'mock@restaurant.com',
      'latitude': 12.9716,
      'longitude': 77.5946,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Extension methods for testing
extension DealTestExtensions on Deal {
  /// Check if deal matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        (description?.toLowerCase().contains(lowerQuery) ?? false);
  }
  
  /// Check if deal is in category (mock implementation)
  bool isInCategory(String categoryName) {
    // This would normally check against actual category mappings
    // For testing, we'll use simple rules
    switch (categoryName.toLowerCase()) {
      case 'buffet':
        return title.toLowerCase().contains('buffet');
      case 'combo':
        return title.toLowerCase().contains('combo');
      case 'student':
        return title.toLowerCase().contains('student');
      default:
        return false;
    }
  }
}

/// Test data constants
class TestData {
  static const List<String> restaurantNames = [
    'Spice Garden Restaurant',
    'Bella Vista Pizzeria',
    'Dragon Palace',
    'The Urban Cafe',
    'Quick Bites Express',
  ];
  
  static const List<String> dealTitles = [
    'Lunch Buffet Special',
    'Buy 1 Get 1 Pizza',
    'Dim Sum Festival',
    'All Day Breakfast',
    'Mega Burger Combo',
  ];
  
  static const List<String> categories = [
    'Buffet',
    'Combo Meals',
    'Happy Hours',
    'Student Offers',
    'Family Deals',
    'Express Meals',
  ];
}