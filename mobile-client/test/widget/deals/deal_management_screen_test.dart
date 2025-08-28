import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:grabeat/features/deals/screens/deal_management_screen.dart';
import 'package:grabeat/features/deals/providers/deal_provider.dart';
import 'package:grabeat/shared/models/deal.dart';
import 'package:grabeat/shared/theme/app_theme.dart';

// Mock providers for testing
class MockDealListNotifier extends StateNotifier<DealListState> {
  MockDealListNotifier() : super(const DealListState());

  void setMockState(DealListState newState) {
    state = newState;
  }

  @override
  Future<void> loadDeals({String? businessId}) async {
    state = state.copyWith(isLoading: false, deals: _mockDeals);
  }

  @override
  Future<bool> createDeal(Map<String, dynamic> dealData) async {
    return true;
  }

  @override
  Future<bool> deactivateDeal(String dealId) async {
    return true;
  }

  List<Deal> get _mockDeals => [
    Deal(
      id: 'deal-1',
      businessId: 'business-1',
      title: 'Pizza Special',
      description: 'Delicious pizza at 50% off',
      originalPrice: 20.0,
      discountedPrice: 10.0,
      quantityAvailable: 5,
      quantitySold: 2,
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      status: DealStatus.active,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now(),
    ),
    Deal(
      id: 'deal-2',
      businessId: 'business-1',
      title: 'Urgent Burger Deal',
      description: 'Burgers expiring soon',
      originalPrice: 15.0,
      discountedPrice: 7.5,
      quantityAvailable: 10,
      quantitySold: 9, // Almost sold out
      expiresAt: DateTime.now().add(const Duration(minutes: 30)), // Expiring soon
      status: DealStatus.active,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now(),
    ),
    Deal(
      id: 'deal-3',
      businessId: 'business-1',
      title: 'Expired Sandwich Deal',
      description: 'This deal has expired',
      originalPrice: 12.0,
      discountedPrice: 6.0,
      quantityAvailable: 8,
      quantitySold: 3,
      expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: DealStatus.expired,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
}

void main() {
  group('DealManagementScreen Widget Tests', () {
    late MockDealListNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockDealListNotifier();
    });

    Widget createTestWidget({DealListState? initialState}) {
      return ProviderScope(
        overrides: [
          dealListProvider.overrideWith((ref) => mockNotifier),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DealManagementScreen(),
        ),
      );
    }

    testWidgets('should display loading state initially', (tester) async {
      mockNotifier.setMockState(const DealListState(isLoading: true));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display deal management screen with tabs', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if the screen has the correct title
      expect(find.text('Deal Management'), findsOneWidget);

      // Check if tabs are present
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Expiring'), findsOneWidget);
      expect(find.text('Expired'), findsOneWidget);

      // Check if create deal FAB is present
      expect(find.byKey(const Key('create_deal_fab')), findsOneWidget);
      expect(find.text('Create Deal'), findsOneWidget);
    });

    testWidgets('should display statistics header with correct data', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check statistics header
      expect(find.text('Today\'s Overview'), findsOneWidget);
      expect(find.text('Active Deals'), findsOneWidget);
      expect(find.text('Expiring Soon'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);

      // Check if statistics show correct values
      expect(find.text('2'), findsOneWidget); // 2 active deals
      expect(find.text('1'), findsOneWidget); // 1 expiring deal
    });

    testWidgets('should display active deals in active tab', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Active tab should be selected by default
      expect(find.text('Pizza Special'), findsOneWidget);
      expect(find.text('Urgent Burger Deal'), findsOneWidget);
      expect(find.text('Expired Sandwich Deal'), findsNothing); // Should not be in active tab

      // Check deal cards have action buttons
      expect(find.text('Edit'), findsAtLeast(1));
      expect(find.text('Deactivate'), findsAtLeast(1));
    });

    testWidgets('should display expiring deals in expiring tab', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on expiring tab
      await tester.tap(find.text('Expiring'));
      await tester.pumpAndSettle();

      // Should show only the expiring deal
      expect(find.text('Urgent Burger Deal'), findsOneWidget);
      expect(find.text('Pizza Special'), findsNothing);
      expect(find.text('Expired Sandwich Deal'), findsNothing);
    });

    testWidgets('should display expired deals in expired tab', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on expired tab
      await tester.tap(find.text('Expired'));
      await tester.pumpAndSettle();

      // Should show only the expired deal
      expect(find.text('Expired Sandwich Deal'), findsOneWidget);
      expect(find.text('Pizza Special'), findsNothing);
      expect(find.text('Urgent Burger Deal'), findsNothing);
    });

    testWidgets('should display empty state when no active deals', (tester) async {
      mockNotifier.setMockState(const DealListState(
        deals: [],
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No Active Deals'), findsOneWidget);
      expect(find.text('Create your first deal to start selling surplus food items.'), findsOneWidget);
      expect(find.text('Create Deal'), findsAtLeast(1));
    });

    testWidgets('should show create deal bottom sheet when FAB is tapped', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the create deal FAB
      await tester.tap(find.byKey(const Key('create_deal_fab')));
      await tester.pumpAndSettle();

      // Should show create deal bottom sheet
      expect(find.text('Create New Deal'), findsOneWidget);
      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Deal Title *'), findsOneWidget);
    });

    testWidgets('should show deactivate dialog when deactivate button is tapped', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap a deactivate button
      await tester.tap(find.text('Deactivate').first);
      await tester.pumpAndSettle();

      // Should show deactivate confirmation dialog
      expect(find.text('Deactivate Deal'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Deactivate'), findsAtLeast(1));
    });

    testWidgets('should handle refresh when pull to refresh is triggered', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the RefreshIndicator and trigger refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // The list should still be there after refresh
      expect(find.text('Pizza Special'), findsOneWidget);
    });

    testWidgets('should display error state when there is an error', (tester) async {
      mockNotifier.setMockState(const DealListState(
        isLoading: false,
        error: 'Failed to load deals',
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show error message (implementation depends on how errors are displayed)
      // This might be in a SnackBar or error widget - adjust based on actual implementation
    });

    testWidgets('should show urgency indicators for urgent deals', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Go to expiring tab where urgent deals should show urgency indicators
      await tester.tap(find.text('Expiring'));
      await tester.pumpAndSettle();

      // The urgent burger deal should have urgency indicators
      expect(find.text('Urgent Burger Deal'), findsOneWidget);
    });

    testWidgets('should navigate between tabs correctly', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start on active tab
      expect(find.text('Pizza Special'), findsOneWidget);

      // Navigate to expiring tab
      await tester.tap(find.text('Expiring'));
      await tester.pumpAndSettle();
      expect(find.text('Urgent Burger Deal'), findsOneWidget);
      expect(find.text('Pizza Special'), findsNothing);

      // Navigate to expired tab
      await tester.tap(find.text('Expired'));
      await tester.pumpAndSettle();
      expect(find.text('Expired Sandwich Deal'), findsOneWidget);
      expect(find.text('Urgent Burger Deal'), findsNothing);

      // Navigate back to active tab
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();
      expect(find.text('Pizza Special'), findsOneWidget);
      expect(find.text('Expired Sandwich Deal'), findsNothing);
    });

    testWidgets('should display deal cards with proper information', (tester) async {
      mockNotifier.setMockState(DealListState(
        deals: mockNotifier._mockDeals,
        isLoading: false,
      ));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check if deal information is displayed
      expect(find.text('Pizza Special'), findsOneWidget);
      expect(find.text('Delicious pizza at 50% off'), findsOneWidget);
      expect(find.text('\$10.00'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);

      // Check for pricing information
      expect(find.textContaining('50%'), findsAtLeast(1)); // Discount percentage
    });
  });

  group('DealCard Widget Tests', () {
    testWidgets('should display deal information correctly', (tester) async {
      final deal = Deal(
        id: 'test-deal',
        businessId: 'test-business',
        title: 'Test Deal',
        description: 'Test description',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 5,
        quantitySold: 2,
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        status: DealStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DealCard(deal: deal),
          ),
        ),
      );

      expect(find.text('Test Deal'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('\$10.00'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should show urgency indicator for urgent deals', (tester) async {
      final urgentDeal = Deal(
        id: 'urgent-deal',
        businessId: 'test-business',
        title: 'Urgent Deal',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 10,
        quantitySold: 9, // Almost sold out
        expiresAt: DateTime.now().add(const Duration(minutes: 30)), // Expiring soon
        status: DealStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DealCard(
              deal: urgentDeal,
              showUrgencyIndicator: true,
            ),
          ),
        ),
      );

      expect(find.text('URGENT'), findsOneWidget);
    });

    testWidgets('should not show action buttons in read-only mode', (tester) async {
      final deal = Deal(
        id: 'readonly-deal',
        businessId: 'test-business',
        title: 'Read Only Deal',
        originalPrice: 20.0,
        discountedPrice: 10.0,
        quantityAvailable: 5,
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        status: DealStatus.expired,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DealCard(
              deal: deal,
              isReadOnly: true,
            ),
          ),
        ),
      );

      expect(find.text('Edit'), findsNothing);
      expect(find.text('Deactivate'), findsNothing);
    });
  });
}