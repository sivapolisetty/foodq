import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../services/production_auth_service.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/enums/user_type.dart';

/// Provider for production auth service (uses Workers API)
final productionAuthServiceProvider = Provider<ProductionAuthService>((ref) {
  return ProductionAuthService();
});

/// Provider for legacy auth service (direct Supabase)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for current authenticated user
final currentAuthUserProvider = StateNotifierProvider.autoDispose<AuthUserNotifier, AsyncValue<AppUser?>>((ref) {
  final authService = ref.read(authServiceProvider);
  final productionAuthService = ref.read(productionAuthServiceProvider);
  return AuthUserNotifier(authService, productionAuthService);
});

/// Auth user notifier
class AuthUserNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  AuthUserNotifier(this._authService, this._productionAuthService) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthService _authService;
  final ProductionAuthService _productionAuthService;
  StreamSubscription<AuthState>? _authSubscription;

  void _init() {
    // Listen to auth state changes from AuthService
    _authSubscription = _authService.authStateChanges.listen((authState) {
      _handleAuthStateChange(authState);
    });

    // Load initial user
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _handleAuthStateChange(AuthState authState) {
    // Only handle auth state changes if not disposed
    if (!mounted) return;
    
    switch (authState.event) {
      case AuthChangeEvent.signedIn:
        _loadCurrentUser();
        break;
      case AuthChangeEvent.signedOut:
        if (mounted) {
          state = const AsyncValue.data(null);
        }
        break;
      case AuthChangeEvent.userUpdated:
        _loadCurrentUser();
        break;
      default:
        break;
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Use ProductionAuthService for getting user data (via Workers API)
      final user = await _productionAuthService.getCurrentUser();
      
      // Only update state if not disposed
      if (mounted) {
        state = AsyncValue.data(user);
      }
    } catch (e) {
      // Only update state if not disposed
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }


  /// Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    UserType userType = UserType.customer,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        userType: userType,
        metadata: metadata,
      );

      if (response.user != null) {
        await _loadCurrentUser();
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
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadCurrentUser();
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google using Supabase OAuth
  Future<bool> signInWithGoogle() async {
    try {
      final success = await _authService.signInWithGoogle();
      
      if (success) {
        // OAuth flow launched successfully
        // User will be redirected back to app on success
        // Auth state change will be handled by AuthWrapper
      }
      
      return success;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Magic Link
  Future<void> signInWithMagicLink(String email) async {
    try {
      await _authService.signInWithMagicLink(email: email);
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
      final response = await _authService.verifyOTP(
        email: email,
        token: token,
      );
      
      if (response.user != null) {
        await _loadCurrentUser();
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current user and clear all cached data
  Future<void> signOut() async {
    try {
      // Use production auth service for comprehensive logout
      await _productionAuthService.signOut();
      
      // Immediately clear the state
      state = const AsyncValue.data(null);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      await _authService.updateProfile(updates);
      await _loadCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authUser = ref.watch(currentAuthUserProvider);
  return authUser.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// Provider to get current user type
final currentUserTypeProvider = Provider<UserType?>((ref) {
  final authUser = ref.watch(currentAuthUserProvider);
  return authUser.maybeWhen(
    data: (user) => user?.userType,
    orElse: () => null,
  );
});

/// Provider to check if current user is business
final isBusinessUserProvider = Provider<bool>((ref) {
  final userType = ref.watch(currentUserTypeProvider);
  return userType == UserType.business;
});

/// Provider to check if current user is customer
final isCustomerUserProvider = Provider<bool>((ref) {
  final userType = ref.watch(currentUserTypeProvider);
  return userType == UserType.customer;
});