import 'dart:async';
import '../../core/services/api_service.dart';
import '../../core/config/api_config.dart';
import '../models/api_models.dart';
import '../models/deal.dart';

/// Clean API-driven service for expired deals  
/// TEMPORARY: Uses existing deals API until backend endpoints are implemented
class ExpiredDealsApiService {
  
  /// Get expired deals from dedicated API endpoint
  /// Now uses proper expired-deals endpoint instead of filtering
  static Future<List<ExpiredDeal>> getExpiredDeals() async {
    print('🕒 EXPIRED_API: Starting getExpiredDeals() call - FIXED VERSION');
    try {
      // Note: User-specific expired deals endpoint doesn't exist
      // Using general deals endpoint - this service may need refactoring
      final expiredDealsUrl = '${ApiConfig.dealsUrl}?status=expired';
      print('🕒 EXPIRED_API: Making request to: $expiredDealsUrl');
      print('⚠️ WARNING: Using general deals endpoint, not user-specific');
      
      final response = await ApiService.get<dynamic>(
        '/deals?status=expired',
      );
      
      if (response.success && response.data != null) {
        print('🕒 EXPIRED_API: Received successful response with ${response.data.length} expired deals');
        final expiredDealsData = response.data as List<dynamic>;
        
        // Convert raw deal JSON to ExpiredDeal objects
        final expiredDeals = expiredDealsData
            .map((json) {
              final dealJson = json as Map<String, dynamic>;
              final deal = Deal.fromJson(dealJson);
              
              // Create ExpiredDeal with computed fields since API returns raw deals
              return ExpiredDeal(
                deal: deal,
                expiredAt: deal.expiresAt,
                discoveredAt: deal.createdAt,
                wasViewedByUser: false, // Default since we don't have user tracking yet
                wasInUserCart: false, // Default since we don't have cart tracking yet
                regretLevel: _calculateRegretLevel(deal),
                regretMessage: _generateRegretMessage(deal),
                timeDisplayMessage: _formatTimeDisplayMessage(deal.expiresAt),
              );
            })
            .toList();
        
        print('🕒 EXPIRED_API: Successfully parsed ${expiredDeals.length} ExpiredDeal objects');
        return expiredDeals;
      } else {
        print('🕒 EXPIRED_API: API request failed: ${response.error}');
        print('🕒 EXPIRED_API: Falling back to filtered deals from main API');
        
        // Fallback to existing deals API and filter for expired deals
        final dealsResponse = await ApiService.get<dynamic>(
          '${ApiConfig.dealsEndpoint}',
        );
        
        if (dealsResponse.success && dealsResponse.data != null) {
          final dealsData = dealsResponse.data as List<dynamic>;
          final allDeals = dealsData
              .map((json) => Deal.fromJson(json as Map<String, dynamic>))
              .toList();
          
          // Filter for expired deals and convert to ExpiredDeal format
          final now = DateTime.now();
          final expiredDeals = allDeals
              .where((deal) => deal.expiresAt.isBefore(now))
              .map((deal) => ExpiredDeal(
                deal: deal,
                expiredAt: deal.expiresAt,
                discoveredAt: deal.createdAt,
                wasViewedByUser: false,
                wasInUserCart: false,
                regretLevel: _calculateRegretLevel(deal),
                regretMessage: _generateRegretMessage(deal),
                timeDisplayMessage: _formatTimeDisplayMessage(deal.expiresAt),
              ))
              .take(10)
              .toList();
          
          print('🕒 EXPIRED_API: Fallback successful, found ${expiredDeals.length} expired deals');
          return expiredDeals;
        } else {
          print('🕒 EXPIRED_API: Fallback also failed: ${dealsResponse.error}');
          return [];
        }
      }
    } catch (e) {
      print('🕒 EXPIRED_API: Exception in getExpiredDeals(): $e');
      return [];
    }
  }
  
  /// Calculate regret level based on deal properties
  static String _calculateRegretLevel(Deal deal) {
    if (deal.savingsAmount >= 15.0) return 'critical';
    if (deal.savingsAmount >= 10.0) return 'high';
    if (deal.savingsAmount >= 5.0) return 'medium';
    return 'low';
  }
  
  /// Generate regret message based on deal
  static String _generateRegretMessage(Deal deal) {
    final savings = deal.savingsAmount;
    if (savings >= 15.0) {
      return 'You missed out on huge savings of \$${savings.toStringAsFixed(0)}!';
    } else if (savings >= 10.0) {
      return 'Could have saved \$${savings.toStringAsFixed(0)} on this deal!';
    } else if (savings >= 5.0) {
      return 'Small savings add up - missed \$${savings.toStringAsFixed(0)}';
    } else {
      return 'This deal expired recently';
    }
  }
  
  /// Format time display message for expired deals
  static String _formatTimeDisplayMessage(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = now.difference(expiresAt);
    
    if (difference.inDays > 0) {
      return 'Expired ${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return 'Expired ${difference.inHours}h ago';
    } else {
      return 'Expired ${difference.inMinutes}m ago';
    }
  }
  
  /// Get expired deals statistics from dedicated API endpoint
  /// Now uses proper stats endpoint instead of calculating client-side
  static Future<ExpiredDealStats?> getExpiredDealsStats() async {
    print('🕒 EXPIRED_STATS: Starting getExpiredDealsStats() call');
    try {
      // Note: User-specific expired deals stats endpoint doesn't exist
      // This feature may need to be implemented server-side or calculated client-side
      print('🕒 EXPIRED_STATS: Stats endpoint not available');
      print('⚠️ WARNING: Expired deals stats endpoint does not exist');
      
      // Return null since endpoint doesn't exist
      // TODO: Either implement server-side stats endpoint or calculate client-side
      return null;
    } catch (e) {
      print('🕒 EXPIRED_STATS: Exception in getExpiredDealsStats(): $e');
      return null;
    }
  }
  
  /// Get expired deals that were viewed by the user (high regret)
  /// TEMPORARY: Returns all expired deals until user tracking is implemented
  static Future<List<ExpiredDeal>> getViewedExpiredDeals() async {
    return await getExpiredDeals();
  }
  
  /// Get expired deals that were in the user's cart (maximum regret)
  /// TEMPORARY: Returns high-savings expired deals until cart tracking is implemented
  static Future<List<ExpiredDeal>> getCartExpiredDeals() async {
    final allExpired = await getExpiredDeals();
    return allExpired
        .where((deal) => deal.regretLevel == 'critical' || deal.regretLevel == 'high')
        .toList();
  }
  
  /// Get recently expired deals (within last 6 hours)
  static Future<List<ExpiredDeal>> getRecentlyExpiredDeals() async {
    final allExpired = await getExpiredDeals();
    final now = DateTime.now();
    return allExpired
        .where((deal) => now.difference(deal.expiredAt).inHours <= 6)
        .toList();
  }
  
  /// Check if a specific deal is in expired list
  /// TEMPORARY: Checks expiration date directly until backend tracking is implemented
  static Future<bool> isDealExpired(String dealId) async {
    try {
      final allExpired = await getExpiredDeals();
      return allExpired.any((expiredDeal) => expiredDeal.deal.id == dealId);
    } catch (e) {
      print('Error checking if deal is expired: $e');
      return false;
    }
  }
  
  /// Remove expired deal from tracking (user acknowledged it)
  /// TEMPORARY: Returns true until backend implementation
  static Future<bool> acknowledgeExpiredDeal(String dealId) async {
    try {
      // TODO: Implement when backend endpoint is available
      print('Acknowledged expired deal: $dealId');
      return true;
    } catch (e) {
      print('Error acknowledging expired deal: $e');
      return false;
    }
  }
}