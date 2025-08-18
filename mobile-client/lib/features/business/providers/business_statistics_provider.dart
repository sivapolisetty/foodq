import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/deal.dart';
import '../../deals/services/deal_service.dart';
import 'dart:developer' as developer;

class BusinessStatistics {
  final double todayRevenue;
  final int todayOrders;
  final int activeDeals;
  final double customerRating;
  final double weeklyRevenue;
  final int weeklyOrders;
  final double avgOrderValue;
  final String revenueChange;
  final String ordersChange;
  final String dealsChange;
  final String ratingChange;
  final String weeklyRevenueChange;
  final String weeklyOrdersChange;
  final String avgOrderChange;

  const BusinessStatistics({
    this.todayRevenue = 0.0,
    this.todayOrders = 0,
    this.activeDeals = 0,
    this.customerRating = 0.0,
    this.weeklyRevenue = 0.0,
    this.weeklyOrders = 0,
    this.avgOrderValue = 0.0,
    this.revenueChange = '+0%',
    this.ordersChange = '+0',
    this.dealsChange = 'No change',
    this.ratingChange = '+0.0',
    this.weeklyRevenueChange = '+0%',
    this.weeklyOrdersChange = '+0%',
    this.avgOrderChange = '+0%',
  });

  BusinessStatistics copyWith({
    double? todayRevenue,
    int? todayOrders,
    int? activeDeals,
    double? customerRating,
    double? weeklyRevenue,
    int? weeklyOrders,
    double? avgOrderValue,
    String? revenueChange,
    String? ordersChange,
    String? dealsChange,
    String? ratingChange,
    String? weeklyRevenueChange,
    String? weeklyOrdersChange,
    String? avgOrderChange,
  }) {
    return BusinessStatistics(
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayOrders: todayOrders ?? this.todayOrders,
      activeDeals: activeDeals ?? this.activeDeals,
      customerRating: customerRating ?? this.customerRating,
      weeklyRevenue: weeklyRevenue ?? this.weeklyRevenue,
      weeklyOrders: weeklyOrders ?? this.weeklyOrders,
      avgOrderValue: avgOrderValue ?? this.avgOrderValue,
      revenueChange: revenueChange ?? this.revenueChange,
      ordersChange: ordersChange ?? this.ordersChange,
      dealsChange: dealsChange ?? this.dealsChange,
      ratingChange: ratingChange ?? this.ratingChange,
      weeklyRevenueChange: weeklyRevenueChange ?? this.weeklyRevenueChange,
      weeklyOrdersChange: weeklyOrdersChange ?? this.weeklyOrdersChange,
      avgOrderChange: avgOrderChange ?? this.avgOrderChange,
    );
  }
}

class BusinessStatisticsState {
  final BusinessStatistics? statistics;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const BusinessStatisticsState({
    this.statistics,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  BusinessStatisticsState copyWith({
    BusinessStatistics? statistics,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return BusinessStatisticsState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BusinessStatisticsNotifier extends StateNotifier<BusinessStatisticsState> {
  BusinessStatisticsNotifier() : super(const BusinessStatisticsState());

  Future<void> loadStatistics(String businessId) async {
    if (businessId.trim().isEmpty) {
      state = const BusinessStatisticsState(
        hasError: true,
        errorMessage: 'Business ID is required',
      );
      return;
    }

    state = state.copyWith(isLoading: true, hasError: false, errorMessage: null);

    try {
      developer.log('📊 Loading business statistics for: $businessId');

      // Fetch data from multiple sources
      final dealService = DealService();

      // Get deals for this business
      final deals = await dealService.getDealsByBusinessId(businessId);
      final activeDealsCount = deals.where((deal) => deal.status == DealStatus.active).length;

      // Get orders for this business (if business orders endpoint exists)
      // For now, we'll use mock calculations based on deals
      final todayOrders = deals.fold<int>(0, (sum, deal) => sum + deal.quantitySold);
      final todayRevenue = deals.fold<double>(0, (sum, deal) => 
        sum + (deal.discountedPrice * deal.quantitySold));

      // Calculate weekly metrics (mock for now - would need historical data)
      final weeklyRevenue = todayRevenue * 7; // Rough estimate
      final weeklyOrders = todayOrders * 7; // Rough estimate
      final avgOrderValue = weeklyOrders > 0 ? weeklyRevenue / weeklyOrders : 0.0;

      // Mock rating (would come from customer feedback system)
      final customerRating = 4.2 + (deals.length * 0.1).clamp(0, 0.8);

      // Create statistics object
      final statistics = BusinessStatistics(
        todayRevenue: todayRevenue,
        todayOrders: todayOrders,
        activeDeals: activeDealsCount,
        customerRating: double.parse(customerRating.toStringAsFixed(1)),
        weeklyRevenue: weeklyRevenue,
        weeklyOrders: weeklyOrders,
        avgOrderValue: avgOrderValue,
        revenueChange: todayRevenue > 0 ? '+12%' : '0%', // Mock change
        ordersChange: todayOrders > 0 ? '+${(todayOrders * 0.1).round()}' : '0',
        dealsChange: activeDealsCount > 0 ? 'No change' : 'No change',
        ratingChange: '+0.1', // Mock change
        weeklyRevenueChange: '+15%', // Mock change
        weeklyOrdersChange: '+8%', // Mock change
        avgOrderChange: '+2%', // Mock change
      );

      developer.log('✅ Business statistics loaded successfully');
      developer.log('   - Today Revenue: \$${statistics.todayRevenue.toStringAsFixed(2)}');
      developer.log('   - Today Orders: ${statistics.todayOrders}');
      developer.log('   - Active Deals: ${statistics.activeDeals}');
      developer.log('   - Customer Rating: ${statistics.customerRating}');

      state = BusinessStatisticsState(
        statistics: statistics,
        isLoading: false,
      );

    } catch (e) {
      developer.log('❌ Error loading business statistics: $e');
      state = BusinessStatisticsState(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const BusinessStatisticsState();
  }
}

final businessStatisticsProvider = 
    StateNotifierProvider<BusinessStatisticsNotifier, BusinessStatisticsState>((ref) {
  return BusinessStatisticsNotifier();
});

// Convenience provider for specific business statistics
final businessStatisticsForUserProvider = 
    FutureProvider.family<BusinessStatistics?, String>((ref, businessId) async {
  if (businessId.trim().isEmpty) return null;
  
  try {
    developer.log('📊 Loading business statistics for: $businessId');

    // Fetch data directly without using StateNotifier to avoid provider conflicts
    final dealService = DealService();

    // Get deals for this business
    final deals = await dealService.getDealsByBusinessId(businessId);
    final activeDealsCount = deals.where((deal) => deal.status == DealStatus.active).length;

    // Get orders for this business (if business orders endpoint exists)
    // For now, we'll use mock calculations based on deals
    final todayOrders = deals.fold<int>(0, (sum, deal) => sum + deal.quantitySold);
    final todayRevenue = deals.fold<double>(0, (sum, deal) => 
      sum + (deal.discountedPrice * deal.quantitySold));

    // Calculate weekly metrics (mock for now - would need historical data)
    final weeklyRevenue = todayRevenue * 7; // Rough estimate
    final weeklyOrders = todayOrders * 7; // Rough estimate
    final avgOrderValue = weeklyOrders > 0 ? weeklyRevenue / weeklyOrders : 0.0;

    // Mock rating (would come from customer feedback system)
    final customerRating = 4.2 + (deals.length * 0.1).clamp(0, 0.8);

    // Create statistics object
    final statistics = BusinessStatistics(
      todayRevenue: todayRevenue,
      todayOrders: todayOrders,
      activeDeals: activeDealsCount,
      customerRating: double.parse(customerRating.toStringAsFixed(1)),
      weeklyRevenue: weeklyRevenue,
      weeklyOrders: weeklyOrders,
      avgOrderValue: avgOrderValue,
      revenueChange: todayRevenue > 0 ? '+12%' : '0%', // Mock change
      ordersChange: todayOrders > 0 ? '+${(todayOrders * 0.1).round()}' : '0',
      dealsChange: activeDealsCount > 0 ? 'No change' : 'No change',
      ratingChange: '+0.1', // Mock change
      weeklyRevenueChange: '+15%', // Mock change
      weeklyOrdersChange: '+8%', // Mock change
      avgOrderChange: '+2%', // Mock change
    );

    developer.log('✅ Business statistics loaded successfully');
    developer.log('   - Today Revenue: \$${statistics.todayRevenue.toStringAsFixed(2)}');
    developer.log('   - Today Orders: ${statistics.todayOrders}');
    developer.log('   - Active Deals: ${statistics.activeDeals}');
    developer.log('   - Customer Rating: ${statistics.customerRating}');

    return statistics;

  } catch (e) {
    developer.log('❌ Error loading business statistics: $e');
    throw e;
  }
});