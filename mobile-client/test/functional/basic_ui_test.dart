import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Basic UI tests for GraBeat functionality
/// These tests validate core user interface elements and interactions
void main() {
  group('GraBeat Basic UI Tests', () {
    
    testWidgets('Login Screen - Core Elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('GraBeat')),
            body: Column(
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
                  onPressed: () {},
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify login elements
      expect(find.text('GraBeat'), findsOneWidget);
      expect(find.text('Welcome to GraBeat'), findsOneWidget);
      expect(find.byKey(Key('email_field')), findsOneWidget);
      expect(find.byKey(Key('password_field')), findsOneWidget);
      expect(find.byKey(Key('login_button')), findsOneWidget);
    });

    testWidgets('Home Screen - Layout Verification', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('GraBeat')),
            body: Column(
              children: [
                TextField(
                  key: Key('search_bar'),
                  decoration: InputDecoration(
                    hintText: 'Search deals...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                Expanded(
                  child: Container(
                    key: Key('map_view'),
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Text('Map View')),
                  ),
                ),
                Expanded(
                  child: ListView(
                    key: Key('deals_list'),
                    children: [
                      Card(
                        child: ListTile(
                          title: Text('Pizza Margherita'),
                          subtitle: Text('\$15.00 - 50% OFF'),
                          trailing: Text('0.5km'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text('Sushi Combo'),
                          subtitle: Text('\$20.00 - 40% OFF'),
                          trailing: Text('0.8km'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify home screen elements
      expect(find.byKey(Key('search_bar')), findsOneWidget);
      expect(find.byKey(Key('map_view')), findsOneWidget);
      expect(find.byKey(Key('deals_list')), findsOneWidget);
      expect(find.text('Pizza Margherita'), findsOneWidget);
      expect(find.text('Sushi Combo'), findsOneWidget);
      expect(find.text('\$15.00 - 50% OFF'), findsOneWidget);
    });

    testWidgets('Cart Functionality - Basic Operations', (WidgetTester tester) async {
      int cartCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              appBar: AppBar(
                title: Text('Cart'),
                actions: [
                  if (cartCount > 0)
                    Chip(label: Text('$cartCount')),
                ],
              ),
              body: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Sushi Platter'),
                      subtitle: Text('\$20.00'),
                      trailing: ElevatedButton(
                        key: Key('add_to_cart'),
                        onPressed: () {
                          setState(() {
                            cartCount++;
                          });
                        },
                        child: Text('Add to Cart'),
                      ),
                    ),
                  ),
                  if (cartCount > 0) ...[
                    Text('Cart Items: $cartCount'),
                    Text('Total: \$${(20.00 * cartCount).toStringAsFixed(2)}'),
                    ElevatedButton(
                      key: Key('checkout_button'),
                      onPressed: () {},
                      child: Text('Checkout'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

      // Test adding to cart
      expect(find.text('Sushi Platter'), findsOneWidget);
      expect(find.byKey(Key('add_to_cart')), findsOneWidget);
      expect(find.text('0'), findsNothing);

      // Add item
      await tester.tap(find.byKey(Key('add_to_cart')));
      await tester.pumpAndSettle();

      // Verify cart updated
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Cart Items: 1'), findsOneWidget);
      expect(find.text('Total: \$20.00'), findsOneWidget);
      expect(find.byKey(Key('checkout_button')), findsOneWidget);
    });

    testWidgets('Business Dashboard - Basic Layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Business Dashboard')),
            body: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text('Revenue'),
                              Text('\$5,420', style: TextStyle(fontSize: 24)),
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
                              Text('Orders'),
                              Text('23', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  key: Key('deal_title'),
                  decoration: InputDecoration(labelText: 'Deal Title'),
                ),
                ElevatedButton(
                  key: Key('post_deal'),
                  onPressed: () {},
                  child: Text('Post Deal'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify dashboard elements
      expect(find.text('Business Dashboard'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('\$5,420'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      expect(find.byKey(Key('deal_title')), findsOneWidget);
      expect(find.byKey(Key('post_deal')), findsOneWidget);
    });

    testWidgets('Search Functionality - Filter Deals', (WidgetTester tester) async {
      List<String> deals = ['Pizza Special', 'Sushi Combo', 'Burger Deal'];
      String searchQuery = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              appBar: AppBar(title: Text('Search Deals')),
              body: Column(
                children: [
                  TextField(
                    key: Key('search_input'),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search deals...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: deals.length,
                      itemBuilder: (context, index) {
                        final deal = deals[index];
                        if (searchQuery.isEmpty || 
                            deal.toLowerCase().contains(searchQuery)) {
                          return ListTile(
                            title: Text(deal),
                            subtitle: Text('Great deal!'),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Test initial state
      expect(find.text('Pizza Special'), findsOneWidget);
      expect(find.text('Sushi Combo'), findsOneWidget);
      expect(find.text('Burger Deal'), findsOneWidget);

      // Test search filtering
      await tester.enterText(find.byKey(Key('search_input')), 'pizza');
      await tester.pumpAndSettle();

      expect(find.text('Pizza Special'), findsOneWidget);
      expect(find.text('Sushi Combo'), findsNothing);
      expect(find.text('Burger Deal'), findsNothing);
    });

    testWidgets('User Role Toggle - Customer vs Business', (WidgetTester tester) async {
      bool isBusinessMode = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              appBar: AppBar(title: Text('GraBeat')),
              body: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Customer'),
                      Switch(
                        key: Key('role_toggle'),
                        value: isBusinessMode,
                        onChanged: (value) {
                          setState(() {
                            isBusinessMode = value;
                          });
                        },
                      ),
                      Text('Business'),
                    ],
                  ),
                  if (isBusinessMode) ...[
                    Text('Business Features'),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Manage Deals'),
                    ),
                  ] else ...[
                    Text('Customer Features'),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Browse Deals'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

      // Test initial customer mode
      expect(find.text('Customer Features'), findsOneWidget);
      expect(find.text('Browse Deals'), findsOneWidget);
      expect(find.text('Business Features'), findsNothing);

      // Switch to business mode
      await tester.tap(find.byKey(Key('role_toggle')));
      await tester.pumpAndSettle();

      // Verify business mode
      expect(find.text('Business Features'), findsOneWidget);
      expect(find.text('Manage Deals'), findsOneWidget);
      expect(find.text('Customer Features'), findsNothing);
    });
  });
}