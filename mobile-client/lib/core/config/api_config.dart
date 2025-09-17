import 'package:supabase_flutter/supabase_flutter.dart';
import 'environment_config.dart';

/// API Configuration for FoodQ
/// 
/// Centralized configuration for Cloudflare Worker API endpoints
/// and related constants.

class ApiConfig {
  // Base URLs for different environments
  static const String _prodApiUrl = 'https://foodq.pages.dev/api';
  static const String _devApiUrl = 'http://localhost:8788';

  // Current environment API URL (loaded from .env file)
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;

  // No longer using API keys - authentication is handled by Supabase JWT tokens

  // API Endpoints (no additional prefix needed, baseUrl includes /api)
  static const String dealsEndpoint = '/deals';
  static const String businessesEndpoint = '/businesses';
  static const String usersEndpoint = '/users';
  static const String ordersEndpoint = '/orders';
  static const String uploadEndpoint = '/upload';
  static const String restaurantOnboardingEndpoint = '/restaurant-onboarding';
  
  // User interaction endpoints
  static const String userInteractionsEndpoint = '/users/me/interactions';
  static const String userMissedDealsEndpoint = '/users/me/missed-deals';
  static const String userExpiredDealsEndpoint = '/users/me/expired-deals';
  static const String nearbyDealsEndpoint = '/deals/nearby';
  static const String trendingDealsEndpoint = '/deals/trending';
  static const String endingSoonDealsEndpoint = '/deals/ending-soon';

  // Full URLs
  static String get dealsUrl => '$baseUrl$dealsEndpoint';
  static String get businessesUrl => '$baseUrl$businessesEndpoint';
  static String get usersUrl => '$baseUrl$usersEndpoint';
  static String get ordersUrl => '$baseUrl$ordersEndpoint';
  static String get uploadUrl => '$baseUrl$uploadEndpoint';
  static String get restaurantOnboardingUrl => '$baseUrl$restaurantOnboardingEndpoint';
  
  // User interaction URLs
  static String get userInteractionsUrl => '$baseUrl$userInteractionsEndpoint';
  static String get userMissedDealsUrl => '$baseUrl$userMissedDealsEndpoint';
  static String get userExpiredDealsUrl => '$baseUrl$userExpiredDealsEndpoint';
  static String get nearbyDealsUrl => '$baseUrl$nearbyDealsEndpoint';
  static String get trendingDealsUrl => '$baseUrl$trendingDealsEndpoint';
  static String get endingSoonDealsUrl => '$baseUrl$endingSoonDealsEndpoint';

  // Deal-specific endpoints
  static String dealByIdUrl(String dealId) => '$dealsUrl/$dealId';
  static String dealsByBusinessUrl(String businessId) => '$dealsUrl/business/$businessId';
  
  // Order-specific endpoints
  static String orderByIdUrl(String orderId) => '$ordersUrl/$orderId';
  static String ordersByCustomerUrl(String customerId) => '$ordersUrl?customer_id=$customerId';
  static String ordersByBusinessUrl(String businessId) => '$ordersUrl?business_id=$businessId';
  
  // User-specific endpoints
  static String userByIdUrl(String userId) => '$usersUrl/$userId';
  
  // Restaurant onboarding endpoints
  static String restaurantOnboardingByIdUrl(String requestId) => '$restaurantOnboardingUrl/$requestId';
  static String restaurantOnboardingByUserUrl(String userId) => '$restaurantOnboardingUrl/user/$userId';
  
  // Business-specific endpoints
  static String businessByIdUrl(String businessId) => '$businessesUrl/$businessId';
  static String businessByOwnerUrl(String ownerId) => '$businessesUrl/owner/$ownerId';
  
  // Places API endpoints  
  static String get placesAutocompleteUrl => '$baseUrl/places/autocomplete';
  static String get placesDetailsUrl => '$baseUrl/places/details';
  
  // Note: User-specific expired deals endpoints don't exist in current API
  // Use deals endpoint with appropriate filters instead:
  // - Expired deals: ${baseUrl}/deals?status=expired  
  // - User deals: ${baseUrl}/deals?user_id={userId}
  
  // Restaurant onboarding request endpoints
  static String get restaurantOnboardingRequestsUrl => '$baseUrl/restaurant-onboarding-requests';
  static String restaurantOnboardingRequestByIdUrl(String requestId) => '$restaurantOnboardingRequestsUrl/$requestId';
  static String restaurantOnboardingRequestByUserUrl(String userId) => '$restaurantOnboardingRequestsUrl/user/$userId';
  static String restaurantOnboardingRequestApproveUrl(String requestId) => '$restaurantOnboardingRequestsUrl/$requestId/approve';
  static String restaurantOnboardingRequestRejectUrl(String requestId) => '$restaurantOnboardingRequestsUrl/$requestId/reject';

  // Request timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);

  // Headers with Supabase JWT authentication
  static Map<String, String> get headers {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    final accessToken = session?.accessToken;
    
    if (accessToken == null) {
      throw Exception('Authentication required. Please sign in to continue.');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  // Headers with optional authentication
  static Map<String, String> get headersWithOptionalAuth {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    final accessToken = session?.accessToken;
    
    final baseHeaders = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (accessToken != null) {
      baseHeaders['Authorization'] = 'Bearer $accessToken';
    }
    
    return baseHeaders;
  }

  // Environment detection
  static bool get isDevelopment => baseUrl.contains('localhost');
  static bool get isProduction => !isDevelopment;

  // Validation
  static bool get isConfigured => EnvironmentConfig.hasValidApiConfig;
  
  // Debug info
  static void printDebugInfo() {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    print('🔧 API Config Debug:');
    print('   Base URL: $baseUrl');
    print('   Authentication: ${session != null ? 'Authenticated' : 'Not authenticated'}');
    print('   Environment: ${isDevelopment ? 'Development' : 'Production'}');
    print('   Is Configured: $isConfigured');
    print('   Endpoints:');
    print('     - Deals: $dealsUrl');
    print('     - Users: $usersUrl');
    print('     - Orders: $ordersUrl');
    print('     - Restaurant Onboarding: $restaurantOnboardingUrl');
  }
}