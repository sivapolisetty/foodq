import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kravekart/features/notifications/services/notification_service.dart';
import 'package:kravekart/features/notifications/models/notification.dart';
import 'package:kravekart/features/orders/models/order.dart';
import 'package:kravekart/shared/models/deal.dart';

@GenerateMocks([SupabaseClient])
import 'notification_service_test.mocks.dart';

void main() {
  late NotificationService notificationService;
  late MockSupabaseClient mockSupabaseClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    notificationService = NotificationService(supabaseClient: mockSupabaseClient);
  });

  group('NotificationService Tests', () {
    group('sendOrderStatusNotification', () {
      test('should send order confirmed notification', () async {
        // Arrange
        final mockOrder = Order(
          id: 'order-123',
          customerId: 'customer-456',
          items: [],
          totalAmount: 25.50,
          status: OrderStatus.confirmed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final expectedNotification = {
          'id': 'notif-123',
          'recipient_id': 'customer-456',
          'type': 'order_confirmed',
          'title': 'Order Confirmed!',
          'message': 'Your order #order-123 has been confirmed and is being prepared.',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Mock database calls
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').insert(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select().single()).thenAnswer((_) async => expectedNotification);

        // Act
        final result = await notificationService.sendOrderStatusNotification(mockOrder);

        // Assert
        expect(result.type, NotificationType.orderConfirmed);
        expect(result.recipientId, 'customer-456');
        expect(result.title, 'Order Confirmed!');
        expect(result.message.contains('order-123'), true);
      });

      test('should send order ready notification with pickup code', () async {
        // Arrange
        final mockOrder = Order(
          id: 'order-456',
          customerId: 'customer-789',
          items: [],
          totalAmount: 18.00,
          status: OrderStatus.ready,
          pickupCode: '123456',
          estimatedPickupTime: DateTime.now().add(const Duration(minutes: 5)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final expectedNotification = {
          'id': 'notif-456',
          'recipient_id': 'customer-789',
          'type': 'order_ready',
          'title': 'Order Ready for Pickup!',
          'message': 'Your order is ready! Use pickup code: 123-456',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Mock database calls
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').insert(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select().single()).thenAnswer((_) async => expectedNotification);

        // Act
        final result = await notificationService.sendOrderStatusNotification(mockOrder);

        // Assert
        expect(result.type, NotificationType.orderReady);
        expect(result.message.contains('123-456'), true);
      });

      test('should send order cancelled notification', () async {
        // Arrange
        final mockOrder = Order(
          id: 'order-789',
          customerId: 'customer-123',
          items: [],
          totalAmount: 32.00,
          status: OrderStatus.cancelled,
          cancelledReason: 'Out of ingredients',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final expectedNotification = {
          'id': 'notif-789',
          'recipient_id': 'customer-123',
          'type': 'order_cancelled',
          'title': 'Order Cancelled',
          'message': 'Your order has been cancelled: Out of ingredients',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Mock database calls
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').insert(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select().single()).thenAnswer((_) async => expectedNotification);

        // Act
        final result = await notificationService.sendOrderStatusNotification(mockOrder);

        // Assert
        expect(result.type, NotificationType.orderCancelled);
        expect(result.message.contains('Out of ingredients'), true);
      });
    });

    group('sendDealNotification', () {
      test('should send new deal notification', () async {
        // Arrange
        final mockDeal = Deal(
          id: 'deal-123',
          businessId: 'business-456',
          title: 'Flash Sale Pizza',
          description: '50% off pepperoni pizza',
          originalPrice: 20.0,
          discountedPrice: 10.0,
          quantityAvailable: 10,
          quantitySold: 0,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final customerId = 'customer-789';
        final expectedNotification = {
          'id': 'notif-deal-123',
          'recipient_id': customerId,
          'type': 'new_deal',
          'title': 'New Deal Alert!',
          'message': 'Flash Sale Pizza - 50% off pepperoni pizza. Only \$10.00!',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Mock database calls
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').insert(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select().single()).thenAnswer((_) async => expectedNotification);

        // Act
        final result = await notificationService.sendDealNotification(mockDeal, customerId);

        // Assert
        expect(result.type, NotificationType.newDeal);
        expect(result.recipientId, customerId);
        expect(result.message.contains('Flash Sale Pizza'), true);
        expect(result.message.contains('\$10.00'), true);
      });

      test('should send deal expiring notification', () async {
        // Arrange
        final mockDeal = Deal(
          id: 'deal-456',
          businessId: 'business-789',
          title: 'Last Chance Burger',
          description: 'Gourmet burger deal',
          originalPrice: 15.0,
          discountedPrice: 8.0,
          quantityAvailable: 2,
          quantitySold: 3,
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final customerId = 'customer-456';
        final expectedNotification = {
          'id': 'notif-expire-456',
          'recipient_id': customerId,
          'type': 'deal_expiring',
          'title': 'Deal Expiring Soon!',
          'message': 'Last Chance Burger expires in 30 minutes. Only 2 left!',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Mock database calls
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').insert(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').insert(any).select().single()).thenAnswer((_) async => expectedNotification);

        // Act
        final result = await notificationService.sendDealExpiringNotification(mockDeal, customerId);

        // Assert
        expect(result.type, NotificationType.dealExpiring);
        expect(result.message.contains('30 minutes'), true);
        expect(result.message.contains('Only 2 left'), true);
      });
    });

    group('getNotificationsForUser', () {
      test('should return user notifications sorted by date', () async {
        // Arrange
        final customerId = 'customer-123';
        final mockNotifications = [
          {
            'id': 'notif-1',
            'recipient_id': customerId,
            'type': 'order_confirmed',
            'title': 'Order Confirmed',
            'message': 'Your order has been confirmed',
            'is_read': false,
            'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          },
          {
            'id': 'notif-2',
            'recipient_id': customerId,
            'type': 'new_deal',
            'title': 'New Deal Alert',
            'message': 'Check out this amazing deal',
            'is_read': true,
            'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          },
        ];

        // Mock database query
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select().eq('recipient_id', customerId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select().eq('recipient_id', customerId).order('created_at')).thenAnswer((_) async => mockNotifications);

        // Act
        final result = await notificationService.getNotificationsForUser(customerId);

        // Assert
        expect(result.length, 2);
        expect(result.first.id, 'notif-1');
        expect(result.first.isRead, false);
        expect(result.last.id, 'notif-2');
        expect(result.last.isRead, true);
      });

      test('should return empty list when no notifications exist', () async {
        // Arrange
        final customerId = 'customer-no-notifs';

        // Mock database query returning empty list
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select().eq('recipient_id', customerId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select().eq('recipient_id', customerId).order('created_at')).thenAnswer((_) async => []);

        // Act
        final result = await notificationService.getNotificationsForUser(customerId);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('markAsRead', () {
      test('should mark notification as read', () async {
        // Arrange
        final notificationId = 'notif-123';
        final updatedNotification = {
          'id': notificationId,
          'is_read': true,
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Mock database update
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').update(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').update(any).eq('id', notificationId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').update(any).eq('id', notificationId).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').update(any).eq('id', notificationId).select().single()).thenAnswer((_) async => updatedNotification);

        // Act
        final result = await notificationService.markAsRead(notificationId);

        // Assert
        expect(result.isRead, true);
      });
    });

    group('getUnreadCount', () {
      test('should return correct unread count', () async {
        // Arrange
        final customerId = 'customer-123';
        final mockCountResponse = [{'count': 5}];

        // Mock database count query
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').select('id')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select('id').eq('recipient_id', customerId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select('id').eq('recipient_id', customerId).eq('is_read', false)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select('id').eq('recipient_id', customerId).eq('is_read', false).count()).thenAnswer((_) async => mockCountResponse);

        // Act
        final result = await notificationService.getUnreadCount(customerId);

        // Assert
        expect(result, 5);
      });

      test('should handle zero unread notifications', () async {
        // Arrange
        final customerId = 'customer-no-unread';
        final mockCountResponse = [{'count': 0}];

        // Mock database count query
        when(mockSupabaseClient.from('notifications')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('notifications').select('id')).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select('id').eq('recipient_id', customerId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select('id').eq('recipient_id', customerId).eq('is_read', false)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('notifications').select('id').eq('recipient_id', customerId).eq('is_read', false).count()).thenAnswer((_) async => mockCountResponse);

        // Act
        final result = await notificationService.getUnreadCount(customerId);

        // Assert
        expect(result, 0);
      });
    });

    group('subscribeToOrderUpdates', () {
      test('should set up real-time subscription for order updates', () async {
        // Arrange
        final customerId = 'customer-123';

        // Act
        final subscription = notificationService.subscribeToOrderUpdates(customerId);

        // Assert
        expect(subscription, isNotNull);
        // In a real test, you would verify the subscription setup
      });
    });

    group('error handling', () {
      test('should handle database errors gracefully', () async {
        // Arrange
        final customerId = 'customer-error';
        when(mockSupabaseClient.from('notifications')).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => notificationService.getNotificationsForUser(customerId),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle invalid notification data', () async {
        // Arrange
        final mockOrder = Order(
          id: '',
          customerId: '',
          items: [],
          totalAmount: 0,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => notificationService.sendOrderStatusNotification(mockOrder),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// Mock classes for Supabase
class MockPostgrestQueryBuilder extends Mock {}
class MockPostgrestFilterBuilder extends Mock {}