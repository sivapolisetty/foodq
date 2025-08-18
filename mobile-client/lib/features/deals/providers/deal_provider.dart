import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/deal_result.dart';
import '../services/deal_service.dart';

part 'deal_provider.freezed.dart';

@freezed
class DealListState with _$DealListState {
  const factory DealListState({
    List<Deal>? deals,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? error,
    DateTime? lastUpdated,
  }) = _DealListState;
}

// Deal service provider
final dealServiceProvider = Provider<DealService>((ref) {
  return DealService();
});

// Deal list state provider
final dealListProvider = StateNotifierProvider<DealListNotifier, DealListState>((ref) {
  final dealService = ref.watch(dealServiceProvider);
  return DealListNotifier(dealService);
});

// Separate provider for dashboard active deals section
final dashboardDealsProvider = StateNotifierProvider<DealListNotifier, DealListState>((ref) {
  final dealService = ref.watch(dealServiceProvider);
  return DealListNotifier(dealService);
});

class DealListNotifier extends StateNotifier<DealListState> {
  final DealService _dealService;

  DealListNotifier(this._dealService) : super(const DealListState());

  /// Load deals for the current business
  /// If businessId is provided, load deals for that specific business
  /// Otherwise, load deals for authenticated user's businesses
  Future<void> loadDeals({String? businessId, bool forceRefresh = false}) async {
    print('🔄 DealProvider.loadDeals called with businessId: $businessId, forceRefresh: $forceRefresh');
    
    if (state.isLoading) {
      print('⏭️ Already loading, skipping...');
      return;
    }
    
    // Skip loading if deals are already loaded for this business (unless forcing refresh)
    if (!forceRefresh && state.deals != null && state.lastUpdated != null) {
      // Check if data is recent (less than 5 seconds old for debugging)
      final isDataRecent = DateTime.now().difference(state.lastUpdated!).inSeconds < 5;
      if (isDataRecent) {
        print('📋 Using cached deals (${state.deals!.length} deals)');
        return;
      }
    }
    
    print('🔄 Starting to load deals...');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // API will automatically filter by authenticated user's businesses if no businessId provided
      print('🟡🟡🟡 PROVIDER_DEBUG: Calling getDealsByBusinessId with businessId: $businessId');
      final deals = await _dealService.getDealsByBusinessId(businessId);
      print('🟡🟡🟡 PROVIDER_DEBUG: Service returned deals list, type: ${deals.runtimeType}');
      print('🟡🟡🟡 PROVIDER_DEBUG: Deals list length: ${deals.length}');
      
      if (deals.isEmpty) {
        print('🟡🟡🟡 PROVIDER_DEBUG: WARNING - Service returned empty list!');
      } else {
        print('🟡🟡🟡 PROVIDER_DEBUG: First deal title: ${deals[0].title}');
      }
      
      print('✅ Loaded ${deals.length} deals from API');
      
      state = state.copyWith(
        deals: deals,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      
      print('🟡🟡🟡 PROVIDER_DEBUG: State updated, state.deals?.length = ${state.deals?.length}');
      print('📊 Provider state updated with ${deals.length} deals');
    } catch (e, stackTrace) {
      print('❌ Error loading deals: $e');
      print('🟡🟡🟡 PROVIDER_DEBUG: Exception in loadDeals: $e');
      print('🟡🟡🟡 PROVIDER_DEBUG: Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load deals: ${e.toString()}',
      );
    }
  }

  /// Refresh deals
  /// If businessId is provided, refresh deals for that specific business
  /// Otherwise, refresh deals for authenticated user's businesses
  Future<void> refreshDeals({String? businessId}) async {
    state = state.copyWith(isRefreshing: true, error: null);
    
    try {
      // API will automatically filter by authenticated user's businesses if no businessId provided
      final deals = await _dealService.getDealsByBusinessId(businessId);
      
      state = state.copyWith(
        deals: deals,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh deals: ${e.toString()}',
      );
    }
  }

  /// Create a new deal
  Future<bool> createDeal(Map<String, dynamic> dealData) async {
    try {
      print('🏪 DealProvider.createDeal called with data: $dealData');
      
      final result = await _dealService.createDeal(
        businessId: dealData['business_id'] as String,
        title: dealData['title'] as String,
        description: (dealData['description'] as String?) ?? '',
        originalPrice: dealData['original_price'] as double,
        discountedPrice: dealData['discounted_price'] as double,
        quantityAvailable: dealData['quantity_available'] as int,
        expiresAt: DateTime.parse(dealData['expires_at'] as String),
        allergenInfo: dealData['allergen_info'] as String?,
      );

      print('📊 DealService result: success=${result.isSuccess}, error=${result.error}');

      if (result.isSuccess) {
        // Add the new deal to the current list
        final currentDeals = state.deals ?? [];
        final updatedDeals = [result.deal!, ...currentDeals];
        
        state = state.copyWith(
          deals: updatedDeals,
          lastUpdated: DateTime.now(),
        );
        
        print('✅ Deal added to provider state, total deals: ${updatedDeals.length}');
        return true;
      } else {
        print('❌ Deal creation failed: ${result.error}');
        state = state.copyWith(error: result.error);
        return false;
      }
    } catch (e) {
      print('💥 Exception in DealProvider.createDeal: $e');
      state = state.copyWith(error: 'Failed to create deal: ${e.toString()}');
      return false;
    }
  }

  /// Update an existing deal
  Future<bool> updateDeal(String dealId, Map<String, dynamic> updates) async {
    try {
      final result = await _dealService.updateDeal(dealId, updates);

      if (result.isSuccess) {
        // Update the deal in the current list
        final currentDeals = state.deals ?? [];
        final updatedDeals = currentDeals.map((deal) {
          return deal.id == dealId ? result.deal! : deal;
        }).toList();
        
        state = state.copyWith(
          deals: updatedDeals,
          lastUpdated: DateTime.now(),
        );
        
        return true;
      } else {
        state = state.copyWith(error: result.error);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update deal: ${e.toString()}');
      return false;
    }
  }

  /// Deactivate a deal
  Future<bool> deactivateDeal(String dealId) async {
    try {
      final success = await _dealService.deactivateDeal(dealId);

      if (success) {
        // Update the deal status in the current list
        final currentDeals = state.deals ?? [];
        final updatedDeals = currentDeals.map((deal) {
          if (deal.id == dealId) {
            return deal.copyWith(
              status: DealStatus.expired,
              updatedAt: DateTime.now(),
            );
          }
          return deal;
        }).toList();
        
        state = state.copyWith(
          deals: updatedDeals,
          lastUpdated: DateTime.now(),
        );
        
        return true;
      } else {
        state = state.copyWith(error: 'Failed to deactivate deal');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to deactivate deal: ${e.toString()}');
      return false;
    }
  }

  /// Increment quantity sold (when an order is placed)
  Future<bool> incrementQuantitySold(String dealId, int quantity) async {
    try {
      final success = await _dealService.incrementQuantitySold(dealId, quantity);

      if (success) {
        // Update the quantity in the current list
        final currentDeals = state.deals ?? [];
        final updatedDeals = currentDeals.map((deal) {
          if (deal.id == dealId) {
            return deal.copyWith(
              quantitySold: deal.quantitySold + quantity,
              updatedAt: DateTime.now(),
            );
          }
          return deal;
        }).toList();
        
        state = state.copyWith(
          deals: updatedDeals,
          lastUpdated: DateTime.now(),
        );
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get deals by urgency for notifications
  Future<List<Deal>> getDealsByUrgency(DealUrgency urgency) async {
    try {
      return await _dealService.getDealsByUrgency(urgency);
    } catch (e) {
      return [];
    }
  }

  /// Get expiring deals for notifications
  Future<List<Deal>> getExpiringDeals({int hoursThreshold = 2}) async {
    try {
      return await _dealService.getExpiringDeals(hoursThreshold: hoursThreshold);
    } catch (e) {
      return [];
    }
  }

  /// Get almost sold out deals for notifications
  Future<List<Deal>> getAlmostSoldOutDeals({double thresholdPercentage = 20.0}) async {
    try {
      return await _dealService.getAlmostSoldOutDeals(thresholdPercentage: thresholdPercentage);
    } catch (e) {
      return [];
    }
  }
}

// Provider for active deals (customer-facing)
final activeDealsProvider = FutureProvider<List<Deal>>((ref) async {
  final dealService = ref.watch(dealServiceProvider);
  return dealService.getActiveDeals(limit: 50);
});

// Provider for deal by ID
final dealByIdProvider = FutureProvider.family<Deal?, String>((ref, dealId) async {
  final dealService = ref.watch(dealServiceProvider);
  final deals = await dealService.getActiveDeals(limit: 100);
  
  try {
    return deals.firstWhere((deal) => deal.id == dealId);
  } catch (e) {
    return null;
  }
});

// Provider for urgent deals (for notifications)
final urgentDealsProvider = FutureProvider<List<Deal>>((ref) async {
  final dealService = ref.watch(dealServiceProvider);
  return dealService.getDealsByUrgency(DealUrgency.urgent);
});

// Provider for expiring deals
final expiringDealsProvider = FutureProvider<List<Deal>>((ref) async {
  final dealService = ref.watch(dealServiceProvider);
  return dealService.getExpiringDeals(hoursThreshold: 2);
});

// Provider for almost sold out deals
final almostSoldOutDealsProvider = FutureProvider<List<Deal>>((ref) async {
  final dealService = ref.watch(dealServiceProvider);
  return dealService.getAlmostSoldOutDeals(thresholdPercentage: 20.0);
});