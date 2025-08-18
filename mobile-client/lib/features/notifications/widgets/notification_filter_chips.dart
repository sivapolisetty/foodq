import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../../../shared/theme/app_theme.dart';

class NotificationFilterChips extends StatelessWidget {
  final NotificationType? selectedFilter;
  final ValueChanged<NotificationType?> onFilterChanged;

  const NotificationFilterChips({
    Key? key,
    this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          context,
          label: 'All',
          isSelected: selectedFilter == null,
          onTap: () => onFilterChanged(null),
        ),
        ...NotificationType.values.map((type) => _buildFilterChip(
          context,
          label: type.displayName,
          isSelected: selectedFilter == type,
          onTap: () => onFilterChanged(type),
          iconData: _getIconData(type.iconName),
          color: Color(type.iconColor),
        )),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? iconData,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (color ?? AppTheme.primaryColor)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (color ?? AppTheme.primaryColor)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null) ...[
              Icon(
                iconData,
                size: 16,
                color: isSelected 
                    ? Colors.white 
                    : (color ?? Colors.grey[600]),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Colors.white 
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
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
}