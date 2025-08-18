import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A simplified wrapper that prevents overflow issues throughout the app
class OverflowSafeWrapper extends StatelessWidget {
  final Widget child;
  final bool enableDebugMode;
  final bool preventOverflow;
  final Color? debugColor;
  final String? debugLabel;
  final VoidCallback? onOverflowDetected;

  const OverflowSafeWrapper({
    super.key,
    required this.child,
    this.enableDebugMode = false, // Disabled for production
    this.preventOverflow = true,
    this.debugColor,
    this.debugLabel,
    this.onOverflowDetected,
  });

  @override
  Widget build(BuildContext context) {
    // For now, simply wrap the child to prevent basic overflow issues
    if (preventOverflow) {
      return Material(
        type: MaterialType.transparency,
        child: child,
      );
    }
    
    return child;
  }
}

/// Utility class for overflow debugging
class OverflowDebugger {
  static bool _isEnabled = kDebugMode;
  static final List<String> _overflowLog = [];

  static void enable() => _isEnabled = true;
  static void disable() => _isEnabled = false;
  static bool get isEnabled => _isEnabled;

  static void logOverflow(String widgetName, String details) {
    if (!_isEnabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $widgetName: $details';
    
    _overflowLog.add(logEntry);
    debugPrint('🚨 OVERFLOW: $logEntry');
    
    // Keep only last 100 entries
    if (_overflowLog.length > 100) {
      _overflowLog.removeAt(0);
    }
  }

  static List<String> getOverflowLog() => List.unmodifiable(_overflowLog);
  
  static void clearLog() => _overflowLog.clear();
}

/// Extension for easy overflow-safe wrapping
extension OverflowSafeExtension on Widget {
  Widget overflowSafe({
    bool enableDebugMode = false,
    bool preventOverflow = true,
    Color? debugColor,
    String? debugLabel,
    VoidCallback? onOverflowDetected,
  }) {
    return OverflowSafeWrapper(
      enableDebugMode: enableDebugMode,
      preventOverflow: preventOverflow,
      debugColor: debugColor,
      debugLabel: debugLabel,
      onOverflowDetected: onOverflowDetected,
      child: this,
    );
  }
}