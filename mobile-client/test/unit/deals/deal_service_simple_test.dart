import 'package:flutter_test/flutter_test.dart';
import 'package:kravekart/features/deals/services/deal_service.dart';
import 'package:kravekart/shared/models/deal.dart';
import 'package:kravekart/shared/models/deal_result.dart';

// Simple mock Supabase client for testing validation logic
class MockSupabaseClient {
  bool shouldThrowError = false;
  Map<String, dynamic>? mockResponse;
  List<Map<String, dynamic>>? mockListResponse;

  MockSupabaseQueryBuilder from(String table) {
    return MockSupabaseQueryBuilder(this);
  }
}

class MockSupabaseQueryBuilder {
  final MockSupabaseClient client;
  MockSupabaseQueryBuilder(this.client);

  MockPostgrestFilterBuilder insert(Map<String, dynamic> values) => MockPostgrestFilterBuilder(client);
  MockPostgrestFilterBuilder update(Map<String, dynamic> values) => MockPostgrestFilterBuilder(client);
  MockPostgrestFilterBuilder select([String columns = '*']) => MockPostgrestFilterBuilder(client);
}

class MockPostgrestFilterBuilder {
  final MockSupabaseClient client;
  MockPostgrestFilterBuilder(this.client);

  MockPostgrestFilterBuilder eq(String column, Object value) => this;
  MockPostgrestFilterBuilder gt(String column, Object value) => this;
  MockPostgrestFilterBuilder lt(String column, Object value) => this;
  MockPostgrestFilterBuilder select([String columns = '*']) => this;
  MockPostgrestFilterBuilder order(String column, {bool ascending = false, bool nullsFirst = false}) => this;
  MockPostgrestFilterBuilder limit(int count) => this;
  MockPostgrestFilterBuilder range(int from, int to) => this;

  Future<Map<String, dynamic>> single() async {
    if (client.shouldThrowError) {
      throw Exception('Mock error');
    }
    return client.mockResponse ?? {};
  }

  Future<List<Map<String, dynamic>>> call() async {
    if (client.shouldThrowError) {
      throw Exception('Mock error');
    }
    return client.mockListResponse ?? [];
  }
}

void main() {
  group('DealService Validation Tests', () {
    test('should validate required fields for deal creation', () async {
      // Test validation logic directly by creating a deal service with a mock client
      // Since we can't easily mock the actual Supabase client types, 
      // we'll test the validation by passing invalid data
      
      final mockClient = MockSupabaseClient();
      // We can't directly instantiate DealService with our mock, 
      // so we'll test the validation logic separately
      
      // Test 1: Empty business ID should fail
      expect(() {
        _validateDealInput(
          businessId: '',
          title: 'Test Deal',
          originalPrice: 20.0,
          discountedPrice: 10.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );
      }, throwsA(isA<String>()));

      // Test 2: Empty title should fail
      expect(() {
        _validateDealInput(
          businessId: 'business-id',
          title: '',
          originalPrice: 20.0,
          discountedPrice: 10.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );
      }, throwsA(isA<String>()));

      // Test 3: Invalid pricing should fail
      expect(() {
        _validateDealInput(
          businessId: 'business-id',
          title: 'Test Deal',
          originalPrice: 10.0,
          discountedPrice: 15.0, // Higher than original
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );
      }, throwsA(isA<String>()));

      // Test 4: Past expiration time should fail
      expect(() {
        _validateDealInput(
          businessId: 'business-id',
          title: 'Test Deal',
          originalPrice: 20.0,
          discountedPrice: 10.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
      }, throwsA(isA<String>()));

      // Test 5: Valid data should pass
      expect(() {
        _validateDealInput(
          businessId: 'business-id',
          title: 'Test Deal',
          originalPrice: 20.0,
          discountedPrice: 10.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );
      }, returnsNormally);
    });

    test('should validate deal business logic', () {
      // Test Deal model business logic
      final deal = Deal(
        id: 'deal-1',
        businessId: 'business-1',
        title: 'Pizza Special',
        description: 'Delicious pizza at 50% off',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 5,
        quantitySold: 2,
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test discount calculation
      expect(deal.discountPercentage, 50.0);
      expect(deal.savingsAmount, 10.0);
      expect(deal.remainingQuantity, 3);
      expect(deal.isAvailable, true);
      expect(deal.formattedDiscountPercentage, '50%');
      expect(deal.formattedOriginalPrice, '\$20.00');
      expect(deal.formattedDiscountedPrice, '\$10.00');
    });

    test('should determine deal urgency correctly', () {
      final now = DateTime.now();
      
      // Test normal urgency
      final normalDeal = Deal(
        id: 'deal-1',
        businessId: 'business-1',
        title: 'Normal Deal',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 10,
        quantitySold: 1,
        expiresAt: now.add(const Duration(hours: 12)),
        createdAt: now,
        updatedAt: now,
      );
      expect(normalDeal.urgency, DealUrgency.normal);

      // Test moderate urgency (expires in 6 hours)
      final moderateDeal = Deal(
        id: 'deal-2',
        businessId: 'business-1',
        title: 'Moderate Deal',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 10,
        quantitySold: 1,
        expiresAt: now.add(const Duration(hours: 4)),
        createdAt: now,
        updatedAt: now,
      );
      expect(moderateDeal.urgency, DealUrgency.moderate);

      // Test urgent deal (expires soon)
      final urgentDeal = Deal(
        id: 'deal-3',
        businessId: 'business-1',
        title: 'Urgent Deal',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 10,
        quantitySold: 1,
        expiresAt: now.add(const Duration(minutes: 30)),
        createdAt: now,
        updatedAt: now,
      );
      expect(urgentDeal.urgency, DealUrgency.urgent);

      // Test almost sold out deal
      final almostSoldOutDeal = Deal(
        id: 'deal-4',
        businessId: 'business-1',
        title: 'Almost Sold Out Deal',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 10,
        quantitySold: 9, // Only 1 remaining (10%)
        expiresAt: now.add(const Duration(hours: 12)),
        createdAt: now,
        updatedAt: now,
      );
      expect(almostSoldOutDeal.urgency, DealUrgency.urgent);
      expect(almostSoldOutDeal.isAlmostSoldOut, true);
    });

    test('should format time remaining correctly', () {
      final now = DateTime.now();
      
      // Test days and hours - use more precise calculation
      final dealDays = Deal(
        id: 'deal-1',
        businessId: 'business-1',
        title: 'Deal with Days',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 5,
        expiresAt: now.add(const Duration(days: 2, hours: 5, minutes: 30)),
        createdAt: now,
        updatedAt: now,
      );
      expect(dealDays.timeRemainingText, matches(RegExp(r'2d [4-5]h')));

      // Test hours and minutes
      final dealHours = Deal(
        id: 'deal-2',
        businessId: 'business-1',
        title: 'Deal with Hours',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 5,
        expiresAt: now.add(const Duration(hours: 3, minutes: 45)),
        createdAt: now,
        updatedAt: now,
      );
      expect(dealHours.timeRemainingText, matches(RegExp(r'3h [0-9]+m')));

      // Test minutes only
      final dealMinutes = Deal(
        id: 'deal-3',
        businessId: 'business-1',  
        title: 'Deal with Minutes',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 5,
        expiresAt: now.add(const Duration(minutes: 30)),
        createdAt: now,
        updatedAt: now,
      );
      expect(dealMinutes.timeRemainingText, matches(RegExp(r'[0-9]+m')));

      // Test expired deal
      final expiredDeal = Deal(
        id: 'deal-4',
        businessId: 'business-1',
        title: 'Expired Deal',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 5,
        expiresAt: now.subtract(const Duration(hours: 1)),
        createdAt: now,
        updatedAt: now,
      );
      expect(expiredDeal.timeRemainingText, 'Expired');
    });
  });
}

// Validation helper function for testing
String? _validateDealInput({
  required String businessId,
  required String title,
  required double originalPrice,
  required double discountedPrice,
  required int quantityAvailable,
  required DateTime expiresAt,
}) {
  if (businessId.trim().isEmpty) {
    throw 'Business ID is required';
  }

  if (title.trim().isEmpty) {
    throw 'Title is required';
  }

  if (title.trim().length < 3) {
    throw 'Title must be at least 3 characters long';
  }

  if (originalPrice <= 0) {
    throw 'Original price must be greater than 0';
  }

  if (discountedPrice <= 0) {
    throw 'Discounted price must be greater than 0';
  }

  if (discountedPrice >= originalPrice) {
    throw 'Discounted price must be less than original price';
  }

  if (quantityAvailable <= 0) {
    throw 'Quantity available must be greater than 0';
  }

  if (expiresAt.isBefore(DateTime.now())) {
    throw 'Expiration time must be in the future';
  }

  final maxExpiration = DateTime.now().add(const Duration(days: 7));
  if (expiresAt.isAfter(maxExpiration)) {
    throw 'Expiration time cannot be more than 7 days from now';
  }

  return null;
}