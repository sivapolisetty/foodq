import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kravekart/features/home/screens/customer_home_screen.dart';
import 'package:kravekart/features/deals/services/deal_service.dart';
import 'package:kravekart/shared/models/deal.dart';
import 'package:kravekart/features/deals/models/restaurant.dart';
import 'package:kravekart/shared/theme/app_theme.dart';

@GenerateMocks([DealService])
import 'customer_home_comprehensive_test.mocks.dart';

void main() {
  group('CustomerHomeScreen Widget Tests', () {
    late MockDealService mockDealService;

    setUp(() {
      mockDealService = MockDealService();
    });

    Widget createTestWidget({List<Deal>? deals}) {
      return ProviderScope(
        overrides: [],
        child: MaterialApp(
          theme: AppTheme.theme,
          home: CustomerHomeScreen(),
        ),
      );
    }

    Deal createTestDeal({
      String id = 'test-deal-1',
      String title = 'Test Pizza Deal',
      double originalPrice = 20.0,
      double discountedPrice = 15.0,
      int quantityAvailable = 10,
      Restaurant? restaurant,
    }) {
      return Deal(
        id: id,
        businessId: 'test-business-1',
        title: title,
        description: 'Delicious test pizza deal',
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        quantityAvailable: quantityAvailable,
        quantitySold: 0,
        imageUrl: 'https://example.com/pizza.jpg',
        allergenInfo: 'Contains gluten',
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
        status: DealStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        restaurant: restaurant ?? createTestRestaurant(),
      );
    }

    Restaurant createTestRestaurant({
      String id = 'test-restaurant-1',
      String name = 'Test Pizza Place',
      double latitude = 40.7128,
      double longitude = -74.0060,
    }) {
      return Restaurant(
        id: id,
        name: name,
        description: 'Best pizza in town',
        address: '123 Pizza Street, New York, NY',
        phone: '+1234567890',
        email: 'contact@testpizza.com',
        logoUrl: 'https://example.com/logo.jpg',
        coverImageUrl: 'https://example.com/cover.jpg',
        latitude: latitude,
        longitude: longitude,
        isApproved: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    testWidgets('should display app bar with correct title', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('KraveKart'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display category filter chips', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pickup Now'), findsOneWidget);
      expect(find.text('Nearby'), findsOneWidget);
      expect(find.text('Best Discount'), findsOneWidget);
      expect(find.text('Meals'), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [];
      });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Don't wait for completion

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display deals when loaded successfully', (WidgetTester tester) async {
      // Arrange
      final testDeals = [
        createTestDeal(
          id: 'deal-1',
          title: 'Pizza Special',
          originalPrice: 25.0,
          discountedPrice: 18.0,
        ),
        createTestDeal(
          id: 'deal-2',
          title: 'Burger Combo',
          originalPrice: 15.0,
          discountedPrice: 12.0,
        ),
      ];
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => testDeals);

      // Act
      await tester.pumpWidget(createTestWidget(deals: testDeals));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pizza Special'), findsOneWidget);
      expect(find.text('Burger Combo'), findsOneWidget);
      expect(find.text('\$25.00'), findsOneWidget); // Original price
      expect(find.text('\$18.00'), findsOneWidget); // Discounted price
      expect(find.text('\$15.00'), findsOneWidget); // Original price
      expect(find.text('\$12.00'), findsOneWidget); // Discounted price
    });

    testWidgets('should display deal cards with correct information', (WidgetTester tester) async {
      // Arrange
      final testDeal = createTestDeal(
        title: 'Gourmet Pizza Deal',
        originalPrice: 30.0,
        discountedPrice: 22.0,
        quantityAvailable: 5,
      );
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => [testDeal]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [testDeal]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Gourmet Pizza Deal'), findsOneWidget);
      expect(find.text('Test Pizza Place'), findsOneWidget);
      expect(find.text('\$30.00'), findsOneWidget);
      expect(find.text('\$22.00'), findsOneWidget);
      expect(find.text('5 left'), findsOneWidget);
      
      // Check discount percentage
      expect(find.text('27% OFF'), findsOneWidget);
    });

    testWidgets('should handle empty deals list', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(deals: []));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No deals available'), findsOneWidget);
      expect(find.text('Check back later for new deals!'), findsOneWidget);
    });

    testWidgets('should display error message when deal loading fails', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.fetchCustomerDeals()).thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to load deals'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should filter deals when category is selected', (WidgetTester tester) async {
      // Arrange
      final testDeals = [
        createTestDeal(title: 'Quick Pizza'),
        createTestDeal(title: 'Slow Burger'),
      ];
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => testDeals);
      when(mockDealService.fetchCustomerDeals(filter: 'pickup_now')).thenAnswer((_) async => [testDeals.first]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: testDeals));
      await tester.pumpAndSettle();
      
      // Tap on "Pickup Now" filter
      await tester.tap(find.text('Pickup Now'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Quick Pizza'), findsOneWidget);
      expect(find.text('Slow Burger'), findsNothing);
    });

    testWidgets('should navigate to deal details when deal card is tapped', (WidgetTester tester) async {
      // Arrange
      final testDeal = createTestDeal();
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => [testDeal]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [testDeal]));
      await tester.pumpAndSettle();
      
      // Tap on deal card
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Assert - Check if navigation occurred (this would depend on your navigation setup)
      // For now, just verify the tap doesn't cause errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display correct urgency indicators', (WidgetTester tester) async {
      // Arrange
      final urgentDeal = Deal(
        id: 'urgent-deal',
        businessId: 'test-business',
        title: 'Urgent Deal',
        description: 'Almost sold out!',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        quantitySold: 9, // Almost sold out
        expiresAt: DateTime.now().add(const Duration(minutes: 30)), // Expiring soon
        status: DealStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        restaurant: createTestRestaurant(),
      );
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => [urgentDeal]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [urgentDeal]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Act Fast!'), findsOneWidget);
      expect(find.text('1 left'), findsOneWidget);
    });

    testWidgets('should handle pull-to-refresh gesture', (WidgetTester tester) async {
      // Arrange
      final testDeals = [createTestDeal()];
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => testDeals);

      // Act
      await tester.pumpWidget(createTestWidget(deals: testDeals));
      await tester.pumpAndSettle();
      
      // Perform pull-to-refresh
      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Assert
      verify(mockDealService.fetchCustomerDeals()).called(greaterThan(1));
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search for deals...'), findsOneWidget);
    });

    testWidgets('should trigger search when search text is entered', (WidgetTester tester) async {
      // Arrange
      final searchResults = [createTestDeal(title: 'Pizza Search Result')];
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => []);
      when(mockDealService.searchDeals('pizza')).thenAnswer((_) async => searchResults);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Enter search text
      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.pump(const Duration(milliseconds: 600)); // Debounce delay
      await tester.pumpAndSettle();

      // Assert
      verify(mockDealService.searchDeals('pizza')).called(1);
    });

    testWidgets('should display deal images correctly', (WidgetTester tester) async {
      // Arrange
      final dealWithImage = createTestDeal(
        title: 'Image Deal',
      );
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => [dealWithImage]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [dealWithImage]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should handle deals with missing restaurant data gracefully', (WidgetTester tester) async {
      // Arrange
      final dealWithoutRestaurant = Deal(
        id: 'no-restaurant-deal',
        businessId: 'test-business',
        title: 'No Restaurant Deal',
        description: 'Deal without restaurant',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        quantitySold: 0,
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
        status: DealStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        restaurant: null, // No restaurant data
      );
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => [dealWithoutRestaurant]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [dealWithoutRestaurant]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No Restaurant Deal'), findsOneWidget);
      expect(tester.takeException(), isNull); // Should not throw exception
    });

    testWidgets('should display time remaining correctly', (WidgetTester tester) async {
      // Arrange
      final expiringDeal = Deal(
        id: 'expiring-deal',
        businessId: 'test-business',
        title: 'Expiring Deal',
        description: 'This deal is expiring soon',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        quantitySold: 0,
        expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
        status: DealStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        restaurant: createTestRestaurant(),
      );
      when(mockDealService.fetchCustomerDeals()).thenAnswer((_) async => [expiringDeal]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [expiringDeal]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('2h'), findsOneWidget); // Time remaining format
    });
  });
}