import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';

import '../../../lib/features/profile/screens/profile_screen.dart';
import '../../../lib/features/profile/widgets/profile_menu_section.dart';
import '../../../lib/features/profile/widgets/user_selection_modal.dart';
import '../../../lib/features/profile/providers/user_provider.dart';
import '../../../lib/features/profile/services/user_service.dart';
import '../../../lib/shared/models/app_user.dart';
import '../../../lib/shared/enums/user_type.dart';

import 'user_management_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserService>(),
  MockSpec<GoRouter>(),
])
void main() {
  group('User Management Tests', () {
    late MockUserService mockUserService;
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockUserService = MockUserService();
      mockGoRouter = MockGoRouter();
    });

    final testBusinessUser = AppUser(
      id: 'business-1',
      name: 'John Restaurant Owner',
      email: 'john@restaurant.com',
      userType: UserType.business,
      businessName: 'Johns Bistro',
    );

    final testCustomerUser = AppUser(
      id: 'customer-1', 
      name: 'Jane Customer',
      email: 'jane@email.com',
      userType: UserType.customer,
    );

    final testUsers = [testBusinessUser, testCustomerUser];

    group('ProfileScreen Tests', () {
      testWidgets('displays user selection button when no user selected', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => const AsyncValue.data(null)),
            ],
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );

        expect(find.text('No User Selected'), findsOneWidget);
        expect(find.text('Select User'), findsOneWidget);
        expect(find.byIcon(Icons.person_add), findsOneWidget);
      });

      testWidgets('displays user profile when user is selected', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );

        expect(find.text('Business Profile'), findsOneWidget);
        expect(find.byIcon(Icons.people_alt), findsOneWidget);
      });

      testWidgets('shows user switching button in app bar', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );

        expect(find.byIcon(Icons.people_alt), findsOneWidget);
        
        // Tap the user switching button
        await tester.tap(find.byIcon(Icons.people_alt));
        await tester.pumpAndSettle();

        // Should show user selection modal
        expect(find.text('Select User'), findsOneWidget);
      });

      testWidgets('displays loading state correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => const AsyncValue.loading()),
            ],
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('displays error state correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.error('Test error', StackTrace.empty)),
            ],
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );

        expect(find.text('Error Loading Profile'), findsOneWidget);
        expect(find.text('Test error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('ProfileMenuSection Tests', () {
      testWidgets('displays correct menu items for business user', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProfileMenuSection(user: testBusinessUser),
              ),
            ),
          ),
        );

        // User management section
        expect(find.text('User Management'), findsOneWidget);
        expect(find.text('Switch User'), findsOneWidget);
        expect(find.text('Create New User'), findsOneWidget);

        // Business features
        expect(find.text('Business Features'), findsOneWidget);
        expect(find.text('Business Dashboard'), findsOneWidget);
        expect(find.text('Manage Deals'), findsOneWidget);
        expect(find.text('Finances'), findsOneWidget);
        expect(find.text('Business Orders'), findsOneWidget);

        // Common features
        expect(find.text('Account & Settings'), findsOneWidget);
        expect(find.text('Edit Profile'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
      });

      testWidgets('displays correct menu items for customer user', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProfileMenuSection(user: testCustomerUser),
              ),
            ),
          ),
        );

        // User management section
        expect(find.text('User Management'), findsOneWidget);

        // Customer features
        expect(find.text('Customer Features'), findsOneWidget);
        expect(find.text('Explore Deals'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
        expect(find.text('Favorites'), findsOneWidget);
        expect(find.text('My Orders'), findsOneWidget);

        // Should not show business features
        expect(find.text('Business Features'), findsNothing);
        expect(find.text('Business Dashboard'), findsNothing);
      });

      testWidgets('tap switch user opens modal', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProfileMenuSection(user: testCustomerUser),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Switch User'));
        await tester.pumpAndSettle();

        expect(find.text('Select User'), findsOneWidget);
      });

      testWidgets('logout shows confirmation dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProfileMenuSection(user: testCustomerUser),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Switch to Guest Mode'));
        await tester.pumpAndSettle();

        expect(find.text('Switch to Guest Mode'), findsWidgets);
        expect(find.text('Are you sure you want to log out?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Logout'), findsOneWidget);
      });

      testWidgets('delete user shows confirmation dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ProfileMenuSection(user: testCustomerUser),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Delete User'));
        await tester.pumpAndSettle();

        expect(find.text('Delete User Account'), findsOneWidget);
        expect(find.text('Are you sure you want to permanently delete'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });
    });

    group('UserSelectionModal Tests', () {
      testWidgets('displays tab bar with correct tabs', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => AsyncValue.data(testUsers)),
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        expect(find.text('All Users'), findsOneWidget);
        expect(find.text('Business'), findsOneWidget);
        expect(find.text('Customer'), findsOneWidget);
      });

      testWidgets('displays create new user button', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => AsyncValue.data(testUsers)),
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        expect(find.text('Create New User'), findsOneWidget);
        expect(find.byIcon(Icons.person_add), findsOneWidget);
      });

      testWidgets('displays user cards correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => AsyncValue.data(testUsers)),
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        // Check for user names
        expect(find.text('John Restaurant Owner'), findsOneWidget);
        expect(find.text('Jane Customer'), findsOneWidget);

        // Check for business name
        expect(find.text('Johns Bistro'), findsOneWidget);

        // Check for user type badges
        expect(find.text('Business'), findsOneWidget);
        expect(find.text('Customer'), findsOneWidget);
      });

      testWidgets('shows current user with check mark', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => AsyncValue.data(testUsers)),
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        // Current user should have check mark
        expect(find.byIcon(Icons.check), findsOneWidget);
        
        // Other users should have arrow
        expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      });

      testWidgets('shows empty state when no users', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => const AsyncValue.data([])),
              currentUserProvider.overrideWith((ref) => const AsyncValue.data(null)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        expect(find.text('No Users Found'), findsOneWidget);
        expect(find.text('Create your first user to get started'), findsOneWidget);
        expect(find.text('Create Customer Account'), findsOneWidget);
        expect(find.text('Onboard Business'), findsOneWidget);
      });

      testWidgets('shows loading state', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => const AsyncValue.loading()),
              currentUserProvider.overrideWith((ref) => const AsyncValue.loading()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows error state', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => AsyncValue.error('Load error', StackTrace.empty)),
              currentUserProvider.overrideWith((ref) => const AsyncValue.data(null)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        expect(find.text('Failed to Load Users'), findsOneWidget);
        expect(find.text('Load error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('close button works', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => AsyncValue.data(testUsers)),
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => const UserSelectionModal(),
                    ),
                    child: const Text('Open Modal'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        expect(find.text('Select User'), findsOneWidget);
        
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(find.text('Select User'), findsNothing);
      });
    });

    group('User Management Integration Tests', () {
      testWidgets('complete user switching flow', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
              userListProvider.overrideWith((ref) => AsyncValue.data(testUsers)),
            ],
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );

        // Start from profile screen
        expect(find.text('Business Profile'), findsOneWidget);

        // Tap user switching button
        await tester.tap(find.byIcon(Icons.people_alt));
        await tester.pumpAndSettle();

        // Should show user selection modal
        expect(find.text('Select User'), findsOneWidget);
        expect(find.text('John Restaurant Owner'), findsOneWidget);
        expect(find.text('Jane Customer'), findsOneWidget);

        // Check current user indicator
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('onboarding buttons navigate correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => const AsyncValue.data([])),
              currentUserProvider.overrideWith((ref) => const AsyncValue.data(null)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        expect(find.text('Create Customer Account'), findsOneWidget);
        expect(find.text('Onboard Business'), findsOneWidget);
      });
    });

    group('User Management Provider Tests', () {
      testWidgets('user provider state changes correctly', (WidgetTester tester) async {
        final container = ProviderContainer();
        
        // Initially no user
        expect(container.read(currentUserProvider).value, isNull);
        
        // Dispose container
        container.dispose();
      });
    });

    group('Accessibility Tests', () {
      testWidgets('profile screen has proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );

        // Check for proper button semantics
        final switchUserButton = find.byIcon(Icons.people_alt);
        expect(switchUserButton, findsOneWidget);
        
        // Verify tooltip is accessible
        await tester.longPress(switchUserButton);
        await tester.pumpAndSettle();
      });

      testWidgets('user selection modal has proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => AsyncValue.data(testUsers)),
              currentUserProvider.overrideWith((ref) => AsyncValue.data(testBusinessUser)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        // Check tab accessibility
        expect(find.text('All Users'), findsOneWidget);
        expect(find.text('Business'), findsOneWidget);
        expect(find.text('Customer'), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('handles user service errors gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userListProvider.overrideWith((ref) => AsyncValue.error('Network error', StackTrace.empty)),
              currentUserProvider.overrideWith((ref) => const AsyncValue.data(null)),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: UserSelectionModal(),
              ),
            ),
          ),
        );

        expect(find.text('Failed to Load Users'), findsOneWidget);
        expect(find.text('Network error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });
  });
}