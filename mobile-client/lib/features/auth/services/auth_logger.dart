import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthLogger {
  static const String _tag = 'AUTH';

  static void logAuthEvent(String event, {Map<String, dynamic>? data}) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('🔐 AUTH EVENT: $event');
    
    if (data != null) {
      logMessage.writeln('📋 Data:');
      data.forEach((key, value) {
        // Sanitize sensitive information
        final displayValue = _sanitizeAuthValue(key, value);
        logMessage.writeln('   $key: $displayValue');
      });
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logAuthError(String operation, Object error, {StackTrace? stackTrace}) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('❌ AUTH ERROR: $operation');
    logMessage.writeln('🔥 Error: $error');
    
    if (stackTrace != null) {
      logMessage.writeln('📍 Stack trace:');
      logMessage.writeln(stackTrace.toString());
    }

    developer.log(
      logMessage.toString(), 
      name: _tag, 
      error: error, 
      stackTrace: stackTrace,
    );
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logUserState(User? user, {String? context}) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('👤 USER STATE${context != null ? " ($context)" : ""}');
    
    if (user != null) {
      logMessage.writeln('✅ User authenticated:');
      logMessage.writeln('   ID: ${user.id}');
      logMessage.writeln('   Email: ${user.email ?? 'N/A'}');
      logMessage.writeln('   Phone: ${user.phone ?? 'N/A'}');
      logMessage.writeln('   Created: ${user.createdAt}');
      logMessage.writeln('   Last Sign In: ${user.lastSignInAt ?? 'N/A'}');
      logMessage.writeln('   Email Confirmed: ${user.emailConfirmedAt != null}');
      logMessage.writeln('   Phone Confirmed: ${user.phoneConfirmedAt != null}');
      
      if (user.userMetadata?.isNotEmpty == true) {
        logMessage.writeln('   Metadata:');
        user.userMetadata?.forEach((key, value) {
          final displayValue = _sanitizeAuthValue(key, value);
          logMessage.writeln('     $key: $displayValue');
        });
      }

      if (user.appMetadata?.isNotEmpty == true) {
        logMessage.writeln('   App Metadata:');
        user.appMetadata?.forEach((key, value) {
          final displayValue = _sanitizeAuthValue(key, value);
          logMessage.writeln('     $key: $displayValue');
        });
      }
    } else {
      logMessage.writeln('❌ No authenticated user');
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logSessionState(Session? session, {String? context}) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('🎫 SESSION STATE${context != null ? " ($context)" : ""}');
    
    if (session != null) {
      logMessage.writeln('✅ Session active:');
      logMessage.writeln('   Access Token: ${_maskToken(session.accessToken)}');
      logMessage.writeln('   Refresh Token: ${_maskToken(session.refreshToken ?? 'N/A')}');
      logMessage.writeln('   Token Type: ${session.tokenType}');
      logMessage.writeln('   Expires At: ${session.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch((session.expiresAt! * 1000).toInt()) : 'N/A'}');
      logMessage.writeln('   Expires In: ${session.expiresIn}s');
      
      if (session.providerToken != null) {
        logMessage.writeln('   Provider Token: ${_maskToken(session.providerToken!)}');
      }
      
      if (session.providerRefreshToken != null) {
        logMessage.writeln('   Provider Refresh Token: ${_maskToken(session.providerRefreshToken!)}');
      }
    } else {
      logMessage.writeln('❌ No active session');
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logAuthStateChange(AuthChangeEvent event, Session? session) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('🔄 AUTH STATE CHANGE: ${event.name}');
    
    if (session != null) {
      logMessage.writeln('   User ID: ${session.user.id}');
      logMessage.writeln('   Email: ${session.user.email ?? 'N/A'}');
      logMessage.writeln('   Session expires: ${session.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch((session.expiresAt! * 1000).toInt()) : 'N/A'}');
    } else {
      logMessage.writeln('   No session data');
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logSupabaseOperation(String operation, {Map<String, dynamic>? data}) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('🗄️ SUPABASE OPERATION: $operation');
    
    if (data != null) {
      logMessage.writeln('📋 Parameters:');
      data.forEach((key, value) {
        final displayValue = _sanitizeAuthValue(key, value);
        logMessage.writeln('   $key: $displayValue');
      });
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static String _sanitizeAuthValue(String key, dynamic value) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('token') ||
        lowerKey.contains('password') ||
        lowerKey.contains('secret') ||
        lowerKey.contains('key')) {
      return _maskToken(value.toString());
    }
    
    if (value is Map || value is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        return value.toString();
      }
    }
    
    return value.toString();
  }

  static String _maskToken(String token) {
    if (token.length <= 8) {
      return '*' * token.length;
    }
    return '${token.substring(0, 4)}${'*' * (token.length - 8)}${token.substring(token.length - 4)}';
  }
}