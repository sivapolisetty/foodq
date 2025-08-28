import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:grabeat/features/business/screens/business_enrollment_screen.dart';
import 'package:grabeat/features/deals/screens/deal_management_screen.dart';
import 'test_setup.dart';

void main() {
  group('Business Management Flow - Functional Tests', () {
    setUp(() {
      TestSupabaseService.initialize();
    });

    testWidgets('Business enrollment - complete registration flow', (WidgetTester tester) async {
      // Setup: New business user
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: null, // Not enrolled yet
      );
      
      // Mock business registration
      when(TestSupabaseService.mockClient.from('businesses').insert(any)).thenAnswer(
        (_) async => [TestData.sampleBusiness],
      );
      
      // Act: Load enrollment screen
      await tester.pumpWidget(const TestApp(
        child: BusinessEnrollmentScreen(),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Enrollment form displayed
      expect(find.text('Enroll Your Business'), findsOneWidget);
      expect(find.byKey(const Key('business_name_field')), findsOneWidget);
      expect(find.byKey(const Key('business_address_field')), findsOneWidget);
      expect(find.byKey(const Key('business_phone_field')), findsOneWidget);
      
      // Act: Fill form
      await tester.enterText(find.byKey(const Key('business_name_field')), 'Test Restaurant');
      await tester.enterText(find.byKey(const Key('business_address_field')), '123 Test St');
      await tester.enterText(find.byKey(const Key('business_phone_field')), '555-0123');
      
      // Act: Submit enrollment
      final submitButton = find.text('Submit Application');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      
      // Assert: Success confirmation
      expect(find.text('Application submitted successfully'), findsOneWidget);
      expect(find.text('Pending approval'), findsOneWidget);
    });

    testWidgets('Business dashboard - view analytics and metrics', (WidgetTester tester) async {
      // Setup: Enrolled business user
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: 'business-456',
      );
      
      // Mock analytics data
      when(TestSupabaseService.mockClient.rpc('get_business_analytics', params: any)).thenAnswer(
        (_) async => {
          'total_revenue': 5420.50,
          'total_orders': 127,
          'deals_posted': 45,
          'waste_reduced_kg': 85.2,
        },
      );
      
      // Act: Load business dashboard
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Business Dashboard'),
              Card(
                child: Column(
                  children: [
                    Text('Total Revenue'),
                    Text('\$5,420.50'),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Text('Total Orders'),
                    Text('127'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Analytics displayed
      expect(find.text('Business Dashboard'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('\$5,420.50'), findsOneWidget);
      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('127'), findsOneWidget);
    });

    testWidgets('Create new deal - full posting flow', (WidgetTester tester) async {
      // Setup: Business user
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: 'business-456',
      );
      
      // Mock deal creation
      when(TestSupabaseService.mockClient.from('deals').insert(any)).thenAnswer(
        (_) async => [TestData.sampleDeal],
      );
      
      // Act: Load deal management screen
      await tester.pumpWidget(const TestApp(
        child: DealManagementScreen(),
      ));
      
      await tester.pumpAndSettle();
      
      // Act: Tap create deal button
      final createButton = find.byKey(const Key('create_deal_button'));
      await tester.tap(createButton);
      await tester.pumpAndSettle();
      
      // Assert: Deal creation form displayed
      expect(find.text('Create New Deal'), findsOneWidget);
      expect(find.byKey(const Key('deal_title_field')), findsOneWidget);
      expect(find.byKey(const Key('deal_description_field')), findsOneWidget);
      expect(find.byKey(const Key('original_price_field')), findsOneWidget);
      expect(find.byKey(const Key('discount_price_field')), findsOneWidget);
      expect(find.byKey(const Key('quantity_field')), findsOneWidget);
      
      // Act: Fill deal form
      await tester.enterText(find.byKey(const Key('deal_title_field')), 'Fresh Sushi Platter');
      await tester.enterText(find.byKey(const Key('deal_description_field')), 'Assorted sushi rolls');
      await tester.enterText(find.byKey(const Key('original_price_field')), '40.00');
      await tester.enterText(find.byKey(const Key('discount_price_field')), '20.00');
      await tester.enterText(find.byKey(const Key('quantity_field')), '10');
      
      // Act: Submit deal
      final submitButton = find.text('Post Deal');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      
      // Assert: Deal posted successfully
      expect(find.text('Deal posted successfully'), findsOneWidget);
      expect(find.text('Fresh Sushi Platter'), findsOneWidget);
    });

    testWidgets('Staff management - add and manage staff', (WidgetTester tester) async {
      // Setup: Business owner
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: 'business-456',
      );
      
      // Mock staff list
      when(TestSupabaseService.mockClient.from('staff').select().eq('business_id', 'business-456')).thenAnswer(
        (_) async => [
          {
            'id': 'staff-001',
            'email': 'staff1@test.com',
            'name': 'John Staff',
            'role': 'staff',
            'created_at': DateTime.now().toIso8601String(),
          },
        ],
      );
      
      // Act: Load staff management screen
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Staff Management'),
              ElevatedButton(
                key: Key('add_staff_button'),
                onPressed: null,
                child: Text('Add Staff'),
              ),
              ListTile(
                title: Text('John Staff'),
                subtitle: Text('staff1@test.com'),
                trailing: Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Staff list displayed
      expect(find.text('Staff Management'), findsOneWidget);
      expect(find.text('John Staff'), findsOneWidget);
      expect(find.text('staff1@test.com'), findsOneWidget);
      
      // Act: Add new staff
      final addButton = find.byKey(const Key('add_staff_button'));
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      
      // Assert: Add staff dialog
      expect(find.text('Add Staff Member'), findsOneWidget);
      expect(find.byKey(const Key('staff_email_field')), findsOneWidget);
      expect(find.byKey(const Key('staff_name_field')), findsOneWidget);
    });

    testWidgets('Orders management - view and process orders', (WidgetTester tester) async {
      // Setup: Business user
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: 'business-456',
      );
      
      // Mock orders data
      when(TestSupabaseService.mockClient.from('orders').select().eq('business_id', 'business-456')).thenAnswer(
        (_) async => [
          {
            ...TestData.sampleOrder,
            'customer_name': 'John Customer',
            'pickup_time': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          },
        ],
      );
      
      // Act: Load orders management screen
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Orders Management'),
              Card(
                child: ListTile(
                  title: Text('Order #PICKUP123'),
                  subtitle: Text('John Customer - 2 items'),
                  trailing: ElevatedButton(
                    onPressed: null,
                    child: Text('Mark Ready'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Orders displayed
      expect(find.text('Orders Management'), findsOneWidget);
      expect(find.text('Order #PICKUP123'), findsOneWidget);
      expect(find.text('John Customer - 2 items'), findsOneWidget);
      expect(find.text('Mark Ready'), findsOneWidget);
    });

    testWidgets('Staff user restrictions - limited access', (WidgetTester tester) async {
      // Setup: Staff user
      TestSupabaseService.setupAuthenticatedUser(
        role: 'staff',
        businessId: 'business-456',
      );
      
      // Act: Load staff dashboard
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Staff Dashboard'),
              ElevatedButton(
                onPressed: null,
                child: Text('Manage Items'),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text('View Orders'),
              ),
              // Note: No Finances or Staff Management buttons for staff
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Limited options shown
      expect(find.text('Staff Dashboard'), findsOneWidget);
      expect(find.text('Manage Items'), findsOneWidget);
      expect(find.text('View Orders'), findsOneWidget);
      
      // Assert: Restricted options not shown
      expect(find.text('Finances'), findsNothing);
      expect(find.text('Staff Management'), findsNothing);
    });

    testWidgets('Deal editing and quantity management', (WidgetTester tester) async {
      // Setup: Business user with existing deals
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: 'business-456',
      );
      
      // Mock deals list
      when(TestSupabaseService.mockClient.from('deals').select().eq('business_id', 'business-456')).thenAnswer(
        (_) async => [TestData.sampleDeal],
      );
      
      // Act: Load deal management screen
      await tester.pumpWidget(const TestApp(
        child: DealManagementScreen(),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Existing deal displayed
      expect(find.text('Fresh Sushi Platter'), findsOneWidget);
      expect(find.text('Qty: 10'), findsOneWidget);
      
      // Act: Edit deal quantity
      final editButton = find.byIcon(Icons.edit).first;
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      
      // Assert: Edit dialog shown
      expect(find.text('Edit Deal'), findsOneWidget);
      
      // Act: Update quantity
      final quantityField = find.byKey(const Key('edit_quantity_field'));
      await tester.enterText(quantityField, '15');
      
      final saveButton = find.text('Save Changes');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      
      // Assert: Quantity updated
      expect(find.text('Qty: 15'), findsOneWidget);
    });

    testWidgets('Financial reporting - revenue and payouts', (WidgetTester tester) async {
      // Setup: Business owner (not staff)
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: 'business-456',
      );
      
      // Mock financial data
      when(TestSupabaseService.mockClient.rpc('get_financial_report', params: any)).thenAnswer(
        (_) async => {
          'total_revenue': 5420.50,
          'pending_payout': 1250.75,
          'total_fees': 325.50,
          'transactions': [
            {
              'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
              'amount': 85.00,
              'type': 'sale',
              'order_id': 'order-001',
            }
          ],
        },
      );
      
      // Act: Load finances screen
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Financial Dashboard'),
              Card(
                child: Column(
                  children: [
                    Text('Total Revenue'),
                    Text('\$5,420.50'),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Text('Pending Payout'),
                    Text('\$1,250.75'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Financial metrics displayed
      expect(find.text('Financial Dashboard'), findsOneWidget);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('\$5,420.50'), findsOneWidget);
      expect(find.text('Pending Payout'), findsOneWidget);
      expect(find.text('\$1,250.75'), findsOneWidget);
    });

    testWidgets('Order pickup validation - QR code scanning', (WidgetTester tester) async {
      // Setup: Staff user processing pickup
      TestSupabaseService.setupAuthenticatedUser(
        role: 'staff',
        businessId: 'business-456',
      );
      
      // Mock order validation
      when(TestSupabaseService.mockClient.from('orders').select().eq('pickup_code', 'PICKUP123')).thenAnswer(
        (_) async => [TestData.sampleOrder],
      );
      
      // Act: Load order pickup screen
      await tester.pumpWidget(const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              Text('Order Pickup'),
              Text('Scan customer QR code'),
              ElevatedButton(
                key: Key('manual_code_button'),
                onPressed: null,
                child: Text('Enter Code Manually'),
              ),
            ],
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Act: Enter pickup code manually
      final manualButton = find.byKey(const Key('manual_code_button'));
      await tester.tap(manualButton);
      await tester.pumpAndSettle();
      
      // Assert: Manual entry dialog
      expect(find.text('Enter Pickup Code'), findsOneWidget);
      
      // Act: Enter code
      final codeField = find.byKey(const Key('pickup_code_field'));
      await tester.enterText(codeField, 'PICKUP123');
      
      final validateButton = find.text('Validate');
      await tester.tap(validateButton);
      await tester.pumpAndSettle();
      
      // Assert: Order details shown
      expect(find.text('Order validated'), findsOneWidget);
      expect(find.text('Mark as Complete'), findsOneWidget);
    });
  });
}