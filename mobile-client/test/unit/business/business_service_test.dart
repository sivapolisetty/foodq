import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kravekart/features/business/services/business_service.dart';
import 'package:kravekart/shared/models/business.dart';
import 'package:kravekart/shared/models/business_result.dart';

@GenerateMocks([SupabaseClient, PostgrestQueryBuilder, PostgrestFilterBuilder])
import 'business_service_test.mocks.dart';

void main() {
  late BusinessService businessService;
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    
    businessService = BusinessService(supabaseClient: mockSupabaseClient);
  });

  group('BusinessService Tests', () {
    group('enrollBusiness', () {
      test('should successfully enroll a new business', () async {
        // Arrange
        final businessData = {
          'owner_id': 'test-user-id',
          'name': 'Test Restaurant',
          'description': 'A great restaurant',
          'address': '123 Main St, City',
          'phone': '+1234567890',
          'email': 'test@restaurant.com',
        };

        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {
          'id': 'business-id',
          'owner_id': 'test-user-id',
          'name': 'Test Restaurant',
          'description': 'A great restaurant',
          'address': '123 Main St, City',
          'phone': '+1234567890',
          'email': 'test@restaurant.com',
          'is_approved': false,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Act
        final result = await businessService.enrollBusiness(
          ownerId: 'test-user-id',
          name: 'Test Restaurant',
          description: 'A great restaurant',
          address: '123 Main St, City',
          latitude: 40.7128,
          longitude: -74.0060,
          phone: '+1234567890',
          email: 'test@restaurant.com',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.business?.name, 'Test Restaurant');
        expect(result.business?.isApproved, false);
        verify(mockSupabaseClient.from('businesses')).called(1);
      });

      test('should return error when business name already exists', () async {
        // Arrange
        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenThrow(
          const PostgrestException(
            message: 'duplicate key value violates unique constraint',
            code: '23505',
          ),
        );

        // Act
        final result = await businessService.enrollBusiness(
          ownerId: 'test-user-id',
          name: 'Existing Restaurant',
          description: 'A restaurant',
          address: '123 Main St, City',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('already exists'));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenThrow(Exception('Network error'));

        // Act
        final result = await businessService.enrollBusiness(
          ownerId: 'test-user-id',
          name: 'Test Restaurant',
          description: 'A restaurant',
          address: '123 Main St, City',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Network error'));
      });

      test('should validate required fields', () async {
        // Act
        final result = await businessService.enrollBusiness(
          ownerId: '',
          name: '',
          description: '',
          address: '',
          latitude: 0,
          longitude: 0,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('required'));
      });
    });

    group('getBusinessByOwnerId', () {
      test('should return business for valid owner', () async {
        // Arrange
        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('owner_id', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => {
          'id': 'business-id',
          'owner_id': 'test-user-id',
          'name': 'Test Restaurant',
          'description': 'A great restaurant',
          'address': '123 Main St, City',
          'phone': '+1234567890',
          'email': 'test@restaurant.com',
          'is_approved': true,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Act
        final result = await businessService.getBusinessByOwnerId('test-user-id');

        // Assert
        expect(result, isNotNull);
        expect(result?.name, 'Test Restaurant');
        expect(result?.isApproved, true);
      });

      test('should return null when no business found', () async {
        // Arrange
        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('owner_id', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenThrow(
          const PostgrestException(message: 'No rows found', code: 'PGRST116'),
        );

        // Act
        final result = await businessService.getBusinessByOwnerId('nonexistent-user');

        // Assert
        expect(result, isNull);
      });
    });

    group('updateBusiness', () {
      test('should update business successfully', () async {
        // Arrange
        final updates = {
          'name': 'Updated Restaurant',
          'description': 'Updated description',
          'phone': '+0987654321',
        };

        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenAnswer((_) async => {
          'id': 'business-id',
          'owner_id': 'test-user-id',
          'name': 'Updated Restaurant',
          'description': 'Updated description',
          'address': '123 Main St, City',
          'phone': '+0987654321',
          'email': 'test@restaurant.com',
          'is_approved': true,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Act
        final result = await businessService.updateBusiness('business-id', updates);

        // Assert
        expect(result.isSuccess, true);
        expect(result.business?.name, 'Updated Restaurant');
        expect(result.business?.phone, '+0987654321');
      });

      test('should return error when business not found', () async {
        // Arrange
        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.single()).thenThrow(
          const PostgrestException(message: 'No rows found', code: 'PGRST116'),
        );

        // Act
        final result = await businessService.updateBusiness('nonexistent-id', {});

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('not found'));
      });
    });

    group('uploadBusinessImages', () {
      test('should upload logo successfully', () async {
        // Arrange
        final mockStorage = MockSupabaseStorageClient();
        when(mockSupabaseClient.storage).thenReturn(mockStorage);
        
        final mockFileObject = MockFileObject();
        when(mockStorage.from('business-images')).thenReturn(MockStorageFileApi());

        // Act
        final result = await businessService.uploadBusinessLogo(
          'business-id',
          'fake-image-data',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.imageUrl, isNotNull);
      });

      test('should handle upload errors', () async {
        // Arrange
        final mockStorage = MockSupabaseStorageClient();
        when(mockSupabaseClient.storage).thenReturn(mockStorage);
        when(mockStorage.from('business-images')).thenThrow(Exception('Upload failed'));

        // Act
        final result = await businessService.uploadBusinessLogo(
          'business-id',
          'fake-image-data',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.error, contains('Upload failed'));
      });
    });

    group('searchBusinesses', () {
      test('should return businesses matching search query', () async {
        // Arrange
        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.or(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_approved', true)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.limit(any)).thenAnswer((_) async => [
          {
            'id': 'business-1',
            'name': 'Pizza Palace',
            'description': 'Great pizza',
            'address': '123 Pizza St',
            'is_approved': true,
            'is_active': true,
          },
          {
            'id': 'business-2',
            'name': 'Pizza Corner',
            'description': 'Corner pizza shop',
            'address': '456 Corner Ave',
            'is_approved': true,
            'is_active': true,
          },
        ]);

        // Act
        final result = await businessService.searchBusinesses('pizza');

        // Assert
        expect(result, hasLength(2));
        expect(result.first.name, 'Pizza Palace');
        expect(result.last.name, 'Pizza Corner');
      });

      test('should return empty list when no matches found', () async {
        // Arrange
        when(mockSupabaseClient.from('businesses')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.or(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_approved', true)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.limit(any)).thenAnswer((_) async => []);

        // Act
        final result = await businessService.searchBusinesses('nonexistent');

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}

// Additional mock classes
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}
class MockFileObject extends Mock implements FileObject {}
class MockStorageFileApi extends Mock implements StorageFileApi {}