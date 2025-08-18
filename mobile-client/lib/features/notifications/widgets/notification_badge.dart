import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../../../shared/theme/app_theme.dart';

class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final String userId;
  final bool showZero;

  const NotificationBadge({
    Key? key,
    required this.child,
    required this.userId,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider(userId));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (unreadCount > 0 || showZero)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationIcon extends ConsumerWidget {
  final String userId;
  final VoidCallback? onTap;
  final Color? color;
  final double size;

  const NotificationIcon({
    Key? key,
    required this.userId,
    this.onTap,
    this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider(userId));
    final hasHighPriority = ref.watch(highPriorityNotificationsProvider(userId)).isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: NotificationBadge(
        userId: userId,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            hasHighPriority ? Icons.priority_high : Icons.notifications,
            key: ValueKey(hasHighPriority),
            size: size,
            color: hasHighPriority ? Colors.red : (color ?? AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }
}