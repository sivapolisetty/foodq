import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:grabeat/main.dart';

// Mock classes for functional testing - simplified to avoid conflicts
class MockFunctionalSupabaseClient extends Mock implements SupabaseClient {
  @override
  final GoTrueClient auth = MockFunctionalGoTrueClient();
}

class MockFunctionalGoTrueClient extends Mock implements GoTrueClient {}

class MockFunctionalUser extends Mock implements User {
  @override
  String get id => 'test-user-id';
  
  @override
  String? get email => 'test@example.com';
}

class TestSupabaseService {
  static late MockFunctionalSupabaseClient mockClient;
  static late MockFunctionalGoTrueClient mockAuth;
  
  static void initialize() {
    mockClient = MockFunctionalSupabaseClient();
    mockAuth = MockFunctionalGoTrueClient();
    
    when(mockClient.auth).thenReturn(mockAuth);
  }
  
  static void setupAuthenticatedUser({
    required String role,
    String? businessId,
  }) {
    final mockUser = MockFunctionalUser();
    final mockSession = MockSession();
    
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockAuth.currentSession).thenReturn(mockSession);
    
    // Mock user metadata
    when(mockUser.userMetadata).thenReturn({
      'role': role,
      if (businessId != null) 'business_id': businessId,
    });
  }
  
  static void setupUnauthenticatedUser() {
    when(mockAuth.currentUser).thenReturn(null);
    when(mockAuth.currentSession).thenReturn(null);
  }
}

class MockSession extends Mock implements Session {
  @override
  String get accessToken => 'mock-access-token';
}

// Test app wrapper for functional tests
class TestApp extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;
  
  const TestApp({
    Key? key,
    required this.child,
    this.overrides = const [],
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
      ),
    );
  }
}

// Test data fixtures
class TestData {
  static Map<String, dynamic> get customerUser => {
    'id': 'customer-123',
    'email': 'customer@test.com',
    'role': 'customer',
    'created_at': DateTime.now().toIso8601String(),
  };
  
  static Map<String, dynamic> get businessUser => {
    'id': 'business-123',
    'email': 'business@test.com',
    'role': 'business',
    'business_id': 'business-456',
    'created_at': DateTime.now().toIso8601String(),
  };
  
  static Map<String, dynamic> get staffUser => {
    'id': 'staff-123',
    'email': 'staff@test.com',
    'role': 'staff',
    'business_id': 'business-456',
    'created_at': DateTime.now().toIso8601String(),
  };
  
  static Map<String, dynamic> get sampleBusiness => {
    'id': 'business-456',
    'name': 'Test Restaurant',
    'address': '123 Test St',
    'phone': '555-0123',
    'email': 'business@test.com',
    'latitude': 37.7749,
    'longitude': -122.4194,
    'created_at': DateTime.now().toIso8601String(),
  };
  
  static Map<String, dynamic> get sampleDeal => {
    'id': 'deal-789',
    'business_id': 'business-456',
    'title': 'Fresh Sushi Platter',
    'description': 'Assorted sushi rolls, 50% off original price',
    'original_price': 40.00,
    'discount_price': 20.00,
    'quantity': 10,
    'category': 'japanese',
    'pickup_start': DateTime.now().toIso8601String(),
    'pickup_end': DateTime.now().add(Duration(hours: 3)).toIso8601String(),
    'created_at': DateTime.now().toIso8601String(),
  };
  
  static List<Map<String, dynamic>> get nearbyDeals => [
    {
      ...sampleDeal,
      'id': 'deal-001',
      'title': 'Pizza Margherita',
      'category': 'italian',
      'distance': 0.5,
    },
    {
      ...sampleDeal,
      'id': 'deal-002',
      'title': 'Burger Combo',
      'category': 'american',
      'distance': 0.8,
    },
    {
      ...sampleDeal,
      'id': 'deal-003',
      'title': 'Pad Thai',
      'category': 'thai',
      'distance': 1.2,
    },
  ];
  
  static Map<String, dynamic> get sampleOrder => {
    'id': 'order-001',
    'user_id': 'customer-123',
    'business_id': 'business-456',
    'items': [
      {
        'deal_id': 'deal-789',
        'quantity': 2,
        'price': 20.00,
      }
    ],
    'total_amount': 40.00,
    'status': 'pending',
    'pickup_code': 'PICKUP123',
    'created_at': DateTime.now().toIso8601String(),
  };
}

// Common test actions
class TestActions {
  static Future<void> login(WidgetTester tester, {required String email, required String password}) async {
    final emailField = find.byKey(Key('email_field'));
    final passwordField = find.byKey(Key('password_field'));
    final loginButton = find.byKey(Key('login_button'));
    
    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }
  
  static Future<void> navigateToTab(WidgetTester tester, String tabLabel) async {
    final tab = find.text(tabLabel);
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }
  
  static Future<void> scrollUntilVisible(WidgetTester tester, Finder finder) async {
    await tester.dragUntilVisible(
      finder,
      find.byType(ListView).first,
      const Offset(0, -100),
    );
  }
  
  static Future<void> waitForData(WidgetTester tester) async {
    // Wait for loading indicators to disappear
    await tester.pump(Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }
}

// Test expectations
class TestExpectations {
  static void expectLoginScreen(WidgetTester tester) {
    expect(find.text('GraBeat'), findsOneWidget);
    expect(find.byKey(Key('email_field')), findsOneWidget);
    expect(find.byKey(Key('password_field')), findsOneWidget);
    expect(find.byKey(Key('login_button')), findsOneWidget);
    expect(find.byKey(Key('role_toggle')), findsOneWidget);
  }
  
  static void expectCustomerHomeScreen(WidgetTester tester) {
    expect(find.byKey(Key('map_view')), findsOneWidget);
    expect(find.byKey(Key('deals_list')), findsOneWidget);
    expect(find.byKey(Key('search_bar')), findsOneWidget);
    expect(find.byKey(Key('bottom_nav')), findsOneWidget);
  }
  
  static void expectBusinessDashboard(WidgetTester tester) {
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Staff'), findsOneWidget);
    expect(find.text('Finances'), findsOneWidget);
  }
  
  static void expectStaffDashboard(WidgetTester tester) {
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Staff'), findsNothing); // Staff can't see this
    expect(find.text('Finances'), findsNothing); // Staff can't see this
  }
}