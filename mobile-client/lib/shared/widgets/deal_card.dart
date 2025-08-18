import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/deal.dart';

class DealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback onTap;
  final bool showDistance;
  final double? distance;

  const DealCard({
    super.key,
    required this.deal,
    required this.onTap,
    this.showDistance = false,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Image
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Colors.grey[200],
              ),
              child: deal.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        deal.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      ),
                    )
                  : _buildPlaceholderImage(),
            ),

            // Deal Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Discount Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          deal.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildDiscountBadge(),
                    ],
                  ),

                  // Description
                  if (deal.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      deal.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Price Information
                  Row(
                    children: [
                      Text(
                        '\$${deal.discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${deal.originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bottom Row: Quantity + Time/Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Available
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: deal.isAlmostSoldOut
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${deal.quantityAvailable} left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: deal.isAlmostSoldOut
                                ? Colors.red
                                : Colors.grey[700],
                          ),
                        ),
                      ),

                      // Time or Distance
                      if (showDistance && distance != null)
                        _buildDistanceInfo()
                      else
                        _buildTimeInfo(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        color: Colors.grey,
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDiscountBadge() {
    if (deal.discountPercentage <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${deal.discountPercentage.round()}% OFF',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDistanceInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 12,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            distance! < 1
                ? '${(distance! * 1000).round()}m'
                : '${distance!.toStringAsFixed(1)}km',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    final now = DateTime.now();
    final hoursLeft = deal.expiresAt.difference(now).inHours;
    
    Color color = Colors.grey[700]!;
    String text = '';
    
    if (deal.isExpiringSoon) {
      color = AppTheme.accentOrange;
      if (hoursLeft < 1) {
        text = 'Expires soon';
      } else {
        text = '${hoursLeft}h left';
      }
    } else {
      final daysLeft = deal.expiresAt.difference(now).inDays;
      if (daysLeft > 0) {
        text = '${daysLeft}d left';
      } else {
        text = '${hoursLeft}h left';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: deal.isExpiringSoon
            ? AppTheme.accentOrange.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}