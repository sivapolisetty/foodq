import 'package:flutter/material.dart';
import '../../../shared/models/deal.dart';
import 'dart:math' as math;

class DealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback onTap;

  const DealCard({
    Key? key,
    required this.deal,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with discount badge
            _buildImageSection(),
            
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant name and rating
                    _buildRestaurantInfo(),
                    
                    const SizedBox(height: 6),
                    
                    // Deal title
                    _buildDealTitle(),
                    
                    const SizedBox(height: 8),
                    
                    // Time, distance and price
                    _buildBottomInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          // Deal image with fallback
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: deal.imageUrl != null && deal.imageUrl!.isNotEmpty
                ? Image.network(
                    deal.imageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey[300]!,
                              Colors.grey[200]!,
                            ],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),
          
          // Gradient overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.3),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // Discount badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '-${deal.discountPercentage.round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: const Icon(
        Icons.restaurant_menu,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    // Use actual restaurant data if available
    final restaurantName = deal.restaurant?.name ?? 'Restaurant';
    
    // Generate mock rating data for demo (in real app, this would come from reviews)
    final random = math.Random(deal.id.hashCode);
    final rating = (random.nextDouble() * 1.5 + 3.5);
    final reviewCount = random.nextInt(200) + 10;
    
    return Row(
      children: [
        Expanded(
          child: Text(
            restaurantName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Rating
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 14,
              color: Color(0xFFFFB300),
            ),
            const SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              '($reviewCount)',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDealTitle() {
    return Text(
      deal.title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF212121),
        height: 1.1,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomInfo() {
    // Calculate distance if restaurant location is available
    final random = math.Random(deal.id.hashCode);
    final distance = deal.restaurant?.latitude != null && deal.restaurant?.longitude != null
        ? '${(random.nextDouble() * 5 + 0.5).toStringAsFixed(1)} km'
        : '${(random.nextDouble() * 15 + 0.5).toStringAsFixed(1)} km';
    
    // Show actual expiry time
    final timeLeft = _getTimeLeft();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time and distance
        Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 12,
              color: Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 4),
            Text(
              timeLeft,
              style: TextStyle(
                fontSize: 11,
                color: _isUrgent() ? const Color(0xFFE53935) : const Color(0xFF9E9E9E),
                fontWeight: _isUrgent() ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            
            const SizedBox(width: 12),
            
            const Icon(
              Icons.location_on,
              size: 12,
              color: Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 4),
            Text(
              distance,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '\$${deal.originalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${deal.discountedPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
            
            // Quantity available indicator
            if (deal.quantityAvailable <= 5)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${deal.quantityAvailable} left',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _getPickupTimeRange() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour < 12) {
      return '09:00 - 11:00';
    } else if (hour < 17) {
      return '12:00 - 16:00';
    } else {
      return '17:00 - 20:00';
    }
  }

  String _getTimeLeft() {
    final now = DateTime.now();
    final difference = deal.expiresAt.difference(now);
    
    if (difference.isNegative) {
      return 'Expired';
    }
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min left';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours left';
    } else {
      return '${difference.inDays} days left';
    }
  }

  bool _isUrgent() {
    final now = DateTime.now();
    final difference = deal.expiresAt.difference(now);
    return difference.inHours <= 2 && !difference.isNegative;
  }
}