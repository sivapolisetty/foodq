import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLogger {
  static const String _tag = 'SUPABASE';

  static void logQuery(
    String table,
    String operation, {
    Map<String, dynamic>? filters,
    Map<String, dynamic>? data,
    String? select,
  }) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('🗄️ SUPABASE $operation: $table');
    
    if (select != null) {
      logMessage.writeln('📋 Select: $select');
    }
    
    if (filters != null && filters.isNotEmpty) {
      logMessage.writeln('🔍 Filters:');
      filters.forEach((key, value) {
        logMessage.writeln('   $key: $value');
      });
    }

    if (data != null && data.isNotEmpty) {
      logMessage.writeln('📦 Data:');
      logMessage.writeln(_formatData(data));
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logAuth(
    String operation, {
    String? email,
    String? provider,
    Map<String, dynamic>? metadata,
  }) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    logMessage.writeln('🔐 SUPABASE AUTH: $operation');
    
    if (email != null) {
      logMessage.writeln('📧 Email: $email');
    }
    
    if (provider != null) {
      logMessage.writeln('🔑 Provider: $provider');
    }
    
    if (metadata != null && metadata.isNotEmpty) {
      logMessage.writeln('📋 Metadata:');
      logMessage.writeln(_formatData(metadata));
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static void logResponse(
    String operation,
    dynamic result, {
    Duration? duration,
    String? error,
  }) {
    if (!kDebugMode) return;

    final logMessage = StringBuffer();
    
    if (error != null) {
      logMessage.writeln('❌ SUPABASE ERROR: $operation');
      logMessage.writeln('🔥 Error: $error');
    } else {
      logMessage.writeln('✅ SUPABASE SUCCESS: $operation');
      
      if (result != null) {
        logMessage.writeln('📦 Result:');
        if (result is List) {
          logMessage.writeln('   Count: ${result.length} items');
          if (result.isNotEmpty) {
            logMessage.writeln(_formatData(result.first));
          }
        } else if (result is Map) {
          logMessage.writeln(_formatData(result));
        } else {
          logMessage.writeln('   $result');
        }
      }
    }
    
    if (duration != null) {
      logMessage.writeln('⏱️ Duration: ${duration.inMilliseconds}ms');
    }

    developer.log(logMessage.toString(), name: _tag);
    print('${DateTime.now().toIso8601String()} | $_tag | ${logMessage.toString()}');
  }

  static String _formatData(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return 'Error formatting data: $e';
    }
  }
}

class LoggingSupabaseClient {
  final SupabaseClient _client;

  LoggingSupabaseClient(this._client);

  SupabaseClient get client => _client;

  // Auth wrapper
  LoggingGoTrueClient get auth => LoggingGoTrueClient(_client.auth);

  // Table query wrapper - simplified approach
  PostgrestQueryBuilder from(String table) {
    SupabaseLogger.logQuery(table, 'QUERY_START');
    return _client.from(table);
  }
}

class LoggingGoTrueClient {
  final GoTrueClient _auth;

  LoggingGoTrueClient(this._auth);

  // Delegate all properties
  User? get currentUser => _auth.currentUser;
  Session? get currentSession => _auth.currentSession;
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
    String? captchaToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    SupabaseLogger.logAuth(
      'signUp',
      email: email,
      metadata: data,
    );

    try {
      final result = await _auth.signUp(
        email: email,
        password: password,
        data: data,
        captchaToken: captchaToken,
      );
      
      stopwatch.stop();
      SupabaseLogger.logResponse('signUp', result.user?.id, duration: stopwatch.elapsed);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      SupabaseLogger.logResponse('signUp', null, duration: stopwatch.elapsed, error: e.toString());
      rethrow;
    }
  }

  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    SupabaseLogger.logAuth(
      'signInWithPassword',
      email: email ?? phone ?? 'unknown',
    );

    try {
      final result = await _auth.signInWithPassword(
        email: email,
        phone: phone,
        password: password,
        captchaToken: captchaToken,
      );
      
      stopwatch.stop();
      SupabaseLogger.logResponse('signInWithPassword', result.user?.id, duration: stopwatch.elapsed);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      SupabaseLogger.logResponse('signInWithPassword', null, duration: stopwatch.elapsed, error: e.toString());
      rethrow;
    }
  }

  Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
    String? scopes,
    Map<String, String>? queryParams,
    LaunchMode authScreenLaunchMode = LaunchMode.platformDefault,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    SupabaseLogger.logAuth(
      'signInWithOAuth',
      provider: provider.name,
    );

    try {
      final result = await _auth.signInWithOAuth(
        provider,
        redirectTo: redirectTo,
        scopes: scopes,
        queryParams: queryParams,
        authScreenLaunchMode: authScreenLaunchMode,
      );
      
      stopwatch.stop();
      SupabaseLogger.logResponse('signInWithOAuth', result, duration: stopwatch.elapsed);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      SupabaseLogger.logResponse('signInWithOAuth', null, duration: stopwatch.elapsed, error: e.toString());
      rethrow;
    }
  }

  Future<void> signInWithOtp({
    String? email,
    String? phone,
    String? emailRedirectTo,
    bool? shouldCreateUser,
    Map<String, dynamic>? data,
    String? captchaToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    SupabaseLogger.logAuth(
      'signInWithOtp',
      email: email ?? phone ?? 'unknown',
      metadata: data,
    );

    try {
      await _auth.signInWithOtp(
        email: email,
        phone: phone,
        emailRedirectTo: emailRedirectTo,
        shouldCreateUser: shouldCreateUser,
        data: data,
        captchaToken: captchaToken,
      );
      
      stopwatch.stop();
      SupabaseLogger.logResponse('signInWithOtp', 'OTP sent', duration: stopwatch.elapsed);
    } catch (e) {
      stopwatch.stop();
      SupabaseLogger.logResponse('signInWithOtp', null, duration: stopwatch.elapsed, error: e.toString());
      rethrow;
    }
  }

  Future<AuthResponse> verifyOTP({
    String? email,
    String? phone,
    required String token,
    required OtpType type,
    String? redirectTo,
    String? captchaToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    SupabaseLogger.logAuth(
      'verifyOTP',
      email: email ?? phone ?? 'unknown',
    );

    try {
      final result = await _auth.verifyOTP(
        email: email,
        phone: phone,
        token: token,
        type: type,
        redirectTo: redirectTo,
        captchaToken: captchaToken,
      );
      
      stopwatch.stop();
      SupabaseLogger.logResponse('verifyOTP', result.user?.id, duration: stopwatch.elapsed);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      SupabaseLogger.logResponse('verifyOTP', null, duration: stopwatch.elapsed, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut({SignOutScope scope = SignOutScope.global}) async {
    final stopwatch = Stopwatch()..start();
    
    SupabaseLogger.logAuth('signOut');

    try {
      await _auth.signOut(scope: scope);
      
      stopwatch.stop();
      SupabaseLogger.logResponse('signOut', 'Success', duration: stopwatch.elapsed);
    } catch (e) {
      stopwatch.stop();
      SupabaseLogger.logResponse('signOut', null, duration: stopwatch.elapsed, error: e.toString());
      rethrow;
    }
  }

  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
    String? captchaToken,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    SupabaseLogger.logAuth('resetPasswordForEmail', email: email);

    try {
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
        captchaToken: captchaToken,
      );
      
      stopwatch.stop();
      SupabaseLogger.logResponse('resetPasswordForEmail', 'Email sent', duration: stopwatch.elapsed);
    } catch (e) {
      stopwatch.stop();
      SupabaseLogger.logResponse('resetPasswordForEmail', null, duration: stopwatch.elapsed, error: e.toString());
      rethrow;
    }
  }
}

// Extension methods to add logging to existing Supabase queries
extension LoggingPostgrestQueryBuilder on PostgrestQueryBuilder {
  Future<List<Map<String, dynamic>>> selectWithLogging([String columns = '*']) async {
    final stopwatch = Stopwatch()..start();
    SupabaseLogger.logQuery('table', 'SELECT', select: columns);
    
    try {
      final result = await select(columns);
      
      stopwatch.stop();
      SupabaseLogger.logResponse('SELECT', result, duration: stopwatch.elapsed);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      SupabaseLogger.logResponse('SELECT', null, duration: stopwatch.elapsed, error: e.toString());
      rethrow;
    }
  }
}