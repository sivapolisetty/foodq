import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/production_login_screen.dart';
import '../screens/user_onboarding_screen.dart';
import '../services/production_auth_service.dart';
import '../services/auth_logger.dart';
import '../providers/auth_provider.dart';
import '../../business/screens/restaurant_onboarding_page.dart';
import '../../business/screens/business_home_screen.dart';
import '../../business/screens/business_waiting_list_screen.dart';
import '../../home/screens/customer_home_screen.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/enums/user_type.dart';
import '../../../shared/theme/app_colors.dart';
import '../../location/providers/customer_address_provider.dart';

/// Provider for production auth service
final productionAuthServiceProvider = Provider<ProductionAuthService>((ref) {
  return ProductionAuthService();
});

/// Provider for onboarding status - auto-dispose to prevent cross-user contamination
final onboardingStatusProvider = FutureProvider.family.autoDispose<OnboardingStatus, AppUser>((ref, user) async {
  print('🔍 onboardingStatusProvider called for user: ${user.id} (${user.userType})');
  final authService = ref.read(productionAuthServiceProvider);
  final status = await authService.getOnboardingStatus(user);
  print('🔍 onboardingStatusProvider result: needsOnboarding=${status.needsOnboarding}, hasBusiness=${status.hasBusiness}');
  return status;
});

/// Provider for current user state with enhanced business ID mapping and auto-retry
final authenticatedUserProvider = FutureProvider.autoDispose<AppUser?>((ref) async {
  print('🔄 currentUserProvider called - fetching current user');
  final authService = ref.read(productionAuthServiceProvider);
  
  // Try up to 3 times with automatic token refresh on auth failures
  for (int attempt = 1; attempt <= 3; attempt++) {
    try {
      var user = await authService.getCurrentUser();
      print('🔄 currentUserProvider attempt $attempt result: $user');
      
      if (user != null) {
        return await _enhanceBusinessUser(user, authService);
      }
      
      // If user is null but we have a session, token might be expired
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && attempt < 3) {
        print('🔄 User null but session exists - attempting token refresh (attempt $attempt)');
        await Supabase.instance.client.auth.refreshSession();
        await Future.delayed(Duration(milliseconds: 500)); // Brief delay after refresh
        continue; // Retry with refreshed token
      }
      
      return null;
      
    } catch (e) {
      print('🔄 currentUserProvider attempt $attempt failed: $e');
      
      // Check if it's an auth error that might be resolved with token refresh
      if (e.toString().contains('Invalid token') || 
          e.toString().contains('JWT') || 
          e.toString().contains('Authentication') ||
          e.toString().contains('token')) {
        
        if (attempt < 3) {
          print('🔄 Authentication error detected - attempting token refresh (attempt $attempt)');
          try {
            await Supabase.instance.client.auth.refreshSession();
            await Future.delayed(Duration(milliseconds: 500)); // Brief delay after refresh
            continue; // Retry with refreshed token
          } catch (refreshError) {
            print('🔄 Token refresh failed: $refreshError');
            if (attempt == 3) rethrow; // Final attempt failed
          }
        } else {
          rethrow; // Final attempt failed
        }
      } else {
        rethrow; // Non-auth error, don't retry
      }
    }
  }
  
  return null;
});

/// Helper function to enhance business user data
Future<AppUser?> _enhanceBusinessUser(AppUser user, authService) async {
  var enhancedUser = user;
  print('🔄 currentUserProvider base result: $enhancedUser');
  
  // For business users, get the correct business ID and business name from onboarding status
  if (enhancedUser.isBusiness) {
    print('🔄 Attempting to enhance business user with ID: ${enhancedUser.id}');
    try {
      print('🔄 Calling getOnboardingStatusRaw...');
      final response = await authService.getOnboardingStatusRaw(enhancedUser.id);
      print('🔄 getOnboardingStatusRaw response: $response');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final businessStatus = data['business_status'] as Map<String, dynamic>?;
        
        if (businessStatus != null) {
          final actualBusinessId = businessStatus['id'] as String?;
          final businessName = businessStatus['name'] as String?;
          final businessPhone = businessStatus['phone'] as String?;
          final businessEmail = businessStatus['email'] as String?;
          final businessAddress = businessStatus['address'] as String?;
          
          print('🔄 Enhancing user with business data:');
          print('   Business ID: $actualBusinessId');
          print('   Business Name: $businessName');
          print('   Business Phone: $businessPhone');
          print('   Business Email: $businessEmail');
          print('   Business Address: $businessAddress');
          
          // Create updated user with correct business information
          enhancedUser = enhancedUser.copyWith(
            businessId: actualBusinessId ?? enhancedUser.businessId,
            businessName: businessName,
            name: businessName ?? enhancedUser.name, // Use business name as display name
            phone: businessPhone ?? enhancedUser.phone,
            // Note: Don't override user email with business email, keep user email
            address: businessAddress ?? enhancedUser.address,
          );
          print('🔄 currentUserProvider enhanced result: ${enhancedUser.name} (businessName: ${enhancedUser.businessName})');
        }
      }
    } catch (e) {
      print('⚠️ Failed to enhance user with business data: $e');
      // Continue with original user if enhancement fails
    }
  }
  
  print('🔄 currentUserProvider final result: $enhancedUser');
  return enhancedUser;
}

/// Production auth wrapper with role-based routing
class ProductionAuthWrapper extends ConsumerWidget {
  final Widget? child;
  
  const ProductionAuthWrapper({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🏗️  ProductionAuthWrapper.build() called');
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.hasData 
            ? snapshot.data!.session 
            : Supabase.instance.client.auth.currentSession;

        print('📱 AuthWrapper build state:');
        print('   Has snapshot data: ${snapshot.hasData}');
        print('   Session exists: ${session != null}');
        print('   Session user: ${session?.user?.id}');

        AuthLogger.logSessionState(session, context: 'AuthWrapper.build');

        if (snapshot.hasData) {
          AuthLogger.logAuthStateChange(
            snapshot.data!.event, 
            snapshot.data!.session,
          );
        }

        if (session == null) {
          // User not authenticated - show login
          print('🔐 No session - showing login screen');
          AuthLogger.logAuthEvent('No session - showing login screen');
          return const ProductionLoginScreen();
        }

        // User is authenticated - determine where to route them
        print('✅ Session found - loading user profile with currentUserProvider');
        AuthLogger.logAuthEvent('Session found - loading user profile');
        return ref.watch(authenticatedUserProvider).when(
          data: (user) {
            print('📊 currentUserProvider.data: user = $user');
            return _buildAuthenticatedApp(context, ref, user);
          },
          loading: () {
            print('⏳ currentUserProvider.loading - showing loading screen');
            return _buildLoadingScreen();
          },
          error: (error, stackTrace) {
            print('💥 currentUserProvider.error: $error');
            AuthLogger.logAuthError('currentUserProvider', error, stackTrace: stackTrace);
            return _buildErrorScreen(context, error);
          },
        );
      },
    );
  }

  Widget _buildAuthenticatedApp(BuildContext context, WidgetRef ref, AppUser? user) {
    print('🏠 _buildAuthenticatedApp called with user: $user');
    
    if (user == null) {
      // Check if session still exists - if not, user has been logged out
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        print('🔐 User is null and no session - showing login screen');
        AuthLogger.logAuthEvent('User logged out - showing login screen');
        return const ProductionLoginScreen();
      }
      
      // User authenticated but no profile - show onboarding
      print('👤 User is null but session exists - showing onboarding screen');
      AuthLogger.logAuthEvent('Authenticated user has no profile - showing onboarding');
      return const UserOnboardingScreen();
    }

    print('👤 Building authenticated app for user:');
    print('   ID: ${user.id}');
    print('   Type: ${user.userType}');
    print('   Name: ${user.name}');

    AuthLogger.logAuthEvent('Building authenticated app', data: {
      'user_type': user.userType,
      'user_id': user.id,
    });

    // Handle routing based on user type and onboarding status
    return Consumer(
      builder: (context, ref, child) {
        final onboardingStatusAsync = ref.watch(onboardingStatusProvider(user));
        
        return onboardingStatusAsync.when(
          loading: () {
            print('⏳ Onboarding check waiting - showing loading screen');
            return _buildLoadingScreen();
          },
          error: (error, stackTrace) {
            print('💥 Onboarding status error: $error');
            AuthLogger.logAuthError('onboardingStatusProvider', error, stackTrace: stackTrace);
            // On error, assume needs onboarding to be safe
            final onboardingStatus = OnboardingStatus.needsOnboarding();
            return _buildForOnboardingStatus(context, ref, user, onboardingStatus);
          },
          data: (onboardingStatus) {
            print('✅ Onboarding status loaded successfully');
            return _buildForOnboardingStatus(context, ref, user, onboardingStatus);
          },
        );
      },
    );
  }

  Widget _buildForOnboardingStatus(BuildContext context, WidgetRef ref, AppUser user, OnboardingStatus onboardingStatus) {
    print('📋 Onboarding decision for user ${user.id}:');
    print('   User type: ${user.userType}');
    print('   User email: ${user.email}');
    print('   Needs onboarding: ${onboardingStatus.needsOnboarding}');
    print('   Is waiting for approval: ${onboardingStatus.isWaitingForApproval}');
    print('   Is business active: ${onboardingStatus.isBusinessActive}');

    // Load saved addresses for authenticated users
    _loadUserAddresses(context, ref, user);
    
    AuthLogger.logAuthEvent('Onboarding check complete', data: {
      'user_type': user.userType,
      'needs_onboarding': onboardingStatus.needsOnboarding,
      'is_waiting_for_approval': onboardingStatus.isWaitingForApproval,
      'is_business_active': onboardingStatus.isBusinessActive,
    });

    if (user.userType == UserType.business) {
      if (onboardingStatus.needsOnboarding) {
        // Business user needs onboarding
        print('🏢 Routing to restaurant onboarding');
        AuthLogger.logAuthEvent('Routing to restaurant onboarding');
        return const RestaurantOnboardingPage();
      } else if (onboardingStatus.isWaitingForApproval) {
        // Business user is waiting for approval - show waiting list screen
        print('⏳ Routing to business waiting list screen');
        AuthLogger.logAuthEvent('Routing to business waiting list screen');
        return BusinessWaitingListScreen(onboardingStatus: onboardingStatus);
      } else {
        // Business user completed onboarding and approved - show child or default to dashboard
        print('🏢 Business user authorized - showing ${child != null ? 'child screen' : 'business home screen'}');
        AuthLogger.logAuthEvent(child != null ? 'Showing child screen for business user' : 'Routing to business home screen');
        return child ?? const BusinessHomeScreen();
      }
    } else {
      // Customer user - show child or default to home screen
      print('🛍️  Customer user authorized - showing ${child != null ? 'child screen' : 'customer home screen'}');
      AuthLogger.logAuthEvent(child != null ? 'Showing child screen for customer user' : 'Routing to customer home screen');
      return child ?? const CustomerHomeScreen();
    }
  }

  /// Load user's saved addresses when authenticated
  void _loadUserAddresses(BuildContext context, WidgetRef ref, AppUser user) {
    // Use post-frame callback to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        print('📍 AUTH WRAPPER: Loading saved addresses for user: ${user.id}');
        // Load addresses in the background - don't await to avoid blocking UI
        ref.read(customerAddressProvider.notifier).loadAddresses(user.id).catchError((e) {
          print('📍 AUTH WRAPPER: Error loading addresses: $e');
          // Don't show error to user - addresses are optional
        });
      }
    });
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'grabeat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Loading your account...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              const Text(
                'Unable to load your profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'There was an issue checking your account. This might be due to a network problem or an authentication issue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Force refresh by invalidating the provider
                      final container = ProviderScope.containerOf(context);
                      container.invalidate(authenticatedUserProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper provider to check if current user is business
final isBusinessUserProvider = Provider<bool>((ref) {
  return ref.watch(authenticatedUserProvider).maybeWhen(
    data: (user) => user?.userType == UserType.business,
    orElse: () => false,
  );
});

/// Helper provider to check if current user is customer
final isCustomerUserProvider = Provider<bool>((ref) {
  return ref.watch(authenticatedUserProvider).maybeWhen(
    data: (user) => user?.userType == UserType.customer,
    orElse: () => false,
  );
});

/// Comprehensive logout utility that clears all cached data
Future<void> performCompleteLogout(WidgetRef ref) async {
  try {
    print('🚪 Starting comprehensive logout...');
    
    // 1. Use production auth service for complete logout (clears Supabase + SharedPreferences)
    final authService = ref.read(productionAuthServiceProvider);
    await authService.signOut();
    
    // 2. Invalidate auth-related providers to prevent cross-user contamination
    print('🧹 Invalidating auth providers to ensure clean state...');
    ref.invalidate(authenticatedUserProvider);
    ref.invalidate(onboardingStatusProvider);
    
    // Also invalidate the currentAuthUserProvider from auth_provider.dart
    ref.invalidate(currentAuthUserProvider);
    
    print('✅ Comprehensive logout completed - auth providers cleared');
  } catch (e) {
    print('💥 Error during comprehensive logout: $e');
    rethrow;
  }
}