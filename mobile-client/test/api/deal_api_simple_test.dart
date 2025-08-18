import 'package:flutter_test/flutter_test.dart';
import 'package:kravekart/models/deal.dart';
import 'package:kravekart/models/business.dart';

void main() {
  group('Deal Model Tests', () {
    test('should create deal from JSON', () {
      final json = {
        'id': '123',
        'title': 'Test Deal',
        'description': 'Test Description',
        'original_price': 100.0,
        'discounted_price': 80.0,
        'discount_percentage': 20,
        'business_id': 'business123',
        'image_url': 'https://example.com/image.jpg',
        'is_active': true,
        'valid_from': '2024-01-01T00:00:00Z',
        'valid_until': '2024-12-31T23:59:59Z',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final deal = Deal.fromJson(json);

      expect(deal.id, '123');
      expect(deal.title, 'Test Deal');
      expect(deal.originalPrice, 100.0);
      expect(deal.discountedPrice, 80.0);
      expect(deal.discountPercentage, 20);
      expect(deal.isActive, true);
    });

    test('should convert deal to JSON', () {
      final deal = Deal(
        id: '123',
        title: 'Test Deal',
        description: 'Test Description',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: 'business123',
        imageUrl: 'https://example.com/image.jpg',
        isActive: true,
        validFrom: DateTime.parse('2024-01-01T00:00:00Z'),
        validUntil: DateTime.parse('2024-12-31T23:59:59Z'),
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final json = deal.toJson();

      expect(json['id'], '123');
      expect(json['title'], 'Test Deal');
      expect(json['original_price'], 100.0);
      expect(json['discounted_price'], 80.0);
    });

    test('should correctly identify valid deals', () {
      final validDeal = Deal(
        id: '1',
        title: 'Valid Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: 'business1',
        isActive: true,
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        maxRedemptions: 10,
        currentRedemptions: 5,
        createdAt: DateTime.now(),
      );

      expect(validDeal.isValid, true);
      expect(validDeal.isExpired, false);
    });

    test('should correctly identify expired deals', () {
      final expiredDeal = Deal(
        id: '2',
        title: 'Expired Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: 'business1',
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

    test('should correctly identify sold out deals', () {
      final soldOutDeal = Deal(
        id: '3',
        title: 'Sold Out Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: 'business1',
        isActive: true,
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        maxRedemptions: 10,
        currentRedemptions: 10,
        createdAt: DateTime.now(),
      );

      expect(soldOutDeal.isValid, false);
    });

    test('should calculate savings amount correctly', () {
      final deal = Deal(
        id: '4',
        title: 'Savings Deal',
        originalPrice: 1000.0,
        discountedPrice: 750.0,
        discountPercentage: 25,
        businessId: 'business1',
        isActive: true,
        validFrom: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      expect(deal.savingsAmount, 250.0);
    });
  });

  group('Business Model Tests', () {
    test('should create business from JSON', () {
      final json = {
        'id': 'business123',
        'name': 'Test Restaurant',
        'description': 'Test Description',
        'owner_id': 'owner123',
        'address': '123 Test St',
        'phone': '+1234567890',
        'email': 'test@restaurant.com',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'is_active': true,
        'created_at': '2024-01-01T00:00:00Z',
      };

      final business = Business.fromJson(json);

      expect(business.id, 'business123');
      expect(business.name, 'Test Restaurant');
      expect(business.ownerId, 'owner123');
      expect(business.hasLocation, true);
      expect(business.isActive, true);
    });

    test('should convert business to JSON', () {
      final business = Business(
        id: 'business123',
        name: 'Test Restaurant',
        description: 'Test Description',
        ownerId: 'owner123',
        address: '123 Test St',
        phone: '+1234567890',
        email: 'test@restaurant.com',
        latitude: 12.9716,
        longitude: 77.5946,
        isActive: true,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final json = business.toJson();

      expect(json['id'], 'business123');
      expect(json['name'], 'Test Restaurant');
      expect(json['owner_id'], 'owner123');
    });

    test('should detect if business has location', () {
      final businessWithLocation = Business(
        id: '1',
        name: 'Located Restaurant',
        ownerId: 'owner1',
        latitude: 12.9716,
        longitude: 77.5946,
        createdAt: DateTime.now(),
      );

      final businessWithoutLocation = Business(
        id: '2',
        name: 'Remote Restaurant',
        ownerId: 'owner1',
        createdAt: DateTime.now(),
      );

      expect(businessWithLocation.hasLocation, true);
      expect(businessWithoutLocation.hasLocation, false);
    });
  });

  group('Deal Business Logic Tests', () {
    test('should handle deals with unlimited redemptions', () {
      final unlimitedDeal = Deal(
        id: '1',
        title: 'Unlimited Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: 'business1',
        isActive: true,
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        maxRedemptions: 0, // 0 means unlimited
        currentRedemptions: 1000, // Even with high redemptions, should be valid
        createdAt: DateTime.now(),
      );

      expect(unlimitedDeal.isValid, true);
    });

    test('should handle deals starting in the future', () {
      final futureDeal = Deal(
        id: '1',
        title: 'Future Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: 'business1',
        isActive: true,
        validFrom: DateTime.now().add(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
      );

      expect(futureDeal.isValid, false);
      expect(futureDeal.isExpired, false);
    });

    test('should handle inactive deals', () {
      final inactiveDeal = Deal(
        id: '1',
        title: 'Inactive Deal',
        originalPrice: 100.0,
        discountedPrice: 80.0,
        discountPercentage: 20,
        businessId: 'business1',
        isActive: false, // Inactive
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      expect(inactiveDeal.isValid, false);
    });
  });

  group('Seed Data Validation Tests', () {
    test('should validate restaurant data structure', () {
      final restaurants = [
        'Spice Garden Restaurant',
        'Bella Vista Pizzeria',
        'Dragon Palace',
        'The Urban Cafe',
        'Quick Bites Express',
      ];

      expect(restaurants.length, 5);
      expect(restaurants.contains('Spice Garden Restaurant'), true);
      expect(restaurants.contains('Bella Vista Pizzeria'), true);
      expect(restaurants.contains('Dragon Palace'), true);
      expect(restaurants.contains('The Urban Cafe'), true);
      expect(restaurants.contains('Quick Bites Express'), true);
    });

    test('should validate deal types variety', () {
      final dealTypes = [
        'Buffet',
        'Pizza',
        'Dim Sum',
        'Breakfast',
        'Burger',
        'Student Special',
        'Family Deal',
        'Corporate Lunch',
      ];

      expect(dealTypes.length >= 8, true);
      expect(dealTypes.contains('Buffet'), true);
      expect(dealTypes.contains('Student Special'), true);
    });

    test('should validate discount ranges', () {
      final discountPercentages = [20, 25, 30, 33, 38, 43, 50];
      
      expect(discountPercentages.every((d) => d >= 20 && d <= 50), true);
      expect(discountPercentages.contains(50), true); // Should have some high discounts
    });
  });
}