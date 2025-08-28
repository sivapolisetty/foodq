import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/app_user.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../../deals/providers/deal_provider.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../widgets/business_dashboard_header.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/business_stats_cards.dart';
import '../widgets/recent_orders_section.dart';
import '../widgets/active_deals_section.dart';

/// Business home screen with dashboard for restaurant owners
/// Shows business performance, deal management, and quick actions
class BusinessHomeScreen extends ConsumerStatefulWidget {
  const BusinessHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends ConsumerState<BusinessHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);

    return currentUserAsync.when(
      data: (currentUser) {
        // ProductionAuthWrapper ensures currentUser is not null
        // Here we only check if user is a business user
        if (currentUser != null && !currentUser.isBusiness) {
          return _buildUnauthorizedState();
        }
        
        // The auth wrapper already handles onboarding status checks
        // If we're here, the user is authorized to see the business dashboard
        return _buildBusinessDashboard(currentUser!);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      ),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildBusinessDashboard(AppUser businessUser) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(businessUser),
        color: const Color(0xFF4CAF50),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Custom app bar with business info
            _buildSliverAppBar(businessUser),
            
            // Dashboard content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  
                  // Quick actions section
                  QuickActionsSection(businessUser: businessUser),
                  
                  const SizedBox(height: 32),
                  
                  // Business stats cards
                  BusinessStatsCards(businessUser: businessUser),
                  
                  const SizedBox(height: 32),
                  
                  // Active deals section
                  ActiveDealsSection(businessUser: businessUser),
                  
                  const SizedBox(height: 32),
                  
                  // Recent orders section
                  RecentOrdersSection(businessUser: businessUser),
                  
                  const SizedBox(height: 120), // Space for bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSliverAppBar(AppUser businessUser) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF4CAF50),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32), // Dark green
                Color(0xFF4CAF50), // Light green
              ],
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 24, bottom: 14),
        title: Text(
          businessUser.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      actions: [
        // Clean notifications button
        IconButton(
          onPressed: () => context.go('/notifications'),
          icon: Stack(
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 24,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    return currentUserAsync.when(
      data: (currentUser) => CustomBottomNav(
        currentIndex: 0, // Business home index
        currentUser: currentUser,
        onTap: (index) => _handleBottomNavTap(index),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingOnboardingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_center,
                color: Color(0xFF4CAF50),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Setting up your business profile...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthorizedState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_center,
                size: 64,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Business Access Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You need to be logged in as a business user\nto access the business dashboard',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Switch User',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53935),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(authenticatedUserProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh(AppUser businessUser) async {
    // Refresh all data
    ref.invalidate(authenticatedUserProvider);
    
    // Trigger a proper refresh of deals with business ID for dashboard
    await ref.read(dashboardDealsProvider.notifier).refreshDeals(businessId: businessUser.businessId);
    
    // Wait a bit for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on business home dashboard
        break;
      case 1:
        context.go('/deals');
        break;
      case 2:
        context.go('/finances');
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