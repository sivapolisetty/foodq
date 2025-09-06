import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../models/deal.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/cart/services/cart_validation_service.dart';

class DealCard extends ConsumerWidget {
  final Deal deal;
  final VoidCallback onTap;
  final bool showDistance;
  final double? distance;
  final bool showCartControls;

  const DealCard({
    super.key,
    required this.deal,
    required this.onTap,
    this.showDistance = false,
    this.distance,
    this.showCartControls = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final itemQuantityInCart = cartState.getTotalQuantityForDeal(deal.id);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Discount Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          deal.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildDiscountBadge(),
                    ],
                  ),

                  // Business name
                  if (deal.restaurant?.name != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      deal.restaurant!.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Description - single line
                  if (deal.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      deal.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Price, Quantity, Distance in one line
                  Row(
                    children: [
                      // Price
                      Text(
                        '\$${deal.discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${deal.originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[500],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Quantity Available
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: deal.isAlmostSoldOut
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${deal.quantityAvailable} left',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: deal.isAlmostSoldOut
                                ? Colors.red
                                : Colors.grey[700],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Time or Distance
                      if (showDistance && distance != null)
                        _buildDistanceInfo()
                      else
                        _buildTimeInfo(),
                    ],
                  ),
                  
                  // Cart controls
                  if (showCartControls) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCartControls(context, ref, itemQuantityInCart),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartControls(BuildContext context, WidgetRef ref, int itemQuantityInCart) {
    final isOutOfStock = (deal.quantityAvailable - deal.quantitySold) <= 0;
    final restaurant = deal.restaurant;
    
    if (isOutOfStock) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Out of Stock',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }

    if (itemQuantityInCart == 0) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleQuickOrder(context, ref, restaurant),
              icon: const Icon(Icons.flash_on, size: 14),
              label: const Text(
                'Quick Order',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: BorderSide(color: AppTheme.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: const Size(0, 28),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleAddToCart(context, ref, restaurant),
              icon: const Icon(Icons.shopping_bag_outlined, size: 14),
              label: const Text(
                'Add Cart',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: const Size(0, 28),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            ref.read(cartProvider.notifier).decrementDealQuantity(deal.id);
          },
          icon: const Icon(Icons.remove_circle_outline),
          color: Colors.grey.shade600,
          iconSize: 20,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$itemQuantityInCart in cart',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            ref.read(cartProvider.notifier).incrementDealQuantity(deal.id);
          },
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.primaryGreen,
          iconSize: 20,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  void _handleAddToCart(BuildContext context, WidgetRef ref, restaurant) async {
    if (restaurant == null) return;
    
    await CartValidationService.validateAndAddToCart(
      context: context,
      ref: ref,
      dealId: deal.id,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      dealName: deal.title,
      dealDescription: deal.description ?? '',
      price: deal.discountedPrice,
      imageUrl: deal.imageUrl,
    );
  }

  void _handleQuickOrder(BuildContext context, WidgetRef ref, restaurant) async {
    if (restaurant == null) return;
    
    await CartValidationService.quickOrder(
      context: context,
      ref: ref,
      dealId: deal.id,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      dealName: deal.title,
      dealDescription: deal.description ?? '',
      price: deal.discountedPrice,
      imageUrl: deal.imageUrl,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 10,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 2),
          Text(
            distance! < 1
                ? '${(distance! * 1000).round()}m'
                : '${distance!.toStringAsFixed(1)}km',
            style: TextStyle(
              fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: deal.isExpiringSoon
            ? AppTheme.accentOrange.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}