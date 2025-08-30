import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/deal.dart';

/// Service for managing notifications and real-time updates
class NotificationService {
  final SupabaseClient _supabaseClient;
  final Map<String, StreamSubscription> _subscriptions = {};

  NotificationService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Send order status notification to customer
  Future<AppNotification> sendOrderStatusNotification(Order order) async {
    try {
      final notification = _createOrderStatusNotification(order);
      
      final response = await _supabaseClient
          .from('notifications')
          .insert(notification.toJson())
          .select()
          .single();

      // Send push notification if available
      await _sendPushNotification(notification);

      return AppNotification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send order notification: ${e.toString()}');
    }
  }

  /// Send new deal notification to interested customers
  Future<AppNotification> sendDealNotification(Deal deal, String customerId) async {
    try {
      final notification = AppNotification.forNewDeal(
        recipientId: customerId,
        dealId: deal.id,
        title: 'New Deal Alert!',
        message: '${deal.title} - ${deal.description}. Only \$${deal.discountedPrice.toStringAsFixed(2)}!',
        imageUrl: deal.imageUrl,
      );

      final response = await _supabaseClient
          .from('notifications')
          .insert(notification.toJson())
          .select()
          .single();

      await _sendPushNotification(notification);

      return AppNotification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send deal notification: ${e.toString()}');
    }
  }

  /// Send deal expiring notification
  Future<AppNotification> sendDealExpiringNotification(Deal deal, String customerId) async {
    try {
      final timeUntilExpiry = deal.expiresAt.difference(DateTime.now());
      final timeText = timeUntilExpiry.inHours > 0 
          ? '${timeUntilExpiry.inHours} hours'
          : '${timeUntilExpiry.inMinutes} minutes';
      
      final notification = AppNotification(
        id: 'expire_${deal.id}_${DateTime.now().millisecondsSinceEpoch}',
        recipientId: customerId,
        type: NotificationType.dealExpiring,
        title: 'Deal Expiring Soon!',
        message: '${deal.title} expires in $timeText. Only ${deal.quantityAvailable} left!',
        actionUrl: '/deal/${deal.id}',
        relatedId: deal.id,
        priority: NotificationPriority.high,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _supabaseClient
          .from('notifications')
          .insert(notification.toJson())
          .select()
          .single();

      await _sendPushNotification(notification);

      return AppNotification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send expiring deal notification: ${e.toString()}');
    }
  }

  /// Get notifications for a specific user
  Future<List<AppNotification>> getNotificationsForUser(
    String userId, {
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      var query = _supabaseClient
          .from('notifications')
          .select()
          .eq('recipient_id', userId);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .where((notification) => !notification.isExpired)
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }

  /// Mark notification as read
  Future<AppNotification> markAsRead(String notificationId) async {
    try {
      final response = await _supabaseClient
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .select()
          .single();

      return AppNotification.fromJson(response);
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('recipient_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  /// Get unread notification count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabaseClient
          .from('notifications')
          .select('id')
          .eq('recipient_id', userId)
          .eq('is_read', false)
          .count();

      return (response as List<dynamic>).first['count'] as int;
    } catch (e) {
      throw Exception('Failed to get unread count: ${e.toString()}');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }

  /// Subscribe to real-time order updates
  StreamSubscription subscribeToOrderUpdates(String customerId) {
    final subscription = _supabaseClient
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', customerId)
        .listen((List<Map<String, dynamic>> data) {
          // Handle real-time notification updates
          for (final json in data) {
            final notification = AppNotification.fromJson(json);
            _handleRealtimeNotification(notification);
          }
        });

    _subscriptions['orders_$customerId'] = subscription;
    return subscription;
  }

  /// Subscribe to deal updates
  StreamSubscription subscribeToDealUpdates(String customerId) {
    final subscription = _supabaseClient
        .from('deals')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          // Handle new deals, price changes, etc.
          for (final json in data) {
            _handleDealUpdate(json, customerId);
          }
        });

    _subscriptions['deals_$customerId'] = subscription;
    return subscription;
  }

  /// Send system announcement to all users or specific group
  Future<List<AppNotification>> sendSystemAnnouncement({
    required String title,
    required String message,
    List<String>? recipientIds,
    String? actionUrl,
    NotificationPriority priority = NotificationPriority.normal,
    DateTime? expiresAt,
  }) async {
    try {
      final recipients = recipientIds ?? await _getAllActiveUserIds();
      final notifications = <AppNotification>[];

      for (final recipientId in recipients) {
        final notification = AppNotification.systemAnnouncement(
          recipientId: recipientId,
          title: title,
          message: message,
          actionUrl: actionUrl,
          priority: priority,
          expiresAt: expiresAt,
        );

        final response = await _supabaseClient
            .from('notifications')
            .insert(notification.toJson())
            .select()
            .single();

        final createdNotification = AppNotification.fromJson(response);
        notifications.add(createdNotification);
        
        await _sendPushNotification(createdNotification);
      }

      return notifications;
    } catch (e) {
      throw Exception('Failed to send system announcement: ${e.toString()}');
    }
  }

  /// Clean up expired notifications
  Future<void> cleanupExpiredNotifications() async {
    try {
      await _supabaseClient
          .from('notifications')
          .delete()
          .lt('expires_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Failed to cleanup expired notifications: ${e.toString()}');
    }
  }

  /// Dispose of all subscriptions
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  // Private helper methods

  AppNotification _createOrderStatusNotification(Order order) {
    String title;
    String message;
    NotificationType type;
    NotificationPriority priority = NotificationPriority.normal;

    switch (order.status) {
      case OrderStatus.confirmed:
        type = NotificationType.orderConfirmed;
        title = 'Order Confirmed!';
        message = 'Your order #${order.id} has been confirmed. Show QR code or pickup code: ${order.formattedVerificationCode}';
        break;
      case OrderStatus.completed:
        type = NotificationType.orderCompleted;
        title = 'Order Completed';
        message = 'Thank you for your order! We hope you enjoyed your meal.';
        break;
      case OrderStatus.cancelled:
        type = NotificationType.orderCancelled;
        title = 'Order Cancelled';
        message = 'Your order has been cancelled. Please contact the restaurant for more details.';
        priority = NotificationPriority.high;
        break;
      default:
        throw Exception('Unsupported order status: ${order.status}');
    }

    return AppNotification.forOrderStatus(
      recipientId: order.userId,
      orderId: order.id,
      type: type,
      title: title,
      message: message,
      priority: priority,
    );
  }

  String _formatPickupTime(DateTime? pickupTime) {
    if (pickupTime == null) return 'soon';
    
    final now = DateTime.now();
    final difference = pickupTime.difference(now);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes';
    } else {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    }
  }

  Future<void> _sendPushNotification(AppNotification notification) async {
    // In a real implementation, this would send push notifications
    // via Firebase Cloud Messaging, APNs, or another service
    // For now, we'll just log it
    print('🔔 Push notification sent: ${notification.title}');
  }

  void _handleRealtimeNotification(AppNotification notification) {
    // Handle real-time notification updates
    // This could trigger local notifications, update UI, etc.
    print('🔄 Real-time notification: ${notification.title}');
  }

  void _handleDealUpdate(Map<String, dynamic> dealJson, String customerId) {
    // Handle deal updates and send notifications if relevant
    // This could check user preferences, location, etc.
    print('📢 Deal update for customer $customerId');
  }

  Future<List<String>> _getAllActiveUserIds() async {
    try {
      // In a real implementation, this would query the users table
      // For demo purposes, return empty list
      return [];
    } catch (e) {
      return [];
    }
  }
}