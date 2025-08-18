import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../lib/features/orders/screens/orders_screen.dart';
import '../../../lib/features/orders/providers/order_provider.dart';
import '../../../lib/features/orders/services/order_service.dart';
import '../../../lib/shared/models/app_user.dart';
import '../../../lib/shared/models/order.dart';
import '../../../lib/shared/enums/user_type.dart';
import '../../../lib/features/profile/providers/user_provider.dart';

import 'orders_screen_debug_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<OrderService>(),
])
void main() {
  group('Orders Screen Debug Tests', () {
    late MockOrderService mockOrderService;

    setUp(() {
      mockOrderService = MockOrderService();
    });

    final testCustomerUser = AppUser(
      id: 'customer-1',
      name: 'Test Customer',
      email: 'customer@test.com',
      userType: UserType.customer,
    );

    final testBusinessUser = AppUser(
      id: 'business-1',
      name: 'Test Business',
      email: 'business@test.com',
      userType: UserType.business,
      businessId: 'business-1',
    );

    final testOrder = Order(
      id: 'order-1',
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

    group('Error Display Tests', () {
      testWidgets('shows enhanced error message when orders fail to load', (WidgetTester tester) async {
        when(mockOrderService.getCustomerOrders(any))
            .thenThrow(Exception('Network connection failed'));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
              orderServiceProvider.overrideWith((ref) => mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show enhanced error UI
        expect(find.text('Failed to load orders'), findsOneWidget);
        expect(find.text('Exception: Network connection failed'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.byIcon(Icons.bug_report), findsOneWidget);
        expect(find.text('Debug Info'), findsOneWidget);
      });

      testWidgets('debug info button works', (WidgetTester tester) async {
        when(mockOrderService.getCustomerOrders(any))
            .thenThrow(Exception('Test error'));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
              orderServiceProvider.overrideWith((ref) => mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap debug info button (should not crash)
        await tester.tap(find.text('Debug Info'));
        await tester.pump();

        // Should still show the same error screen
        expect(find.text('Failed to load orders'), findsOneWidget);
      });

      testWidgets('retry button triggers reload', (WidgetTester tester) async {
        int callCount = 0;
        when(mockOrderService.getCustomerOrders(any)).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('First attempt failed');
          }
          return [testOrder];
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
              orderServiceProvider.overrideWith((ref) => mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show error initially
        expect(find.text('Failed to load orders'), findsOneWidget);
        expect(callCount, equals(1));

        // Tap retry
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Should now show the order
        expect(callCount, equals(2));
        expect(find.text('Failed to load orders'), findsNothing);
      });
    });

    group('Success State Tests', () {
      testWidgets('shows empty state when no orders exist', (WidgetTester tester) async {
        when(mockOrderService.getCustomerOrders(any)).thenAnswer((_) async => []);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
              orderServiceProvider.overrideWith((ref) => mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show empty state
        expect(find.text('No active orders yet'), findsOneWidget);
        expect(find.text('Browse Deals'), findsOneWidget);
        expect(find.byIcon(Icons.pending_actions), findsOneWidget);
      });

      testWidgets('shows orders when they exist', (WidgetTester tester) async {
        when(mockOrderService.getCustomerOrders(any)).thenAnswer((_) async => [testOrder]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
              orderServiceProvider.overrideWith((ref) => mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show the order
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('User Type Tests', () {
      testWidgets('handles customer user correctly', (WidgetTester tester) async {
        when(mockOrderService.getCustomerOrders('customer-1'))
            .thenAnswer((_) async => [testOrder]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
              orderServiceProvider.overrideWith((ref) => mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should call customer orders API
        verify(mockOrderService.getCustomerOrders('customer-1')).called(1);
        verifyNever(mockOrderService.getBusinessOrders(any));
      });

      testWidgets('handles business user correctly', (WidgetTester tester) async {
        when(mockOrderService.getBusinessOrders('business-1'))
            .thenAnswer((_) async => [testOrder]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
              orderServiceProvider.overrideWith((ref) => mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should call business orders API
        verify(mockOrderService.getBusinessOrders('business-1')).called(1);
        verifyNever(mockOrderService.getCustomerOrders(any));
      });
    });

    group('Loading State Tests', () {
      testWidgets('shows loading indicator initially', (WidgetTester tester) async {
        when(mockOrderService.getCustomerOrders(any))
            .thenAnswer((_) => Future.delayed(const Duration(seconds: 1), () => [testOrder]));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testCustomerUser)),
              orderServiceProvider.overrideWith((ref) => mockOrderService),
            ],
            child: const MaterialApp(
              home: OrdersScreen(),
            ),
          ),
        );

        // Should show loading initially
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // Loading should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });
}