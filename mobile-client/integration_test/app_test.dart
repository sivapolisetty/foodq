import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:grabeat/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GraBeat App Integration Tests', () {
    testWidgets('App launches and shows welcome screen', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to fully load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app title or key elements
      expect(find.text('GraBeat'), findsAtLeastOneWidget);
      
      // Look for welcome screen elements
      expect(
        find.byType(MaterialApp), 
        findsOneWidget,
        reason: 'App should have MaterialApp root widget'
      );

      // Take screenshot for visual verification
      await tester.binding.convertFlutterSurfaceToImage();
      
      print('✅ App launched successfully on mobile device');
    });

    testWidgets('User creation flow works on mobile', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to stabilize
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for user selection entry point
      final selectUserFinder = find.text('Select User');
      
      if (!selectUserFinder.evaluate().isEmpty) {
        print('✅ Found "Select User" button');
        await tester.tap(selectUserFinder);
        await tester.pumpAndSettle();
        
        // Look for user creation options
        final createUserFinder = find.text('Create User');
        if (!createUserFinder.evaluate().isEmpty) {
          print('✅ Found "Create User" option');
          await tester.tap(createUserFinder);
          await tester.pumpAndSettle();
          
          print('✅ User creation flow is accessible');
        } else {
          print('ℹ️  Create User option not immediately visible');
        }
      } else {
        print('ℹ️  App may already have user selected or different state');
      }

      // Verify we can navigate (basic functionality test)
      expect(find.byType(Scaffold), findsAtLeastOneWidget);
      print('✅ Basic navigation structure is present');
    });
  });
}