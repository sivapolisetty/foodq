/**
 * Comprehensive API Integration Tests for FoodQ
 * 
 * Tests all API endpoints end-to-end:
 * - User CRUD operations
 * - Deal CRUD operations
 * - Business operations
 * 
 * Run with: dart test test/api/api_integration_test.dart
 */

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:8800';
const String apiKey = 'local-dev-secret-key';

class ApiClient {
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-API-Key': apiKey,
  };

  static Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    print('GET $endpoint -> ${response.statusCode}: ${response.body}');
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    print('POST $endpoint -> ${response.statusCode}: ${response.body}');
    return response;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    print('PUT $endpoint -> ${response.statusCode}: ${response.body}');
    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    print('DELETE $endpoint -> ${response.statusCode}: ${response.body}');
    return response;
  }
}

void main() {
  // Test data
  late String testBusinessUserId;
  late String testCustomerUserId;
  late String testDealId;
  
  const testBusinessId = '550e8400-e29b-41d4-a716-446655440001';

  group('FoodQ API Integration Tests', () {
    setUpAll(() async {
      print('🚀 Starting API Integration Tests');
      print('Base URL: $baseUrl');
      
      // Verify API is running
      try {
        final response = await ApiClient.get('/api/deals');
        expect(response.statusCode, equals(200));
        print('✅ API is running and accessible');
      } catch (e) {
        fail('❌ API is not accessible. Make sure the Cloudflare Worker is running on port 8800');
      }
    });

    group('User API Tests', () {
      test('should create a business user', () async {
        final userData = {
          'name': 'Test Business Owner',
          'email': 'test-business-${DateTime.now().millisecondsSinceEpoch}@test.com',
          'user_type': 'business',
          'business_id': testBusinessId,
          'phone': '+1-555-TEST-001',
        };

        final response = await ApiClient.post('/api/users', userData);
        
        expect(response.statusCode, equals(201));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data']['user_type'], equals('business'));
        expect(responseData['data']['business_id'], equals(testBusinessId));
        
        testBusinessUserId = responseData['data']['id'];
        print('✅ Created business user with ID: $testBusinessUserId');
      });

      test('should create a customer user', () async {
        final userData = {
          'name': 'Test Customer',
          'email': 'test-customer-${DateTime.now().millisecondsSinceEpoch}@test.com',
          'user_type': 'customer',
          'phone': '+1-555-TEST-002',
        };

        final response = await ApiClient.post('/api/users', userData);
        
        expect(response.statusCode, equals(201));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data']['user_type'], equals('customer'));
        expect(responseData['data']['business_id'], isNull);
        
        testCustomerUserId = responseData['data']['id'];
        print('✅ Created customer user with ID: $testCustomerUserId');
      });

      test('should get all users', () async {
        final response = await ApiClient.get('/api/users');
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data'], isList);
        expect(responseData['data'].length, greaterThan(0));
        
        print('✅ Retrieved ${responseData['data'].length} users');
      });

      test('should get users by type', () async {
        final response = await ApiClient.get('/api/users?user_type=eq.business');
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data'], isList);
        
        // All returned users should be business type
        for (final user in responseData['data']) {
          expect(user['user_type'], equals('business'));
        }
        
        print('✅ Retrieved ${responseData['data'].length} business users');
      });

      test('should update a user', () async {
        final updateData = {
          'name': 'Updated Test Business Owner',
          'phone': '+1-555-UPDATED',
        };

        final response = await ApiClient.put('/api/users/$testBusinessUserId', updateData);
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data']['name'], equals('Updated Test Business Owner'));
        expect(responseData['data']['phone'], equals('+1-555-UPDATED'));
        
        print('✅ Updated user successfully');
      });

      test('should handle user creation validation errors', () async {
        final invalidUserData = {
          'name': 'Test User',
          // Missing required fields: email, user_type
        };

        final response = await ApiClient.post('/api/users', invalidUserData);
        
        expect(response.statusCode, equals(400));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isFalse);
        expect(responseData['error'], contains('required fields'));
        
        print('✅ Validation errors handled correctly');
      });

      test('should handle duplicate email validation', () async {
        final userData = {
          'name': 'Duplicate User',
          'email': 'duplicate@test.com',
          'user_type': 'customer',
        };

        // Create first user
        final response1 = await ApiClient.post('/api/users', userData);
        expect(response1.statusCode, equals(201));

        // Try to create duplicate
        final response2 = await ApiClient.post('/api/users', userData);
        expect(response2.statusCode, equals(409));
        
        final responseData = jsonDecode(response2.body);
        expect(responseData['success'], isFalse);
        expect(responseData['error'], contains('already exists'));
        
        print('✅ Duplicate email validation working');
      });
    });

    group('Deal API Tests', () {
      test('should create a deal', () async {
        final dealData = {
          'business_id': testBusinessId,
          'title': 'Test Deal - Fresh Pizza',
          'description': 'Delicious test pizza deal',
          'original_price': 15.99,
          'discounted_price': 9.99,
          'quantity_available': 10,
          'expires_at': DateTime.now().add(Duration(hours: 4)).toIso8601String(),
          'allergen_info': 'Contains gluten',
        };

        final response = await ApiClient.post('/api/deals', dealData);
        
        expect(response.statusCode, equals(201));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data']['title'], equals('Test Deal - Fresh Pizza'));
        expect(responseData['data']['business_id'], equals(testBusinessId));
        expect(responseData['data']['status'], equals('active'));
        
        testDealId = responseData['data']['id'];
        print('✅ Created deal with ID: $testDealId');
      });

      test('should get all deals', () async {
        final response = await ApiClient.get('/api/deals');
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data'], isList);
        
        print('✅ Retrieved ${responseData['data'].length} deals');
      });

      test('should get deals by business', () async {
        final response = await ApiClient.get('/api/deals?business_id=eq.$testBusinessId');
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data'], isList);
        
        // All returned deals should belong to the test business
        for (final deal in responseData['data']) {
          expect(deal['business_id'], equals(testBusinessId));
        }
        
        print('✅ Retrieved ${responseData['data'].length} deals for business');
      });

      test('should update a deal', () async {
        final updateData = {
          'title': 'Updated Test Deal - Fresh Pizza',
          'discounted_price': 8.99,
          'quantity_available': 5,
        };

        final response = await ApiClient.put('/api/deals/$testDealId', updateData);
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data']['title'], equals('Updated Test Deal - Fresh Pizza'));
        expect(responseData['data']['discounted_price'], equals(8.99));
        expect(responseData['data']['quantity_available'], equals(5));
        
        print('✅ Updated deal successfully');
      });

      test('should handle deal creation validation errors', () async {
        final invalidDealData = {
          'title': 'Invalid Deal',
          // Missing required fields: business_id, prices, etc.
        };

        final response = await ApiClient.post('/api/deals', invalidDealData);
        
        expect(response.statusCode, equals(400));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isFalse);
        
        print('✅ Deal validation errors handled correctly');
      });

      test('should handle expired deal creation', () async {
        final expiredDealData = {
          'business_id': testBusinessId,
          'title': 'Expired Deal',
          'description': 'This deal should fail',
          'original_price': 10.00,
          'discounted_price': 5.00,
          'quantity_available': 1,
          'expires_at': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(), // Past date
        };

        final response = await ApiClient.post('/api/deals', expiredDealData);
        
        expect(response.statusCode, equals(400));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isFalse);
        expect(responseData['error'], contains('future'));
        
        print('✅ Expired deal validation working');
      });

      test('should deactivate a deal', () async {
        final response = await ApiClient.delete('/api/deals/$testDealId');
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        
        print('✅ Deal deactivated successfully');
      });
    });

    group('Business API Tests', () {
      test('should get all businesses', () async {
        final response = await ApiClient.get('/api/businesses');
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data'], isList);
        expect(responseData['data'].length, greaterThan(0));
        
        print('✅ Retrieved ${responseData['data'].length} businesses');
      });

      test('should get business by ID', () async {
        final response = await ApiClient.get('/api/businesses/$testBusinessId');
        
        expect(response.statusCode, equals(200));
        
        final responseData = jsonDecode(response.body);
        expect(responseData['success'], isTrue);
        expect(responseData['data']['id'], equals(testBusinessId));
        
        print('✅ Retrieved business by ID successfully');
      });
    });

    tearDownAll(() async {
      print('🧹 Cleaning up test data...');
      
      // Clean up test users
      if (testBusinessUserId.isNotEmpty) {
        await ApiClient.delete('/api/users?id=eq.$testBusinessUserId');
        print('🗑️ Deleted test business user');
      }
      
      if (testCustomerUserId.isNotEmpty) {
        await ApiClient.delete('/api/users?id=eq.$testCustomerUserId');
        print('🗑️ Deleted test customer user');
      }
      
      print('✅ API Integration Tests completed successfully');
    });
  });
}