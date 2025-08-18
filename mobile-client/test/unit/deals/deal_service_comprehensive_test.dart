import 'package:flutter_test/flutter_test.dart';
import 'package:kravekart/features/deals/services/deal_service.dart';
import 'package:kravekart/shared/models/deal.dart';
import 'package:kravekart/shared/models/deal_result.dart';

void main() {
  group('DealService Comprehensive Tests', () {
    late DealService dealService;

    setUp(() {
      dealService = DealService();
    });

    group('createDeal', () {
      test('should create deal successfully with valid input', () async {
        // Arrange
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 6));
        final expectedDealData = {
          'id': 'test-deal-id',
          'business_id': 'test-business-id',
          'title': 'Test Deal',
          'description': 'Test Description',
          'original_price': 20.0,
          'discounted_price': 15.0,
          'quantity_available': 10,
          'quantity_sold': 0,
          'image_url': null,
          'allergen_info': null,
          'expires_at': expiresAt.toIso8601String(),
          'status': 'active',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => expectedDealData);

        // Act
        final result = await dealService.createDeal(
          businessId: 'test-business-id',
          title: 'Test Deal',
          description: 'Test Description',
          originalPrice: 20.0,
          discountedPrice: 15.0,
          quantityAvailable: 10,
          expiresAt: expiresAt,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.deal?.title, 'Test Deal');
        expect(result.deal?.originalPrice, 20.0);
        expect(result.deal?.discountedPrice, 15.0);
        verify(mockSupabaseClient.from('deals')).called(1);
      });

      test('should return validation error for invalid business ID', () async {
        // Act
        final result = await dealService.createDeal(
          businessId: '',
          title: 'Test Deal',
          description: 'Test Description',
          originalPrice: 20.0,
          discountedPrice: 15.0,
          quantityAvailable: 10,
          expiresAt: DateTime.now().add(const Duration(hours: 6)),
        );

        // Assert
        expect(result.isError, true);
        expect(result.error, 'Business ID is required');
        expect(result.errorCode, 'VALIDATION_ERROR');
      });

      test('should return validation error for short title', () async {
        // Act
        final result = await dealService.createDeal(
          businessId: 'test-business-id',
          title: 'AB',
          description: 'Test Description',
          originalPrice: 20.0,
          discountedPrice: 15.0,
          quantityAvailable: 10,
          expiresAt: DateTime.now().add(const Duration(hours: 6)),
        );

        // Assert
        expect(result.isError, true);
        expect(result.error, 'Title must be at least 3 characters long');
      });

      test('should return validation error for invalid pricing', () async {
        // Act
        final result = await dealService.createDeal(
          businessId: 'test-business-id',
          title: 'Test Deal',
          description: 'Test Description',
          originalPrice: 15.0,
          discountedPrice: 20.0,
          quantityAvailable: 10,
          expiresAt: DateTime.now().add(const Duration(hours: 6)),
        );

        // Assert
        expect(result.isError, true);
        expect(result.error, 'Discounted price must be less than original price');
      });

      test('should return validation error for past expiration time', () async {
        // Act
        final result = await dealService.createDeal(
          businessId: 'test-business-id',
          title: 'Test Deal',
          description: 'Test Description',
          originalPrice: 20.0,
          discountedPrice: 15.0,
          quantityAvailable: 10,
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Assert
        expect(result.isError, true);
        expect(result.error, 'Expiration time must be in the future');
      });

      test('should handle database errors gracefully', () async {
        // Arrange
        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenThrow(
          PostgrestException(
            message: 'Database error',
            code: 'DB_ERROR',
            details: 'Connection failed',
            hint: 'Check database connection',
          ),
        );

        // Act
        final result = await dealService.createDeal(
          businessId: 'test-business-id',
          title: 'Test Deal',
          description: 'Test Description',
          originalPrice: 20.0,
          discountedPrice: 15.0,
          quantityAvailable: 10,
          expiresAt: DateTime.now().add(const Duration(hours: 6)),
        );

        // Assert
        expect(result.isError, true);
        expect(result.error, contains('Failed to create deal'));
        expect(result.errorCode, 'DB_ERROR');
      });
    });

    group('updateDeal', () {
      test('should update deal successfully', () async {
        // Arrange
        const dealId = 'test-deal-id';
        final updates = {'title': 'Updated Deal Title'};
        final expectedResponse = {
          'id': dealId,
          'business_id': 'test-business-id',
          'title': 'Updated Deal Title',
          'description': 'Test Description',
          'original_price': 20.0,
          'discounted_price': 15.0,
          'quantity_available': 10,
          'quantity_sold': 0,
          'image_url': null,
          'allergen_info': null,
          'expires_at': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
          'status': 'active',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', dealId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await dealService.updateDeal(dealId, updates);

        // Assert
        expect(result.isSuccess, true);
        expect(result.deal?.title, 'Updated Deal Title');
        verify(mockSupabaseClient.from('deals')).called(1);
      });

      test('should return error for empty deal ID', () async {
        // Act
        final result = await dealService.updateDeal('', {'title': 'Updated Title'});

        // Assert
        expect(result.isError, true);
        expect(result.error, 'Deal ID is required');
        expect(result.errorCode, 'INVALID_INPUT');
      });

      test('should validate pricing updates', () async {
        // Arrange
        const dealId = 'test-deal-id';
        final updates = {
          'original_price': 10.0,
          'discounted_price': 15.0,
        };

        // Act
        final result = await dealService.updateDeal(dealId, updates);

        // Assert
        expect(result.isError, true);
        expect(result.error, 'Discounted price must be less than original price');
        expect(result.errorCode, 'INVALID_PRICING');
      });
    });

    group('getDealsByBusinessId', () {
      test('should return deals for valid business ID', () async {
        // Arrange
        const businessId = 'test-business-id';
        final expectedDeals = [
          {
            'id': 'deal-1',
            'business_id': businessId,
            'title': 'Deal 1',
            'description': 'Description 1',
            'original_price': 20.0,
            'discounted_price': 15.0,
            'quantity_available': 10,
            'quantity_sold': 0,
            'image_url': null,
            'allergen_info': null,
            'expires_at': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('business_id', businessId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenAnswer((_) async => expectedDeals);

        // Act
        final deals = await dealService.getDealsByBusinessId(businessId);

        // Assert
        expect(deals.length, 1);
        expect(deals.first.title, 'Deal 1');
        expect(deals.first.businessId, businessId);
      });

      test('should return empty list for invalid business ID', () async {
        // Act
        final deals = await dealService.getDealsByBusinessId('');

        // Assert
        expect(deals, isEmpty);
      });

      test('should handle database errors and return empty list', () async {
        // Arrange
        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('business_id', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenThrow(Exception('Database error'));

        // Act
        final deals = await dealService.getDealsByBusinessId('test-business-id');

        // Assert
        expect(deals, isEmpty);
      });
    });

    group('getActiveDeals', () {
      test('should return active deals with pagination', () async {
        // Arrange
        final now = DateTime.now();
        final expectedDeals = [
          {
            'id': 'deal-1',
            'business_id': 'business-1',
            'title': 'Active Deal 1',
            'description': 'Description 1',
            'original_price': 20.0,
            'discounted_price': 15.0,
            'quantity_available': 10,
            'quantity_sold': 0,
            'image_url': null,
            'allergen_info': null,
            'expires_at': now.add(const Duration(hours: 6)).toIso8601String(),
            'status': 'active',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
        ];

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'active')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gt('expires_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gt('quantity_available', 0)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.range(0, 19)).thenAnswer((_) async => expectedDeals);

        // Act
        final deals = await dealService.getActiveDeals(limit: 20, offset: 0);

        // Assert
        expect(deals.length, 1);
        expect(deals.first.title, 'Active Deal 1');
        expect(deals.first.status, DealStatus.active);
      });
    });

    group('incrementQuantitySold', () {
      test('should increment quantity sold successfully', () async {
        // Arrange
        const dealId = 'test-deal-id';
        const quantity = 2;
        final currentData = {
          'quantity_available': 10,
          'quantity_sold': 3,
        };
        final updatedData = {
          'id': dealId,
          'quantity_sold': 5,
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('quantity_available, quantity_sold')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', dealId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => currentData);

        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', dealId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => updatedData);

        // Act
        final result = await dealService.incrementQuantitySold(dealId, quantity);

        // Assert
        expect(result, true);
        verify(mockSupabaseClient.from('deals')).called(2);
      });

      test('should return false when insufficient quantity available', () async {
        // Arrange
        const dealId = 'test-deal-id';
        const quantity = 8;
        final currentData = {
          'quantity_available': 10,
          'quantity_sold': 5, // Only 5 remaining, but trying to sell 8
        };

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('quantity_available, quantity_sold')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', dealId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => currentData);

        // Act
        final result = await dealService.incrementQuantitySold(dealId, quantity);

        // Assert
        expect(result, false);
      });

      test('should return false for invalid input', () async {
        // Act
        final result1 = await dealService.incrementQuantitySold('', 1);
        final result2 = await dealService.incrementQuantitySold('deal-id', 0);
        final result3 = await dealService.incrementQuantitySold('deal-id', -1);

        // Assert
        expect(result1, false);
        expect(result2, false);
        expect(result3, false);
      });
    });

    group('fetchCustomerDeals', () {
      test('should fetch customer deals with business data', () async {
        // Arrange
        final expectedResponse = [
          {
            'id': 'deal-1',
            'business_id': 'business-1',
            'title': 'Customer Deal 1',
            'description': 'Description 1',
            'original_price': 20.0,
            'discounted_price': 15.0,
            'quantity_available': 10,
            'quantity_sold': 0,
            'image_url': null,
            'allergen_info': null,
            'expires_at': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'businesses': {
              'id': 'business-1',
              'name': 'Test Restaurant',
              'description': 'A great restaurant',
              'address': '123 Main St',
              'phone': '555-1234',
              'email': 'test@example.com',
              'logo_url': null,
              'cover_image_url': null,
              'location': 'POINT(-74.006 40.7128)',
            },
          },
        ];

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'active')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gt('expires_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gt('quantity_available', 0)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.range(0, 49)).thenAnswer((_) async => expectedResponse);

        // Act
        final deals = await dealService.fetchCustomerDeals();

        // Assert
        expect(deals.length, 1);
        expect(deals.first.title, 'Customer Deal 1');
        expect(deals.first.restaurant?.name, 'Test Restaurant');
        expect(deals.first.restaurant?.latitude, 40.7128);
        expect(deals.first.restaurant?.longitude, -74.006);
      });

      test('should apply pickup_now filter correctly', () async {
        // Arrange
        final now = DateTime.now();
        final expiringDeal = {
          'id': 'deal-1',
          'business_id': 'business-1',
          'title': 'Expiring Deal',
          'description': 'Description 1',
          'original_price': 20.0,
          'discounted_price': 15.0,
          'quantity_available': 10,
          'quantity_sold': 0,
          'image_url': null,
          'allergen_info': null,
          'expires_at': now.add(const Duration(hours: 1)).toIso8601String(), // Expires in 1 hour
          'status': 'active',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'businesses': {
            'id': 'business-1',
            'name': 'Test Restaurant',
            'description': 'A great restaurant',
            'address': '123 Main St',
            'phone': '555-1234',
            'email': 'test@example.com',
            'logo_url': null,
            'cover_image_url': null,
            'location': 'POINT(-74.006 40.7128)',
          },
        };

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'active')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gt('expires_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gt('quantity_available', 0)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.range(0, 49)).thenAnswer((_) async => [expiringDeal]);

        // Act
        final deals = await dealService.fetchCustomerDeals(filter: 'pickup_now');

        // Assert
        expect(deals.length, 1);
        expect(deals.first.title, 'Expiring Deal');
      });
    });

    group('searchDeals', () {
      test('should search deals by title', () async {
        // Arrange
        const query = 'pizza';
        final expectedResponse = [
          {
            'id': 'deal-1',
            'business_id': 'business-1',
            'title': 'Pizza Deal',
            'description': 'Delicious pizza',
            'original_price': 20.0,
            'discounted_price': 15.0,
            'quantity_available': 10,
            'quantity_sold': 0,
            'image_url': null,
            'allergen_info': null,
            'expires_at': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'businesses': {
              'id': 'business-1',
              'name': 'Pizza Place',
              'description': 'Best pizza in town',
              'address': '123 Pizza St',
              'phone': '555-1234',
              'email': 'pizza@example.com',
              'logo_url': null,
              'cover_image_url': null,
              'location': 'POINT(-74.006 40.7128)',
            },
          },
        ];

        when(mockSupabaseClient.from('deals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', 'active')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gt('expires_at', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gt('quantity_available', 0)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.ilike('title', '%$query%')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(50)).thenAnswer((_) async => expectedResponse);

        // Act
        final deals = await dealService.searchDeals(query);

        // Assert
        expect(deals.length, 1);
        expect(deals.first.title, 'Pizza Deal');
        expect(deals.first.restaurant?.name, 'Pizza Place');
      });

      test('should return all deals for empty query', () async {
        // Act
        final deals = await dealService.searchDeals('');

        // Assert - Should call fetchCustomerDeals internally
        verify(mockSupabaseClient.from('deals')).called(1);
      });
    });
  });
}