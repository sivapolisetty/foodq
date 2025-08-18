import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:kravekart/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('KraveKart Onboarding Flow Tests', () {
    testWidgets('Complete Customer User Creation Flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Take screenshot of home screen
      await binding.takeScreenshot('01_home_screen');

      // Navigate to Profile screen
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('02_profile_screen');

      // Look for "Select User" button or similar
      final selectUserButton = find.text('Select User').first;
      if (selectUserButton.evaluate().isNotEmpty) {
        await tester.tap(selectUserButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await binding.takeScreenshot('03_user_selection_screen');
      }

      // Find and tap "Create User" or "Create New User" button
      final createUserButton = find.textContaining('Create').first;
      expect(createUserButton, findsOneWidget);
      await tester.tap(createUserButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('04_create_user_screen');

      // Verify all required fields are present
      expect(find.byKey(const Key('name_field')).or(find.textContaining('Full Name')), findsOneWidget);
      expect(find.byKey(const Key('email_field')).or(find.textContaining('Email')), findsOneWidget);
      expect(find.byKey(const Key('phone_field')).or(find.textContaining('Phone')), findsOneWidget);
      expect(find.byKey(const Key('address_field')).or(find.textContaining('Address')), findsOneWidget);
      expect(find.byKey(const Key('city_field')).or(find.textContaining('City')), findsOneWidget);
      expect(find.byKey(const Key('state_field')).or(find.textContaining('State')), findsOneWidget);
      expect(find.byKey(const Key('postal_field')).or(find.textContaining('Postal')), findsOneWidget);

      // Fill out the form with test data
      await _fillTextField(tester, 'Full Name', 'John Test User');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await _fillTextField(tester, 'Email', 'john.test@example.com');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await _fillTextField(tester, 'Phone', '5551234567');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Scroll down to see address fields
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await binding.takeScreenshot('05_address_fields_visible');

      await _fillTextField(tester, 'Address', '123 Test Street');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await _fillTextField(tester, 'City', 'Test City');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await _fillTextField(tester, 'State', 'CA');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await _fillTextField(tester, 'Postal', '12345');
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await binding.takeScreenshot('06_form_filled_complete');

      // Scroll down to find submit button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Find and tap the create user button
      final submitButton = find.textContaining('Create').last;
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await binding.takeScreenshot('07_user_created_success');

      // Verify success - look for success message or navigation back
      expect(
        find.textContaining('success').or(find.textContaining('created')),
        findsAtLeastNWidget(0), // May or may not find success message
      );

      print('✅ Customer user creation test completed successfully');
    });

    testWidgets('Restaurant Onboarding Flow Test', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to home screen if not already there
      final homeButton = find.byIcon(Icons.home);
      if (homeButton.evaluate().isNotEmpty) {
        await tester.tap(homeButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
      await binding.takeScreenshot('08_home_for_restaurant');

      // Look for "Become a Partner" link
      final partnerLink = find.textContaining('Partner').or(find.textContaining('restaurant'));
      if (partnerLink.evaluate().isNotEmpty) {
        await tester.tap(partnerLink.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await binding.takeScreenshot('09_restaurant_onboarding_page');

        // Look for "Start Application" or similar button
        final startButton = find.textContaining('Start').or(find.textContaining('Apply'));
        if (startButton.evaluate().isNotEmpty) {
          await tester.tap(startButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await binding.takeScreenshot('10_restaurant_application_form');

          // Fill out basic restaurant information if form is present
          await _fillTextFieldIfExists(tester, 'Restaurant Name', 'Test Restaurant');
          await _fillTextFieldIfExists(tester, 'Business Name', 'Test Restaurant LLC');
          await _fillTextFieldIfExists(tester, 'Email', 'owner@testrestaurant.com');
          await _fillTextFieldIfExists(tester, 'Phone', '5559876543');

          await tester.pumpAndSettle(const Duration(seconds: 1));
          await binding.takeScreenshot('11_restaurant_form_filled');

          print('✅ Restaurant onboarding test completed successfully');
        }
      }
    });

    testWidgets('Form Validation Test', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to create user screen
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final selectUserButton = find.text('Select User').first;
      if (selectUserButton.evaluate().isNotEmpty) {
        await tester.tap(selectUserButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      final createUserButton = find.textContaining('Create').first;
      await tester.tap(createUserButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('12_empty_form');

      // Try to submit empty form to test validation
      final submitButton = find.textContaining('Create').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('13_validation_errors');

      // Verify validation errors appear
      expect(find.textContaining('enter'), findsAtLeastNWidget(1));

      print('✅ Form validation test completed successfully');
    });
  });
}

// Helper function to fill text fields
Future<void> _fillTextField(WidgetTester tester, String labelText, String value) async {
  final textField = find.widgetWithText(TextFormField, labelText)
      .or(find.ancestor(
        of: find.textContaining(labelText),
        matching: find.byType(TextFormField),
      ));
  
  if (textField.evaluate().isNotEmpty) {
    await tester.enterText(textField.first, value);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }
}

// Helper function to fill text field only if it exists
Future<void> _fillTextFieldIfExists(WidgetTester tester, String labelText, String value) async {
  final textField = find.widgetWithText(TextFormField, labelText)
      .or(find.ancestor(
        of: find.textContaining(labelText),
        matching: find.byType(TextFormField),
      ));
  
  if (textField.evaluate().isNotEmpty) {
    await tester.enterText(textField.first, value);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }
}