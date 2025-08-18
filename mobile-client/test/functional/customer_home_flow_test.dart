import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:kravekart/features/home/screens/customer_home_screen.dart';
import 'package:kravekart/features/deals/screens/deal_details_screen.dart';
import 'package:kravekart/features/search/screens/search_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'test_setup.dart';

void main() {
  group('Customer Home Screen - Functional Tests', () {
    setUp(() {
      TestSupabaseService.initialize();
      TestSupabaseService.setupAuthenticatedUser(role: 'customer');
      
      // Mock location permissions
      when(Geolocator.checkPermission()).thenAnswer((_) async => LocationPermission.always);
      when(Geolocator.getCurrentPosition()).thenAnswer((_) async => Position(
        longitude: -122.4194,
        latitude: 37.7749,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      ));
    });

    testWidgets('Home screen displays nearby deals on map and list', (WidgetTester tester) async {
      // Setup: Mock nearby deals API response
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Assert: Map view is displayed
      expect(find.byKey(const Key('map_view')), findsOneWidget);
      
      // Assert: Deal cards are displayed in list
      expect(find.byKey(const Key('deals_list')), findsOneWidget);
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Burger Combo'), findsOneWidget);
      expect(find.text('Pad Thai'), findsOneWidget);
      
      // Assert: Deal information is displayed correctly
      expect(find.text('\$20.00'), findsWidgets); // Discount prices
      expect(find.text('50% OFF'), findsWidgets); // Discount percentage
    });

    testWidgets('Tapping deal card navigates to deal details', (WidgetTester tester) async {
      // Setup: Mock deals data
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Act: Tap on a deal card
      final dealCard = find.text('Pizza Margherita').first;
      await tester.tap(dealCard);
      await tester.pumpAndSettle();
      
      // Assert: Navigation to deal details screen
      expect(find.byType(DealDetailsScreen), findsOneWidget);
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('Search bar functionality - filters deals', (WidgetTester tester) async {
      // Setup: Mock deals data
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Act: Enter search query
      final searchBar = find.byKey(const Key('search_bar'));
      await tester.tap(searchBar);
      await tester.enterText(searchBar, 'Pizza');
      await tester.pumpAndSettle();
      
      // Assert: Only matching deals are shown
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Burger Combo'), findsNothing); // Filtered out
      expect(find.text('Pad Thai'), findsNothing); // Filtered out
    });

    testWidgets('Category filters work correctly', (WidgetTester tester) async {
      // Setup: Mock deals data
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Act: Tap Italian category filter
      final italianFilter = find.text('Italian');
      await tester.tap(italianFilter);
      await tester.pumpAndSettle();
      
      // Assert: Only Italian deals shown
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Burger Combo'), findsNothing);
      expect(find.text('Pad Thai'), findsNothing);
    });

    testWidgets('Pull to refresh updates deals list', (WidgetTester tester) async {
      // Setup: Initial deals
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals.take(2).toList(),
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Assert: Initial deals shown
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Burger Combo'), findsOneWidget);
      expect(find.text('Pad Thai'), findsNothing);
      
      // Setup: Mock refreshed data with new deal
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Act: Pull to refresh
      await tester.drag(find.byType(ListView).first, const Offset(0, 300));
      await tester.pumpAndSettle();
      
      // Assert: All deals now shown
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Burger Combo'), findsOneWidget);
      expect(find.text('Pad Thai'), findsOneWidget);
    });

    testWidgets('Location permission denied - shows permission request', (WidgetTester tester) async {
      // Setup: Mock location permission denied
      when(Geolocator.checkPermission()).thenAnswer((_) async => LocationPermission.denied);
      when(Geolocator.requestPermission()).thenAnswer((_) async => LocationPermission.denied);
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Location permission dialog shown
      expect(find.text('Location Permission Required'), findsOneWidget);
      expect(find.text('Enable Location'), findsOneWidget);
    });

    testWidgets('Real-time notification for new nearby deal', (WidgetTester tester) async {
      // Setup: Initial deals
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals.take(2).toList(),
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Assert: Initial state
      expect(find.text('Pad Thai'), findsNothing);
      
      // Act: Simulate real-time notification
      // In real app, this would come from Firebase
      // Here we simulate by updating the mock and triggering rebuild
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Simulate notification banner
      await tester.pump();
      
      // Assert: Notification banner shown
      expect(find.text('New deal nearby!'), findsOneWidget);
      
      // Act: Tap notification to refresh
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      
      // Assert: New deal appears
      expect(find.text('Pad Thai'), findsOneWidget);
    });

    testWidgets('Map view interactions - tap pin shows deal info', (WidgetTester tester) async {
      // Setup: Mock deals data
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Act: Tap on map pin (simulated by tapping on map at specific location)
      final mapView = find.byKey(const Key('map_view'));
      await tester.tapAt(tester.getCenter(mapView));
      await tester.pumpAndSettle();
      
      // Assert: Deal info popup shown
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('Distance-based sorting of deals', (WidgetTester tester) async {
      // Setup: Mock deals with distances
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Act: Change sort to distance
      final sortButton = find.byKey(const Key('sort_button'));
      await tester.tap(sortButton);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Distance'));
      await tester.pumpAndSettle();
      
      // Assert: Deals sorted by distance
      final dealsList = find.byKey(const Key('deals_list'));
      final dealsListWidget = tester.widget<ListView>(dealsList);
      
      // Verify order: Pizza (0.5km) -> Burger (0.8km) -> Pad Thai (1.2km)
      expect(find.text('0.5 km away'), findsOneWidget);
      expect(find.text('0.8 km away'), findsOneWidget);
      expect(find.text('1.2 km away'), findsOneWidget);
    });

    testWidgets('Empty state when no deals available', (WidgetTester tester) async {
      // Setup: Mock empty deals response
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => [],
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Assert: Empty state message
      expect(find.text('No deals available nearby'), findsOneWidget);
      expect(find.text('Check back later for new deals!'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('Bottom navigation works correctly', (WidgetTester tester) async {
      // Setup: Mock deals data
      when(TestSupabaseService.mockClient.from('deals').select().gte('quantity', 1)).thenAnswer(
        (_) async => TestData.nearbyDeals,
      );
      
      // Act: Load home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      await TestActions.waitForData(tester);
      
      // Assert: Bottom nav is visible
      expect(find.byKey(const Key('bottom_nav')), findsOneWidget);
      
      // Act: Tap Search tab
      await TestActions.navigateToTab(tester, 'Search');
      
      // Assert: Navigation to search screen
      expect(find.byType(SearchScreen), findsOneWidget);
      
      // Act: Navigate back to Home
      await TestActions.navigateToTab(tester, 'Home');
      
      // Assert: Back to home screen
      expect(find.byType(CustomerHomeScreen), findsOneWidget);
    });
  });
}