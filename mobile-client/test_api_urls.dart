import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/core/config/environment_config.dart';
import 'lib/core/config/api_config.dart';

/// Test script to verify API URL generation for different environments
void main() async {
  print('🧪 Testing API URL Generation\n');
  
  // Test QA Environment
  await testEnvironment('.env.qa', 'QA Environment');
  
  // Test Production Environment  
  await testEnvironment('.env.production', 'Production Environment');
  
  // Test with missing .env (fallback to defaults)
  await testEnvironment('.env.missing', 'Default Fallback');
}

Future<void> testEnvironment(String envFile, String environmentName) async {
  print('📋 $environmentName ($envFile)');
  print('${'=' * 50}');
  
  try {
    // Load the specific environment file
    if (envFile != '.env.missing') {
      await dotenv.load(fileName: envFile);
    } else {
      // Test fallback behavior
      dotenv.testLoad(fileInput: 'ENVIRONMENT=development\n');
    }
    
    // Initialize environment config
    await EnvironmentConfig.initialize();
    
    // Print configuration
    print('Base URL: ${EnvironmentConfig.apiBaseUrl}');
    print('Environment: ${EnvironmentConfig.environment}');
    
    // Print generated URLs
    print('\nGenerated API URLs:');
    print('  Deals: ${ApiConfig.dealsUrl}');
    print('  Users: ${ApiConfig.usersUrl}');
    print('  Businesses: ${ApiConfig.businessesUrl}');
    print('  Orders: ${ApiConfig.ordersUrl}');
    
    // Test specific endpoint with parameters
    const businessId = '4aef106d-9c91-40a1-a738-f29a21195ab9';
    const testUrl = '${ApiConfig.dealsUrl}?limit=100&offset=0&business_id=$businessId';
    print('\nTest URL (the one causing CORS issues):');
    print('  $testUrl');
    
    // Verify URL structure
    print('\nURL Analysis:');
    final uri = Uri.parse(testUrl);
    print('  Protocol: ${uri.scheme}');
    print('  Host: ${uri.host}');
    print('  Path: ${uri.path}');
    print('  Query: ${uri.query}');
    
    // Check if /api is present in the path
    final hasApiPrefix = uri.path.startsWith('/api/');
    print('  Has /api prefix: ${hasApiPrefix ? '✅ YES' : '❌ NO'}');
    
    if (!hasApiPrefix && uri.host.contains('foodq.pages.dev')) {
      print('  ⚠️  WARNING: Missing /api prefix for QA environment!');
    }
    
  } catch (e) {
    print('❌ Error testing $envFile: $e');
  }
  
  print('\n');
}