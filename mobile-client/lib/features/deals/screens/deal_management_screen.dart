import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/widgets/deal_card.dart';
import '../widgets/create_deal_bottom_sheet.dart';
import '../providers/deal_provider.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
// Removed unused mock user provider import

class DealManagementScreen extends ConsumerStatefulWidget {
  const DealManagementScreen({super.key});

  @override
  ConsumerState<DealManagementScreen> createState() => _DealManagementScreenState();
}

class _DealManagementScreenState extends ConsumerState<DealManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load deals when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDeals();
    });
  }

  Future<void> _loadUserDeals() async {
    print('🔄 DealManagement: Loading user deals...');
    // Get current user and their business ID
    final currentUser = await ref.read(authenticatedUserProvider.future);
    print('👤 Current user: ${currentUser?.name}, isBusiness: ${currentUser?.isBusiness}, businessId: ${currentUser?.businessId}');
    
    if (currentUser != null && currentUser.isBusiness && currentUser.businessId != null) {
      // Load deals for the current user's business
      print('🏢 Loading deals for business: ${currentUser.businessId}');
      ref.read(dealListProvider.notifier).loadDeals(businessId: currentUser.businessId);
    } else {
      // Fallback: load all deals if user info is unavailable
      print('🌐 Loading all deals (no specific business ID)');
      ref.read(dealListProvider.notifier).loadDeals();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dealState = ref.watch(dealListProvider);
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    
    // Load deals when current user becomes available
    currentUserAsync.whenData((currentUser) {
      if (currentUser != null && currentUser.isBusiness && currentUser.businessId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!dealState.isLoading) {
            print('🔄 DealManagement: Auto-loading deals for business: ${currentUser.businessId}');
            ref.read(dealListProvider.notifier).loadDeals(businessId: currentUser.businessId);
          }
        });
      }
    });
    
    // Calculate stats
    final activeDeals = dealState.deals?.where((deal) => deal.status == DealStatus.active).length ?? 0;
    final expiringDeals = dealState.deals?.where((deal) => deal.isExpiringSoon && deal.status == DealStatus.active).length ?? 0;
    final expiredDeals = dealState.deals?.where((deal) => 
      deal.status == DealStatus.expired || !deal.isAvailable
    ).length ?? 0;
    
    return OverflowSafeWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Deals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Color(0xFF212121)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: const Color(0xFF9E9E9E),
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Active'),
                        if (activeDeals > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$activeDeals',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Expiring'),
                        if (expiringDeals > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$expiringDeals',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Expired'),
                        if (expiredDeals > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9E9E9E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$expiredDeals',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveDealsTab(dealState),
            _buildExpiringDealsTab(dealState),
            _buildExpiredDealsTab(dealState),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('create_deal_fab'),
          onPressed: () => _showCreateDealBottomSheet(context),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          icon: const Icon(Icons.add),
          label: const Text('Create Deal'),
        ).animate().scale(
          delay: 300.ms,
          duration: 200.ms,
          curve: Curves.elasticOut,
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }


  Widget _buildActiveDealsTab(DealListState state) {
    print('🏪 DealManagement: Building active deals tab');
    print('🔍 State: isLoading=${state.isLoading}, deals count=${state.deals?.length ?? 0}, error=${state.error}');
    
    if (state.isLoading) {
      print('⏳ Showing loading state');
      return _buildLoadingState();
    }

    final activeDeals = state.deals?.where((deal) => deal.status == DealStatus.active).toList() ?? [];
    print('📋 Active deals count: ${activeDeals.length}');
    
    if (activeDeals.isEmpty) {
      print('📭 No active deals found, showing empty state');
      return _buildEmptyState(
        icon: Icons.storefront_outlined,
        title: 'No Active Deals',
        subtitle: 'Create your first deal to start selling surplus food items.',
        action: ElevatedButton.icon(
          onPressed: () => _showCreateDealBottomSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Create Deal'),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await _loadUserDeals();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: activeDeals.length,
        itemBuilder: (context, index) {
          final deal = activeDeals[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  DealCard(
                    deal: deal,
                    onTap: () => _showEditDealBottomSheet(context, deal),
                    showCartControls: false,
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDealBottomSheet(context, deal);
                        } else if (value == 'deactivate') {
                          _showDeactivateDealDialog(context, deal);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'deactivate',
                          child: Row(
                            children: [
                              Icon(Icons.remove_circle, size: 16),
                              SizedBox(width: 8),
                              Text('Deactivate'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ).animate().fadeIn(
            delay: Duration(milliseconds: 100 * index),
          ).slideX(begin: 0.3, end: 0);
        },
      ),
    );
  }

  Widget _buildExpiringDealsTab(DealListState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    final expiringDeals = state.deals?.where((deal) => 
      deal.status == DealStatus.active && deal.isExpiringSoon
    ).toList() ?? [];
    
    if (expiringDeals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.schedule_outlined,
        title: 'No Expiring Deals',
        subtitle: 'All your deals have plenty of time remaining.',
        color: AppColors.success,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: expiringDeals.length,
      itemBuilder: (context, index) {
        final deal = expiringDeals[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                DealCard(
                  deal: deal,
                  onTap: () => _showEditDealBottomSheet(context, deal),
                  showCartControls: false,
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.warning, color: Colors.white, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDealBottomSheet(context, deal);
                      } else if (value == 'deactivate') {
                        _showDeactivateDealDialog(context, deal);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle, size: 16),
                            SizedBox(width: 8),
                            Text('Deactivate'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
        ).slideX(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildExpiredDealsTab(DealListState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    final expiredDeals = state.deals?.where((deal) => 
      deal.status == DealStatus.expired || !deal.isAvailable
    ).toList() ?? [];
    
    if (expiredDeals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_outlined,
        title: 'No Expired Deals',
        subtitle: 'Your deal history will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: expiredDeals.length,
      itemBuilder: (context, index) {
        final deal = expiredDeals[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DealCard(
            deal: deal,
            onTap: () {},
            showCartControls: false,
          ),
        ).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
        ).slideX(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
    Color? color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (color ?? AppColors.surfaceVariant).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color ?? AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateDealBottomSheet(BuildContext context) {
    // Get current user from provider
    final currentUserAsync = ref.read(authenticatedUserProvider);
    final currentUser = currentUserAsync.valueOrNull;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateDealBottomSheet(currentUser: currentUser),
    );
  }

  void _showEditDealBottomSheet(BuildContext context, Deal deal) {
    // Get current user from provider
    final currentUserAsync = ref.read(authenticatedUserProvider);
    final currentUser = currentUserAsync.valueOrNull;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateDealBottomSheet(deal: deal, currentUser: currentUser),
    );
  }

  void _showDeactivateDealDialog(BuildContext context, Deal deal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Deal'),
        content: Text(
          'Are you sure you want to deactivate "${deal.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              
              final success = await ref.read(dealListProvider.notifier).deactivateDeal(deal.id);
              
              if (mounted && context.mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Deal deactivated successfully'
                        : 'Failed to deactivate deal',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Deactivate'),
          ),
        ],
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
              currentIndex: 1, // Deals tab index
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
    if (!mounted || !context.mounted) return;
    
    // Prevent navigation if already on the target screen
    if (index == 1) return; // Already on deals screen
    
    try {
      switch (index) {
        case 0:
          context.go('/business-home');
          break;
        case 2:
          context.go('/qr-scanner');
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}