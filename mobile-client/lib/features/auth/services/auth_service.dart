import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/auth_result.dart';
import '../../../shared/models/user_role.dart';
import '../../../core/services/api_service.dart';

class AuthService {
  final SupabaseClient _supabaseClient;

  AuthService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const AuthResult.failure('Sign in failed: No user returned');
      }

      final user = await _getUserProfile(response.user!.id);
      if (user == null) {
        return const AuthResult.failure('Failed to load user profile');
      }

      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.failure('Sign in failed: ${e.message}');
    } catch (e) {
      return AuthResult.failure('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign up with email, password, and full name
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    UserRole role = UserRole.customer,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const AuthResult.failure('Sign up failed: No user returned');
      }

      // Create user profile
      final profileData = {
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': role.value,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Create profile via API instead of direct database call
      final response = await ApiService.post<Map<String, dynamic>>(
        '/api/users',
        body: profileData,
      );
      
      if (!response.success) {
        throw Exception('Failed to create profile: ${response.error}');
      }

      final user = AppUser.customer(
        id: response.user!.id,
        name: fullName,
        email: email,
        phone: phone,
      );

      return AuthResult.success(user);
    } on AuthException catch (e) {
      return AuthResult.failure('Sign up failed: ${e.message}');
    } catch (e) {
      return AuthResult.failure('Sign up failed: ${e.toString()}');
    }
  }

  /// Switch user role (for business toggle)
  Future<AuthResult> switchUserRole(UserRole newRole) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const AuthResult.failure('User not authenticated');
      }

      // Update role via API
      final response = await ApiService.put<Map<String, dynamic>>(
        '/api/users/${currentUser.id}',
        body: {
          'role': newRole.value,
        },
      );
      
      if (!response.success) {
        throw Exception('Failed to update user role: ${response.error}');
      }

      final user = await _getUserProfile(currentUser.id);
      if (user == null) {
        return const AuthResult.failure('Failed to load updated user profile');
      }

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Failed to switch role: ${e.toString()}');
    }
  }

  /// Sign in with Google OAuth via Supabase
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:8081/auth/callback',
      );
      return response;
    } catch (e) {
      print('Google sign-in error: $e');
      return false;
    }
  }

  /// Sign in with magic link
  Future<AuthResult> signInWithMagicLink({required String email}) async {
    try {
      await _supabaseClient.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'http://localhost:8081/auth/callback',
      );
      return const AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.failure('Magic link failed: ${e.message}');
    } catch (e) {
      return AuthResult.failure('Magic link failed: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  /// Get current authenticated user
  Future<AppUser?> getCurrentUser() async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return null;

      return await _getUserProfile(currentUser.id);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated => _supabaseClient.auth.currentUser != null;

  /// Get user profile via API
  Future<AppUser?> _getUserProfile(String userId) async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        '/api/users/$userId',
      );

      if (!response.success || response.data == null) {
        return null;
      }

      final profileData = response.data!;

      return AppUser.customer(
        id: profileData['id'],
        name: profileData['full_name'] ?? profileData['name'] ?? '',
        email: profileData['email'] ?? '',
        phone: profileData['phone'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return const AuthResult.failure('User not authenticated');
      }

      final updates = <String, dynamic>{};

      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      // Update profile via API
      final response = await ApiService.put<Map<String, dynamic>>(
        '/api/users/${currentUser.id}',
        body: updates,
      );
      
      if (!response.success) {
        throw Exception('Failed to update profile: ${response.error}');
      }

      final user = await _getUserProfile(currentUser.id);
      if (user == null) {
        return const AuthResult.failure('Failed to load updated user profile');
      }

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  /// Listen to auth state changes
  Stream<AppUser?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;
      
      return await _getUserProfile(user.id);
    });
  }
}