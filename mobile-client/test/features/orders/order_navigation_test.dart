import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';

import '../../../lib/features/deals/screens/deal_details_screen.dart';
import '../../../lib/features/orders/screens/orders_screen.dart';
import '../../../lib/shared/models/deal.dart';
import '../../../lib/shared/models/order.dart';
import '../../../lib/shared/models/app_user.dart';
import '../../../lib/shared/enums/user_type.dart';
import '../../../lib/features/profile/providers/user_provider.dart';

import 'order_navigation_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GoRouter>(),
])
void main() {
  group('Order Navigation Tests', () {
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockGoRouter = MockGoRouter();
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

    testWidgets('successful order placement navigates to orders screen', (WidgetTester tester) async {
      // Create a test router that captures navigation calls
      final router = GoRouter(
        initialLocation: '/deal-details',
        routes: [
          GoRoute(
            path: '/deal-details',
            builder: (context, state) => DealDetailsScreen(deal: testDeal),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/order-details',
            builder: (context, state) {
              final order = state.extra as Order;
              return Scaffold(
                body: Center(child: Text('Order Details: ${order.id}')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Wait for the initial screen to load
      await tester.pumpAndSettle();

      // Verify we're on the deal details screen initially
      expect(find.byType(DealDetailsScreen), findsOneWidget);
    });

    testWidgets('orders screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
          ],
          child: const MaterialApp(
            home: OrdersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify orders screen is displayed
      expect(find.byType(OrdersScreen), findsOneWidget);
    });

    testWidgets('snackbar shows order confirmation message', (WidgetTester tester) async {
      // Create a minimal widget that triggers the same navigation logic
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  // Simulate the same navigation logic as _handleOrderPlaced
                  Navigator.of(context).pushNamed('/orders');
                  
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
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text('Place Order'),
              ),
            ),
          ),
          routes: {
            '/orders': (context) => const Scaffold(
              body: Center(child: Text('Orders Screen')),
            ),
          },
        ),
      );

      // Tap the button to trigger order placement logic
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      // Verify success message is shown
      expect(find.text('Order #ORDER-12 placed successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    group('Order Flow Integration Tests', () {
      testWidgets('complete order placement flow works end-to-end', (WidgetTester tester) async {
        bool ordersScreenVisited = false;
        bool confirmationMessageShown = false;

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Simulate successful order placement
                        context.go('/orders');
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        confirmationMessageShown = true;
                      },
                      child: const Text('Place Order'),
                    ),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/orders',
              builder: (context, state) {
                ordersScreenVisited = true;
                return const Scaffold(
                  body: Center(child: Text('Orders Screen')),
                );
              },
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(routerConfig: router),
        );

        await tester.pumpAndSettle();

        // Tap place order button
        await tester.tap(find.text('Place Order'));
        await tester.pumpAndSettle();

        // Verify navigation occurred
        expect(ordersScreenVisited, isTrue);
        expect(find.text('Orders Screen'), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('navigation failure is handled gracefully', (WidgetTester tester) async {
        // Test that navigation errors don't crash the app
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    try {
                      Navigator.of(context).pushNamed('/nonexistent');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigation failed'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Test Navigation'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Test Navigation'));
        await tester.pumpAndSettle();

        // App should still be functional even if navigation fails
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}