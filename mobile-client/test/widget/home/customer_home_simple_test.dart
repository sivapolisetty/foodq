import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kravekart/features/home/screens/customer_home_screen.dart';
import 'package:kravekart/shared/models/deal.dart';

void main() {
  group('CustomerHomeScreen Simple Tests', () {
    testWidgets('should build without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );

      // Assert - just verify it builds
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search for meal and restaurant...'), findsOneWidget);
    });

    testWidgets('should display category icons', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Pickup Now'), findsOneWidget);
      expect(find.text('Near Me'), findsOneWidget);
      expect(find.text('Top Deals'), findsOneWidget);
      expect(find.text('Best Reviews'), findsOneWidget);
      expect(find.text('Meals'), findsOneWidget);
    });

    testWidgets('should display location and impact cards', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Your Location'), findsOneWidget);
      expect(find.text('Current Location'), findsOneWidget);
      expect(find.text('Rescue Impact'), findsOneWidget);
      expect(find.text('by KraveKart Community'), findsOneWidget);
    });

    testWidgets('should display bottom navigation', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should handle category icon taps', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap on "Top Deals" category
      await tester.tap(find.text('Top Deals'));
      await tester.pump();

      // Assert - no crash, just verify interaction works
      expect(find.text('Top Deals'), findsOneWidget);
    });

    testWidgets('should handle search input', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Enter text in search bar
      await tester.enterText(find.byType(TextField), 'pizza');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Assert - verify search functionality works
      expect(find.text('pizza'), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display green header with gradient', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomerHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert - verify header styling
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });
}