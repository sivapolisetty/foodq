import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum NotificationType {
  @JsonValue('order_confirmed')
  orderConfirmed,
  @JsonValue('order_preparing')
  orderPreparing,
  @JsonValue('order_ready')
  orderReady,
  @JsonValue('order_completed')
  orderCompleted,
  @JsonValue('order_cancelled')
  orderCancelled,
  @JsonValue('new_deal')
  newDeal,
  @JsonValue('deal_expiring')
  dealExpiring,
  @JsonValue('deal_sold_out')
  dealSoldOut,
  @JsonValue('payment_successful')
  paymentSuccessful,
  @JsonValue('payment_failed')
  paymentFailed,
  @JsonValue('system_announcement')
  systemAnnouncement,
  @JsonValue('restaurant_update')
  restaurantUpdate;

  String get displayName {
    switch (this) {
      case NotificationType.orderConfirmed:
        return 'Order Confirmed';
      case NotificationType.orderPreparing:
        return 'Order Being Prepared';
      case NotificationType.orderReady:
        return 'Order Ready';
      case NotificationType.orderCompleted:
        return 'Order Completed';
      case NotificationType.orderCancelled:
        return 'Order Cancelled';
      case NotificationType.newDeal:
        return 'New Deal';
      case NotificationType.dealExpiring:
        return 'Deal Expiring';
      case NotificationType.dealSoldOut:
        return 'Deal Sold Out';
      case NotificationType.paymentSuccessful:
        return 'Payment Successful';
      case NotificationType.paymentFailed:
        return 'Payment Failed';
      case NotificationType.systemAnnouncement:
        return 'System Announcement';
      case NotificationType.restaurantUpdate:
        return 'Restaurant Update';
    }
  }

  int get iconColor {
    switch (this) {
      case NotificationType.orderConfirmed:
      case NotificationType.orderReady:
      case NotificationType.orderCompleted:
      case NotificationType.paymentSuccessful:
        return 0xFF4CAF50; // Green
      case NotificationType.orderPreparing:
        return 0xFF2196F3; // Blue
      case NotificationType.orderCancelled:
      case NotificationType.paymentFailed:
        return 0xFFF44336; // Red
      case NotificationType.newDeal:
        return 0xFFFF9800; // Orange
      case NotificationType.dealExpiring:
      case NotificationType.dealSoldOut:
        return 0xFFFF5722; // Deep Orange
      case NotificationType.systemAnnouncement:
      case NotificationType.restaurantUpdate:
        return 0xFF9C27B0; // Purple
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.orderConfirmed:
        return 'check_circle';
      case NotificationType.orderPreparing:
        return 'restaurant';
      case NotificationType.orderReady:
        return 'notifications_active';
      case NotificationType.orderCompleted:
        return 'done_all';
      case NotificationType.orderCancelled:
        return 'cancel';
      case NotificationType.newDeal:
        return 'local_offer';
      case NotificationType.dealExpiring:
        return 'schedule';
      case NotificationType.dealSoldOut:
        return 'remove_shopping_cart';
      case NotificationType.paymentSuccessful:
        return 'payment';
      case NotificationType.paymentFailed:
        return 'error';
      case NotificationType.systemAnnouncement:
        return 'campaign';
      case NotificationType.restaurantUpdate:
        return 'store';
    }
  }

  bool get isOrderRelated => [
    NotificationType.orderConfirmed,
    NotificationType.orderPreparing,
    NotificationType.orderReady,
    NotificationType.orderCompleted,
    NotificationType.orderCancelled,
  ].contains(this);

  bool get isDealRelated => [
    NotificationType.newDeal,
    NotificationType.dealExpiring,
    NotificationType.dealSoldOut,
  ].contains(this);

  bool get isPaymentRelated => [
    NotificationType.paymentSuccessful,
    NotificationType.paymentFailed,
  ].contains(this);
}

enum NotificationPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent;

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  int get priority => index;
}

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    @JsonKey(name: 'recipient_id') required String recipientId,
    required NotificationType type,
    required String title,
    required String message,
    @JsonKey(name: 'action_url') String? actionUrl,
    @JsonKey(name: 'related_id') String? relatedId, // order_id, deal_id, etc.
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default(NotificationPriority.normal) NotificationPriority priority,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'metadata') Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

  const AppNotification._();

  /// Check if notification has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if notification is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inHours < 24;
  }

  /// Get time ago string for display
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Get formatted created date
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (notificationDate == today) {
      return 'Today ${_formatTime(createdAt)}';
    } else if (notificationDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${_formatTime(createdAt)}';
    } else {
      return '${_formatDate(createdAt)} ${_formatTime(createdAt)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  /// Check if this is a high priority notification
  bool get isHighPriority => [
    NotificationPriority.high,
    NotificationPriority.urgent,
  ].contains(priority);

  /// Check if notification should show badge
  bool get shouldShowBadge => !isRead && !isExpired;

  /// Get summary for notification list
  String get summary {
    if (message.length <= 100) return message;
    return '${message.substring(0, 97)}...';
  }

  /// Create notification for order status change
  static AppNotification forOrderStatus({
    required String recipientId,
    required String orderId,
    required NotificationType type,
    required String title,
    required String message,
    String? actionUrl,
    NotificationPriority priority = NotificationPriority.normal,
  }) {
    return AppNotification(
      id: 'order_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
      recipientId: recipientId,
      type: type,
      title: title,
      message: message,
      actionUrl: actionUrl ?? '/order/$orderId',
      relatedId: orderId,
      priority: priority,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create notification for new deal
  static AppNotification forNewDeal({
    required String recipientId,
    required String dealId,
    required String title,
    required String message,
    String? imageUrl,
    String? actionUrl,
  }) {
    return AppNotification(
      id: 'deal_${dealId}_${DateTime.now().millisecondsSinceEpoch}',
      recipientId: recipientId,
      type: NotificationType.newDeal,
      title: title,
      message: message,
      actionUrl: actionUrl ?? '/deal/$dealId',
      relatedId: dealId,
      imageUrl: imageUrl,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create system announcement notification
  static AppNotification systemAnnouncement({
    required String recipientId,
    required String title,
    required String message,
    String? actionUrl,
    DateTime? expiresAt,
    NotificationPriority priority = NotificationPriority.normal,
  }) {
    return AppNotification(
      id: 'system_${DateTime.now().millisecondsSinceEpoch}',
      recipientId: recipientId,
      type: NotificationType.systemAnnouncement,
      title: title,
      message: message,
      actionUrl: actionUrl,
      priority: priority,
      expiresAt: expiresAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}