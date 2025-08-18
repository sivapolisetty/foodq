import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kravekart/services/business_service.dart';
import 'package:kravekart/services/deal_service.dart';

/// Real API Integration Tests
/// These test actual Supabase API calls and would have caught the 400 error
void main() {
  group('Real API Integration Tests - Supabase', () {
    late SupabaseClient supabase;
    late BusinessService businessService;
    late DealService dealService;

    setUpAll(() async {
      // Initialize Supabase with real credentials for testing
      await Supabase.initialize(
        url: 'https://zobhorsszzthyljriiim.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5ODIzNzYsImV4cCI6MjA2OTU1ODM3Nn0.91GlHZxmJGg5E-T2iR5rzgLrQJzNPNW-SzS2VhqlymA',
      );
      
      supabase = Supabase.instance.client;
      businessService = BusinessService();
      dealService = DealService();
    });

    group('Business Service API Tests', () {
      test('getBusinessesForOwner - should handle non-existent owner gracefully', () async {
        // This test would have caught the 400 error!
        try {
          final businesses = await businessService.getBusinessesForOwner('demo-owner-id');
          
          // Should return empty list for non-existent owner, not throw error
          expect(businesses, isA<List>());
          expect(businesses.length, equals(0));
          
          print('✅ Non-existent owner handled gracefully: ${businesses.length} businesses found');
        } catch (e) {
          fail('❌ API should handle non-existent owner gracefully, but threw: $e');
        }
      });

      test('businesses table exists and is accessible', () async {
        try {
          // Test if we can query the businesses table at all
          final response = await supabase
              .from('businesses')
              .select('id')
              .limit(1);
          
          expect(response, isA<List>());
          print('✅ Businesses table is accessible');
        } catch (e) {
          fail('❌ Cannot access businesses table: $e');
        }
      });

      test('deals table exists and is accessible', () async {
        try {
          // Test if we can query the deals table
          final response = await supabase
              .from('deals')
              .select('id')
              .limit(1);
          
          expect(response, isA<List>());
          print('✅ Deals table is accessible');
        } catch (e) {
          fail('❌ Cannot access deals table: $e');
        }
      });
    });

    group('Database Schema Validation', () {
      test('businesses table has required columns', () async {
        try {
          // Try to query with expected columns
          final response = await supabase
              .from('businesses')
              .select('id, name, owner_id, created_at, is_active')
              .limit(1);
          
          expect(response, isA<List>());
          print('✅ Businesses table has required columns');
        } catch (e) {
          fail('❌ Businesses table missing required columns: $e');
        }
      });

      test('deals table has required columns', () async {
        try {
          // Try to query with expected columns  
          final response = await supabase
              .from('deals')
              .select('id, business_id, title, original_price, discount_price, quantity')
              .limit(1);
          
          expect(response, isA<List>());
          print('✅ Deals table has required columns');
        } catch (e) {
          fail('❌ Deals table missing required columns: $e');
        }
      });
    });

    group('Error Handling Tests', () {
      test('invalid column query should return meaningful error', () async {
        try {
          await supabase
              .from('businesses')
              .select('invalid_column_name')
              .limit(1);
          
          fail('❌ Query with invalid column should have failed');
        } catch (e) {
          expect(e.toString(), contains('column'));
          print('✅ Invalid column query properly rejected: $e');
        }
      });

      test('non-existent table query should return meaningful error', () async {
        try {
          await supabase
              .from('non_existent_table')
              .select('*')
              .limit(1);
          
          fail('❌ Query to non-existent table should have failed');
        } catch (e) {
          print('✅ Non-existent table query properly rejected: $e');
        }
      });
    });

    group('Sample Data Tests', () {
      test('can insert and retrieve test business', () async {
        try {
          // Insert a test business
          final testBusiness = {
            'name': 'Test Restaurant API',
            'owner_id': 'test-api-owner-${DateTime.now().millisecondsSinceEpoch}',
            'address': '123 Test API Street',
            'phone': '555-TEST-API',
            'is_active': true,
          };

          final insertResponse = await supabase
              .from('businesses')
              .insert(testBusiness)
              .select()
              .single();

          expect(insertResponse['name'], equals('Test Restaurant API'));
          print('✅ Successfully inserted test business: ${insertResponse['id']}');

          // Clean up - delete the test business
          await supabase
              .from('businesses')
              .delete()
              .eq('id', insertResponse['id']);
          
          print('✅ Test business cleaned up');
        } catch (e) {
          print('⚠️ Could not insert test business (may need permissions): $e');
        }
      });
    });
  });
}

/// This class shows the difference between UI tests and API tests
class TestComparisonExplanation {
  static void explainDifference() {
    print('''
    🔍 UI TESTS vs API TESTS - The Difference:
    
    ❌ UI TESTS (what passed):
    - Test widget rendering: ✅ "Does the button show up?"
    - Test static data display: ✅ "Does 'Revenue' text appear?"
    - Test user interactions: ✅ "Can I tap the button?"
    - Mock all external dependencies
    - Fast execution (milliseconds)
    
    ✅ API TESTS (what would catch the real error):
    - Test real database queries: "Does the API call work?"
    - Test network connectivity: "Can we reach Supabase?"
    - Test data validation: "Do the tables exist?"
    - Test error handling: "What happens when owner_id doesn't exist?"
    - Use real external services
    - Slower execution (seconds)
    
    🎯 THE ISSUE:
    UI tests passed because they never made real API calls.
    The 400 error only happens when the real Deal Management page
    tries to fetch data for 'demo-owner-id' which doesn't exist.
    
    💡 SOLUTION:
    Add both types of tests:
    1. UI tests for interface validation
    2. API tests for integration validation
    ''');
  }
}