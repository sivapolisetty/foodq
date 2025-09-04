import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation helper utilities to safely handle navigation operations
class NavigationHelper {
  /// Safely pops the current route or navigates to fallback route
  /// 
  /// This prevents the "GoError: There is nothing to pop" error by checking
  /// if navigation stack can be popped before attempting to pop.
  /// 
  /// [context] - BuildContext for navigation
  /// [fallbackRoute] - Route to navigate to if pop is not possible (default: '/')
  static void safePopOrNavigate(BuildContext context, [String fallbackRoute = '/']) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  /// Safely pops the current route or goes back to customer home
  /// 
  /// Convenience method for customer-facing screens that should return
  /// to customer home if no navigation history exists.
  static void safePopOrGoHome(BuildContext context) {
    safePopOrNavigate(context, '/customer-home');
  }

  /// Safely pops using Navigator if GoRouter pop fails
  /// 
  /// Useful for modals and dialogs where Navigator.pop might be more appropriate
  static void safePopModal(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}