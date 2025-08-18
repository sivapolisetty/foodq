import 'package:flutter_test/flutter_test.dart';
import 'package:kravekart/features/notifications/models/notification.dart';
import 'package:kravekart/features/orders/models/order.dart';
import 'package:kravekart/shared/models/deal.dart';

void main() {
  group('NotificationService Unit Tests (Simple)', () {
    group('AppNotification Model Tests', () {
      test('should create notification with correct properties', () {
        // Arrange
        final now = DateTime.now();
        final notification = AppNotification(
          id: 'test-123',
          recipientId: 'user-456',
          type: NotificationType.orderConfirmed,
          title: 'Order Confirmed',
          message: 'Your order has been confirmed',
          priority: NotificationPriority.normal,
          createdAt: now,
          updatedAt: now,
        );

        // Assert
        expect(notification.id, 'test-123');
        expect(notification.recipientId, 'user-456');
        expect(notification.type, NotificationType.orderConfirmed);
        expect(notification.title, 'Order Confirmed');
        expect(notification.message, 'Your order has been confirmed');
        expect(notification.priority, NotificationPriority.normal);
        expect(notification.isRead, false);
        expect(notification.createdAt, now);
        expect(notification.updatedAt, now);
      });

      test('should check if notification is expired correctly', () {
        // Arrange
        final expiredNotification = AppNotification(
          id: 'expired-123',
          recipientId: 'user-456',
          type: NotificationType.newDeal,
          title: 'Expired Deal',
          message: 'This deal has expired',
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        final activeNotification = AppNotification(
          id: 'active-123',
          recipientId: 'user-456',
          type: NotificationType.newDeal,
          title: 'Active Deal',
          message: 'This deal is still active',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(expiredNotification.isExpired, true);
        expect(activeNotification.isExpired, false);
      });

      test('should check if notification is recent correctly', () {
        // Arrange
        final recentNotification = AppNotification(
          id: 'recent-123',
          recipientId: 'user-456',
          type: NotificationType.orderReady,
          title: 'Recent Order',
          message: 'Your order is ready',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final oldNotification = AppNotification(
          id: 'old-123',
          recipientId: 'user-456',
          type: NotificationType.orderCompleted,
          title: 'Old Order',
          message: 'Your order was completed',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        // Assert
        expect(recentNotification.isRecent, true);
        expect(oldNotification.isRecent, false);
      });

      test('should format time ago correctly', () {
        // Arrange
        final justNowNotification = AppNotification(
          id: 'just-now-123',
          recipientId: 'user-456',
          type: NotificationType.orderConfirmed,
          title: 'Just Now',
          message: 'Just created',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final minutesAgoNotification = AppNotification(
          id: 'minutes-ago-123',
          recipientId: 'user-456',
          type: NotificationType.orderConfirmed,
          title: 'Minutes Ago',
          message: 'Created minutes ago',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        final hoursAgoNotification = AppNotification(
          id: 'hours-ago-123',
          recipientId: 'user-456',
          type: NotificationType.orderConfirmed,
          title: 'Hours Ago',
          message: 'Created hours ago',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        );

        // Assert
        expect(justNowNotification.timeAgo, 'Just now');
        expect(minutesAgoNotification.timeAgo, '30m ago');
        expect(hoursAgoNotification.timeAgo, '3h ago');
      });

      test('should check high priority notifications correctly', () {
        // Arrange
        final highPriorityNotification = AppNotification(
          id: 'high-123',
          recipientId: 'user-456',
          type: NotificationType.orderCancelled,
          title: 'High Priority',
          message: 'High priority notification',
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final normalPriorityNotification = AppNotification(
          id: 'normal-123',
          recipientId: 'user-456',
          type: NotificationType.orderConfirmed,
          title: 'Normal Priority',
          message: 'Normal priority notification',
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(highPriorityNotification.isHighPriority, true);
        expect(normalPriorityNotification.isHighPriority, false);
      });

      test('should show badge for unread, non-expired notifications', () {
        // Arrange
        final shouldShowBadge = AppNotification(
          id: 'badge-123',
          recipientId: 'user-456',
          type: NotificationType.newDeal,
          title: 'Should Show Badge',
          message: 'Unread and not expired',
          isRead: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final shouldNotShowBadge = AppNotification(
          id: 'no-badge-123',
          recipientId: 'user-456',
          type: NotificationType.newDeal,
          title: 'Should Not Show Badge',
          message: 'Read notification',
          isRead: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(shouldShowBadge.shouldShowBadge, true);
        expect(shouldNotShowBadge.shouldShowBadge, false);
      });

      test('should truncate long messages for summary', () {
        // Arrange
        final longMessage = 'This is a very long notification message that should be truncated when displayed in the summary view to prevent overflow and maintain good UI design';
        
        final notification = AppNotification(
          id: 'long-123',
          recipientId: 'user-456',
          type: NotificationType.systemAnnouncement,
          title: 'Long Message',
          message: longMessage,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(notification.summary.length, lessThanOrEqualTo(100));
        expect(notification.summary.endsWith('...'), true);
      });
    });

    group('NotificationType Tests', () {
      test('should identify order-related notifications correctly', () {
        // Assert
        expect(NotificationType.orderConfirmed.isOrderRelated, true);
        expect(NotificationType.orderPreparing.isOrderRelated, true);
        expect(NotificationType.orderReady.isOrderRelated, true);
        expect(NotificationType.orderCompleted.isOrderRelated, true);
        expect(NotificationType.orderCancelled.isOrderRelated, true);
        expect(NotificationType.newDeal.isOrderRelated, false);
        expect(NotificationType.systemAnnouncement.isOrderRelated, false);
      });

      test('should identify deal-related notifications correctly', () {
        // Assert
        expect(NotificationType.newDeal.isDealRelated, true);
        expect(NotificationType.dealExpiring.isDealRelated, true);
        expect(NotificationType.dealSoldOut.isDealRelated, true);
        expect(NotificationType.orderConfirmed.isDealRelated, false);
        expect(NotificationType.paymentSuccessful.isDealRelated, false);
      });

      test('should identify payment-related notifications correctly', () {
        // Assert
        expect(NotificationType.paymentSuccessful.isPaymentRelated, true);
        expect(NotificationType.paymentFailed.isPaymentRelated, true);
        expect(NotificationType.orderConfirmed.isPaymentRelated, false);
        expect(NotificationType.newDeal.isPaymentRelated, false);
      });

      test('should have correct display names', () {
        // Assert
        expect(NotificationType.orderConfirmed.displayName, 'Order Confirmed');
        expect(NotificationType.newDeal.displayName, 'New Deal');
        expect(NotificationType.paymentFailed.displayName, 'Payment Failed');
        expect(NotificationType.systemAnnouncement.displayName, 'System Announcement');
      });

      test('should have correct icon colors', () {
        // Assert
        expect(NotificationType.orderConfirmed.iconColor, 0xFF4CAF50); // Green
        expect(NotificationType.orderCancelled.iconColor, 0xFFF44336); // Red
        expect(NotificationType.newDeal.iconColor, 0xFFFF9800); // Orange
        expect(NotificationType.systemAnnouncement.iconColor, 0xFF9C27B0); // Purple
      });
    });

    group('NotificationPriority Tests', () {
      test('should have correct display names', () {
        // Assert
        expect(NotificationPriority.low.displayName, 'Low');
        expect(NotificationPriority.normal.displayName, 'Normal');
        expect(NotificationPriority.high.displayName, 'High');
        expect(NotificationPriority.urgent.displayName, 'Urgent');
      });

      test('should have correct priority values', () {
        // Assert
        expect(NotificationPriority.low.priority, 0);
        expect(NotificationPriority.normal.priority, 1);
        expect(NotificationPriority.high.priority, 2);
        expect(NotificationPriority.urgent.priority, 3);
      });
    });

    group('Factory Constructors Tests', () {
      test('should create order status notification correctly', () {
        // Arrange & Act
        final notification = AppNotification.forOrderStatus(
          recipientId: 'user-123',
          orderId: 'order-456',
          type: NotificationType.orderReady,
          title: 'Order Ready',
          message: 'Your order is ready for pickup',
          priority: NotificationPriority.high,
        );

        // Assert
        expect(notification.recipientId, 'user-123');
        expect(notification.relatedId, 'order-456');
        expect(notification.type, NotificationType.orderReady);
        expect(notification.title, 'Order Ready');
        expect(notification.message, 'Your order is ready for pickup');
        expect(notification.priority, NotificationPriority.high);
        expect(notification.actionUrl, '/order/order-456');
        expect(notification.id.startsWith('order_order-456_'), true);
      });

      test('should create new deal notification correctly', () {
        // Arrange & Act
        final notification = AppNotification.forNewDeal(
          recipientId: 'user-123',
          dealId: 'deal-789',
          title: 'Amazing Pizza Deal',
          message: '50% off all pizzas today only!',
          imageUrl: 'https://example.com/pizza.jpg',
        );

        // Assert
        expect(notification.recipientId, 'user-123');
        expect(notification.relatedId, 'deal-789');
        expect(notification.type, NotificationType.newDeal);
        expect(notification.title, 'Amazing Pizza Deal');
        expect(notification.message, '50% off all pizzas today only!');
        expect(notification.imageUrl, 'https://example.com/pizza.jpg');
        expect(notification.actionUrl, '/deal/deal-789');
        expect(notification.priority, NotificationPriority.normal);
        expect(notification.id.startsWith('deal_deal-789_'), true);
      });

      test('should create system announcement correctly', () {
        // Arrange
        final expiresAt = DateTime.now().add(const Duration(days: 7));
        
        // Act
        final notification = AppNotification.systemAnnouncement(
          recipientId: 'user-123',
          title: 'New Feature Available',
          message: 'Check out our new order tracking feature!',
          actionUrl: '/features/tracking',
          expiresAt: expiresAt,
          priority: NotificationPriority.high,
        );

        // Assert
        expect(notification.recipientId, 'user-123');
        expect(notification.type, NotificationType.systemAnnouncement);
        expect(notification.title, 'New Feature Available');
        expect(notification.message, 'Check out our new order tracking feature!');
        expect(notification.actionUrl, '/features/tracking');
        expect(notification.expiresAt, expiresAt);
        expect(notification.priority, NotificationPriority.high);
        expect(notification.id.startsWith('system_'), true);
      });
    });
  });
}