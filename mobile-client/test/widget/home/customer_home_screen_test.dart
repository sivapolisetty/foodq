import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kravekart/features/home/screens/customer_home_screen.dart';
import 'package:kravekart/features/search/services/search_service.dart';
import 'package:kravekart/shared/models/deal.dart';

@GenerateMocks([SearchService])
import 'customer_home_screen_test.mocks.dart';

void main() {
  late MockSearchService mockSearchService;

  setUp(() {
    mockSearchService = MockSearchService();
  });

  Widget createTestWidget(WidgetTester tester) {
    return ProviderScope(
      overrides: [
        searchServiceProvider.overrideWithValue(mockSearchService),
      ],
      child: MaterialApp(
        home: CustomerHomeScreen(),
      ),
    );
  }

  group('CustomerHomeScreen Widget Tests', () {
    testWidgets('should display search bar at the top', (WidgetTester tester) async {
      // Arrange
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search for meal and restaurant...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display category icons row', (WidgetTester tester) async {
      // Arrange
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pickup Now'), findsOneWidget);
      expect(find.text('Near Me'), findsOneWidget);
      expect(find.text('Top Deals'), findsOneWidget);
      expect(find.text('Best Reviews'), findsOneWidget);
      expect(find.text('Meals'), findsOneWidget);
    });

    testWidgets('should display location card', (WidgetTester tester) async {
      // Arrange
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Your Location'), findsOneWidget);
      expect(find.text('Current Location'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should display rescue impact card', (WidgetTester tester) async {
      // Arrange
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Rescue Impact'), findsOneWidget);
      expect(find.text('by KraveKart Community'), findsOneWidget);
      expect(find.textContaining('kg CO₂'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should display morning pickup section', (WidgetTester tester) async {
      // Arrange
      final mockDeals = [
        Deal(
          id: 'deal-1',
          businessId: 'business-1',
          title: 'Breakfast Box',
          description: 'Delicious breakfast items',
          originalPrice: 500.0,
          discountedPrice: 300.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => mockDeals);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pickup in the morning'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);
    });

    testWidgets('should display afternoon pickup section', (WidgetTester tester) async {
      // Arrange
      final mockDeals = [
        Deal(
          id: 'deal-2',
          businessId: 'business-2',
          title: 'Lunch Special',
          description: 'Afternoon deals',
          originalPrice: 800.0,
          discountedPrice: 480.0,
          quantityAvailable: 3,
          expiresAt: DateTime.now().add(const Duration(hours: 4)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => mockDeals);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pickup in the afternoon'), findsOneWidget);
    });

    testWidgets('should display deal cards with correct information', (WidgetTester tester) async {
      // Arrange
      final mockDeals = [
        Deal(
          id: 'deal-1',
          businessId: 'business-1',
          title: 'Princess Srinakarin Breakfast Box',
          description: 'Delicious breakfast items',
          originalPrice: 500.0,
          discountedPrice: 300.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => mockDeals);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Princess Srinakarin Breakfast Box'), findsOneWidget);
      expect(find.text('₿300'), findsOneWidget);
      expect(find.text('₿500'), findsOneWidget);
    });

    testWidgets('should display discount badges on deal cards', (WidgetTester tester) async {
      // Arrange
      final mockDeals = [
        Deal(
          id: 'deal-1',
          businessId: 'business-1',
          title: 'Discounted Meal',
          description: 'Great deal',
          originalPrice: 1000.0,
          discountedPrice: 600.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => mockDeals);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('-40%'), findsOneWidget);
    });

    testWidgets('should display bottom navigation bar', (WidgetTester tester) async {
      // Arrange
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should display rating stars and counts', (WidgetTester tester) async {
      // Arrange
      final mockDeals = [
        Deal(
          id: 'deal-1',
          businessId: 'business-1',
          title: 'Rated Restaurant',
          description: 'Highly rated',
          originalPrice: 500.0,
          discountedPrice: 300.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => mockDeals);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.star), findsWidgets);
      expect(find.textContaining('4.'), findsWidgets);
    });

    testWidgets('should display time and distance information', (WidgetTester tester) async {
      // Arrange
      final mockDeals = [
        Deal(
          id: 'deal-1',
          businessId: 'business-1',
          title: 'Nearby Restaurant',
          description: 'Close location',
          originalPrice: 500.0,
          discountedPrice: 300.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => mockDeals);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('09:00 - 11:00'), findsWidgets);
      expect(find.textContaining('km'), findsWidgets);
    });

    testWidgets('should handle loading state', (WidgetTester tester) async {
      // Arrange
      when(mockSearchService.getDeals(any, any)).thenAnswer(
        (_) async => await Future.delayed(const Duration(seconds: 1), () => []),
      );

      // Act
      await tester.pumpWidget(createTestWidget(tester));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should handle empty deals state', (WidgetTester tester) async {
      // Arrange
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No deals available'), findsWidgets);
    });

    testWidgets('should handle category icon taps', (WidgetTester tester) async {
      // Arrange
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Top Deals'));
      await tester.pumpAndSettle();

      // Assert - verify navigation or state change
      // This would be implemented based on the actual navigation logic
    });

    testWidgets('should handle deal card taps', (WidgetTester tester) async {
      // Arrange
      final mockDeals = [
        Deal(
          id: 'deal-1',
          businessId: 'business-1',
          title: 'Tappable Deal',
          description: 'Tap to view',
          originalPrice: 500.0,
          discountedPrice: 300.0,
          quantityAvailable: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(mockSearchService.getDeals(any, any)).thenAnswer((_) async => mockDeals);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tappable Deal'));
      await tester.pumpAndSettle();

      // Assert - verify navigation to deal details
    });
  });
}