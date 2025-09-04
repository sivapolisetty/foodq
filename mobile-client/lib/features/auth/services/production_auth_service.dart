import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/enums/user_type.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import 'auth_logger.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductionAuthService {
  final SupabaseClient _supabase;
  
  ProductionAuthService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Get current authenticated user with profile
  Future<AppUser?> getCurrentUser() async {
    try {
      print('🔄 ProductionAuthService.getCurrentUser() - Starting');
      AuthLogger.logAuthEvent('Getting current user');
      
      final user = _supabase.auth.currentUser;
      print('👤 Current user from Supabase: ${user?.id} (${user?.email})');
      AuthLogger.logUserState(user, context: 'getCurrentUser');
      
      if (user == null) {
        print('❌ No current user, returning null');
        return null;
      }

      print('🌐 Making API call to fetch user profile: /api/users/${user.id}');
      AuthLogger.logAuthEvent('Fetching user profile via API', data: {
        'user_id': user.id,
      });

      // Get user profile from API (not direct database)
      final response = await _getWithOptionalAuth<Map<String, dynamic>>(
        '/api/users/${user.id}',
      );

      print('📡 API Response received:');
      print('   Success: ${response.success}');
      print('   Status Code: ${response.statusCode}');
      print('   Error: ${response.error}');
      print('   Has Data: ${response.data != null}');
      print('   Data Keys: ${response.data?.keys.toList()}');

      AuthLogger.logAuthEvent('Profile API response received', data: {
        'success': response.success,
        'statusCode': response.statusCode,
        'error': response.error,
        'hasData': response.data != null,
      });

      if (response.success && response.data != null) {
        print('✅ Profile found via API - mapping to AppUser');
        print('📋 Raw profile data from API:');
        print('   - id: ${response.data!['id']}');
        print('   - email: ${response.data!['email']}');
        print('   - full_name: ${response.data!['full_name']}');
        print('   - user_type: ${response.data!['user_type']}');
        print('   - business_id: ${response.data!['business_id']}');
        print('   - business_name: ${response.data!['business_name']}');
        
        AuthLogger.logAuthEvent('Profile found via API', data: {
          'profile_data': response.data,
        });
        final appUser = _mapToAppUser(response.data!, user);
        print('👤 Mapped AppUser details:');
        print('   - ID: ${appUser.id}');
        print('   - Email: ${appUser.email}');
        print('   - Name: "${appUser.name}"');
        print('   - Type: ${appUser.userType}');
        return appUser;
      } else {
        print('⚠️  Profile API call failed or no data');
        // Check the specific error to determine if it's "no profile" vs other issues
        if (response.statusCode == 404 || response.statusCode == 500) {
          print('🔄 User has no profile (${response.statusCode}) - creating from JWT metadata');
          // User doesn't have a profile yet - create one from JWT metadata
          // This handles both 404 (not found) and 500 (database error) cases
          AuthLogger.logAuthEvent('User has no profile (${response.statusCode}) - creating from JWT metadata', data: {
            'user_id': user.id,
            'error': response.error,
          });
          final newUser = await _createAppUserFromJWT(user);
          print('👤 Created new user from JWT: ${newUser?.id} (${newUser?.userType})');
          return newUser;
        } else if (response.statusCode == 401) {
          print('🔐 Authentication failed - token expired or invalid');
          // Authentication failed - token expired or invalid
          AuthLogger.logAuthError('getCurrentUser authentication failed', 'JWT token expired or invalid: ${response.error}');
          // Don't sign out automatically - let Supabase handle token refresh
          // Instead, throw an error so the auth wrapper can handle it properly
          throw Exception('Authentication failed: ${response.error}');
        } else {
          print('💥 API error - Status: ${response.statusCode}, Error: ${response.error}');
          // Other error (500, network, etc.) - log it but don't force onboarding
          AuthLogger.logAuthError('getCurrentUser API error', 'API call failed: ${response.statusCode} - ${response.error}');
          // For other errors, we don't know if the user has a profile or not
          // It's better to let them try again rather than force onboarding
          throw Exception('Unable to check user profile: ${response.error}');
        }
      }
    } catch (e) {
      print('💥 Exception in getCurrentUser: $e');
      print('   Type: ${e.runtimeType}');
      AuthLogger.logAuthError('getCurrentUser', e);
      // Re-throw the exception so the auth wrapper can handle it properly
      // instead of returning null which triggers onboarding
      rethrow;
    }
  }

  /// Create user profile after successful authentication
  Future<AppUser?> _createUserProfile(User user) async {
    try {
      AuthLogger.logAuthEvent('Creating user profile', data: {'user_id': user.id});
      
      // Get stored role selection (from login screen)
      final prefs = await SharedPreferences.getInstance();
      final selectedRole = prefs.getString('selected_role') ?? 'customer';
      
      AuthLogger.logAuthEvent('Role selection retrieved', data: {'role': selectedRole});
      
      // Extract name from user metadata
      final fullName = user.userMetadata?['full_name'] ?? 
                       user.userMetadata?['name'] ?? 
                       user.email?.split('@')[0] ?? 
                       'User';

      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': fullName,
        'user_type': selectedRole,
        'avatar_url': user.userMetadata?['avatar_url'],
      };

      AuthLogger.logAuthEvent('Creating profile via API', data: {
        'endpoint': '/users/profile',
        'data': profileData,
      });

      // Create profile via API (not direct database)
      final response = await ApiService.post<Map<String, dynamic>>(
        '/api/users/profile',
        body: profileData,
      );

      if (response.success && response.data != null) {
        AuthLogger.logAuthEvent('Profile created successfully via API');
        
        // Clear stored role selection
        await prefs.remove('selected_role');

        return _mapToAppUser(response.data!, user);
      } else {
        throw Exception('Failed to create user profile: ${response.error}');
      }
    } catch (e) {
      AuthLogger.logAuthError('_createUserProfile', e);
      return null;
    }
  }

  /// Store selected role for after OAuth callback
  Future<void> storeSelectedRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_role', role);
  }

  /// Check if user needs onboarding (business users)
  Future<bool> needsOnboarding(AppUser user) async {
    final status = await getOnboardingStatus(user);
    return status.needsOnboarding;
  }

  /// Get raw onboarding status response (for business ID extraction)
  Future<Map<String, dynamic>> getOnboardingStatusRaw(String userId) async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        '/api/users/$userId/onboarding-status',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.error,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get comprehensive onboarding status information
  Future<OnboardingStatus> getOnboardingStatus(AppUser user) async {
    print('🔍 ===== ONBOARDING STATUS CHECK =====');
    print('🔍 User ID: ${user.id}');
    print('🔍 User email: ${user.email}');
    print('🔍 User type: ${user.userType}');
    print('🔍 User name: ${user.name}');
    
    if (user.userType != UserType.business) {
      print('🔍 User is CUSTOMER type - checking if profile is complete');
      
      // For customers, check if they have complete profile data
      bool hasCompleteName = user.name != null && user.name!.isNotEmpty && user.name != 'User';
      bool hasCompleteEmail = user.email != null && user.email!.isNotEmpty;
      
      print('🔍 Customer profile check:');
      print('   - Has complete name: $hasCompleteName (name: "${user.name}")');
      print('   - Has complete email: $hasCompleteEmail (email: "${user.email}")');
      
      bool needsOnboarding = !hasCompleteName || !hasCompleteEmail;
      
      print('🔍 Customer needs onboarding: $needsOnboarding');
      
      return OnboardingStatus(
        needsOnboarding: needsOnboarding,
        hasBusiness: false,
        isBusinessApproved: false,
      );
    }

    try {
      print('🌐 Business user - checking if they have business data in profile');
      
      // First check if we already have complete business data in the user profile
      if (user.isBusiness && user.businessId != null && user.businessName != null) {
        print('🏢 User already has business data in profile:');
        print('   Business ID: ${user.businessId}');
        print('   Business Name: ${user.businessName}');
        print('   User Name: ${user.name}');
        
        // If user has business data, they've completed onboarding
        print('✅ Business user has complete profile data - no onboarding needed');
        return OnboardingStatus(
          needsOnboarding: false,
          hasBusiness: true,
          businessName: user.businessName,
          isBusinessApproved: true, // Assume approved if they have business data
          businessCreatedAt: null,
        );
      }
      
      print('🌐 Checking onboarding status via API: /api/users/${user.id}/onboarding-status');
      AuthLogger.logAuthEvent('Checking onboarding status via API', data: {
        'user_id': user.id,
        'user_type': user.userType,
      });

      // Check onboarding status via API
      final response = await _getWithOptionalAuth<Map<String, dynamic>>(
        '/api/users/${user.id}/onboarding-status',
      );

      print('📡 Onboarding status API response:');
      print('   Success: ${response.success}');
      print('   Status Code: ${response.statusCode}');
      print('   Data: ${response.data}');
      print('   Error: ${response.error}');

      if (response.success && response.data != null) {
        final data = response.data!;
        print('📋 Parsing API data:');
        print('   Raw data: $data');
        print('   needs_onboarding: ${data['needs_onboarding']}');
        print('   has_business: ${data['has_business']}');
        print('   business_status: ${data['business_status']}');
        
        final needsOnboarding = data['needs_onboarding'] ?? true;
        final hasBusiness = data['has_business'] ?? false;
        final businessStatus = data['business_status'] as Map<String, dynamic>?;
        
        print('🏢 Business status details:');
        print('   businessStatus: $businessStatus');
        print('   is_approved: ${businessStatus?['is_approved']}');
        print('   onboarding_completed: ${businessStatus?['onboarding_completed']}');
        
        // Override needsOnboarding if business has onboarding_completed = true
        bool finalNeedsOnboarding = needsOnboarding;
        if (businessStatus != null && businessStatus['onboarding_completed'] == true) {
          print('🎉 Business has onboarding_completed = true, overriding needs_onboarding to false');
          finalNeedsOnboarding = false;
        }
        
        print('✅ Final onboarding status: needs_onboarding = $finalNeedsOnboarding');
        AuthLogger.logAuthEvent('Onboarding status retrieved', data: {
          'needs_onboarding': finalNeedsOnboarding,
          'has_business': hasBusiness,
          'business_status': businessStatus,
          'onboarding_completed_override': businessStatus?['onboarding_completed'],
        });
        
        final onboardingStatus = OnboardingStatus(
          needsOnboarding: finalNeedsOnboarding,
          hasBusiness: hasBusiness || (businessStatus != null),
          businessName: businessStatus?['name'],
          isBusinessApproved: businessStatus?['is_approved'] ?? false,
          businessCreatedAt: businessStatus?['created_at'],
        );
        
        print('🔍 Final OnboardingStatus:');
        print('   needsOnboarding: ${onboardingStatus.needsOnboarding}');
        print('   hasBusiness: ${onboardingStatus.hasBusiness}');
        print('   isBusinessApproved: ${onboardingStatus.isBusinessApproved}');
        print('   isWaitingForApproval: ${onboardingStatus.isWaitingForApproval}');
        print('   isBusinessActive: ${onboardingStatus.isBusinessActive}');
        
        return onboardingStatus;
      } else {
        print('⚠️  API call failed, checking if we can determine from user data');
        print('⚠️  Response: success=${response.success}, statusCode=${response.statusCode}, error=${response.error}');
        
        // If API fails but user has business data, assume they're complete
        if (user.isBusiness && user.businessName != null) {
          print('🏢 API failed but user has business data - assuming complete');
          return OnboardingStatus(
            needsOnboarding: false,
            hasBusiness: true,
            businessName: user.businessName,
            isBusinessApproved: true,
            businessCreatedAt: null,
          );
        }
        
        AuthLogger.logAuthError('getOnboardingStatus', 'API call failed: ${response.error}');
        return OnboardingStatus.needsOnboarding(); // Assume needs onboarding on error
      }
    } catch (e, stackTrace) {
      print('💥 Exception in getOnboardingStatus: $e');
      print('💥 Stack trace: $stackTrace');
      
      // If exception but user has business data, assume they're complete
      if (user.isBusiness && user.businessName != null) {
        print('🏢 Exception but user has business data - assuming complete');
        return OnboardingStatus(
          needsOnboarding: false,
          hasBusiness: true,
          businessName: user.businessName,
          isBusinessApproved: true,
          businessCreatedAt: null,
        );
      }
      
      AuthLogger.logAuthError('getOnboardingStatus', e);
      return OnboardingStatus.needsOnboarding(); // Assume needs onboarding on error
    }
  }

  /// Mark restaurant onboarding as completed
  Future<void> completeRestaurantOnboarding(String userId) async {
    try {
      AuthLogger.logAuthEvent('Completing onboarding via API', data: {
        'user_id': userId,
      });

      // Complete onboarding via API
      final response = await _postWithOptionalAuth<Map<String, dynamic>>(
        '/api/users/$userId/complete-onboarding',
        body: {
          'onboarding_completed': true,
        },
      );

      if (response.success) {
        AuthLogger.logAuthEvent('Onboarding completed successfully');
      } else {
        throw Exception('Failed to complete onboarding: ${response.error}');
      }
    } catch (e) {
      AuthLogger.logAuthError('completeRestaurantOnboarding', e);
      rethrow;
    }
  }

  /// Sign out current user and clear all local data
  Future<void> signOut() async {
    try {
      print('🚪 Starting complete logout process...');
      AuthLogger.logAuthEvent('Starting complete logout');
      
      // 1. Clear Supabase session
      await _supabase.auth.signOut();
      print('✅ Supabase session cleared');
      
      // 2. Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ SharedPreferences cleared');
      
      AuthLogger.logAuthEvent('Complete logout successful');
      print('🎉 Complete logout process finished');
    } catch (e) {
      print('💥 Error during logout: $e');
      AuthLogger.logAuthError('signOut', e);
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    AuthLogger.logAuthEvent('Updating profile via API', data: {
      'user_id': user.id,
      'updates': updates,
    });

    // Update profile via API
    final response = await _putWithOptionalAuth<Map<String, dynamic>>(
      '/api/users/${user.id}',
      body: updates,
    );

    if (response.success) {
      AuthLogger.logAuthEvent('Profile updated successfully');
    } else {
      throw Exception('Failed to update profile: ${response.error}');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Listen to auth state changes
  Stream<User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange
        .map((data) => data.session?.user);
  }

  /// Complete user onboarding with profile data
  Future<bool> completeUserOnboarding(Map<String, dynamic> profileData) async {
    try {
      AuthLogger.logAuthEvent('Creating user profile via API during onboarding', data: {
        'profile_data': profileData,
      });

      // Create profile via API
      final response = await _postWithOptionalAuth<Map<String, dynamic>>(
        '/api/users/profile',
        body: profileData,
      );

      if (response.success) {
        AuthLogger.logAuthEvent('User profile created successfully during onboarding');
        return true;
      } else {
        throw Exception('Failed to create user profile: ${response.error}');
      }
    } catch (e) {
      AuthLogger.logAuthError('completeUserOnboarding', e);
      return false;
    }
  }

  /// Map database profile to AppUser
  AppUser _mapToAppUser(Map<String, dynamic> profile, User user) {
    final userType = profile['user_type'] ?? 'customer';
    
    if (userType == 'business') {
      return AppUser.business(
        id: profile['id'],
        name: profile['business_name'] ?? profile['full_name'] ?? 'Business User',
        email: profile['email'] ?? user.email ?? '',
        businessId: profile['business_id'] ?? profile['id'], // Use profile ID as fallback
        businessName: profile['business_name'],
        profileImageUrl: profile['avatar_url'],
        phone: profile['phone'],
      );
    } else {
      return AppUser.customer(
        id: profile['id'],
        name: profile['full_name'] ?? 'Customer',
        email: profile['email'] ?? user.email ?? '',
        profileImageUrl: profile['avatar_url'],
        phone: profile['phone'],
      );
    }
  }

  /// Create user profile from JWT metadata when API profile doesn't exist
  Future<AppUser?> _createAppUserFromJWT(User user) async {
    try {
      AuthLogger.logAuthEvent('Creating user profile from JWT metadata', data: {
        'user_id': user.id,
        'user_metadata': user.userMetadata,
      });

      final metadata = user.userMetadata;
      if (metadata == null) {
        AuthLogger.logAuthError('_createAppUserFromJWT', 'No user metadata available');
        return null;
      }

      // Determine user type from JWT metadata (from role selection)
      final selectedRole = metadata['selected_role'] as String?;
      String userType = 'customer'; // Default
      
      if (selectedRole == 'business') {
        userType = 'business';
      }

      // Extract name from metadata
      final fullName = metadata['full_name'] ?? 
                       metadata['name'] ?? 
                       user.email?.split('@')[0] ?? 
                       'User';

      // Create profile via API
      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': fullName,
        'user_type': userType,
        'avatar_url': metadata['avatar_url'],
        'phone': metadata['phone'],
      };

      final response = await _postWithOptionalAuth<Map<String, dynamic>>(
        '/api/users/profile',
        body: profileData,
      );

      if (response.success && response.data != null) {
        AuthLogger.logAuthEvent('User profile created successfully from JWT');
        return _mapToAppUser(response.data!, user);
      } else {
        AuthLogger.logAuthError('_createAppUserFromJWT', 'Failed to create profile: ${response.error}');
        return null;
      }
    } catch (e) {
      AuthLogger.logAuthError('_createAppUserFromJWT', e);
      return null;
    }
  }

  /// GET request with optional authentication
  Future<ApiResponse<T>> _getWithOptionalAuth<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final uriWithQuery = queryParameters != null 
          ? uri.replace(queryParameters: queryParameters)
          : uri;
      
      final headers = ApiConfig.headersWithOptionalAuth;
      
      print('🌐 Making GET request:');
      print('   URL: $uriWithQuery');
      print('   Headers: ${headers.keys.toList()}');
      print('   Has Auth: ${headers.containsKey('Authorization')}');

      final response = await http.get(
        uriWithQuery,
        headers: headers,
      ).timeout(ApiConfig.defaultTimeout);

      print('📡 GET Response:');
      print('   Status: ${response.statusCode}');
      print('   Body length: ${response.body.length}');
      print('   Body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      return _handleHttpResponse<T>(response, fromJson);
    } catch (e) {
      print('💥 Network error in _getWithOptionalAuth: $e');
      return ApiResponse<T>(
        success: false,
        error: 'Network error: ${e.toString()}',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// POST request with optional authentication
  Future<ApiResponse<T>> _postWithOptionalAuth<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}$endpoint';

      final response = await http.post(
        Uri.parse(url),
        headers: ApiConfig.headersWithOptionalAuth,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.defaultTimeout);

      return _handleHttpResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Network error: ${e.toString()}',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// PUT request with optional authentication
  Future<ApiResponse<T>> _putWithOptionalAuth<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: ApiConfig.headersWithOptionalAuth,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(ApiConfig.defaultTimeout);

      return _handleHttpResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Network error: ${e.toString()}',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// Handle HTTP response and parse JSON (similar to ApiService._handleResponse)
  ApiResponse<T> _handleHttpResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final dynamic decodedData = jsonDecode(response.body);
      
      // Check if the API returned an error status
      if (response.statusCode >= 400) {
        // For error responses, we expect a map with error details
        if (decodedData is Map<String, dynamic>) {
          return ApiResponse<T>(
            success: false,
            error: decodedData['error'] ?? 'HTTP ${response.statusCode} error',
            code: decodedData['code'] ?? 'HTTP_ERROR',
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<T>(
            success: false,
            error: 'HTTP ${response.statusCode} error',
            code: 'HTTP_ERROR',
            statusCode: response.statusCode,
          );
        }
      }

      // Handle both object and array responses
      if (decodedData is Map<String, dynamic>) {
        // Response is already wrapped in success/error format
        final apiResponse = ApiResponse.fromJson(decodedData, fromJson);
        // Add status code to the response
        return ApiResponse<T>(
          success: apiResponse.success,
          data: apiResponse.data,
          error: apiResponse.error,
          code: apiResponse.code,
          statusCode: response.statusCode,
        );
      } else if (decodedData is List) {
        // Response is a direct array, wrap it in success format
        return ApiResponse<T>(
          success: true,
          data: fromJson != null ? fromJson(decodedData) : decodedData as T,
          statusCode: response.statusCode,
        );
      } else {
        // Unknown response format
        return ApiResponse<T>(
          success: false,
          error: 'Unexpected response format',
          code: 'PARSE_ERROR',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Failed to parse response: ${e.toString()}',
        code: 'PARSE_ERROR',
      );
    }
  }
}

/// Comprehensive onboarding status information
class OnboardingStatus {
  final bool needsOnboarding;
  final bool hasBusiness;
  final String? businessName;
  final bool isBusinessApproved;
  final String? businessCreatedAt;

  const OnboardingStatus({
    required this.needsOnboarding,
    required this.hasBusiness,
    this.businessName,
    required this.isBusinessApproved,
    this.businessCreatedAt,
  });

  /// Customer user - no onboarding needed
  factory OnboardingStatus.customerUser() {
    return const OnboardingStatus(
      needsOnboarding: false,
      hasBusiness: false,
      isBusinessApproved: false,
    );
  }

  /// Business user needs onboarding
  factory OnboardingStatus.needsOnboarding() {
    return const OnboardingStatus(
      needsOnboarding: true,
      hasBusiness: false,
      isBusinessApproved: false,
    );
  }

  /// Business user has completed onboarding and is waiting for approval
  bool get isWaitingForApproval => !needsOnboarding && hasBusiness && !isBusinessApproved;
  
  /// Business user is fully approved and active
  bool get isBusinessActive => !needsOnboarding && hasBusiness && isBusinessApproved;
}