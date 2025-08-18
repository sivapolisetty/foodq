import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_user.dart';
import '../providers/business_statistics_provider.dart';

/// Business statistics cards showing key metrics
/// Displays revenue, orders, deals, and other business metrics
class BusinessStatsCards extends ConsumerWidget {
  final AppUser businessUser;

  const BusinessStatsCards({
    Key? key,
    required this.businessUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(businessStatisticsForUserProvider(businessUser.businessId ?? ''));
    
    return statisticsAsync.when(
      data: (statistics) => _buildStatsContent(statistics),
      loading: () => _buildLoadingContent(),
      error: (error, _) => _buildErrorContent(error),
    );
  }

  Widget _buildStatsContent(BusinessStatistics? statistics) {
    // Use real data if available, fallback to defaults
    final stats = statistics ?? const BusinessStatistics();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Overview',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // Primary stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Today\'s Revenue',
                  value: '\$${stats.todayRevenue.toStringAsFixed(0)}',
                  change: stats.revenueChange,
                  isPositive: stats.revenueChange.startsWith('+'),
                  icon: Icons.attach_money,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Orders Today',
                  value: '${stats.todayOrders}',
                  change: stats.ordersChange,
                  isPositive: stats.ordersChange.startsWith('+'),
                  icon: Icons.shopping_bag,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Secondary stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Active Deals',
                  value: '${stats.activeDeals}',
                  change: stats.dealsChange,
                  isPositive: stats.dealsChange.startsWith('+') ? true : (stats.dealsChange.contains('-') ? false : null),
                  icon: Icons.local_offer,
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Customer Rating',
                  value: '${stats.customerRating}',
                  change: stats.ratingChange,
                  isPositive: stats.ratingChange.startsWith('+'),
                  icon: Icons.star,
                  color: const Color(0xFFFFC107),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Weekly summary card
          _buildWeeklySummaryCard(stats),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Loading shimmer effect
          Row(
            children: [
              Expanded(child: _buildLoadingCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildLoadingCard()),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildLoadingCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildLoadingCard()),
            ],
          ),
          
          const SizedBox(height: 20),
          _buildLoadingCard(),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(Object error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[600],
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool? isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isPositive != null) ...[
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 12,
                  color: isPositive 
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935),
                ),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    color: isPositive == null
                        ? const Color(0xFF757575)
                        : isPositive
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummaryCard(BusinessStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'This Week\'s Performance',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 10,
                      color: Color(0xFF4CAF50),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Good',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Weekly metrics row
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildWeeklyMetric(
                    'Total Revenue',
                    '\$${stats.weeklyRevenue.toStringAsFixed(0)}',
                    stats.weeklyRevenueChange,
                    stats.weeklyRevenueChange.startsWith('+'),
                  ),
                ),
                Container(
                  width: 1,
                  color: const Color(0xFFE0E0E0),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildWeeklyMetric(
                    'Orders',
                    '${stats.weeklyOrders}',
                    stats.weeklyOrdersChange,
                    stats.weeklyOrdersChange.startsWith('+'),
                  ),
                ),
                Container(
                  width: 1,
                  color: const Color(0xFFE0E0E0),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildWeeklyMetric(
                    'Avg. Order',
                    '\$${stats.avgOrderValue.toStringAsFixed(0)}',
                    stats.avgOrderChange,
                    stats.avgOrderChange.startsWith('+'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMetric(
    String label,
    String value,
    String change,
    bool isPositive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          change,
          style: TextStyle(
            fontSize: 9,
            color: isPositive 
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE53935),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}