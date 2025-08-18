import 'dart:io';

/// Configuration for end-to-end API tests with Supabase cloud
class TestConfig {
  // Get from environment variables or create .env.test file
  static String get supabaseUrl => 
      Platform.environment['SUPABASE_TEST_URL'] ?? 
      'https://your-project.supabase.co';
  
  static String get supabaseAnonKey => 
      Platform.environment['SUPABASE_TEST_ANON_KEY'] ?? 
      'your-test-anon-key';
  
  static String get supabaseServiceKey => 
      Platform.environment['SUPABASE_TEST_SERVICE_KEY'] ?? 
      'your-test-service-key';

  // Test user credentials - use a dedicated test account
  static const String testUserEmail = 'test-owner@kravekart-e2e.com';
  static const String testUserPassword = 'TestPassword123!';
  static const String testUserId = 'test-owner-e2e-uuid'; // Will be generated
  
  // Test data prefixes to identify test data
  static const String testDataPrefix = 'E2E_TEST_';
  static const String testBusinessPrefix = 'E2E_TEST_BIZ_';
  static const String testDealPrefix = 'E2E_TEST_DEAL_';
  
  // Test configuration
  static const bool cleanupAfterTests = true;
  static const bool skipCleanupOnFailure = true;
  static const int testTimeoutSeconds = 30;
  
  static void validateConfig() {
    if (supabaseUrl.contains('your-project') || 
        supabaseAnonKey.contains('your-test')) {
      throw Exception('''
        Test configuration incomplete!
        
        Please set these environment variables:
        - SUPABASE_TEST_URL=https://your-project.supabase.co
        - SUPABASE_TEST_ANON_KEY=your-anon-key
        - SUPABASE_TEST_SERVICE_KEY=your-service-key
        
        Or create a .env.test file with these values.
        
        WARNING: Use a separate Supabase project for testing!
        These tests will create and delete real data.
      ''');
    }
  }
  
  static void printTestInfo() {
    print('🧪 E2E Test Configuration:');
    print('   Supabase URL: ${supabaseUrl.replaceAll(RegExp(r'https://(.+)\.supabase\.co'), 'https://*****.supabase.co')}');
    print('   Test User: $testUserEmail');
    print('   Cleanup After Tests: $cleanupAfterTests');
    print('   Test Timeout: ${testTimeoutSeconds}s');
    print('');
  }
}