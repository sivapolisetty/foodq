import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grabeat/features/auth/screens/login_screen.dart';
import 'package:grabeat/features/auth/providers/auth_provider.dart';
import 'package:grabeat/core/services/auth_service.dart';
import 'package:grabeat/shared/models/app_user.dart';
import 'package:grabeat/shared/enums/user_type.dart';
import 'package:go_router/go_router.dart';

import 'auth_flow_integration_test.mocks.dart';

@GenerateMocks([
  AuthService,
  GoRouter,
])
void main() {
  group('Login Screen Integration Tests', () {
    late MockAuthService mockAuthService;
    late MockGoRouter mockRouter;

    setUp(() {
      mockAuthService = MockAuthService();
      mockRouter = MockGoRouter();
    });

    Widget createTestWidget({required Widget child}) {
      return ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('should display all authentication options', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Assert - Check for main UI elements
      expect(find.text('Sign In to GrabEat'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Magic Link'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('should toggle between password and magic link modes', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Tap on Magic Link tab
      await tester.tap(find.text('Magic Link'));
      await tester.pumpAndSettle();

      // Assert - Password field should be hidden
      expect(find.text('Password'), findsNothing);
      expect(find.text('Send Magic Link'), findsOneWidget);

      // Act - Tap back on Password tab
      await tester.tap(find.text('Password'));
      await tester.pumpAndSettle();

      // Assert - Password field should be visible again
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should validate email field', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Try to sign in without entering email
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);

      // Act - Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should handle password sign in', (tester) async {
      // Arrange
      final mockUser = AppUser(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
        userType: UserType.customer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockAuthService.signIn(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => AuthResponse(
        user: User(
          id: 'user-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: null,
      ));

      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => mockUser);

      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Enter credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      
      // Sign in
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      verify(mockAuthService.signIn(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    testWidgets('should handle magic link sign in', (tester) async {
      // Arrange
      when(mockAuthService.signInWithMagicLink(
        email: 'test@example.com',
      )).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Switch to magic link mode
      await tester.tap(find.text('Magic Link'));
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      
      // Send magic link
      await tester.tap(find.text('Send Magic Link'));
      await tester.pump();

      // Assert
      verify(mockAuthService.signInWithMagicLink(
        email: 'test@example.com',
      )).called(1);
    });

    testWidgets('should show OTP verification after magic link', (tester) async {
      // Arrange
      when(mockAuthService.signInWithMagicLink(
        email: 'test@example.com',
      )).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Switch to magic link and send
      await tester.tap(find.text('Magic Link'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Send Magic Link'));
      await tester.pumpAndSettle();

      // Assert - OTP section should be visible
      expect(find.text('We sent a verification code to test@example.com'), findsOneWidget);
      expect(find.text('Verification Code'), findsOneWidget);
      expect(find.text('Verify Code'), findsOneWidget);
    });

    testWidgets('should handle OTP verification', (tester) async {
      // Arrange
      final mockUser = AppUser(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
        userType: UserType.customer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockAuthService.signInWithMagicLink(
        email: 'test@example.com',
      )).thenAnswer((_) async => {});

      when(mockAuthService.verifyOTP(
        email: 'test@example.com',
        token: '123456',
      )).thenAnswer((_) async => AuthResponse(
        user: User(
          id: 'user-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: null,
      ));

      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => mockUser);

      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Send magic link
      await tester.tap(find.text('Magic Link'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Send Magic Link'));
      await tester.pumpAndSettle();

      // Enter OTP
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.tap(find.text('Verify Code'));
      await tester.pump();

      // Assert
      verify(mockAuthService.verifyOTP(
        email: 'test@example.com',
        token: '123456',
      )).called(1);
    });

    testWidgets('should handle Google sign in', (tester) async {
      // Arrange
      final mockUser = AppUser(
        id: 'google-user-123',
        email: 'google@example.com',
        name: 'Google User',
        userType: UserType.customer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => AuthResponse(
        user: User(
          id: 'google-user-123',
          appMetadata: {},
          userMetadata: {'provider': 'google'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: null,
      ));

      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => mockUser);

      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Tap Google sign in
      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      // Assert
      verify(mockAuthService.signInWithGoogle()).called(1);
    });

    testWidgets('should display error messages', (tester) async {
      // Arrange
      when(mockAuthService.signIn(
        email: any,
        password: any,
      )).thenThrow(Exception('Invalid credentials'));

      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Try to sign in with invalid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert - Error should be displayed
      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should navigate to forgot password', (tester) async {
      // Arrange
      when(mockAuthService.resetPassword('test@example.com'))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act - Enter email and tap forgot password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.resetPassword('test@example.com')).called(1);
    });

    testWidgets('should show loading indicator during sign in', (tester) async {
      // Arrange
      when(mockAuthService.signIn(
        email: any,
        password: any,
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return AuthResponse(
          user: User(
            id: 'user-123',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
          session: null,
        );
      });

      await tester.pumpWidget(createTestWidget(child: const LoginScreen()));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}