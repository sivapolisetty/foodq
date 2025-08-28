import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:grabeat/features/business/screens/business_enrollment_screen.dart';
import 'package:grabeat/features/business/providers/business_provider.dart';
import 'package:grabeat/features/business/services/business_service.dart';
import 'package:grabeat/shared/models/business_result.dart';
import 'package:grabeat/shared/models/business.dart';

import '../../widget/test_helpers.dart';

class MockBusinessService extends Mock implements BusinessService {}

void main() {
  group('BusinessEnrollmentScreen Widget Tests', () {
    late MockBusinessService mockBusinessService;
    
    setUp(() {
      mockBusinessService = MockBusinessService();
    });

    testWidgets('should render business enrollment form', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Assert
      expect(find.text('Enroll Your Business'), findsOneWidget);
      expect(find.text('Join GraBeat and start reducing food waste'), findsOneWidget);
      expect(find.byKey(const Key('business_name_field')), findsOneWidget);
      expect(find.byKey(const Key('business_description_field')), findsOneWidget);
      expect(find.byKey(const Key('business_address_field')), findsOneWidget);
      expect(find.byKey(const Key('business_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('business_email_field')), findsOneWidget);
      expect(find.byKey(const Key('enroll_business_button')), findsOneWidget);
    });

    testWidgets('should validate business name field', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act - Try to submit with empty business name
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Business name is required'), findsOneWidget);
    });

    testWidgets('should validate business description field', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('business_name_field')), 'Test Restaurant');
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Description is required'), findsOneWidget);
    });

    testWidgets('should validate address field', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('business_name_field')), 'Test Restaurant');
      await tester.enterText(find.byKey(const Key('business_description_field')), 'Great food');
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Address is required'), findsOneWidget);
    });

    testWidgets('should validate email format', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('business_email_field')), 'invalid-email');
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate phone format', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('business_phone_field')), '123');
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
    });

    testWidgets('should show loading state during enrollment', (tester) async {
      // Arrange
      when(mockBusinessService.enrollBusiness(
        ownerId: anyNamed('ownerId'),
        name: anyNamed('name'),
        description: anyNamed('description'),
        address: anyNamed('address'),
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        phone: anyNamed('phone'),
        email: anyNamed('email'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return BusinessResult.success(createMockBusiness());
      });

      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await _fillValidForm(tester);
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Enrolling...'), findsOneWidget);
    });

    testWidgets('should call enroll business with correct parameters', (tester) async {
      // Arrange
      when(mockBusinessService.enrollBusiness(
        ownerId: anyNamed('ownerId'),
        name: anyNamed('name'),
        description: anyNamed('description'),
        address: anyNamed('address'),
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        phone: anyNamed('phone'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => BusinessResult.success(createMockBusiness()));

      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await _fillValidForm(tester);
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pumpAndSettle();

      // Assert
      verify(mockBusinessService.enrollBusiness(
        ownerId: anyNamed('ownerId'),
        name: 'Test Restaurant',
        description: 'Great food and service',
        address: '123 Main St, City, State',
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        phone: '+1234567890',
        email: 'test@restaurant.com',
      )).called(1);
    });

    testWidgets('should show success message on successful enrollment', (tester) async {
      // Arrange
      when(mockBusinessService.enrollBusiness(
        ownerId: anyNamed('ownerId'),
        name: anyNamed('name'),
        description: anyNamed('description'),
        address: anyNamed('address'),
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        phone: anyNamed('phone'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => BusinessResult.success(createMockBusiness()));

      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await _fillValidForm(tester);
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('successfully enrolled'), findsOneWidget);
      expect(find.textContaining('pending approval'), findsOneWidget);
    });

    testWidgets('should show error message on enrollment failure', (tester) async {
      // Arrange
      when(mockBusinessService.enrollBusiness(
        ownerId: anyNamed('ownerId'),
        name: anyNamed('name'),
        description: anyNamed('description'),
        address: anyNamed('address'),
        latitude: anyNamed('latitude'),
        longitude: anyNamed('longitude'),
        phone: anyNamed('phone'),
        email: anyNamed('email'),
      )).thenAnswer((_) async => const BusinessResult.failure('Business name already exists'));

      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await _fillValidForm(tester);
      await tester.tap(find.byKey(const Key('enroll_business_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Business name already exists'), findsOneWidget);
    });

    testWidgets('should show image upload section', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Assert
      expect(find.text('Business Images'), findsOneWidget);
      expect(find.byKey(const Key('logo_upload_button')), findsOneWidget);
      expect(find.byKey(const Key('cover_image_upload_button')), findsOneWidget);
    });

    testWidgets('should handle location selection', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('select_location_button')));
      await tester.pumpAndSettle();

      // Assert - Location selection dialog should appear
      // This would need a proper location picker implementation
      expect(tester.takeException(), isNull);
    });

    testWidgets('should apply overflow-safe wrapper', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Assert - Test on different screen sizes
      await testResponsiveness(
        tester, 
        const BusinessEnrollmentScreen(),
        overrides: [
          businessServiceProvider.overrideWithValue(mockBusinessService),
        ],
      );
    });

    testWidgets('should show business guidelines', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const BusinessEnrollmentScreen(),
          overrides: [
            businessServiceProvider.overrideWithValue(mockBusinessService),
          ],
        ),
      );

      // Assert
      expect(find.text('Business Guidelines'), findsOneWidget);
      expect(find.textContaining('approval process'), findsOneWidget);
      expect(find.textContaining('food safety'), findsOneWidget);
    });
  });
}

// Helper function to fill valid form
Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('business_name_field')), 'Test Restaurant');
  await tester.enterText(find.byKey(const Key('business_description_field')), 'Great food and service');
  await tester.enterText(find.byKey(const Key('business_address_field')), '123 Main St, City, State');
  await tester.enterText(find.byKey(const Key('business_phone_field')), '+1234567890');
  await tester.enterText(find.byKey(const Key('business_email_field')), 'test@restaurant.com');
}

// Helper function to create mock business
Business createMockBusiness() {
  return Business(
    id: 'test-business-id',
    ownerId: 'test-owner-id',
    name: 'Test Restaurant',
    description: 'Great food and service',
    address: '123 Main St, City, State',
    latitude: 40.7128,
    longitude: -74.0060,
    phone: '+1234567890',
    email: 'test@restaurant.com',
    isApproved: false,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}