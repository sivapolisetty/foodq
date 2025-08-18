import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service for managing app settings and secrets
class EnvironmentConfig {
  /// Initialize environment configuration
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file doesn't exist, continue with default values
      print('Warning: .env file not found, using default values');
    }
  }

  /// Environment detection - keep using production Supabase for OAuth (following NoenCircles pattern)
  static const bool useLocalSupabase = false; // Keep false to use production OAuth like NoenCircles

  /// Supabase Configuration - switches between local and production (following NoenCircles pattern)
  static String get supabaseUrl => useLocalSupabase
      ? 'http://127.0.0.1:58321' // Local Supabase
      : 'https://zobhorsszzthyljriiim.supabase.co'; // Production Supabase Cloud
  
  static String get supabaseAnonKey => useLocalSupabase
      ? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' // Local anon key
      : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5ODIzNzYsImV4cCI6MjA2OTU1ODM3Nn0.91GlHZxmJGg5E-T2iR5rzgLrQJzNPNW-SzS2VhqlymA'; // Production anon key

  /// Database Configuration
  static String? get databaseUrl => dotenv.env['DATABASE_URL'];

  /// Firebase Configuration (currently disabled)
  static String? get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'];
  static String? get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'];

  /// Stripe Configuration (for future payment integration)
  static String? get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  static String? get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'];

  /// Environment Settings
  static String get environment => 
      dotenv.env['ENVIRONMENT'] ?? 'development';
  
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  /// API Configuration (Cloudflare Pages)
  static String get apiBaseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8788';
  
  static int get apiTimeout => 
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30000;
  
  static int get maxRetryAttempts => 
      int.tryParse(dotenv.env['MAX_RETRY_ATTEMPTS'] ?? '') ?? 3;

  /// Location Services Configuration
  static double get defaultSearchRadiusKm => 
      double.tryParse(dotenv.env['DEFAULT_SEARCH_RADIUS_KM'] ?? '') ?? 10.0;
  
  static double get maxSearchRadiusKm => 
      double.tryParse(dotenv.env['MAX_SEARCH_RADIUS_KM'] ?? '') ?? 50.0;

  /// App Configuration
  static String get appName => 
      dotenv.env['APP_NAME'] ?? 'grabeat';
  
  static String get appVersion => 
      dotenv.env['APP_VERSION'] ?? '1.0.0';

  /// Debug Configuration
  static bool get debugMode => 
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  static bool get enableLogging => 
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';

  /// Validation Methods
  static bool get hasValidSupabaseConfig => 
      supabaseUrl.isNotEmpty && 
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('your-project-id') &&
      !supabaseAnonKey.contains('your-anon-key');

  static bool get hasValidApiConfig => 
      apiBaseUrl.isNotEmpty;

  static bool get hasValidStripeConfig => 
      stripePublishableKey != null && 
      stripeSecretKey != null &&
      stripePublishableKey!.isNotEmpty &&
      stripeSecretKey!.isNotEmpty;

  /// Debug Information
  static Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'apiConfigured': hasValidApiConfig,
    'supabaseConfigured': hasValidSupabaseConfig,
    'stripeConfigured': hasValidStripeConfig,
    'debugMode': debugMode,
    'enableLogging': enableLogging,
    'apiTimeout': apiTimeout,
    'defaultSearchRadius': defaultSearchRadiusKm,
    'apiBaseUrl': apiBaseUrl,
  };

  /// Print configuration status (development only)
  static void printConfigStatus() {
    if (!isDevelopment) return;
    
    print('🚀 grabeat Environment Configuration (NoenCircles Pattern):');
    print('   Environment: $environment');
    print('   Debug Mode: $debugMode');
    print('   API: ${hasValidApiConfig ? '✅ Configured' : '❌ Using defaults'}');
    print('     - URL: $apiBaseUrl (Local Cloudflare Pages Functions)');
    print('   Supabase: ${hasValidSupabaseConfig ? '✅ Production Cloud Connected' : '❌ Using defaults'}');
    print('     - URL: $supabaseUrl (${useLocalSupabase ? 'Local' : 'Production Cloud'})');
    print('   Authentication: Supabase Cloud OAuth (following NoenCircles pattern)');
    print('   Stripe: ${hasValidStripeConfig ? '✅ Configured' : '❌ Not configured'}');
  }
}