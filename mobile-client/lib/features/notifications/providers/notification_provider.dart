import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';

/// Provider for SupabaseClient
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return NotificationService(supabaseClient: supabase);
});

/// State class for notifications
class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Provider for managing notification state
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;
  final String _userId;
  StreamSubscription? _realtimeSubscription;
  Timer? _refreshTimer;

  NotificationNotifier(this._notificationService, this._userId) : super(const NotificationState()) {
    _initializeNotifications();
    _setupRealtimeUpdates();
    _setupPeriodicRefresh();
  }

  /// Initialize notifications by loading from server
  Future<void> _initializeNotifications() async {
    await loadNotifications();
  }

  /// Load notifications from server
  Future<void> loadNotifications({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final notifications = await _notificationService.getNotificationsForUser(
        _userId,
        limit: 50,
        offset: refresh ? 0 : state.notifications.length,
      );

      final unreadCount = await _notificationService.getUnreadCount(_userId);

      if (refresh) {
        state = state.copyWith(
          notifications: notifications,
          unreadCount: unreadCount,
          isLoading: false,
          hasMore: notifications.length >= 50,
        );
      } else {
        final allNotifications = [...state.notifications, ...notifications];
        // Remove duplicates based on ID
        final uniqueNotifications = <String, AppNotification>{};
        for (final notification in allNotifications) {
          uniqueNotifications[notification.id] = notification;
        }

        state = state.copyWith(
          notifications: uniqueNotifications.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
          unreadCount: unreadCount,
          isLoading: false,
          hasMore: notifications.length >= 50,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh notifications (pull to refresh)
  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (state.isLoading || !state.hasMore) return;
    await loadNotifications();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final updatedNotification = await _notificationService.markAsRead(notificationId);
      
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return updatedNotification;
        }
        return notification;
      }).toList();

      final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead(_userId);
      
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final deletedNotification = state.notifications
          .firstWhere((notification) => notification.id == notificationId);
      
      final newUnreadCount = deletedNotification.isRead 
          ? state.unreadCount 
          : (state.unreadCount > 0 ? state.unreadCount - 1 : 0);

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return state.notifications.where((notification) => notification.type == type).toList();
  }

  /// Get unread notifications
  List<AppNotification> getUnreadNotifications() {
    return state.notifications.where((notification) => !notification.isRead).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<AppNotification> getRecentNotifications() {
    return state.notifications.where((notification) => notification.isRecent).toList();
  }

  /// Setup real-time updates
  void _setupRealtimeUpdates() {
    _realtimeSubscription = _notificationService.subscribeToOrderUpdates(_userId);
    // Additional subscriptions can be added here for deals, etc.
  }

  /// Setup periodic refresh for notifications
  void _setupPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      // Only refresh if app is active and not already loading
      if (!state.isLoading) {
        loadNotifications(refresh: true);
      }
    });
  }

  /// Handle real-time notification received
  void _handleRealtimeNotification(AppNotification notification) {
    final updatedNotifications = [notification, ...state.notifications];
    final newUnreadCount = notification.isRead ? state.unreadCount : state.unreadCount + 1;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _refreshTimer?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}

/// Provider for notification state management
final notificationProvider = StateNotifierProvider.family<NotificationNotifier, NotificationState, String>(
  (ref, userId) {
    final notificationService = ref.watch(notificationServiceProvider);
    return NotificationNotifier(notificationService, userId);
  },
);

/// Provider for unread notifications count
final unreadNotificationCountProvider = Provider.family<int, String>((ref, userId) {
  final notificationState = ref.watch(notificationProvider(userId));
  return notificationState.unreadCount;
});

/// Provider for recent notifications (last 24 hours)
final recentNotificationsProvider = Provider.family<List<AppNotification>, String>((ref, userId) {
  final notificationState = ref.watch(notificationProvider(userId));
  return notificationState.notifications.where((notification) => notification.isRecent).toList();
});

/// Provider for order-related notifications
final orderNotificationsProvider = Provider.family<List<AppNotification>, String>((ref, userId) {
  final notificationState = ref.watch(notificationProvider(userId));
  return notificationState.notifications
      .where((notification) => notification.type.isOrderRelated)
      .toList();
});

/// Provider for deal-related notifications
final dealNotificationsProvider = Provider.family<List<AppNotification>, String>((ref, userId) {
  final notificationState = ref.watch(notificationProvider(userId));
  return notificationState.notifications
      .where((notification) => notification.type.isDealRelated)
      .toList();
});

/// Provider for high priority notifications
final highPriorityNotificationsProvider = Provider.family<List<AppNotification>, String>((ref, userId) {
  final notificationState = ref.watch(notificationProvider(userId));
  return notificationState.notifications
      .where((notification) => notification.isHighPriority)
      .toList();
});

/// Provider for checking if notifications are loading
final notificationsLoadingProvider = Provider.family<bool, String>((ref, userId) {
  final notificationState = ref.watch(notificationProvider(userId));
  return notificationState.isLoading;
});

/// Provider for notification error state
final notificationErrorProvider = Provider.family<String?, String>((ref, userId) {
  final notificationState = ref.watch(notificationProvider(userId));
  return notificationState.error;
});