import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/deal.dart';
import 'nearby_deals_api_section.dart';
import 'missed_deals_api_section.dart';
import 'expired_deals_api_section.dart';

/// Comprehensive deals overview combining all deal discovery systems
/// Provides nearby deals, FOMO missed deals, and regret-inducing expired deals
class ComprehensiveDealsOverview extends StatefulWidget {
  final Function(Deal)? onDealTap;
  final VoidCallback? onLocationPermissionRequest;
  final VoidCallback? onEnableNotifications;
  final VoidCallback? onSeeAllNearby;
  final VoidCallback? onSeeAllMissed;
  final VoidCallback? onSeeAllExpired;
  final bool showDistance;
  final bool groupNearbyByDistance;
  
  const ComprehensiveDealsOverview({
    super.key,
    this.onDealTap,
    this.onLocationPermissionRequest,
    this.onEnableNotifications,
    this.onSeeAllNearby,
    this.onSeeAllMissed,
    this.onSeeAllExpired,
    this.showDistance = true,
    this.groupNearbyByDistance = false,
  });

  @override
  State<ComprehensiveDealsOverview> createState() => _ComprehensiveDealsOverviewState();
}

class _ComprehensiveDealsOverviewState extends State<ComprehensiveDealsOverview>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  int _selectedTab = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabHeader(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNearbyTab(),
              _buildMissedTab(),
              _buildExpiredTab(),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTabHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text('Nearby'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_off,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text('Missed'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text('Expired'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNearbyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // Quick stats banner
          _buildQuickStatsBanner(),
          
          // Nearby deals section
          NearbyDealsApiSection(
            onDealTap: widget.onDealTap,
            onLocationPermissionRequest: widget.onLocationPermissionRequest,
            onSeeAllNearby: widget.onSeeAllNearby,
            showDistance: widget.showDistance,
            groupByDistance: widget.groupNearbyByDistance,
            maxVisible: 8,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildMissedTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // FOMO motivation banner
          _buildFOMOMotivationBanner(),
          
          // Missed deals section
          MissedDealsApiSection(
            onDealTap: widget.onDealTap,
            onSeeAllMissed: widget.onSeeAllMissed,
            maxVisible: 6,
            showStats: true,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildExpiredTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // Regret motivation banner
          _buildRegretMotivationBanner(),
          
          // Expired deals section
          ExpiredDealsApiSection(
            onDealTap: widget.onDealTap,
            onSeeAllExpired: widget.onSeeAllExpired,
            onEnableNotifications: widget.onEnableNotifications,
            maxVisible: 5,
            showStats: true,
            showOnlyRecentlyExpired: false,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildQuickStatsBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.explore,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Deals Near You',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Find amazing food deals within walking distance',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'LIVE',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFOMOMotivationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.limitedTime.withOpacity(0.1),
            AppColors.almostGone.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.limitedTime.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: AppColors.limitedTime,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Don\'t Miss Out Again',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.limitedTime,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Deals you viewed but haven\'t decided on yet',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.limitedTime,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'FOMO',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegretMotivationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.missedGray.withOpacity(0.1),
            AppColors.urgentPulse.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.missedGray.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.heart_broken,
            color: AppColors.missedGray,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deals You Missed',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.missedGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Learn from missed opportunities and act faster',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.missedGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'REGRET',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple version without tabs for embedding in other pages
class SimpleDealsOverview extends StatelessWidget {
  final Function(Deal)? onDealTap;
  final VoidCallback? onLocationPermissionRequest;
  final VoidCallback? onSeeAllNearby;
  final VoidCallback? onSeeAllMissed;
  final bool showDistance;
  
  const SimpleDealsOverview({
    super.key,
    this.onDealTap,
    this.onLocationPermissionRequest,
    this.onSeeAllNearby,
    this.onSeeAllMissed,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Nearby deals - highest priority
          NearbyDealsApiSection(
            onDealTap: onDealTap,
            onLocationPermissionRequest: onLocationPermissionRequest,
            onSeeAllNearby: onSeeAllNearby,
            showDistance: showDistance,
            maxVisible: 5,
          ),
          
          const SizedBox(height: 8),
          
          // Missed deals - FOMO motivation
          MissedDealsApiSection(
            onDealTap: onDealTap,
            onSeeAllMissed: onSeeAllMissed,
            maxVisible: 3,
            showStats: false,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}