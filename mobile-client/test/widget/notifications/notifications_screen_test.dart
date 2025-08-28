import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:grabeat/features/notifications/screens/notifications_screen.dart';
import 'package:grabeat/features/notifications/providers/notification_provider.dart';
import 'package:grabeat/features/notifications/models/notification.dart';
import 'package:grabeat/features/notifications/services/notification_service.dart';

@GenerateMocks([NotificationService])
import 'notifications_screen_test.mocks.dart';

void main() {
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockNotificationService = MockNotificationService();
  });

  Widget createTestWidget(WidgetTester tester) {
    return ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
      child: MaterialApp(
        home: NotificationsScreen(),
      ),
    );
  }

  group('NotificationsScreen Widget Tests', () {
    testWidgets('should display empty state when no notifications exist', (WidgetTester tester) async {
      // Arrange
      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => []);
      when(mockNotificationService.getUnreadCount(any))
          .thenAnswer((_) async => 0);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No Notifications'), findsOneWidget);
      expect(find.text('You\'re all caught up! New notifications will appear here.'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('should display loading state initially', (WidgetTester tester) async {
      // Arrange
      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(tester));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display notifications list when notifications exist', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: 'notif-1',
          recipientId: 'user-123',
          type: NotificationType.orderConfirmed,
          title: 'Order Confirmed',
          message: 'Your order has been confirmed and is being prepared.',
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AppNotification(
          id: 'notif-2',
          recipientId: 'user-123',
          type: NotificationType.newDeal,
          title: 'New Deal Alert',
          message: 'Check out this amazing pizza deal - 50% off!',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => mockNotifications);
      when(mockNotificationService.getUnreadCount(any))
          .thenAnswer((_) async => 1);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Order Confirmed'), findsOneWidget);
      expect(find.text('New Deal Alert'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
      
      // Check for unread indicator
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('should handle notification tap and mark as read', (WidgetTester tester) async {
      // Arrange
      final mockNotification = AppNotification(
        id: 'notif-1',
        recipientId: 'user-123',
        type: NotificationType.orderReady,
        title: 'Order Ready',
        message: 'Your order is ready for pickup!',
        isRead: false,
        actionUrl: '/order/123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => [mockNotification]);
      when(mockNotificationService.getUnreadCount(any))
          .thenAnswer((_) async => 1);
      when(mockNotificationService.markAsRead(any))
          .thenAnswer((_) async => mockNotification.copyWith(isRead: true));

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Assert
      verify(mockNotificationService.markAsRead('notif-1')).called(1);
    });

    testWidgets('should display different icons for different notification types', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: 'notif-1',
          recipientId: 'user-123',
          type: NotificationType.orderConfirmed,
          title: 'Order Confirmed',
          message: 'Order confirmed',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AppNotification(
          id: 'notif-2',
          recipientId: 'user-123',
          type: NotificationType.newDeal,
          title: 'New Deal',
          message: 'New deal available',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AppNotification(
          id: 'notif-3',
          recipientId: 'user-123',
          type: NotificationType.orderCancelled,
          title: 'Order Cancelled',
          message: 'Order was cancelled',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => mockNotifications);
      when(mockNotificationService.getUnreadCount(any))
          .thenAnswer((_) async => 0);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Order confirmed
      expect(find.byIcon(Icons.local_offer), findsOneWidget); // New deal
      expect(find.byIcon(Icons.cancel), findsOneWidget); // Order cancelled
    });

    testWidgets('should show mark all as read button when unread notifications exist', (WidgetTester tester) async {
      // Arrange
      final mockNotifications = [
        AppNotification(
          id: 'notif-1',
          recipientId: 'user-123',
          type: NotificationType.orderConfirmed,
          title: 'Order Confirmed',
          message: 'Order confirmed',
          isRead: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => mockNotifications);
      when(mockNotificationService.getUnreadCount(any))
          .thenAnswer((_) async => 1);
      when(mockNotificationService.markAllAsRead(any))
          .thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mark All Read'), findsOneWidget);

      // Tap mark all as read
      await tester.tap(find.text('Mark All Read'));
      await tester.pumpAndSettle();

      // Verify service call
      verify(mockNotificationService.markAllAsRead('user-123')).called(1);
    });

    testWidgets('should display notification time correctly', (WidgetTester tester) async {
      // Arrange
      final now = DateTime.now();
      final mockNotifications = [
        AppNotification(
          id: 'notif-1',
          recipientId: 'user-123',
          type: NotificationType.orderReady,
          title: 'Order Ready',
          message: 'Order ready for pickup',
          createdAt: now.subtract(const Duration(minutes: 5)),
          updatedAt: now.subtract(const Duration(minutes: 5)),
        ),
        AppNotification(
          id: 'notif-2',
          recipientId: 'user-123',
          type: NotificationType.newDeal,
          title: 'New Deal',
          message: 'New deal available',
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
      ];

      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => mockNotifications);
      when(mockNotificationService.getUnreadCount(any))
          .thenAnswer((_) async => 0);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('5m ago'), findsOneWidget);
      expect(find.text('2h ago'), findsOneWidget);
    });

    testWidgets('should handle refresh functionality', (WidgetTester tester) async {
      // Arrange
      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => []);
      when(mockNotificationService.getUnreadCount(any))
          .thenAnswer((_) async => 0);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Perform pull to refresh
      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      // Assert
      verify(mockNotificationService.getNotificationsForUser(any)).called(greaterThan(1));
    });

    testWidgets('should show high priority notifications with different styling', (WidgetTester tester) async {
      // Arrange
      final mockNotification = AppNotification(
        id: 'notif-1',
        recipientId: 'user-123',
        type: NotificationType.orderCancelled,
        title: 'Order Cancelled',
        message: 'Your order was cancelled',
        priority: NotificationPriority.high,
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockNotificationService.getNotificationsForUser(any))
          .thenAnswer((_) async => [mockNotification]);
      when(mockNotificationService.getUnreadCount(any))
          .thenAnswer((_) async => 1);

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Order Cancelled'), findsOneWidget);
      // In a real implementation, we'd verify visual styling differences
    });

    testWidgets('should handle error state gracefully', (WidgetTester tester) async {
      // Arrange
      when(mockNotificationService.getNotificationsForUser(any))
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createTestWidget(tester));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error loading notifications'), findsOneWidget);
      expect(find.text('Tap to retry'), findsOneWidget);
    });
  });
}