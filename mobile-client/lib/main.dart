import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

// Core Services
import 'core/theme/app_theme.dart';
import 'core/config/environment_config.dart';
import 'core/config/api_config.dart';
import 'core/services/network_logger.dart';

// Shared components
import 'shared/widgets/overflow_safe_wrapper.dart';

// Feature screens
import 'features/search/screens/search_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/orders/screens/cart_screen.dart';
import 'features/orders/screens/checkout_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
// import 'features/profile/screens/profile_screen.dart'; // Disabled - part of removed mock user system
import 'features/profile/screens/production_profile_screen.dart';
// import 'features/profile/screens/create_user_screen.dart'; // Disabled - part of removed mock user system
import 'features/business/screens/business_home_screen.dart';
import 'features/business/screens/business_enrollment_screen.dart';
import 'features/business/screens/business_onboarding_status_screen.dart';
import 'features/business/screens/restaurant_onboarding_page.dart';
import 'features/business/screens/business_profile_screen.dart';
import 'features/business/screens/finance_screen.dart';

// Deal management
import 'features/deals/screens/deal_management_screen.dart';
import 'features/deals/screens/deal_details_screen.dart';
import 'features/home/screens/customer_home_screen.dart';
import 'features/orders/screens/order_confirmation_screen.dart';
import 'features/orders/screens/orders_screen.dart';
import 'features/orders/screens/order_details_screen.dart';
import 'features/auth/screens/simple_login_screen.dart';
import 'features/auth/screens/restaurant_owner_signup_screen.dart';
import 'features/auth/screens/production_login_screen.dart';
import 'features/auth/screens/user_onboarding_screen.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'features/auth/widgets/auth_wrapper.dart';
import 'features/auth/widgets/production_auth_wrapper.dart';
import 'shared/models/deal.dart';
import 'shared/models/order.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    print('🚀 Initializing grabeat...');

    // Initialize environment configuration
    await EnvironmentConfig.initialize();
    print('✅ Environment config loaded');

    // Initialize Supabase with environment configuration and network logging
    await Supabase.initialize(
      url: EnvironmentConfig.supabaseUrl,
      anonKey: EnvironmentConfig.supabaseAnonKey,
      httpClient: LoggingHttpClient(),
    );
    print('✅ Supabase initialized with network logging');
    
    // Print configuration status in development (after Supabase is initialized)
    EnvironmentConfig.printConfigStatus();
    ApiConfig.printDebugInfo();

    runApp(
      const ProviderScope(
        child: GrabeatApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ Error initializing app: $e');
    print('Stack trace: $stackTrace');
    
    // Run minimal app with error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 100, color: Colors.red),
                const SizedBox(height: 20),
                const Text('Initialization Error', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Text('$e', style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GrabeatApp extends ConsumerWidget {
  const GrabeatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _createRouter(ref);

    return OverflowSafeWrapper(
      child: MaterialApp.router(
        title: 'grabeat',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  GoRouter _createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'root',
          builder: (context, state) => const ProductionAuthWrapper(),
        ),
        GoRoute(
          path: '/business-enrollment',
          name: 'businessEnrollment',
          builder: (context, state) => const BusinessEnrollmentScreen(),
        ),
        GoRoute(
          path: '/business-onboarding-status',
          name: 'businessOnboardingStatus',
          builder: (context, state) => const BusinessOnboardingStatusScreen(),
        ),
        GoRoute(
          path: '/deals',
          name: 'dealManagement',
          builder: (context, state) => const DealManagementScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const ProductionAuthWrapper(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProductionProfileScreen(),
        ),
        // Disabled create-user route - part of removed mock user system
        // GoRoute(
        //   path: '/create-user',
        //   name: 'createUser',
        //   builder: (context, state) => const CreateUserScreen(),
        // ),
        GoRoute(
          path: '/business-home',
          name: 'businessHome',
          builder: (context, state) => const BusinessHomeScreen(),
        ),
        GoRoute(
          path: '/business-profile',
          name: 'businessProfile',
          builder: (context, state) => const BusinessProfileScreen(),
        ),
        GoRoute(
          path: '/customer-home',
          name: 'customerHome',
          builder: (context, state) => const ProductionAuthWrapper(
            child: CustomerHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/finances',
          name: 'finances',
          builder: (context, state) => const FinanceScreen(),
        ),
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/deal-details',
          name: 'dealDetails',
          builder: (context, state) {
            final deal = state.extra as Deal?;
            if (deal == null) {
              // If no deal provided, redirect to customer home
              return const CustomerHomeScreen();
            }
            return DealDetailsScreen(deal: deal);
          },
        ),
        GoRoute(
          path: '/order-confirmation',
          name: 'orderConfirmation',  
          builder: (context, state) {
            final order = state.extra as Order?;
            if (order == null) {
              // If no order provided, redirect to orders screen
              return const OrdersScreen();
            }
            return OrderConfirmationScreen(order: order);
          },
        ),
        GoRoute(
          path: '/order-details',
          name: 'orderDetails',
          builder: (context, state) {
            final order = state.extra as Order?;
            if (order == null) {
              // If no order provided, redirect to orders screen
              return const OrdersScreen();
            }
            return OrderDetailsScreen(order: order);
          },
        ),
        GoRoute(
          path: '/restaurant-onboarding',
          name: 'restaurantOnboarding',
          builder: (context, state) => const RestaurantOnboardingPage(),
        ),
        // Authentication routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const SimpleLoginScreen(),
        ),
        GoRoute(
          path: '/restaurant-owner-signup',
          name: 'restaurantOwnerSignup',
          builder: (context, state) => const RestaurantOwnerSignupScreen(),
        ),
        GoRoute(
          path: '/user-onboarding',
          name: 'userOnboarding',
          builder: (context, state) => const UserOnboardingScreen(),
        ),
        GoRoute(
          path: '/role-selection',
          name: 'roleSelection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        // OAuth callback routes
        GoRoute(
          path: '/auth/callback',
          name: 'authCallback',
          builder: (context, state) => const ProductionAuthWrapper(
            child: CustomerHomeScreen(),
          ),
        ),
        GoRoute(
          path: '/login-callback',
          name: 'loginCallback',
          builder: (context, state) => const ProductionAuthWrapper(
            child: CustomerHomeScreen(),
          ),
        ),
      ],
    );
  }
}

