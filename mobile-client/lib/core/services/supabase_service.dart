import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/environment_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvironmentConfig.supabaseUrl,
      anonKey: EnvironmentConfig.supabaseAnonKey,
    );
  }
  
  /// Check if Supabase is properly configured
  static bool get isConfigured => EnvironmentConfig.hasValidSupabaseConfig;
  
  /// Get configuration status for debugging
  static Map<String, dynamic> get configStatus => {
    'isConfigured': isConfigured,
    'url': EnvironmentConfig.supabaseUrl,
    'hasValidCredentials': EnvironmentConfig.hasValidSupabaseConfig,
  };
}

// Provider for Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});