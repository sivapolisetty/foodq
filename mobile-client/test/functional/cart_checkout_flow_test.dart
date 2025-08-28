import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:grabeat/features/home/screens/customer_home_screen.dart';
import 'package:grabeat/features/orders/screens/cart_screen.dart';
import 'package:grabeat/features/orders/screens/checkout_screen.dart';
import 'test_setup.dart';

void main() {
  group('Cart & Checkout Flow - Functional Tests', () {
    setUp(() {
      TestSupabaseService.initialize();
      TestSupabaseService.setupAuthenticatedUser(role: 'customer');
    });

    testWidgets('Add item to cart from deal details', (WidgetTester tester) async {
      // Setup: Mock deal data
      final deal = TestData.sampleDeal;
      when(TestSupabaseService.mockClient.from('deals').select().eq('id', 'deal-789')).thenAnswer(
        (_) async => [deal],
      );
      
      // Act: Load deal details screen
      await tester.pumpWidget(TestApp(
        child: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                Image.network('https://example.com/food.jpg'),
                Text(deal['title']),
                Text('\$${deal['discount_price']}'),
                Text('Originally \$${deal['original_price']}'),
                ElevatedButton(
                  key: const Key('add_to_cart_button'),
                  onPressed: () {
                    // Add to cart logic
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ),
      ));
      
      // Act: Tap add to cart
      await tester.tap(find.byKey(const Key('add_to_cart_button')));
      await tester.pumpAndSettle();
      
      // Assert: Success message shown
      expect(find.text('Added to cart'), findsOneWidget);
      
      // Assert: Cart badge updated
      expect(find.text('1'), findsOneWidget); // Cart item count
    });

    testWidgets('View cart with multiple items', (WidgetTester tester) async {
      // Setup: Mock cart items
      final cartItems = [
        {
          'id': 'cart-item-1',
          'deal': TestData.sampleDeal,
          'quantity': 2,
          'subtotal': 40.00,
        },
        {
          'id': 'cart-item-2',
          'deal': {...TestData.sampleDeal, 'id': 'deal-002', 'title': 'Burger Combo'},
          'quantity': 1,
          'subtotal': 20.00,
        },
      ];
      
      // Act: Load cart screen
      await tester.pumpWidget(TestApp(
        child: CartScreen(cartItems: cartItems),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Cart items displayed
      expect(find.text('Fresh Sushi Platter'), findsOneWidget);
      expect(find.text('Burger Combo'), findsOneWidget);
      
      // Assert: Quantities shown
      expect(find.text('Qty: 2'), findsOneWidget);
      expect(find.text('Qty: 1'), findsOneWidget);
      
      // Assert: Total calculation
      expect(find.text('Total: \$60.00'), findsOneWidget);
    });

    testWidgets('Update item quantity in cart', (WidgetTester tester) async {
      // Setup: Single item in cart
      final cartItems = [
        {
          'id': 'cart-item-1',
          'deal': TestData.sampleDeal,
          'quantity': 1,
          'subtotal': 20.00,
        },
      ];
      
      // Act: Load cart screen
      await tester.pumpWidget(TestApp(
        child: CartScreen(cartItems: cartItems),
      ));
      
      await tester.pumpAndSettle();
      
      // Act: Increase quantity
      final increaseButton = find.byIcon(Icons.add).first;
      await tester.tap(increaseButton);
      await tester.pumpAndSettle();
      
      // Assert: Quantity updated
      expect(find.text('Qty: 2'), findsOneWidget);
      expect(find.text('Total: \$40.00'), findsOneWidget);
      
      // Act: Decrease quantity
      final decreaseButton = find.byIcon(Icons.remove).first;
      await tester.tap(decreaseButton);
      await tester.pumpAndSettle();
      
      // Assert: Quantity back to 1
      expect(find.text('Qty: 1'), findsOneWidget);
      expect(find.text('Total: \$20.00'), findsOneWidget);
    });

    testWidgets('Remove item from cart', (WidgetTester tester) async {
      // Setup: Multiple items in cart
      final cartItems = [
        {
          'id': 'cart-item-1',
          'deal': TestData.sampleDeal,
          'quantity': 2,
          'subtotal': 40.00,
        },
        {
          'id': 'cart-item-2',
          'deal': {...TestData.sampleDeal, 'id': 'deal-002', 'title': 'Burger Combo'},
          'quantity': 1,
          'subtotal': 20.00,
        },
      ];
      
      // Act: Load cart screen
      await tester.pumpWidget(TestApp(
        child: CartScreen(cartItems: cartItems),
      ));
      
      await tester.pumpAndSettle();
      
      // Act: Remove first item
      final removeButton = find.byIcon(Icons.delete).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();
      
      // Assert: Confirmation dialog
      expect(find.text('Remove from cart?'), findsOneWidget);
      
      // Act: Confirm removal
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      
      // Assert: Item removed
      expect(find.text('Fresh Sushi Platter'), findsNothing);
      expect(find.text('Burger Combo'), findsOneWidget);
      expect(find.text('Total: \$20.00'), findsOneWidget);
    });

    testWidgets('Proceed to checkout with valid cart', (WidgetTester tester) async {
      // Setup: Cart with items
      final cartItems = [
        {
          'id': 'cart-item-1',
          'deal': TestData.sampleDeal,
          'quantity': 2,
          'subtotal': 40.00,
        },
      ];
      
      // Act: Load cart screen
      await tester.pumpWidget(TestApp(
        child: CartScreen(cartItems: cartItems),
      ));
      
      await tester.pumpAndSettle();
      
      // Act: Tap checkout button
      final checkoutButton = find.text('Proceed to Checkout');
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();
      
      // Assert: Navigation to checkout screen
      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
    });

    testWidgets('Complete checkout with payment', (WidgetTester tester) async {
      // Setup: Mock Stripe payment
      when(TestSupabaseService.mockClient.rpc('create_payment_intent', params: any)).thenAnswer(
        (_) async => {'client_secret': 'test_secret_123'},
      );
      
      when(TestSupabaseService.mockClient.from('orders').insert(any)).thenAnswer(
        (_) async => [TestData.sampleOrder],
      );
      
      // Act: Load checkout screen
      await tester.pumpWidget(TestApp(
        child: CheckoutScreen(
          cartItems: [
            {
              'id': 'cart-item-1',
              'deal': TestData.sampleDeal,
              'quantity': 2,
              'subtotal': 40.00,
            },
          ],
          totalAmount: 40.00,
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Order details shown
      expect(find.text('Fresh Sushi Platter x2'), findsOneWidget);
      expect(find.text('Total: \$40.00'), findsOneWidget);
      
      // Act: Select payment method
      final cardOption = find.text('Credit/Debit Card');
      await tester.tap(cardOption);
      await tester.pumpAndSettle();
      
      // Act: Enter card details (simulated)
      final payButton = find.text('Pay \$40.00');
      await tester.tap(payButton);
      await tester.pumpAndSettle();
      
      // Assert: Order confirmation
      expect(find.text('Order Confirmed!'), findsOneWidget);
      expect(find.text('Pickup Code: PICKUP123'), findsOneWidget);
    });

    testWidgets('Apply discount code at checkout', (WidgetTester tester) async {
      // Setup: Mock discount validation
      when(TestSupabaseService.mockClient.from('discount_codes').select().eq('code', 'SAVE10')).thenAnswer(
        (_) async => [
          {
            'id': 'discount-001',
            'code': 'SAVE10',
            'discount_percentage': 10,
            'is_active': true,
          }
        ],
      );
      
      // Act: Load checkout screen
      await tester.pumpWidget(TestApp(
        child: CheckoutScreen(
          cartItems: [
            {
              'id': 'cart-item-1',
              'deal': TestData.sampleDeal,
              'quantity': 1,
              'subtotal': 20.00,
            },
          ],
          totalAmount: 20.00,
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Act: Enter discount code
      final discountField = find.byKey(const Key('discount_code_field'));
      await tester.enterText(discountField, 'SAVE10');
      
      final applyButton = find.text('Apply');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();
      
      // Assert: Discount applied
      expect(find.text('Discount (10%)'), findsOneWidget);
      expect(find.text('-\$2.00'), findsOneWidget);
      expect(find.text('Total: \$18.00'), findsOneWidget);
    });

    testWidgets('Checkout validation - empty cart', (WidgetTester tester) async {
      // Act: Load cart screen with no items
      await tester.pumpWidget(TestApp(
        child: CartScreen(cartItems: []),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Empty cart message
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Start browsing deals'), findsOneWidget);
      
      // Assert: Checkout button disabled
      final checkoutButton = find.text('Proceed to Checkout');
      expect(checkoutButton, findsNothing);
    });

    testWidgets('Checkout validation - minimum order amount', (WidgetTester tester) async {
      // Setup: Cart below minimum
      final cartItems = [
        {
          'id': 'cart-item-1',
          'deal': {...TestData.sampleDeal, 'discount_price': 5.00},
          'quantity': 1,
          'subtotal': 5.00,
        },
      ];
      
      // Act: Load cart screen
      await tester.pumpWidget(TestApp(
        child: CartScreen(cartItems: cartItems),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Minimum order message
      expect(find.text('Minimum order: \$10.00'), findsOneWidget);
      
      // Act: Try to checkout
      final checkoutButton = find.text('Proceed to Checkout');
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();
      
      // Assert: Error message
      expect(find.text('Add more items to meet minimum order'), findsOneWidget);
    });

    testWidgets('Payment failure handling', (WidgetTester tester) async {
      // Setup: Mock payment failure
      when(TestSupabaseService.mockClient.rpc('create_payment_intent', params: any)).thenThrow(
        Exception('Payment processing failed'),
      );
      
      // Act: Load checkout screen
      await tester.pumpWidget(TestApp(
        child: CheckoutScreen(
          cartItems: [
            {
              'id': 'cart-item-1',
              'deal': TestData.sampleDeal,
              'quantity': 1,
              'subtotal': 20.00,
            },
          ],
          totalAmount: 20.00,
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Act: Attempt payment
      final payButton = find.text('Pay \$20.00');
      await tester.tap(payButton);
      await tester.pumpAndSettle();
      
      // Assert: Error dialog
      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('Please try again'), findsOneWidget);
      
      // Act: Retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      
      // Assert: Still on checkout screen
      expect(find.byType(CheckoutScreen), findsOneWidget);
    });

    testWidgets('Save cart for later', (WidgetTester tester) async {
      // Setup: Mock save cart
      when(TestSupabaseService.mockClient.from('saved_carts').insert(any)).thenAnswer(
        (_) async => [
          {
            'id': 'saved-cart-001',
            'user_id': 'customer-123',
            'items': [],
            'created_at': DateTime.now().toIso8601String(),
          }
        ],
      );
      
      // Act: Load cart screen
      await tester.pumpWidget(TestApp(
        child: CartScreen(cartItems: [
          {
            'id': 'cart-item-1',
            'deal': TestData.sampleDeal,
            'quantity': 1,
            'subtotal': 20.00,
          },
        ]),
      ));
      
      await tester.pumpAndSettle();
      
      // Act: Save for later
      final saveButton = find.text('Save for Later');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      
      // Assert: Success message
      expect(find.text('Cart saved'), findsOneWidget);
    });
  });
}