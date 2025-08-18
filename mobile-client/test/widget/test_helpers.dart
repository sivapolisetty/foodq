import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:kravekart/features/auth/services/auth_service.dart';
import 'package:kravekart/shared/theme/app_theme.dart';

@GenerateMocks([AuthService])
import 'test_helpers.mocks.dart';

/// Create a test app wrapper with theme and providers
Widget createTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// Create a test app with routing
Widget createTestAppWithRouting({
  required Widget child,
  List<Override> overrides = const [],
  String initialRoute = '/',
  Map<String, WidgetBuilder>? routes,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
      initialRoute: initialRoute,
      routes: routes ?? {},
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// Pump and settle with custom duration
Future<void> pumpAndSettleCustom(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 100),
  int maxFrames = 100,
}) async {
  await tester.pumpAndSettle(duration, EnginePhase.sendSemanticsUpdate, maxFrames);
}

/// Find widget by text containing specific substring
Finder findTextContaining(String substring) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        widget.data!.toLowerCase().contains(substring.toLowerCase()),
  );
}

/// Find widget by key with type checking
Finder findByKeyAndType<T extends Widget>(String key) {
  return find.byWidgetPredicate(
    (widget) => widget.key == Key(key) && widget is T,
  );
}

/// Verify that no overflow occurs in the widget tree
void verifyNoOverflow(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

/// Test different screen sizes
Future<void> testResponsiveness(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
}) async {
  final sizes = [
    const Size(360, 640), // Small phone
    const Size(414, 896), // iPhone 11 Pro Max
    const Size(768, 1024), // iPad
    const Size(1024, 768), // iPad landscape
    const Size(1920, 1080), // Desktop
  ];

  for (final size in sizes) {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(createTestApp(
      child: widget,
      overrides: overrides,
    ));
    await tester.pumpAndSettle();
    
    // Verify no overflow
    verifyNoOverflow(tester);
  }
}

/// Enter text with delay (simulates user typing)
Future<void> enterTextWithDelay(
  WidgetTester tester,
  Finder finder,
  String text, {
  Duration delay = const Duration(milliseconds: 50),
}) async {
  for (int i = 0; i < text.length; i++) {
    await tester.enterText(finder, text.substring(0, i + 1));
    await tester.pump(delay);
  }
}

/// Tap widget with haptic feedback simulation
Future<void> tapWithFeedback(
  WidgetTester tester,
  Finder finder, {
  Duration feedbackDelay = const Duration(milliseconds: 50),
}) async {
  await tester.tap(finder);
  await tester.pump(feedbackDelay);
}

/// Scroll until widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double delta = 100,
  int maxScrolls = 50,
}) async {
  for (int i = 0; i < maxScrolls; i++) {
    if (tester.any(finder)) {
      break;
    }
    await tester.scrollUntilVisible(finder, delta, scrollable: scrollable);
  }
}

/// Custom matchers for testing
class CustomMatchers {
  static Matcher hasOverflow() {
    return predicate<Widget>(
      (widget) {
        // This would need custom implementation based on overflow detection
        return false; // Placeholder
      },
      'has overflow',
    );
  }

  static Matcher hasText(String text) {
    return predicate<Widget>(
      (widget) {
        if (widget is Text) {
          return widget.data?.contains(text) ?? false;
        }
        return false;
      },
      'contains text "$text"',
    );
  }

  static Matcher isEnabled() {
    return predicate<Widget>(
      (widget) {
        if (widget is ElevatedButton) {
          return widget.onPressed != null;
        }
        if (widget is TextButton) {
          return widget.onPressed != null;
        }
        if (widget is OutlinedButton) {
          return widget.onPressed != null;
        }
        return true;
      },
      'is enabled',
    );
  }

  static Matcher isDisabled() {
    return predicate<Widget>(
      (widget) {
        if (widget is ElevatedButton) {
          return widget.onPressed == null;
        }
        if (widget is TextButton) {
          return widget.onPressed == null;
        }
        if (widget is OutlinedButton) {
          return widget.onPressed == null;
        }
        return false;
      },
      'is disabled',
    );
  }
}

/// Test data generators
class TestDataGenerators {
  static const List<String> validEmails = [
    'test@example.com',
    'user.name@domain.co.uk',
    'firstname+lastname@company.org',
  ];

  static const List<String> invalidEmails = [
    'invalid-email',
    '@domain.com',
    'test@',
    'test..email@domain.com',
  ];

  static const List<String> validPasswords = [
    'password123',
    'StrongPassword!',
    'MySecureP@ssw0rd',
  ];

  static const List<String> invalidPasswords = [
    '',
    '123',
    'short',
  ];

  static const List<String> validNames = [
    'John Doe',
    'Jane Smith',
    'Robert Johnson',
  ];

  static const List<String> invalidNames = [
    '',
    'A',
    '123',
  ];
}