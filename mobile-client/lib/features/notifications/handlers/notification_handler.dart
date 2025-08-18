import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';
import '../providers/notification_provider.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/deal.dart';

/// Handler for managing real-time notifications and local notifications
class NotificationHandler {
  final NotificationService _notificationService;
  final WidgetRef _ref;
  final String _userId;
  
  StreamSubscription? _orderSubscription;
  StreamSubscription? _dealSubscription;
  Timer? _periodicTimer;

  NotificationHandler({
    required NotificationService notificationService,
    required WidgetRef ref,
    required String userId,
  }) : _notificationService = notificationService,
       _ref = ref,
       _userId = userId;

  /// Initialize the notification handler
  Future<void> initialize() async {
    await _setupRealtimeSubscriptions();
    _setupPeriodicChecks();
  }

  /// Setup real-time subscriptions for orders and deals
  Future<void> _setupRealtimeSubscriptions() async {
    try {
      // Subscribe to order updates
      _orderSubscription = _notificationService.subscribeToOrderUpdates(_userId);
      
      // Subscribe to deal updates
      _dealSubscription = _notificationService.subscribeToDealUpdates(_userId);
      
      print('✅ Real-time notification subscriptions initialized');
    } catch (e) {
      print('❌ Failed to setup real-time subscriptions: $e');
    }
  }

  /// Setup periodic checks for expired deals and other time-sensitive notifications
  void _setupPeriodicChecks() {
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkForExpiringDeals();
      _cleanupExpiredNotifications();
    });
  }

  /// Handle new order status change
  Future<void> handleOrderStatusChange(Order order) async {
    try {
      final notification = await _notificationService.sendOrderStatusNotification(order);
      
      // Update local state
      _ref.read(notificationProvider(_userId).notifier).refreshNotifications();
      
      // Show local notification if app is in foreground
      await _showLocalNotification(notification);
      
      print('📱 Order status notification sent: ${notification.title}');
    } catch (e) {
      print('❌ Failed to handle order status change: $e');
    }
  }

  /// Handle new deal notification
  Future<void> handleNewDeal(Deal deal) async {
    try {
      final notification = await _notificationService.sendDealNotification(deal, _userId);
      
      // Update local state
      _ref.read(notificationProvider(_userId).notifier).refreshNotifications();
      
      // Show local notification
      await _showLocalNotification(notification);
      
      print('🎉 New deal notification sent: ${notification.title}');
    } catch (e) {
      print('❌ Failed to handle new deal: $e');
    }
  }

  /// Handle deal expiring soon
  Future<void> handleDealExpiring(Deal deal) async {
    try {
      final notification = await _notificationService.sendDealExpiringNotification(deal, _userId);
      
      // Update local state
      _ref.read(notificationProvider(_userId).notifier).refreshNotifications();
      
      // Show local notification with high priority
      await _showLocalNotification(notification);
      
      print('⏰ Deal expiring notification sent: ${notification.title}');
    } catch (e) {
      print('❌ Failed to handle deal expiring: $e');
    }
  }

  /// Send system announcement
  Future<void> sendSystemAnnouncement({
    required String title,
    required String message,
    List<String>? recipientIds,
    String? actionUrl,
    NotificationPriority priority = NotificationPriority.normal,
    DateTime? expiresAt,
  }) async {
    try {
      final notifications = await _notificationService.sendSystemAnnouncement(
        title: title,
        message: message,
        recipientIds: recipientIds,
        actionUrl: actionUrl,
        priority: priority,
        expiresAt: expiresAt,
      );
      
      // Refresh notifications for affected users
      if (recipientIds == null || recipientIds.contains(_userId)) {
        _ref.read(notificationProvider(_userId).notifier).refreshNotifications();
        
        // Show local notification if user is affected
        if (notifications.isNotEmpty) {
          final userNotification = notifications.firstWhere(
            (n) => n.recipientId == _userId,
            orElse: () => notifications.first,
          );
          await _showLocalNotification(userNotification);
        }
      }
      
      print('📢 System announcement sent to ${notifications.length} users');
    } catch (e) {
      print('❌ Failed to send system announcement: $e');
    }
  }

  /// Check for deals that are expiring soon
  Future<void> _checkForExpiringDeals() async {
    try {
      // In a real implementation, this would query the deals service
      // For now, we'll just log the check
      print('🔍 Checking for expiring deals...');
    } catch (e) {
      print('❌ Failed to check expiring deals: $e');
    }
  }

  /// Clean up expired notifications
  Future<void> _cleanupExpiredNotifications() async {
    try {
      await _notificationService.cleanupExpiredNotifications();
      print('🧹 Expired notifications cleaned up');
    } catch (e) {
      print('❌ Failed to cleanup expired notifications: $e');
    }
  }

  /// Show local notification (in-app notification)
  Future<void> _showLocalNotification(AppNotification notification) async {
    try {
      // In a real implementation, this would use flutter_local_notifications
      // or firebase_messaging for push notifications
      
      // For now, we'll simulate showing an in-app notification
      print('🔔 Local notification: ${notification.title}');
      print('   Message: ${notification.message}');
      print('   Priority: ${notification.priority.displayName}');
      
      // You could also show a SnackBar, Dialog, or custom overlay here
      // depending on the app's current state and notification priority
      
    } catch (e) {
      print('❌ Failed to show local notification: $e');
    }
  }

  /// Handle notification tap action
  Future<void> handleNotificationTap(AppNotification notification) async {
    try {
      // Mark as read
      await _ref.read(notificationProvider(_userId).notifier)
          .markAsRead(notification.id);
      
      // Handle navigation based on notification type and action URL
      if (notification.actionUrl != null) {
        await _handleNavigationAction(notification.actionUrl!, notification.type);
      }
      
      print('👆 Notification tapped: ${notification.title}');
    } catch (e) {
      print('❌ Failed to handle notification tap: $e');
    }
  }

  /// Handle navigation action from notification
  Future<void> _handleNavigationAction(String actionUrl, NotificationType type) async {
    try {
      print('🧭 Navigation action: $actionUrl for type: ${type.displayName}');
      
      // In a real implementation, you would use proper navigation here
      // For example, using GoRouter, Navigator, or your preferred routing solution
      
      switch (type) {
        case NotificationType.orderConfirmed:
        case NotificationType.orderPreparing:
        case NotificationType.orderReady:
        case NotificationType.orderCompleted:
        case NotificationType.orderCancelled:
          // Navigate to order details
          print('   → Navigate to order details: $actionUrl');
          break;
          
        case NotificationType.newDeal:
        case NotificationType.dealExpiring:
        case NotificationType.dealSoldOut:
          // Navigate to deal details
          print('   → Navigate to deal details: $actionUrl');
          break;
          
        case NotificationType.paymentSuccessful:
        case NotificationType.paymentFailed:
          // Navigate to payment details
          print('   → Navigate to payment details: $actionUrl');
          break;
          
        case NotificationType.systemAnnouncement:
        case NotificationType.restaurantUpdate:
          // Handle system announcements
          print('   → Handle system announcement: $actionUrl');
          break;
      }
    } catch (e) {
      print('❌ Failed to handle navigation action: $e');
    }
  }

  /// Get notification summary for display
  Map<String, dynamic> getNotificationSummary() {
    final state = _ref.read(notificationProvider(_userId));
    
    return {
      'total': state.notifications.length,
      'unread': state.unreadCount,
      'recent': state.notifications.where((n) => n.isRecent).length,
      'highPriority': state.notifications.where((n) => n.isHighPriority).length,
      'orderRelated': state.notifications.where((n) => n.type.isOrderRelated).length,
      'dealRelated': state.notifications.where((n) => n.type.isDealRelated).length,
    };
  }

  /// Dispose of resources
  void dispose() {
    _orderSubscription?.cancel();
    _dealSubscription?.cancel();
    _periodicTimer?.cancel();
    _notificationService.dispose();
    print('🧹 NotificationHandler disposed');
  }
}

/// Provider for the notification handler
final notificationHandlerProvider = Provider.family<NotificationHandler, String>((ref, userId) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationHandler(
    notificationService: notificationService,
    ref: ref,
    userId: userId,
  );
});