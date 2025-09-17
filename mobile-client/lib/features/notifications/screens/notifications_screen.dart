import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notification_filter_chips.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/models/app_user.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NotificationType? _selectedFilter;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more notifications when near bottom
      ref.read(notificationProvider('user-123').notifier).loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    const userId = 'user-123'; // In real app, get from auth provider
    final notificationState = ref.watch(notificationProvider(userId));
    final unreadCount = ref.watch(unreadNotificationCountProvider(userId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationProvider(userId).notifier).markAllAsRead(),
              child: const Text(
                'Mark All Read',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Orders'),
            Tab(text: 'Deals'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationProvider(userId).notifier).refreshNotifications(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationsList(notificationState, userId, null),
            _buildNotificationsList(notificationState, userId, 'orders'),
            _buildNotificationsList(notificationState, userId, 'deals'),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildNotificationsList(NotificationState state, String userId, String? filter) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to retry',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(notificationProvider(userId).notifier).refreshNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    List<AppNotification> notifications = state.notifications;

    // Apply filter
    if (filter == 'orders') {
      notifications = notifications.where((n) => n.type.isOrderRelated).toList();
    } else if (filter == 'deals') {
      notifications = notifications.where((n) => n.type.isDealRelated).toList();
    }

    // Apply selected filter
    if (_selectedFilter != null) {
      notifications = notifications.where((n) => n.type == _selectedFilter).toList();
    }

    if (notifications.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= notifications.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        final notification = notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(notification, userId),
          onDelete: () => _handleNotificationDelete(notification.id, userId),
        );
      },
    );
  }

  Widget _buildEmptyState(String? filter) {
    String title;
    String subtitle;
    IconData icon;

    switch (filter) {
      case 'orders':
        title = 'No Order Updates';
        subtitle = 'Order status updates will appear here when you place orders.';
        icon = Icons.shopping_bag_outlined;
        break;
      case 'deals':
        title = 'No Deal Alerts';
        subtitle = 'You\'ll be notified about new deals and special offers here.';
        icon = Icons.local_offer_outlined;
        break;
      default:
        title = 'No Notifications';
        subtitle = 'You\'re all caught up! New notifications will appear here.';
        icon = Icons.notifications_none;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification, String userId) async {
    // Mark as read if unread
    if (!notification.isRead) {
      await ref.read(notificationProvider(userId).notifier).markAsRead(notification.id);
    }

    // Navigate based on action URL
    if (notification.actionUrl != null) {
      // In a real app, you'd use proper navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Would navigate to: ${notification.actionUrl}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleNotificationDelete(String notificationId, String userId) {
    ref.read(notificationProvider(userId).notifier).deleteNotification(notificationId);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            NotificationFilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear Filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Consumer(
      builder: (context, ref, child) {
        final currentUserAsync = ref.watch(authenticatedUserProvider);
        
        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Center(
                    child: Text(
                      'Select a user to access navigation',
                      style: TextStyle(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }
            
            return CustomBottomNav(
              currentIndex: 3, // Notifications index (assuming it's added to nav)
              currentUser: currentUser,
              onTap: (index) => _handleBottomNavTap(context, index, currentUser),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleBottomNavTap(BuildContext context, int index, AppUser currentUser) {
    switch (index) {
      case 0:
        if (currentUser.isBusiness) {
          context.go('/business-home');
        } else {
          context.go('/home');
        }
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        if (currentUser.isBusiness) {
          context.go('/deals');
        } else {
          context.go('/favorites');
        }
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}