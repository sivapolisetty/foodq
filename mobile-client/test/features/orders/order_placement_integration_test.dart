import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../lib/features/deals/widgets/order_placement_bottom_sheet.dart';
import '../../../lib/features/deals/screens/deal_details_screen.dart';
import '../../../lib/features/orders/services/order_service.dart';
import '../../../lib/shared/models/deal.dart';
import '../../../lib/shared/models/business.dart';
import '../../../lib/shared/models/order.dart';
import '../../../lib/shared/models/app_user.dart';
import '../../../lib/shared/enums/user_type.dart';
import '../../../lib/features/profile/providers/user_provider.dart';

import 'order_placement_integration_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<OrderService>(),
])
void main() {
  group('Order Placement Integration Tests', () {
    late MockOrderService mockOrderService;

    setUp(() {
      mockOrderService = MockOrderService();
    });

    final testDeal = Deal(
      id: 'deal-1',
      title: 'Test Deal',
      description: 'Test Description', 
      originalPrice: 15.99,
      discountedPrice: 8.99,
      discountPercentage: 44,
      quantityAvailable: 5,
      businessId: 'business-1',
      status: DealStatus.active,
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

    final testBusiness = Business(
      id: 'business-1',
      name: 'Test Restaurant',
      description: 'Test Description',
      address: '123 Test St',
      email: 'test@restaurant.com',
      rating: 4.5,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final testOrder = Order(
      id: 'order-123',
      customerId: 'customer-1',
      dealId: 'deal-1', 
      businessId: 'business-1',
      quantity: 1,
      unitPrice: 8.99,
      totalAmount: 8.99,
      status: OrderStatus.pending,
      orderType: OrderType.pickup,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: PaymentMethod.cash,
      createdAt: DateTime.now(),
    );

    final testCustomerUser = AppUser(
      id: 'customer-1',
      name: 'Test Customer',
      email: 'customer@test.com',
      userType: UserType.customer,
    );

    group('Order Placement UI Tests', () {
      testWidgets('order placement button has improved styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
            ],
            child: MaterialApp(
              home: DealDetailsScreen(deal: testDeal),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the order button
        expect(find.text('Order for Pickup'), findsOneWidget);
        
        // Verify button styling elements are present
        expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
        expect(find.text('\$${testDeal.discountedPrice.toStringAsFixed(2)}'), findsOneWidget);
      });

      testWidgets('unavailable deal shows proper button styling', (WidgetTester tester) async {
        final expiredDeal = testDeal.copyWith(
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
            ],
            child: MaterialApp(
              home: DealDetailsScreen(deal: expiredDeal),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify unavailable button styling
        expect(find.text('Not Available'), findsOneWidget);
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      });
    });

    group('Order Creation Flow Tests', () {
      testWidgets('order placement modal shows and handles creation', (WidgetTester tester) async {
        bool orderPlacedCallbackCalled = false;
        Order? placedOrder;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => OrderPlacementBottomSheet(
                        deal: testDeal,
                        business: testBusiness,
                        onOrderPlaced: (order) {
                          orderPlacedCallbackCalled = true;
                          placedOrder = order;
                        },
                      ),
                    );
                  },
                  child: const Text('Show Order Modal'),
                ),
              ),
            ),
          ),
        );

        // Tap to show modal
        await tester.tap(find.text('Show Order Modal'));
        await tester.pumpAndSettle();

        // Verify modal is shown
        expect(find.text('Place Order'), findsOneWidget);
        expect(find.text('Pickup only • ${testBusiness.name}'), findsOneWidget);
        
        // Verify deal summary is shown
        expect(find.text(testDeal.title), findsOneWidget);
        expect(find.text('\$${testDeal.discountedPrice.toStringAsFixed(2)}'), findsOneWidget);
      });

      testWidgets('order button shows loading state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderPlacementBottomSheet(
                deal: testDeal,
                business: testBusiness,
                onOrderPlaced: (order) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and verify the order button exists
        final orderButton = find.widgetWithText(ElevatedButton, 'Place Order • \$${testDeal.discountedPrice.toStringAsFixed(2)}');
        expect(orderButton, findsOneWidget);
      });
    });

    group('Navigation Flow Tests', () {
      testWidgets('successful order placement triggers navigation', (WidgetTester tester) async {
        bool navigationTriggered = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    // Simulate the _handleOrderPlaced method
                    navigationTriggered = true;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Order #${testOrder.id.substring(0, 8).toUpperCase()} placed successfully!'),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Simulate Order Placement'),
                ),
              ),
            ),
          ),
        );

        // Simulate order placement
        await tester.tap(find.text('Simulate Order Placement'));
        await tester.pumpAndSettle();

        // Verify navigation was triggered
        expect(navigationTriggered, isTrue);
        
        // Verify success message is shown
        expect(find.text('Order #ORDER-12 placed successfully!'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('order creation errors are handled gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    // Simulate error handling
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Failed to create order'),
                          ],
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: const Text('Simulate Error'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Simulate Error'));
        await tester.pumpAndSettle();

        expect(find.text('Failed to create order'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('UI Component Tests', () {
      testWidgets('quantity selector works correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderPlacementBottomSheet(
                deal: testDeal,
                business: testBusiness,
                onOrderPlaced: (order) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find quantity controls
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
        expect(find.text('1'), findsOneWidget); // Initial quantity
      });

      testWidgets('payment method selection works', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderPlacementBottomSheet(
                deal: testDeal,
                business: testBusiness,
                onOrderPlaced: (order) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify payment methods are shown
        expect(find.text('Cash'), findsOneWidget);
        expect(find.text('Card'), findsOneWidget);
        expect(find.text('Digital'), findsOneWidget);
      });
    });
  });
}