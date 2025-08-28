import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grabeat/features/search/services/search_service.dart';
import 'package:grabeat/shared/models/deal.dart';
import 'package:grabeat/shared/models/business.dart';
import 'package:grabeat/features/search/models/search_result.dart';
import 'package:grabeat/features/search/models/search_filters.dart';

@GenerateMocks([SupabaseClient])
import 'search_service_test.mocks.dart';

void main() {
  late SearchService searchService;
  late MockSupabaseClient mockSupabaseClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    searchService = SearchService(supabaseClient: mockSupabaseClient);
  });

  group('SearchService Tests', () {
    group('searchDeals', () {
      test('should return deals matching search query', () async {
        // Arrange
        const query = 'pizza';
        final mockDealsResponse = [
          {
            'id': 'deal-1',
            'business_id': 'business-1',
            'title': 'Margherita Pizza',
            'description': 'Fresh mozzarella pizza',
            'original_price': 15.0,
            'discounted_price': 10.0,
            'quantity_available': 5,
            'quantity_sold': 0,
            'status': 'active',
            'expires_at': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          {
            'id': 'deal-2',
            'business_id': 'business-2',
            'title': 'Pepperoni Pizza',
            'description': 'Spicy pepperoni pizza',
            'original_price': 18.0,
            'discounted_price': 12.0,
            'quantity_available': 3,
            'quantity_sold': 1,
            'status': 'active',
            'expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        ];

        // Mock the database call
        when(mockSupabaseClient.from('deals')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('deals').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', '%$query%')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', '%$query%').order('created_at')).thenAnswer((_) async => mockDealsResponse);

        // Act
        final result = await searchService.searchDeals(query);

        // Assert
        expect(result.length, 2);
        expect(result.first.title, 'Margherita Pizza');
        expect(result.last.title, 'Pepperoni Pizza');
      });

      test('should return empty list when no deals match query', () async {
        // Arrange
        const query = 'nonexistent';
        
        when(mockSupabaseClient.from('deals')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('deals').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', '%$query%')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', '%$query%').order('created_at')).thenAnswer((_) async => []);

        // Act
        final result = await searchService.searchDeals(query);

        // Assert
        expect(result, isEmpty);
      });

      test('should handle search query with special characters', () async {
        // Arrange
        const query = 'café & grill';
        final escapedQuery = 'café \\& grill';
        
        when(mockSupabaseClient.from('deals')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('deals').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', '%$escapedQuery%')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', '%$escapedQuery%').order('created_at')).thenAnswer((_) async => []);

        // Act
        final result = await searchService.searchDeals(query);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('searchNearbyDeals', () {
      test('should return deals within specified radius', () async {
        // Arrange
        const latitude = 40.7128;
        const longitude = -74.0060;
        const radiusInKm = 5.0;
        
        final mockNearbyDeals = [
          {
            'id': 'deal-1',
            'business_id': 'business-1',
            'title': 'Nearby Pizza',
            'original_price': 15.0,
            'discounted_price': 10.0,
            'quantity_available': 5,
            'status': 'active',
            'expires_at': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'business': {
              'id': 'business-1',
              'name': 'Local Pizza Place',
              'latitude': 40.7130,
              'longitude': -74.0065,
            }
          },
        ];

        // Mock complex query with joins
        when(mockSupabaseClient.from('deals')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('deals').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').order('created_at')).thenAnswer((_) async => mockNearbyDeals);

        // Act
        final result = await searchService.searchNearbyDeals(
          latitude: latitude,
          longitude: longitude,
          radiusInKm: radiusInKm,
        );

        // Assert
        expect(result.length, 1);
        expect(result.first.title, 'Nearby Pizza');
      });

      test('should return empty list when no deals nearby', () async {
        // Arrange
        const latitude = 0.0;
        const longitude = 0.0;
        const radiusInKm = 1.0;

        when(mockSupabaseClient.from('deals')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('deals').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').order('created_at')).thenAnswer((_) async => []);

        // Act
        final result = await searchService.searchNearbyDeals(
          latitude: latitude,
          longitude: longitude,
          radiusInKm: radiusInKm,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('searchBusinesses', () {
      test('should return businesses matching search query', () async {
        // Arrange
        const query = 'italian';
        final mockBusinesses = [
          {
            'id': 'business-1',
            'name': 'Italian Bistro',
            'cuisine_type': 'Italian',
            'address': '123 Main St',
            'latitude': 40.7128,
            'longitude': -74.0060,
            'phone': '+1234567890',
            'email': 'info@italianbistro.com',
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
          },
        ];

        when(mockSupabaseClient.from('businesses')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('businesses').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('businesses').select(any).eq('status', 'active')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('businesses').select(any).eq('status', 'active').or(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('businesses').select(any).eq('status', 'active').or(any).order('name')).thenAnswer((_) async => mockBusinesses);

        // Act
        final result = await searchService.searchBusinesses(query);

        // Assert
        expect(result.length, 1);
        expect(result.first.name, 'Italian Bistro');
        expect(result.first.cuisineType, 'Italian');
      });
    });

    group('advancedSearch', () {
      test('should apply filters correctly', () async {
        // Arrange
        final filters = SearchFilters(
          query: 'pizza',
          maxDistance: 10.0,
          minDiscount: 20.0,
          maxPrice: 15.0,
          cuisineTypes: ['Italian', 'American'],
          sortBy: SearchSortBy.discount,
        );
        const latitude = 40.7128;
        const longitude = -74.0060;

        final mockResults = [
          {
            'id': 'deal-1',
            'title': 'Discounted Pizza',
            'original_price': 20.0,
            'discounted_price': 12.0,
            'status': 'active',
            'expires_at': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'business': {
              'cuisine_type': 'Italian',
            }
          },
        ];

        when(mockSupabaseClient.from('deals')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('deals').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', any).lte('discounted_price', any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('deals').select(any).eq('status', 'active').ilike('title', any).lte('discounted_price', any).order(any)).thenAnswer((_) async => mockResults);

        // Act
        final result = await searchService.advancedSearch(
          filters: filters,
          userLatitude: latitude,
          userLongitude: longitude,
        );

        // Assert
        expect(result.deals.length, 1);
        expect(result.deals.first.title, 'Discounted Pizza');
        expect(result.totalCount, 1);
      });
    });

    group('error handling', () {
      test('should handle database errors gracefully', () async {
        // Arrange
        when(mockSupabaseClient.from('deals')).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => searchService.searchDeals('pizza'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle empty query strings', () async {
        // Act
        final result1 = await searchService.searchDeals('');
        final result2 = await searchService.searchDeals('   ');

        // Assert
        expect(result1, isEmpty);
        expect(result2, isEmpty);
      });
    });
  });
}

// Mock classes to avoid complex Supabase mocking
class MockPostgrestQueryBuilder extends Mock {}
class MockPostgrestFilterBuilder extends Mock {}