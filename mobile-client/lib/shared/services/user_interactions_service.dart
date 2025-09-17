import 'dart:async';
import '../../core/services/api_service.dart';
import '../../core/config/api_config.dart';

/// Simple service for tracking user interactions with deals
/// All complex logic happens on the backend
class UserInteractionsService {
  
  /// Track when a user views a deal
  static Future<bool> trackDealViewed(String dealId) async {
    try {
      final response = await ApiService.post<dynamic>(
        '${ApiConfig.userInteractionsEndpoint}/deal-viewed',
        body: {
          'deal_id': dealId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.success;
    } catch (e) {
      print('Error tracking deal view: $e');
      return false;
    }
  }
  
  /// Track when a user purchases a deal
  static Future<bool> trackDealPurchased(String dealId, String orderId) async {
    try {
      final response = await ApiService.post<dynamic>(
        '${ApiConfig.userInteractionsEndpoint}/deal-purchased',
        body: {
          'deal_id': dealId,
          'order_id': orderId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.success;
    } catch (e) {
      print('Error tracking deal purchase: $e');
      return false;
    }
  }
  
  /// Track when a user adds deal to cart
  static Future<bool> trackDealAddedToCart(String dealId) async {
    try {
      final response = await ApiService.post<dynamic>(
        '${ApiConfig.userInteractionsEndpoint}/deal-added-to-cart',
        body: {
          'deal_id': dealId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.success;
    } catch (e) {
      print('Error tracking deal added to cart: $e');
      return false;
    }
  }
  
  /// Track when a user removes deal from cart
  static Future<bool> trackDealRemovedFromCart(String dealId) async {
    try {
      final response = await ApiService.post<dynamic>(
        '${ApiConfig.userInteractionsEndpoint}/deal-removed-from-cart',
        body: {
          'deal_id': dealId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.success;
    } catch (e) {
      print('Error tracking deal removed from cart: $e');
      return false;
    }
  }
  
  /// Track when a user shares a deal
  static Future<bool> trackDealShared(String dealId, String shareMethod) async {
    try {
      final response = await ApiService.post<dynamic>(
        '${ApiConfig.userInteractionsEndpoint}/deal-shared',
        body: {
          'deal_id': dealId,
          'share_method': shareMethod, // 'link', 'social', 'message'
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.success;
    } catch (e) {
      print('Error tracking deal share: $e');
      return false;
    }
  }
}