import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../../../shared/theme/app_theme.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationTile({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: notification.isHighPriority && !notification.isRead
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
        ),
        onDismissed: (_) => onDelete?.call(),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildLeadingIcon(),
          title: Text(
            notification.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
              color: notification.isRead ? Colors.grey[700] : AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.summary,
                style: TextStyle(
                  fontSize: 14,
                  color: notification.isRead ? Colors.grey[600] : Colors.grey[800],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (notification.isHighPriority) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notification.priority.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(height: 4),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Color(notification.type.iconColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getIconData(notification.type.iconName),
        color: Color(notification.type.iconColor),
        size: 24,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'restaurant':
        return Icons.restaurant;
      case 'notifications_active':
        return Icons.notifications_active;
      case 'done_all':
        return Icons.done_all;
      case 'cancel':
        return Icons.cancel;
      case 'local_offer':
        return Icons.local_offer;
      case 'schedule':
        return Icons.schedule;
      case 'remove_shopping_cart':
        return Icons.remove_shopping_cart;
      case 'payment':
        return Icons.payment;
      case 'error':
        return Icons.error;
      case 'campaign':
        return Icons.campaign;
      case 'store':
        return Icons.store;
      default:
        return Icons.notifications;
    }
  }

  Color _getPriorityColor() {
    switch (notification.priority) {
      case NotificationPriority.urgent:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.normal:
        return AppTheme.primaryColor;
      case NotificationPriority.low:
        return Colors.grey;
    }
  }
}