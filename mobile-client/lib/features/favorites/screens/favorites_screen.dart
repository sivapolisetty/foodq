import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/app_user.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    
    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          return _buildNoUserSelected();
        }
        
        return _buildFavoritesContent(currentUser);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildNoUserSelected() {
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Select a user profile first',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/profile'),
                child: const Text('Go to Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesContent(AppUser currentUser) {
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _buildFavoritesBody(),
        bottomNavigationBar: _buildBottomNavigation(currentUser),
      ),
    );
  }

  Widget _buildFavoritesBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 60,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Favorites Coming Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Save your favorite deals and restaurants here.\nThis feature is currently under development.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: const Color(0xFF4CAF50),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'What\'s Coming',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(Icons.restaurant_rounded, 'Favorite Restaurants'),
                  _buildFeatureItem(Icons.local_offer_rounded, 'Saved Deals'),
                  _buildFeatureItem(Icons.history_rounded, 'Quick Reorder'),
                  _buildFeatureItem(Icons.notifications_rounded, 'Favorite Deal Alerts'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Explore Deals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(AppUser currentUser) {
    return CustomBottomNav(
      currentIndex: 2, // Favorites tab
      currentUser: currentUser,
      onTap: (index) => _handleBottomNavTap(context, index, currentUser),
    );
  }

  void _handleBottomNavTap(BuildContext context, int index, AppUser currentUser) {
    if (!mounted || !context.mounted) return;
    
    // Prevent navigation if already on the target screen
    if (index == 2) return; // Already on favorites screen
    
    try {
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
        case 3:
          context.go('/orders');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    } catch (e) {
      debugPrint('❌ Bottom nav navigation error: $e');
    }
  }
}