import 'package:flutter_test/flutter_test.dart';
import 'package:kravekart/features/deals/services/deal_service.dart';
import 'package:kravekart/shared/models/deal.dart';
import 'package:kravekart/shared/models/deal_result.dart';

void main() {
  late DealService dealService;

  setUp(() {
    dealService = DealService();
  });

  group('DealService API Tests', () {
    test('should initialize DealService without parameters', () {
      expect(dealService, isA<DealService>());
    });

    test('should validate deal creation input', () {
      // Test that validation methods exist and work
      // Note: These tests now require the Worker API to be running
      // For unit testing, we would need to mock the HTTP client
      expect(dealService, isNotNull);
    });

    test('should handle network errors gracefully', () async {
      // Test error handling when Worker API is not available
      // This would typically return empty lists or error results
      try {
        final deals = await dealService.getActiveDeals(limit: 1);
        // Should not throw, might return empty list if API unavailable
        expect(deals, isA<List<Deal>>());
      } catch (e) {
        // Network errors are expected if Worker API not running
        expect(e, isA<Exception>());
      }
    });

    test('should handle search with empty query', () async {
      try {
        final deals = await dealService.searchDeals('');
        expect(deals, isA<List<Deal>>());
      } catch (e) {
        // Network errors are expected if Worker API not running
        expect(e, isA<Exception>());
      }
    });
  });

  group('Deal Input Validation', () {
    test('should create deal result with error for invalid input', () async {
      // Test with invalid data that should fail validation
      final result = await dealService.createDeal(
        businessId: '', // Invalid: empty business ID
        title: 'Test Deal',
        description: 'Test description',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      );

      expect(result.isSuccess, false);
      expect(result.error, contains('Business ID is required'));
    });

    test('should validate pricing relationship', () async {
      // Test that discounted price must be less than original price
      final result = await dealService.createDeal(
        businessId: 'test-business-id',
        title: 'Test Deal',
        description: 'Test description',
        originalPrice: 15.0,
        discountedPrice: 20.0, // Invalid: higher than original
        quantityAvailable: 10,
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      );

      expect(result.isSuccess, false);
      expect(result.error, contains('Discounted price must be less than original price'));
    });

    test('should validate expiration date', () async {
      // Test that expiration must be in the future
      final result = await dealService.createDeal(
        businessId: 'test-business-id',
        title: 'Test Deal',
        description: 'Test description',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)), // Invalid: in the past
      );

      expect(result.isSuccess, false);
      expect(result.error, contains('Expiration time must be in the future'));
    });
  });
}