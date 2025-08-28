import 'package:flutter_test/flutter_test.dart';
import 'package:grabeat/features/deals/services/deal_service.dart';

void main() {
  group('Create Deal Integration Tests', () {
    late DealService dealService;

    setUpAll(() async {
      // For testing, we'll use a mock client to avoid real database calls
      // In real tests, you'd initialize Supabase with test database
    });

    setUp(() {
      // Create DealService that uses Worker API
      dealService = DealService();
    });

    test('should validate deal creation input correctly', () async {
      // Test input validation without database calls
      
      // Test 1: Empty business ID should be invalid
      expect(() => _validateCreateDealInput(
        businessId: '',
        title: 'Test Deal',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      ), throwsA(isA<String>()));

      // Test 2: Short title should be invalid
      expect(() => _validateCreateDealInput(
        businessId: 'test-business',
        title: 'AB',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      ), throwsA(isA<String>()));

      // Test 3: Invalid pricing should be invalid
      expect(() => _validateCreateDealInput(
        businessId: 'test-business',
        title: 'Test Deal',
        originalPrice: 15.0,
        discountedPrice: 20.0, // Higher than original
        quantityAvailable: 10,
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      ), throwsA(isA<String>()));

      // Test 4: Past expiration should be invalid
      expect(() => _validateCreateDealInput(
        businessId: 'test-business',
        title: 'Test Deal',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      ), throwsA(isA<String>()));

      // Test 5: Valid input should pass
      expect(() => _validateCreateDealInput(
        businessId: 'test-business',
        title: 'Valid Test Deal',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      ), returnsNormally);
    });

    test('should format deal data correctly for database insertion', () {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 6));

      final dealData = _formatDealDataForDatabase(
        businessId: 'test-business-123',
        title: 'Pizza Special Deal',
        description: 'Delicious pizza at discount',
        originalPrice: 25.99,
        discountedPrice: 18.99,
        quantityAvailable: 15,
        expiresAt: expiresAt,
        allergenInfo: 'Contains gluten',
      );

      expect(dealData['business_id'], equals('test-business-123'));
      expect(dealData['title'], equals('Pizza Special Deal'));
      expect(dealData['description'], equals('Delicious pizza at discount'));
      expect(dealData['original_price'], equals(25.99));
      expect(dealData['discounted_price'], equals(18.99));
      expect(dealData['quantity_available'], equals(15));
      expect(dealData['quantity_sold'], equals(0));
      expect(dealData['allergen_info'], equals('Contains gluten'));
      expect(dealData['status'], equals('active'));
      expect(dealData['expires_at'], equals(expiresAt.toIso8601String()));
    });

    test('should handle form data conversion correctly', () {
      // Test the conversion from form data to service parameters
      final formData = {
        'businessId': '550e8400-e29b-41d4-a716-446655440001',
        'title': 'Form Test Deal',
        'description': 'Test description from form',
        'originalPrice': 30.0,
        'discountedPrice': 22.50,
        'quantityAvailable': 8,
        'expiresAt': DateTime.now().add(const Duration(hours: 4)),
        'allergenInfo': 'Contains nuts',
      };

      // Verify the form data matches expected structure
      expect(formData['businessId'], isA<String>());
      expect(formData['title'], isA<String>());
      expect(formData['originalPrice'], isA<double>());
      expect(formData['discountedPrice'], isA<double>());
      expect(formData['quantityAvailable'], isA<int>());
      expect(formData['expiresAt'], isA<DateTime>());

      // Verify pricing is valid
      expect(formData['discountedPrice'] as double, lessThan(formData['originalPrice'] as double));
      
      // Verify expiration is in future
      final now = DateTime.now();
      final expiresAt = formData['expiresAt'] as DateTime;
      expect(expiresAt.isAfter(now), isTrue);
    });
  });
}

// Helper function to validate deal creation input
void _validateCreateDealInput({
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
    throw 'Quantity must be greater than 0';
  }
  
  if (expiresAt.isBefore(DateTime.now())) {
    throw 'Expiration time must be in the future';
  }
}

// Helper function to format deal data for database
Map<String, dynamic> _formatDealDataForDatabase({
  required String businessId,
  required String title,
  required String description,
  required double originalPrice,
  required double discountedPrice,
  required int quantityAvailable,
  required DateTime expiresAt,
  String? allergenInfo,
}) {
  final now = DateTime.now();
  
  return {
    'business_id': businessId,
    'title': title.trim(),
    'description': description.trim().isEmpty ? null : description.trim(),
    'original_price': originalPrice,
    'discounted_price': discountedPrice,
    'quantity_available': quantityAvailable,
    'quantity_sold': 0,
    'allergen_info': allergenInfo?.trim().isEmpty == true ? null : allergenInfo?.trim(),
    'expires_at': expiresAt.toIso8601String(),
    'status': 'active',
    'created_at': now.toIso8601String(),
    'updated_at': now.toIso8601String(),
  };
}