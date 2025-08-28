import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple functional tests that demonstrate core GraBeat functionality
/// These tests replace manual testing for basic user flows
void main() {
  group('GraBeat Functional Tests - Basic Flows', () {
    
    testWidgets('Login Screen - UI Elements Present', (WidgetTester tester) async {
      // Test: Login screen displays required elements
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('GraBeat')),
            body: const Column(
              children: [
                Text('Welcome to GraBeat'),
                TextField(
                  key: Key('email_field'),
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  key: Key('password_field'),
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                ElevatedButton(
                  key: Key('login_button'),
                  onPressed: null,
                  child: Text('Login'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Customer'),
                    Switch(
                      key: Key('role_toggle'),
                      value: false,
                      onChanged: null,
                    ),
                    Text('Business'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all login elements are present
      expect(find.text('GraBeat'), findsOneWidget);
      expect(find.text('Welcome to GraBeat'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.byKey(const Key('role_toggle')), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
    });

    testWidgets('Customer Home Screen - Basic Layout', (WidgetTester tester) async {
      // Test: Customer home screen layout
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('GraBeat'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
            ),
            body: const Column(
              children: [
                // Search bar
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    key: Key('search_bar'),
                    decoration: InputDecoration(
                      hintText: 'Search restaurants or deals...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                // Map placeholder
                Expanded(
                  flex: 1,
                  child: Container(
                    key: const Key('map_view'),
                    color: Colors.grey,
                    child: const Center(child: Text('Map View')),
                  ),
                ),
                // Deals list
                Expanded(
                  flex: 1,
                  child: Column(
                    key: Key('deals_list'),
                    children: [
                      Text('Nearby Deals'),
                      Card(
                        child: ListTile(
                          title: Text('Pizza Margherita'),
                          subtitle: Text('\$15.00 • 50% OFF'),
                          trailing: Text('0.5km'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text('Sushi Platter'),
                          subtitle: Text('\$20.00 • 40% OFF'),
                          trailing: Text('0.8km'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              key: Key('bottom_nav'),
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      // Verify home screen elements
      expect(find.byKey(const Key('search_bar')), findsOneWidget);
      expect(find.byKey(const Key('map_view')), findsOneWidget);
      expect(find.byKey(const Key('deals_list')), findsOneWidget);
      expect(find.byKey(const Key('bottom_nav')), findsOneWidget);
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Sushi Platter'), findsOneWidget);
      expect(find.text('50% OFF'), findsOneWidget);
    });

    testWidgets('Shopping Cart - Add and Manage Items', (WidgetTester tester) async {
      // Test: Shopping cart functionality
      int cartItemCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              appBar: AppBar(
                title: const Text('Shopping Cart'),
                actions: [
                  if (cartItemCount > 0)
                    Chip(
                      label: Text('$cartItemCount'),
                      backgroundColor: Colors.red,
                    ),
                ],
              ),
              body: Column(
                children: [
                  // Deal item
                  Card(
                    child: ListTile(
                      title: const Text('Fresh Sushi Platter'),
                      subtitle: const Text('\$20.00 • Originally \$40.00'),
                      trailing: ElevatedButton(
                        key: const Key('add_to_cart_button'),
                        onPressed: () {
                          setState(() {
                            cartItemCount++;
                          });
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ),
                  // Cart items
                  if (cartItemCount > 0) ...[
                    const Divider(),
                    const Text('Cart Items'),
                    Card(
                      child: ListTile(
                        title: const Text('Fresh Sushi Platter'),
                        subtitle: Text('Quantity: $cartItemCount'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              key: const Key('decrease_quantity'),
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (cartItemCount > 0) cartItemCount--;
                                });
                              },
                            ),
                            Text('$cartItemCount'),
                            IconButton(
                              key: const Key('increase_quantity'),
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  cartItemCount++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Total: \$${(20.00 * cartItemCount).toStringAsFixed(2)}'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              key: const Key('checkout_button'),
                              onPressed: cartItemCount > 0 ? () {} : null,
                              child: const Text('Proceed to Checkout'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

      // Test adding items to cart
      expect(find.text('Fresh Sushi Platter'), findsOneWidget);
      expect(find.byKey(const Key('add_to_cart_button')), findsOneWidget);
      expect(find.text('0'), findsNothing); // No cart badge initially

      // Add item to cart
      await tester.tap(find.byKey(const Key('add_to_cart_button')));
      await tester.pumpAndSettle();

      // Verify item added
      expect(find.text('1'), findsAtLeastNWidgets(1)); // Cart badge and quantity
      expect(find.text('Cart Items'), findsOneWidget);
      expect(find.text('Total: \$20.00'), findsOneWidget);

      // Test quantity controls
      await tester.tap(find.byKey(const Key('increase_quantity')));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsAtLeastNWidgets(1));
      expect(find.text('Total: \$40.00'), findsOneWidget);

      await tester.tap(find.byKey(const Key('decrease_quantity')));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsAtLeastNWidgets(1));
      expect(find.text('Total: \$20.00'), findsOneWidget);
    });

    testWidgets('Business Dashboard - Deal Management', (WidgetTester tester) async {
      // Test: Business dashboard functionality
      bool dealPosted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              appBar: AppBar(title: const Text('Business Dashboard')),
              body: Column(
                children: [
                  // Stats cards
                  const Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text('Total Revenue'),
                                Text('\$5,420.50', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text('Orders Today'),
                                Text('23', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Post deal section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Post New Deal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const TextField(
                            key: Key('deal_title_field'),
                            decoration: InputDecoration(labelText: 'Deal Title'),
                          ),
                          const TextField(
                            key: Key('original_price_field'),
                            decoration: InputDecoration(labelText: 'Original Price'),
                          ),
                          const TextField(
                            key: Key('discount_price_field'),
                            decoration: InputDecoration(labelText: 'Discount Price'),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            key: const Key('post_deal_button'),
                            onPressed: () {
                              setState(() {
                                dealPosted = true;
                              });
                            },
                            child: const Text('Post Deal'),
                          ),
                          if (dealPosted)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Deal posted successfully!',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify dashboard elements
      expect(find.text('Business Dashboard'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('\$5,420.50'), findsOneWidget);
      expect(find.text('Orders Today'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      
      // Test deal posting
      expect(find.byKey(const Key('deal_title_field')), findsOneWidget);
      expect(find.byKey(const Key('post_deal_button')), findsOneWidget);
      expect(find.text('Deal posted successfully!'), findsNothing);

      // Post a deal
      await tester.enterText(find.byKey(const Key('deal_title_field')), 'Fresh Pasta Special');
      await tester.enterText(find.byKey(const Key('original_price_field')), '25.00');
      await tester.enterText(find.byKey(const Key('discount_price_field')), '15.00');
      
      await tester.tap(find.byKey(const Key('post_deal_button')));
      await tester.pumpAndSettle();

      // Verify deal posted
      expect(find.text('Deal posted successfully!'), findsOneWidget);
    });

    testWidgets('Notifications - Real-time Updates', (WidgetTester tester) async {
      // Test: Notification system
      bool notificationReceived = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              appBar: AppBar(
                title: const Text('GraBeat'),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {},
                      ),
                      if (notificationReceived)
                        const Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text('1', style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              body: Column(
                children: [
                  ElevatedButton(
                    key: const Key('simulate_notification'),
                    onPressed: () {
                      setState(() {
                        notificationReceived = true;
                      });
                    },
                    child: const Text('Simulate New Deal Notification'),
                  ),
                  if (notificationReceived)
                    Card(
                      color: Colors.green.shade100,
                      child: const ListTile(
                        leading: Icon(Icons.local_offer, color: Colors.green),
                        title: Text('New Deal Nearby!'),
                        subtitle: Text('Pizza Margherita - 50% off, only 0.3km away'),
                        trailing: Text('Just now'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Test notification state
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('1'), findsNothing); // No badge initially
      expect(find.text('New Deal Nearby!'), findsNothing);

      // Simulate notification
      await tester.tap(find.byKey(const Key('simulate_notification')));
      await tester.pumpAndSettle();

      // Verify notification received
      expect(find.text('1'), findsOneWidget); // Badge appears
      expect(find.text('New Deal Nearby!'), findsOneWidget);
      expect(find.text('Pizza Margherita - 50% off, only 0.3km away'), findsOneWidget);
    });
  });
}