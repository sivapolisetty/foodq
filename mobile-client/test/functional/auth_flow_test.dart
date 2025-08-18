import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:kravekart/features/auth/screens/login_screen.dart';
import 'package:kravekart/features/home/screens/customer_home_screen.dart';
import 'package:kravekart/features/business/screens/business_enrollment_screen.dart';
import 'test_setup.dart';

void main() {
  group('Authentication Flow - Functional Tests', () {
    setUp(() {
      TestSupabaseService.initialize();
    });

    testWidgets('Customer login flow - successful authentication', (WidgetTester tester) async {
      // Setup: Mock successful customer authentication
      when(TestSupabaseService.mockAuth.signInWithPassword(
        email: 'customer@test.com',
        password: 'password123',
      )).thenAnswer((_) async => AuthResponse(
        user: MockUser(),
        session: MockSession(),
      ));
      
      TestSupabaseService.setupAuthenticatedUser(role: 'customer');
      
      // Act: Load login screen
      await tester.pumpWidget(TestApp(
        child: LoginScreen(),
      ));
      
      // Assert: Login screen is displayed
      TestExpectations.expectLoginScreen(tester);
      
      // Act: Enter credentials and login
      await TestActions.login(
        tester,
        email: 'customer@test.com',
        password: 'password123',
      );
      
      // Assert: Navigation to customer home screen
      await tester.pumpAndSettle();
      expect(find.byType(CustomerHomeScreen), findsOneWidget);
      TestExpectations.expectCustomerHomeScreen(tester);
    });

    testWidgets('Business login flow - successful authentication', (WidgetTester tester) async {
      // Setup: Mock successful business authentication
      when(TestSupabaseService.mockAuth.signInWithPassword(
        email: 'business@test.com',
        password: 'password123',
      )).thenAnswer((_) async => AuthResponse(
        user: MockUser(),
        session: MockSession(),
      ));
      
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: 'business-456',
      );
      
      // Act: Load login screen and switch to business mode
      await tester.pumpWidget(TestApp(
        child: LoginScreen(),
      ));
      
      // Act: Toggle to business mode
      final roleToggle = find.byKey(const Key('role_toggle'));
      await tester.tap(roleToggle);
      await tester.pumpAndSettle();
      
      // Assert: Business mode UI changes
      expect(find.text('Business Login'), findsOneWidget);
      
      // Act: Enter credentials and login
      await TestActions.login(
        tester,
        email: 'business@test.com',
        password: 'password123',
      );
      
      // Assert: Navigation to business dashboard
      await tester.pumpAndSettle();
      TestExpectations.expectBusinessDashboard(tester);
    });

    testWidgets('Staff login flow - limited access', (WidgetTester tester) async {
      // Setup: Mock successful staff authentication
      when(TestSupabaseService.mockAuth.signInWithPassword(
        email: 'staff@test.com',
        password: 'password123',
      )).thenAnswer((_) async => AuthResponse(
        user: MockUser(),
        session: MockSession(),
      ));
      
      TestSupabaseService.setupAuthenticatedUser(
        role: 'staff',
        businessId: 'business-456',
      );
      
      // Act: Load login screen
      await tester.pumpWidget(TestApp(
        child: LoginScreen(),
      ));
      
      // Act: Toggle to business mode (staff use same login)
      final roleToggle = find.byKey(const Key('role_toggle'));
      await tester.tap(roleToggle);
      await tester.pumpAndSettle();
      
      // Act: Enter credentials and login
      await TestActions.login(
        tester,
        email: 'staff@test.com',
        password: 'password123',
      );
      
      // Assert: Navigation to staff dashboard with limited access
      await tester.pumpAndSettle();
      TestExpectations.expectStaffDashboard(tester);
    });

    testWidgets('Failed login - invalid credentials', (WidgetTester tester) async {
      // Setup: Mock failed authentication
      when(TestSupabaseService.mockAuth.signInWithPassword(
        email: 'invalid@test.com',
        password: 'wrongpassword',
      )).thenThrow(AuthException('Invalid credentials'));
      
      // Act: Load login screen
      await tester.pumpWidget(TestApp(
        child: LoginScreen(),
      ));
      
      // Act: Enter invalid credentials
      await TestActions.login(
        tester,
        email: 'invalid@test.com',
        password: 'wrongpassword',
      );
      
      // Assert: Error message displayed
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget); // Still on login screen
    });

    testWidgets('Business enrollment flow for new business', (WidgetTester tester) async {
      // Setup: Mock successful business user without business ID
      when(TestSupabaseService.mockAuth.signInWithPassword(
        email: 'newbusiness@test.com',
        password: 'password123',
      )).thenAnswer((_) async => AuthResponse(
        user: MockUser(),
        session: MockSession(),
      ));
      
      TestSupabaseService.setupAuthenticatedUser(
        role: 'business',
        businessId: null, // No business ID yet
      );
      
      // Act: Load login screen and switch to business mode
      await tester.pumpWidget(TestApp(
        child: LoginScreen(),
      ));
      
      final roleToggle = find.byKey(const Key('role_toggle'));
      await tester.tap(roleToggle);
      await tester.pumpAndSettle();
      
      // Act: Login
      await TestActions.login(
        tester,
        email: 'newbusiness@test.com',
        password: 'password123',
      );
      
      // Assert: Redirected to business enrollment
      await tester.pumpAndSettle();
      expect(find.byType(BusinessEnrollmentScreen), findsOneWidget);
      expect(find.text('Enroll Your Business'), findsOneWidget);
    });

    testWidgets('Sign up flow - new customer registration', (WidgetTester tester) async {
      // Setup: Mock successful sign up
      when(TestSupabaseService.mockAuth.signUp(
        email: 'newcustomer@test.com',
        password: 'password123',
      )).thenAnswer((_) async => AuthResponse(
        user: MockUser(),
        session: MockSession(),
      ));
      
      // Act: Load login screen
      await tester.pumpWidget(TestApp(
        child: LoginScreen(),
      ));
      
      // Act: Tap sign up link
      final signUpLink = find.text('Sign Up');
      await tester.tap(signUpLink);
      await tester.pumpAndSettle();
      
      // Assert: Sign up form displayed
      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('phone_field')), findsOneWidget);
      
      // Act: Fill sign up form
      await tester.enterText(find.byKey(const Key('name_field')), 'New Customer');
      await tester.enterText(find.byKey(const Key('email_field')), 'newcustomer@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('phone_field')), '555-0123');
      
      final signUpButton = find.byKey(const Key('signup_button'));
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();
      
      // Assert: Successful registration and navigation
      expect(find.byType(CustomerHomeScreen), findsOneWidget);
    });

    testWidgets('Logout flow - returns to login screen', (WidgetTester tester) async {
      // Setup: Start with authenticated customer
      TestSupabaseService.setupAuthenticatedUser(role: 'customer');
      
      when(TestSupabaseService.mockAuth.signOut()).thenAnswer((_) async {
        TestSupabaseService.setupUnauthenticatedUser();
      });
      
      // Act: Load customer home screen
      await tester.pumpWidget(TestApp(
        child: CustomerHomeScreen(),
      ));
      
      // Act: Navigate to profile and logout
      await TestActions.navigateToTab(tester, 'Profile');
      
      final logoutButton = find.text('Logout');
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
      
      // Assert: Back to login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      TestExpectations.expectLoginScreen(tester);
    });

    testWidgets('Session persistence - auto login on app restart', (WidgetTester tester) async {
      // Setup: Mock existing session
      TestSupabaseService.setupAuthenticatedUser(role: 'customer');
      
      when(TestSupabaseService.mockAuth.refreshSession()).thenAnswer((_) async => AuthResponse(
        user: MockUser(),
        session: MockSession(),
      ));
      
      // Act: Simulate app start with existing session
      await tester.pumpWidget(TestApp(
        child: Builder(
          builder: (context) {
            // Check session and navigate
            if (TestSupabaseService.mockAuth.currentUser != null) {
              return CustomerHomeScreen();
            }
            return LoginScreen();
          },
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Assert: Directly to home screen, skipping login
      expect(find.byType(CustomerHomeScreen), findsOneWidget);
      TestExpectations.expectCustomerHomeScreen(tester);
    });

    testWidgets('Password reset flow', (WidgetTester tester) async {
      // Setup: Mock password reset
      when(TestSupabaseService.mockAuth.resetPasswordForEmail(
        'customer@test.com',
      )).thenAnswer((_) async {});
      
      // Act: Load login screen
      await tester.pumpWidget(TestApp(
        child: LoginScreen(),
      ));
      
      // Act: Tap forgot password
      final forgotPasswordLink = find.text('Forgot Password?');
      await tester.tap(forgotPasswordLink);
      await tester.pumpAndSettle();
      
      // Assert: Password reset dialog
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byKey(const Key('reset_email_field')), findsOneWidget);
      
      // Act: Enter email and submit
      await tester.enterText(find.byKey(const Key('reset_email_field')), 'customer@test.com');
      final resetButton = find.text('Send Reset Link');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
      
      // Assert: Success message
      expect(find.text('Password reset email sent'), findsOneWidget);
    });

    testWidgets('Social login flow - Google authentication', (WidgetTester tester) async {
      // Setup: Mock Google sign in
      when(TestSupabaseService.mockAuth.signInWithOAuth(
        OAuthProvider.google,
      )).thenAnswer((_) async => AuthResponse(
        user: MockUser(),
        session: MockSession(),
      ));
      
      TestSupabaseService.setupAuthenticatedUser(role: 'customer');
      
      // Act: Load login screen
      await tester.pumpWidget(TestApp(
        child: LoginScreen(),
      ));
      
      // Act: Tap Google sign in
      final googleButton = find.byKey(const Key('google_signin_button'));
      await tester.tap(googleButton);
      await tester.pumpAndSettle();
      
      // Assert: Successful authentication and navigation
      expect(find.byType(CustomerHomeScreen), findsOneWidget);
    });
  });
}