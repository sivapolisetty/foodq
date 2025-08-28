import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/app_user.dart';
import '../../shared/enums/user_type.dart';
import 'supabase_logger.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LoggingGoTrueClient _loggingAuth = LoggingGoTrueClient(Supabase.instance.client.auth);

  /// Get current authenticated user from Supabase
  User? get currentUser => _loggingAuth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
  
  /// Get current session
  Session? get currentSession => _loggingAuth.currentSession;
  
  /// Get access token for API calls (required for all API requests)
  String? get accessToken => currentSession?.accessToken;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _loggingAuth.onAuthStateChange;

  /// Require authentication - throw if not authenticated
  void requireAuth() {
    if (!isAuthenticated) {
      throw Exception('Authentication required. Please sign in to continue.');
    }
  }

  /// Sign up new user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    UserType userType = UserType.customer,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _loggingAuth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'user_type': userType.name,
          if (metadata != null) ...metadata,
        },
      );

      if (response.user != null) {
        // Create app user record
        await _createAppUserRecord(response.user!, name, userType, metadata);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in existing user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _loggingAuth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google using Supabase OAuth
  Future<bool> signInWithGoogle() async {
    try {
      // Determine redirect URL based on platform
      String redirectUrl;
      
      // Check if running on web
      if (kIsWeb) {
        // Running on web - use current origin
        redirectUrl = Uri.base.origin;
      } else {
        // Running on mobile - use app scheme
        redirectUrl = 'com.foodqapp.foodqapp://login-callback/';
      }
      
      // Use Supabase's built-in OAuth flow
      final result = await _loggingAuth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Magic Link (passwordless)
  Future<void> signInWithMagicLink({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await _loggingAuth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP from magic link
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _loggingAuth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      // Create app user record if new user
      if (response.user != null) {
        final existingUser = await getCurrentAppUser();
        
        if (existingUser == null) {
          await _createAppUserRecord(
            response.user!,
            email.split('@')[0],
            UserType.customer,
            {'provider': 'magic_link'},
          );
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      // Sign out from Supabase (handles all OAuth providers)
      await _loggingAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current app user data
  Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('app_users')
          .select()
          .eq('id', user.id)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      // If app user record doesn't exist, create one from JWT metadata
      if (e.toString().contains('PGRST116')) {
        return await _createAppUserFromJWT(user);
      }
      return null;
    }
  }

  /// Create app user record from JWT metadata (for OAuth users)
  Future<AppUser?> _createAppUserFromJWT(User user) async {
    try {
      // Extract user info from JWT metadata
      final metadata = user.userMetadata;
      final selectedRole = metadata?['selected_role'] as String?;
      final name = metadata?['full_name'] as String? ?? 
                   metadata?['name'] as String? ?? 
                   user.email?.split('@')[0] ?? 
                   'User';
      
      // For new users, create with null user_type so they get role selection
      // Only set user_type if it was explicitly provided in metadata
      UserType? userType;
      if (selectedRole == 'business') {
        userType = UserType.business;
      } else if (selectedRole == 'customer') {
        userType = UserType.customer;
      }
      // If no selectedRole, leave userType as null for role selection

      if (userType != null) {
        // User already has a role, create the record
        await _createAppUserRecord(user, name, userType, {
          'provider': 'google',
          'profile_image_url': metadata?['avatar_url'] ?? metadata?['picture'],
          'phone': metadata?['phone'],
        });

        // Fetch the created record
        final response = await _supabase
            .from('app_users')
            .select()
            .eq('id', user.id)
            .single();

        return AppUser.fromJson(response);
      } else {
        // New user without role - return null to trigger role selection
        return null;
      }
    } catch (e) {
      print('Error creating app user from JWT: $e');
      return null;
    }
  }

  /// Check if user needs role selection
  Future<bool> needsRoleSelection() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final response = await _supabase
          .from('app_users')
          .select('user_type')
          .eq('id', user.id)
          .single();

      return false; // User exists, no role selection needed
    } catch (e) {
      // User doesn't exist in app_users table, needs role selection
      return e.toString().contains('PGRST116');
    }
  }

  /// Create app user record in database
  Future<void> _createAppUserRecord(
    User user,
    String name,
    UserType userType,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      final userData = <String, dynamic>{
        'id': user.id,
        'name': name,
        'email': user.email!,
        'user_type': userType.name,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Add metadata if provided
      if (metadata != null) {
        userData.addAll(metadata);
      }

      await _supabase.from('app_users').insert(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      updates['updated_at'] = DateTime.now().toUtc().toIso8601String();
      
      await _supabase
          .from('app_users')
          .update(updates)
          .eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _loggingAuth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}