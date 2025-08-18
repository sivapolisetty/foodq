import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/app_user.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cart functionality has been replaced by direct order placement
    // This screen redirects users to the new order flow
    
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 120,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Direct Order Placement',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'KraveKart now supports direct order placement!\nBrowse deals and order directly for pickup.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text('Browse Deals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.go('/orders'),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('View Order History'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    minimumSize: const Size(200, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Consumer(
      builder: (context, ref, child) {
        final currentUserAsync = ref.watch(authenticatedUserProvider);
        
        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Center(
                    child: Text(
                      'Select a user to access navigation',
                      style: TextStyle(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }
            
            return CustomBottomNav(
              currentIndex: 3, // Orders tab index
              currentUser: currentUser,
              onTap: (index) => _handleBottomNavTap(context, index, currentUser),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleBottomNavTap(BuildContext context, int index, AppUser currentUser) {
    switch (index) {
      case 0:
        if (currentUser.isBusiness) {
          context.go('/business-home');
        } else {
          context.go('/home');
        }
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        if (currentUser.isBusiness) {
          context.go('/deals');
        } else {
          context.go('/favorites');
        }
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}