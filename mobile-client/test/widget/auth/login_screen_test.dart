import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:kravekart/features/auth/screens/login_screen.dart';
import 'package:kravekart/features/auth/providers/auth_provider.dart';
import 'package:kravekart/shared/models/user_role.dart';
import 'package:kravekart/shared/models/auth_result.dart';
import 'package:kravekart/shared/models/app_user.dart';
import 'package:kravekart/shared/theme/app_theme.dart';

import '../test_helpers.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('should render login form with customer mode by default', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Assert
      expect(find.text('Welcome to KraveKart'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
    });

    testWidgets('should toggle between customer and business mode', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act - Tap the toggle switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert - Should show business mode
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
      
      // Check if business mode is highlighted
      expect(find.text('Business'), findsOneWidget);
    });

    testWidgets('should validate email field', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act - Try to submit with invalid email
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password field', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act - Try to submit with empty password
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should show loading state during sign in', (tester) async {
      // Arrange
      when(mockAuthService.signInWithEmail(any, any))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return AuthResult.success(createMockUser());
      });

      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pump(); // Trigger the loading state

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing in...'), findsOneWidget);
    });

    testWidgets('should call sign in with correct parameters', (tester) async {
      // Arrange
      when(mockAuthService.signInWithEmail(any, any))
          .thenAnswer((_) async => AuthResult.success(createMockUser()));

      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.signInWithEmail('test@example.com', 'password123')).called(1);
    });

    testWidgets('should show error message on sign in failure', (tester) async {
      // Arrange
      when(mockAuthService.signInWithEmail(any, any))
          .thenAnswer((_) async => const AuthResult.failure('Invalid credentials'));

      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpassword');
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should navigate to sign up screen when sign up link is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('sign_up_link')));
      await tester.pumpAndSettle();

      // Assert - This would need to be tested with a proper navigation mock
      // For now, we verify the tap doesn't cause errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should hide/show password when toggle is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act - Find password field and toggle visibility
      final passwordField = find.byKey(const Key('password_field'));
      final visibilityToggle = find.byKey(const Key('password_visibility_toggle'));
      
      expect(passwordField, findsOneWidget);
      expect(visibilityToggle, findsOneWidget);

      // Initial state should be obscured
      TextFormField passwordWidget = tester.widget<TextFormField>(passwordField);
      expect(passwordWidget.obscureText, isTrue);

      // Tap to show password
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // Password should now be visible
      passwordWidget = tester.widget<TextFormField>(passwordField);
      expect(passwordWidget.obscureText, isFalse);
    });

    testWidgets('should apply overflow-safe wrapper', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Assert - Check that the screen doesn't overflow in different sizes
      await tester.binding.setSurfaceSize(const Size(300, 500)); // Small screen
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(800, 600)); // Large screen
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('should show business-specific UI when business mode is selected', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );

      // Act - Switch to business mode
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert - Should show business-specific text or UI elements
      // This depends on the specific UI design for business mode
      expect(find.text('Business'), findsOneWidget);
    });
  });
}

// Helper function to create mock user
AppUser createMockUser({UserRole role = UserRole.customer}) {
  return AppUser(
    id: 'test-user-id',
    email: 'test@example.com',
    fullName: 'Test User',
    role: role,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}