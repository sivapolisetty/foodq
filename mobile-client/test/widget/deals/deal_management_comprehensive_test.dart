import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grabeat/features/deals/screens/deal_management_screen.dart';
import 'package:grabeat/features/deals/services/deal_service.dart';
import 'package:grabeat/shared/models/deal.dart';
import 'package:grabeat/shared/models/deal_result.dart';
import 'package:grabeat/shared/theme/app_theme.dart';

@GenerateMocks([DealService])
import 'deal_management_comprehensive_test.mocks.dart';

void main() {
  group('DealManagementScreen Widget Tests', () {
    late MockDealService mockDealService;
    const testBusinessId = 'test-business-123';

    setUp(() {
      mockDealService = MockDealService();
    });

    Widget createTestWidget({List<Deal>? deals}) {
      return ProviderScope(
        overrides: [],
        child: MaterialApp(
          theme: AppTheme.theme,
          home: DealManagementScreen(businessId: testBusinessId),
        ),
      );
    }

    Deal createTestDeal({
      String id = 'test-deal-1',
      String title = 'Test Deal',
      double originalPrice = 20.0,
      double discountedPrice = 15.0,
      int quantityAvailable = 10,
      int quantitySold = 0,
      DealStatus status = DealStatus.active,
    }) {
      return Deal(
        id: id,
        businessId: testBusinessId,
        title: title,
        description: 'Test deal description',
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        quantityAvailable: quantityAvailable,
        quantitySold: quantitySold,
        imageUrl: 'https://example.com/image.jpg',
        allergenInfo: 'Contains nuts',
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    testWidgets('should display app bar with correct title', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Deal Management'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display floating action button to create new deal', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async {
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
          quantityAvailable: 15,
          quantitySold: 3,
        ),
        createTestDeal(
          id: 'deal-2',
          title: 'Burger Combo',
          originalPrice: 15.0,
          discountedPrice: 12.0,
          quantityAvailable: 8,
          quantitySold: 1,
        ),
      ];
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => testDeals);

      // Act
      await tester.pumpWidget(createTestWidget(deals: testDeals));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Pizza Special'), findsOneWidget);
      expect(find.text('Burger Combo'), findsOneWidget);
      expect(find.text('\$25.00'), findsOneWidget);
      expect(find.text('\$18.00'), findsOneWidget);
      expect(find.text('\$15.00'), findsOneWidget);
      expect(find.text('\$12.00'), findsOneWidget);
    });

    testWidgets('should display deal statistics correctly', (WidgetTester tester) async {
      // Arrange
      final testDeal = createTestDeal(
        title: 'Statistics Deal',
        originalPrice: 30.0,
        discountedPrice: 20.0,
        quantityAvailable: 20,
        quantitySold: 5,
      );
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => [testDeal]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [testDeal]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Statistics Deal'), findsOneWidget);
      expect(find.text('15 remaining'), findsOneWidget); // 20 - 5 = 15
      expect(find.text('5 sold'), findsOneWidget);
      expect(find.text('33% OFF'), findsOneWidget); // (30-20)/30 * 100 = 33%
    });

    testWidgets('should display different status badges correctly', (WidgetTester tester) async {
      // Arrange
      final activeDeal = createTestDeal(
        id: 'active-deal',
        title: 'Active Deal',
        status: DealStatus.active,
      );
      final expiredDeal = createTestDeal(
        id: 'expired-deal',
        title: 'Expired Deal',
        status: DealStatus.expired,
      );
      final soldOutDeal = createTestDeal(
        id: 'soldout-deal',
        title: 'Sold Out Deal',
        status: DealStatus.soldOut,
      );

      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => [activeDeal, expiredDeal, soldOutDeal]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('Sold Out'), findsOneWidget);
    });

    testWidgets('should handle empty deals list', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(deals: []));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No deals created yet'), findsOneWidget);
      expect(find.text('Create your first deal to get started!'), findsOneWidget);
    });

    testWidgets('should display error message when deal loading fails', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to load deals'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should open create deal dialog when FAB is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create New Deal'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('should display create deal form with all required fields', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Open create deal dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Deal Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Original Price'), findsOneWidget);
      expect(find.text('Discounted Price'), findsOneWidget);
      expect(find.text('Quantity Available'), findsOneWidget);
      expect(find.text('Expires At'), findsOneWidget);
      expect(find.text('Create Deal'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should validate form fields when creating deal', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Open create deal dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Try to create deal without filling required fields
      await tester.tap(find.text('Create Deal'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Original price is required'), findsOneWidget);
      expect(find.text('Discounted price is required'), findsOneWidget);
      expect(find.text('Quantity is required'), findsOneWidget);
    });

    testWidgets('should create deal successfully with valid input', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => []);
      
      final newDeal = createTestDeal(title: 'New Test Deal');
      when(mockDealService.createDeal(
        businessId: testBusinessId,
        title: 'New Test Deal',
        description: 'Test description',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        expiresAt: any,
      )).thenAnswer((_) async => DealResult.success(deal: newDeal));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Open create deal dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Fill form fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Deal Title'), 'New Test Deal');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Test description');
      await tester.enterText(find.widgetWithText(TextFormField, 'Original Price'), '20.0');
      await tester.enterText(find.widgetWithText(TextFormField, 'Discounted Price'), '15.0');
      await tester.enterText(find.widgetWithText(TextFormField, 'Quantity Available'), '10');
      
      // Submit form
      await tester.tap(find.text('Create Deal'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockDealService.createDeal(
        businessId: testBusinessId,
        title: 'New Test Deal',
        description: 'Test description',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        expiresAt: any,
      )).called(1);
    });

    testWidgets('should display error message when deal creation fails', (WidgetTester tester) async {
      // Arrange
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => []);
      
      when(mockDealService.createDeal(
        businessId: any,
        title: any,
        description: any,
        originalPrice: any,
        discountedPrice: any,
        quantityAvailable: any,
        expiresAt: any,
      )).thenAnswer((_) async => const DealResult.error(
        message: 'Failed to create deal',
        code: 'CREATE_ERROR',
      ));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Open create deal dialog and fill form
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Deal Title'), 'Test Deal');
      await tester.enterText(find.widgetWithText(TextFormField, 'Original Price'), '20.0');
      await tester.enterText(find.widgetWithText(TextFormField, 'Discounted Price'), '15.0');
      await tester.enterText(find.widgetWithText(TextFormField, 'Quantity Available'), '10');
      
      await tester.tap(find.text('Create Deal'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to create deal'), findsOneWidget);
    });

    testWidgets('should allow editing existing deals', (WidgetTester tester) async {
      // Arrange
      final testDeal = createTestDeal(title: 'Editable Deal');
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => [testDeal]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [testDeal]));
      await tester.pumpAndSettle();
      
      // Find and tap edit button (assuming it exists)
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit Deal'), findsOneWidget);
      expect(find.text('Editable Deal'), findsOneWidget); // Pre-filled title
    });

    testWidgets('should allow deactivating deals', (WidgetTester tester) async {
      // Arrange
      final testDeal = createTestDeal(title: 'Deactivatable Deal');
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => [testDeal]);
      when(mockDealService.deactivateDeal(testDeal.id))
          .thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [testDeal]));
      await tester.pumpAndSettle();
      
      // Find and tap deactivate button
      await tester.tap(find.byIcon(Icons.stop).first);
      await tester.pumpAndSettle();
      
      // Confirm deactivation
      await tester.tap(find.text('Deactivate'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockDealService.deactivateDeal(testDeal.id)).called(1);
    });

    testWidgets('should display urgency indicators for deals', (WidgetTester tester) async {
      // Arrange
      final urgentDeal = Deal(
        id: 'urgent-deal',
        businessId: testBusinessId,
        title: 'Urgent Deal',
        description: 'Almost gone!',
        originalPrice: 20.0,
        discountedPrice: 15.0,
        quantityAvailable: 10,
        quantitySold: 9, // Almost sold out
        expiresAt: DateTime.now().add(const Duration(minutes: 30)), // Expiring soon
        status: DealStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => [urgentDeal]);

      // Act
      await tester.pumpWidget(createTestWidget(deals: [urgentDeal]));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Act Fast!'), findsOneWidget);
      expect(find.text('1 remaining'), findsOneWidget);
    });

    testWidgets('should handle pull-to-refresh gesture', (WidgetTester tester) async {
      // Arrange
      final testDeals = [createTestDeal()];
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => testDeals);

      // Act
      await tester.pumpWidget(createTestWidget(deals: testDeals));
      await tester.pumpAndSettle();
      
      // Perform pull-to-refresh
      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Assert
      verify(mockDealService.getDealsByBusinessId(testBusinessId)).called(greaterThan(1));
    });

    testWidgets('should display deal analytics summary', (WidgetTester tester) async {
      // Arrange
      final testDeals = [
        createTestDeal(id: 'deal-1', quantitySold: 5),
        createTestDeal(id: 'deal-2', quantitySold: 3),
        createTestDeal(id: 'deal-3', quantitySold: 0, status: DealStatus.expired),
      ];
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => testDeals);

      // Act
      await tester.pumpWidget(createTestWidget(deals: testDeals));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('3'), findsOneWidget); // Total deals
      expect(find.text('2'), findsOneWidget); // Active deals
      expect(find.text('8'), findsOneWidget); // Total items sold (5+3+0)
    });

    testWidgets('should filter deals by status', (WidgetTester tester) async {
      // Arrange
      final activeDeals = [
        createTestDeal(id: 'active-1', status: DealStatus.active),
        createTestDeal(id: 'active-2', status: DealStatus.active),
      ];
      final expiredDeals = [
        createTestDeal(id: 'expired-1', status: DealStatus.expired),
      ];
      
      when(mockDealService.getDealsByBusinessId(testBusinessId))
          .thenAnswer((_) async => [...activeDeals, ...expiredDeals]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Tap on status filter (assuming it exists)
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Active'), findsWidgets); // Multiple active status badges
      expect(find.text('Expired'), findsNothing); // No expired deals shown
    });
  });
}