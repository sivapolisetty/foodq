import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/app_user.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    
    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null || !currentUser.isBusiness) {
          return _buildUnauthorizedState();
        }
        
        return _buildFinanceContent(currentUser);
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

  Widget _buildUnauthorizedState() {
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finances'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_center,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Business Access Required',
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

  Widget _buildFinanceContent(AppUser currentUser) {
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finances'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: _buildFinanceBody(),
        bottomNavigationBar: _buildBottomNavigation(currentUser),
      ),
    );
  }

  Widget _buildFinanceBody() {
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
                Icons.account_balance_wallet_rounded,
                size: 60,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Finances Coming Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Manage your earnings, payouts, and financial reports here.\nThis feature is currently under development.',
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
                        Icons.trending_up_rounded,
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
                  _buildFeatureItem(Icons.analytics_rounded, 'Revenue Analytics'),
                  _buildFeatureItem(Icons.account_balance_rounded, 'Payout Management'),
                  _buildFeatureItem(Icons.receipt_long_rounded, 'Financial Reports'),
                  _buildFeatureItem(Icons.description_rounded, 'Tax Documents'),
                  _buildFeatureItem(Icons.savings_rounded, 'Earnings History'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/business-home'),
              icon: const Icon(Icons.dashboard_rounded),
              label: const Text('Back to Dashboard'),
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
      currentIndex: 2, // Finance tab
      currentUser: currentUser,
      onTap: (index) => _handleBottomNavTap(context, index, currentUser),
    );
  }

  void _handleBottomNavTap(BuildContext context, int index, AppUser currentUser) {
    if (!mounted || !context.mounted) return;
    
    // Prevent navigation if already on the target screen
    if (index == 2) return; // Already on finance screen
    
    try {
      switch (index) {
        case 0:
          context.go('/business-home');
          break;
        case 1:
          context.go('/deals');
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