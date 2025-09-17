import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/comprehensive_deals_overview.dart';
import '../../../shared/models/deal.dart';
import 'expired_deals_test_page.dart';

/// Test page to demonstrate the deals discovery and FOMO system
class DealsTestPage extends StatefulWidget {
  const DealsTestPage({super.key});

  @override
  State<DealsTestPage> createState() => _DealsTestPageState();
}

class _DealsTestPageState extends State<DealsTestPage> {

  void _handleDealTap(Deal deal) {
    // Navigate to deal details
    Navigator.pushNamed(
      context,
      '/deal-details',
      arguments: deal,
    );
  }

  void _handleLocationPermission() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location permission requested'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleEnableNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications would be enabled here'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Deals Discovery System',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpiredDealsTestPage(),
                ),
              );
            },
            tooltip: 'Expired Deals API Test',
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data comes from API endpoints'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            tooltip: 'API Info',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API-Driven Deals Discovery',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Location-based discovery and FOMO psychology driven by backend APIs',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: ComprehensiveDealsOverview(
              onDealTap: _handleDealTap,
              onLocationPermissionRequest: _handleLocationPermission,
              onEnableNotifications: _handleEnableNotifications,
              onSeeAllNearby: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('See all nearby deals')),
                );
              },
              onSeeAllMissed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('See all missed deals')),
                );
              },
              onSeeAllExpired: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('See all expired deals')),
                );
              },
              showDistance: true,
              groupNearbyByDistance: true,
            ),
          ),
        ],
      ),
    );
  }
}