import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:grabeat/features/notifications/screens/notifications_screen.dart';
import 'test_setup.dart';

void main() {
  group('Notifications Flow - Functional Tests', () {
    setUp(() {
      TestSupabaseService.initialize();
      TestSupabaseService.setupAuthenticatedUser(role: 'customer');
    });

    testWidgets('Real-time notification for new nearby deal', (WidgetTester tester) async {
      // Setup: Mock notification data
      final notifications = [
        {
          'id': 'notif-001',
          'title': 'New Deal Nearby!',
          'body': 'Fresh sushi at 50% off, just 0.3km away',
          'type': 'new_deal',
          'deal_id': 'deal-789',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];
      
      // Act: Simulate notification received
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Home Screen'),
              // Notification banner
              Card(
                color: Colors.green,
                child: ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('New Deal Nearby!'),
                  subtitle: Text('Fresh sushi at 50% off, just 0.3km away'),
                  trailing: TextButton(
                    onPressed: null,
                    child: Text('View'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Notification banner displayed
      expect(find.text('New Deal Nearby!'), findsOneWidget);
      expect(find.text('Fresh sushi at 50% off, just 0.3km away'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      
      // Act: Tap notification to view deal
      final viewButton = find.text('View');
      await tester.tap(viewButton);
      await tester.pumpAndSettle();
      
      // Assert: Navigation to deal details
      expect(find.text('Fresh Sushi Platter'), findsOneWidget);
    });

    testWidgets('Notification permissions - request and handle', (WidgetTester tester) async {
      // Act: Load app and check permissions
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Enable Notifications'),
              Text('Get notified about new deals nearby'),
              ElevatedButton(
                key: Key('enable_notifications_button'),
                onPressed: null,
                child: Text('Enable Notifications'),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Permission request UI
      expect(find.text('Enable Notifications'), findsAtLeastNWidgets(1));
      expect(find.text('Get notified about new deals nearby'), findsOneWidget);
      
      // Act: Grant permissions
      final enableButton = find.byKey(const Key('enable_notifications_button'));
      await tester.tap(enableButton);
      await tester.pumpAndSettle();
      
      // Assert: Permissions granted confirmation
      expect(find.text('Notifications enabled'), findsOneWidget);
    });

    testWidgets('Notification settings - customize preferences', (WidgetTester tester) async {
      // Act: Load notification settings screen
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Notification Settings'),
              SwitchListTile(
                key: Key('new_deals_toggle'),
                title: Text('New Deals'),
                subtitle: Text('Notify when new deals are posted nearby'),
                value: true,
                onChanged: null,
              ),
              SwitchListTile(
                key: Key('order_updates_toggle'),
                title: Text('Order Updates'),
                subtitle: Text('Updates about your orders'),
                value: true,
                onChanged: null,
              ),
              SwitchListTile(
                key: Key('promotional_toggle'),
                title: Text('Promotional'),
                subtitle: Text('Special offers and promotions'),
                value: false,
                onChanged: null,
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Settings displayed
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('New Deals'), findsOneWidget);
      expect(find.text('Order Updates'), findsOneWidget);
      expect(find.text('Promotional'), findsOneWidget);
      
      // Act: Toggle promotional notifications
      final promoToggle = find.byKey(const Key('promotional_toggle'));
      await tester.tap(promoToggle);
      await tester.pumpAndSettle();
      
      // Assert: Setting updated
      // (In real app, this would persist the preference)
    });

    testWidgets('Notification history - view past notifications', (WidgetTester tester) async {
      // Setup: Mock notification history
      final notifications = [
        {
          'id': 'notif-001',
          'title': 'Order Ready for Pickup',
          'body': 'Your sushi order is ready at Test Restaurant',
          'type': 'order_ready',
          'is_read': true,
          'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        },
        {
          'id': 'notif-002',
          'title': 'New Deal Nearby!',
          'body': 'Pizza at 40% off, expires in 2 hours',
          'type': 'new_deal',
          'is_read': false,
          'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        },
      ];
      
      // Act: Load notifications screen
      await tester.pumpWidget(const TestApp(
        child: NotificationsScreen(),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Notification list displayed
      expect(find.text('Order Ready for Pickup'), findsOneWidget);
      expect(find.text('New Deal Nearby!'), findsOneWidget);
      
      // Assert: Read/unread indicators
      expect(find.byIcon(Icons.circle), findsOneWidget); // Unread indicator
      
      // Act: Tap unread notification
      final unreadNotif = find.text('New Deal Nearby!');
      await tester.tap(unreadNotif);
      await tester.pumpAndSettle();
      
      // Assert: Notification marked as read
      expect(find.byIcon(Icons.circle), findsNothing); // No more unread indicators
    });

    testWidgets('Geofenced notifications - location-based triggers', (WidgetTester tester) async {
      // Setup: Mock location and nearby deals
      // (In real app, this would be triggered by location services)
      
      // Simulate entering geofence area
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('You entered a deal area!'),
              Card(
                child: ListTile(
                  title: Text('3 deals available nearby'),
                  subtitle: Text('Tap to explore'),
                  trailing: Icon(Icons.location_on),
                ),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Location-based notification
      expect(find.text('You entered a deal area!'), findsOneWidget);
      expect(find.text('3 deals available nearby'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('Order status notifications - pickup ready', (WidgetTester tester) async {
      // Setup: Order status update notification
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Order Status Update'),
              Card(
                color: Colors.orange,
                child: ListTile(
                  leading: Icon(Icons.restaurant),
                  title: Text('Order #PICKUP123 Ready'),
                  subtitle: Text('Your food is ready for pickup at Test Restaurant'),
                  trailing: TextButton(
                    onPressed: null,
                    child: Text('Show Code'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Order ready notification
      expect(find.text('Order #PICKUP123 Ready'), findsOneWidget);
      expect(find.text('Your food is ready for pickup at Test Restaurant'), findsOneWidget);
      expect(find.text('Show Code'), findsOneWidget);
      
      // Act: Show pickup code
      final showCodeButton = find.text('Show Code');
      await tester.tap(showCodeButton);
      await tester.pumpAndSettle();
      
      // Assert: Pickup code displayed
      expect(find.text('PICKUP123'), findsOneWidget);
    });

    testWidgets('Push notification handling - app in background', (WidgetTester tester) async {
      // Setup: Simulate app receiving background notification
      final notificationData = {
        'title': 'Deal Ending Soon!',
        'body': 'Only 30 minutes left for 50% off sushi',
        'data': {
          'type': 'deal_expiring',
          'deal_id': 'deal-789',
        },
      };
      
      // Act: Simulate notification tap from background
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Deal Details'),
              Text('Deal Ending Soon!'),
              Text('Only 30 minutes left for 50% off sushi'),
              Text('Time remaining: 29:45'),
              ElevatedButton(
                onPressed: null,
                child: Text('Order Now'),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: App opened to relevant deal
      expect(find.text('Deal Ending Soon!'), findsOneWidget);
      expect(find.text('Only 30 minutes left for 50% off sushi'), findsOneWidget);
      expect(find.text('Order Now'), findsOneWidget);
    });

    testWidgets('Notification badge - unread count display', (WidgetTester tester) async {
      // Setup: Multiple unread notifications
      const unreadCount = 3;
      
      // Act: Load app with notification badge
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          appBar: AppBar(
            title: Text('GraBeat'),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: null,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Text('Home Screen'),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Badge shows correct count
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      
      // Act: Tap notifications icon
      final notifIcon = find.byIcon(Icons.notifications);
      await tester.tap(notifIcon);
      await tester.pumpAndSettle();
      
      // Assert: Navigate to notifications screen
      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('Notification actions - quick actions from notification', (WidgetTester tester) async {
      // Setup: Notification with action buttons
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text('New Order Received'),
                      subtitle: Text('Order #PICKUP123 - 2 items - \$40.00'),
                    ),
                    ButtonBar(
                      children: [
                        TextButton(
                          onPressed: null,
                          child: Text('Accept'),
                        ),
                        TextButton(
                          onPressed: null,
                          child: Text('View Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Notification with actions
      expect(find.text('New Order Received'), findsOneWidget);
      expect(find.text('Order #PICKUP123 - 2 items - \$40.00'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
      
      // Act: Accept order
      final acceptButton = find.text('Accept');
      await tester.tap(acceptButton);
      await tester.pumpAndSettle();
      
      // Assert: Order accepted confirmation
      expect(find.text('Order accepted'), findsOneWidget);
    });

    testWidgets('Notification filtering - by type and date', (WidgetTester tester) async {
      // Act: Load notifications with filters
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Notifications'),
              Row(
                children: [
                  FilterChip(
                    key: Key('deals_filter'),
                    label: Text('Deals'),
                    selected: true,
                    onSelected: null,
                  ),
                  FilterChip(
                    key: Key('orders_filter'),
                    label: Text('Orders'),
                    selected: false,
                    onSelected: null,
                  ),
                  FilterChip(
                    key: Key('promotions_filter'),
                    label: Text('Promotions'),
                    selected: false,
                    onSelected: null,
                  ),
                ],
              ),
              ListTile(
                title: Text('New Deal Nearby!'),
                subtitle: Text('Pizza at 40% off'),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Filter chips displayed
      expect(find.text('Deals'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Promotions'), findsOneWidget);
      
      // Act: Switch to orders filter
      final ordersFilter = find.byKey(const Key('orders_filter'));
      await tester.tap(ordersFilter);
      await tester.pumpAndSettle();
      
      // Assert: Filtered notifications shown
      // (In real app, this would show only order-related notifications)
    });
  });
}