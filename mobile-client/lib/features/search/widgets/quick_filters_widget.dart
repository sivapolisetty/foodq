import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/search_filters.dart';

class QuickFiltersWidget extends StatelessWidget {
  final Function(SearchFilters) onFilterSelected;

  const QuickFiltersWidget({
    super.key,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildQuickFilterChip(
            label: 'Nearby',
            icon: Icons.location_on,
            onTap: () => onFilterSelected(SearchFilters.nearbyDeals()),
          ),
          const SizedBox(width: 8),
          _buildQuickFilterChip(
            label: 'High Discounts',
            icon: Icons.local_offer,
            onTap: () => onFilterSelected(SearchFilters.highDiscounts()),
          ),
          const SizedBox(width: 8),
          _buildQuickFilterChip(
            label: 'Expiring Soon',
            icon: Icons.schedule,
            onTap: () => onFilterSelected(SearchFilters.expiringSoon()),
          ),
          const SizedBox(width: 8),
          _buildQuickFilterChip(
            label: 'Budget Friendly',
            icon: Icons.attach_money,
            onTap: () => onFilterSelected(SearchFilters.budget()),
          ),
          const SizedBox(width: 8),
          _buildQuickFilterChip(
            label: 'Vegetarian',
            icon: Icons.eco,
            onTap: () => onFilterSelected(SearchFilters.vegetarian()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen),
          boxShadow: [AppTheme.subtleShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}