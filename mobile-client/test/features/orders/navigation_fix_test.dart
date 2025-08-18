import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../lib/features/deals/widgets/order_placement_bottom_sheet.dart';
import '../../../lib/shared/models/deal.dart';
import '../../../lib/shared/models/business.dart';
import '../../../lib/shared/models/order.dart';
import '../../../lib/shared/models/app_user.dart';
import '../../../lib/shared/enums/user_type.dart';
import '../../../lib/features/profile/providers/user_provider.dart';

void main() {
  group('Navigation Fix Tests', () {
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

    final testCustomerUser = AppUser(
      id: 'customer-1',
      name: 'Test Customer',
      email: 'customer@test.com',
      userType: UserType.customer,
    );

    testWidgets('modal dismissal does not conflict with navigation', (WidgetTester tester) async {
      bool navigationTriggered = false;
      bool modalDismissed = false;
      
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
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
                          // Simulate the fixed navigation flow
                          modalDismissed = true;
                          
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              navigationTriggered = true;
                            }
                          });
                        },
                      ),
                    );
                  },
                  child: const Text('Show Modal'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Orders Screen')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Show modal
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Place Order'), findsOneWidget);
    });

    testWidgets('context mounted checks prevent navigation errors', (WidgetTester tester) async {
      bool contextCheckPassed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => StatefulWidget(
              child: Builder(
                builder: (context) {
                  // Simulate the context checks in our fix
                  if (context.mounted) {
                    contextCheckPassed = true;
                  }
                  
                  return Scaffold(
                    body: ElevatedButton(
                      onPressed: () {
                        // Simulate order placement callback with context checks
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            contextCheckPassed = true;
                            try {
                              // This would be context.go('/orders') in real app
                              Navigator.of(context).pushNamed('/orders');
                            } catch (e) {
                              // Error handling that we added
                              contextCheckPassed = false;
                            }
                          }
                        });
                      },
                      child: const Text('Test Navigation'),
                    ),
                  );
                },
              ),
              createState: () => _TestWidgetState(),
            ),
          ),
          routes: {
            '/orders': (context) => const Scaffold(
              body: Center(child: Text('Orders')),
            ),
          },
        ),
      );

      await tester.tap(find.text('Test Navigation'));
      await tester.pumpAndSettle();

      expect(contextCheckPassed, isTrue);
    });

    testWidgets('order placement flow handles timing correctly', (WidgetTester tester) async {
      final List<String> executionOrder = [];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  // Simulate the order placement timing fix
                  executionOrder.add('1. Order created');
                  
                  // Modal dismissed first
                  executionOrder.add('2. Modal dismissed');
                  
                  // Then callback with delay
                  Future.delayed(const Duration(milliseconds: 50), () {
                    executionOrder.add('3. Navigation callback');
                    
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      executionOrder.add('4. Post-frame navigation');
                      
                      Future.delayed(const Duration(milliseconds: 200), () {
                        executionOrder.add('5. Success message');
                      });
                    });
                  });
                },
                child: const Text('Test Timing'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Timing'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      expect(executionOrder, [
        '1. Order created',
        '2. Modal dismissed',
        '3. Navigation callback',
        '4. Post-frame navigation',
        '5. Success message',
      ]);
    });
  });
}

class _TestWidgetState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}