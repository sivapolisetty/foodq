import 'package:flutter/material.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/theme/app_colors.dart';

class LeanDealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback? onEdit;
  final VoidCallback? onDeactivate;
  final bool isReadOnly;

  const LeanDealCard({
    Key? key,
    required this.deal,
    this.onEdit,
    this.onDeactivate,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discount = ((deal.originalPrice - deal.discountedPrice) / deal.originalPrice * 100).round();
    final isExpiringSoon = deal.isExpiringSoon;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deal icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 20,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      if (deal.description != null && deal.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          deal.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF757575),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Pricing and discount row
            Row(
              children: [
                // Discount badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$discount% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Prices
                Text(
                  '\$${deal.discountedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${deal.originalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                
                const Spacer(),
                
                // Inventory
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${deal.quantityAvailable - deal.quantitySold}/${deal.quantityAvailable}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Time remaining and actions
            Row(
              children: [
                // Time remaining
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isExpiringSoon ? AppColors.warning : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  deal.timeRemainingText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isExpiringSoon ? AppColors.warning : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const Spacer(),
                
                // Action buttons
                if (!isReadOnly) ...[
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF757575),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDeactivate,
                    icon: const Icon(Icons.block_outlined, size: 16),
                    label: const Text('Deactivate'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (deal.status == DealStatus.expired || !deal.isAvailable) {
      return const Color(0xFF9E9E9E);
    }
    if (deal.isExpiringSoon) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  String _getStatusText() {
    if (deal.status == DealStatus.expired || !deal.isAvailable) {
      return 'Expired';
    }
    if (deal.isExpiringSoon) {
      return 'Expiring';
    }
    return 'Active';
  }
}