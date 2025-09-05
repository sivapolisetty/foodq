import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/deal.dart';
import './overflow_safe_wrapper.dart';
import '../../features/cart/providers/cart_provider.dart';
import '../../features/cart/services/cart_validation_service.dart';

enum DealCardMode { 
  customer,     // For customer browsing (cart controls, distance)
  business,     // For business dashboard (edit controls, detailed stats)  
  search,       // For search results (compact with key info)
  list          // For list views (horizontal layout)
}

enum CardOrientation { vertical, horizontal }

class UnifiedDealCard extends ConsumerWidget {
  // Content
  final Deal deal;
  final VoidCallback onTap;
  
  // Display Mode
  final DealCardMode mode;
  final CardOrientation orientation;
  
  // Customer Features
  final bool showDistance;
  final double? distance;
  final bool showCartControls;
  final bool showQuickOrder;
  
  // Business Features  
  final bool showBusinessControls;
  final VoidCallback? onEdit;
  final VoidCallback? onDeactivate;
  final VoidCallback? onView;
  final bool showUrgencyIndicator;
  final bool isReadOnly;
  
  // Layout Options
  final bool isCompact;
  final bool showFullDetails;

  const UnifiedDealCard({
    super.key,
    required this.deal,
    required this.onTap,
    this.mode = DealCardMode.customer,
    this.orientation = CardOrientation.vertical,
    this.showDistance = false,
    this.distance,
    this.showCartControls = true,
    this.showQuickOrder = true,
    this.showBusinessControls = false,
    this.onEdit,
    this.onDeactivate,
    this.onView,
    this.showUrgencyIndicator = false,
    this.isReadOnly = false,
    this.isCompact = false,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemQuantityInCart = ref.read(cartProvider.notifier).getDealTotalQuantity(deal.id);

    if (orientation == CardOrientation.horizontal || mode == DealCardMode.list) {
      return _buildHorizontalLayout(context, ref, itemQuantityInCart);
    }

    return _buildVerticalLayout(context, ref, itemQuantityInCart);
  }

  Widget _buildVerticalLayout(BuildContext context, WidgetRef ref, int itemQuantityInCart) {
    return OverflowSafeWrapper(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: _getCardWidth(),
          margin: EdgeInsets.only(bottom: mode == DealCardMode.business ? 12 : 0),
          child: Card(
            elevation: _getCardElevation(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Urgency indicator bar (business mode only)
                if (showUrgencyIndicator && 
                    mode == DealCardMode.business && 
                    deal.urgency != DealUrgency.normal)
                  _buildUrgencyIndicator(),
                
                // Deal image
                _buildDealImage(),
                
                // Content section
                Padding(
                  padding: EdgeInsets.all(_getContentPadding()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      _buildHeader(),
                      
                      SizedBox(height: _getVerticalSpacing()),
                      
                      // Deal details (business mode)
                      if (mode == DealCardMode.business && showFullDetails)
                        ...[
                          _buildDealDetails(),
                          SizedBox(height: _getVerticalSpacing()),
                        ],
                      
                      // Business name (customer modes)
                      if (mode != DealCardMode.business && deal.restaurant?.name != null)
                        ...[
                          _buildBusinessName(),
                          SizedBox(height: _getVerticalSpacing() / 2),
                        ],
                      
                      // Description
                      if (deal.description != null && !isCompact)
                        ...[
                          _buildDescription(),
                          SizedBox(height: _getVerticalSpacing()),
                        ],
                      
                      // Pricing section
                      _buildPricingSection(),
                      
                      SizedBox(height: _getVerticalSpacing()),
                      
                      // Status section (business mode) or info section (other modes)
                      if (mode == DealCardMode.business)
                        _buildStatusSection()
                      else
                        _buildInfoSection(),
                      
                      // Action controls
                      if (_shouldShowActions()) ...[
                        SizedBox(height: _getVerticalSpacing()),
                        _buildActionControls(context, ref, itemQuantityInCart),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, WidgetRef ref, int itemQuantityInCart) {
    return OverflowSafeWrapper(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: _getCardElevation(),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                // Small image
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.surfaceVariant,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImage(80, 80),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          deal.title,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Price and discount
                        Row(
                          children: [
                            Text(
                              deal.formattedDiscountedPrice,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (deal.discountPercentage > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${deal.discountPercentage.round()}% OFF',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.onSuccess,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        // Distance or quantity info
                        if (showDistance && distance != null)
                          _buildDistanceInfo()
                        else
                          _buildQuantityInfo(),
                      ],
                    ),
                  ),
                ),
                
                // Action button (compact)
                if (showCartControls && mode == DealCardMode.customer)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCompactCartButton(context, ref, itemQuantityInCart),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyIndicator() {
    Color indicatorColor;
    String urgencyText;
    
    switch (deal.urgency) {
      case DealUrgency.urgent:
        indicatorColor = AppColors.error;
        urgencyText = 'URGENT';
        break;
      case DealUrgency.moderate:
        indicatorColor = AppColors.warning;
        urgencyText = 'LIMITED TIME';
        break;
      case DealUrgency.normal:
        indicatorColor = AppColors.success;
        urgencyText = 'AVAILABLE';
        break;
      case DealUrgency.expired:
        indicatorColor = AppColors.onSurfaceVariant;
        urgencyText = 'EXPIRED';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor,
        gradient: LinearGradient(
          colors: [
            indicatorColor,
            indicatorColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Text(
        urgencyText,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).shimmer(
      duration: 2000.ms,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildDealImage() {
    double imageHeight;
    
    switch (mode) {
      case DealCardMode.customer:
        imageHeight = 160;
        break;
      case DealCardMode.business:
        return const SizedBox.shrink(); // Business mode shows image in header
      case DealCardMode.search:
        imageHeight = 120;
        break;
      case DealCardMode.list:
        return const SizedBox.shrink(); // List mode handles image in horizontal layout
    }

    final cardWidth = _getCardWidth();
    return Container(
      height: imageHeight,
      width: cardWidth ?? double.infinity,  // Use double.infinity when cardWidth is null
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        color: AppColors.surfaceVariant,
      ),
      child: _buildImage(cardWidth ?? double.infinity, imageHeight),
    );
  }

  Widget _buildImage(double width, double height) {
    return deal.imageUrl != null
        ? CachedNetworkImage(
            imageUrl: deal.imageUrl!,
            fit: BoxFit.cover,
            width: width,
            height: height,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImagePlaceholder(),
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Icon(
        Icons.fastfood,
        color: AppColors.onSurfaceVariant,
        size: mode == DealCardMode.list ? 20 : 32,
      ),
    );
  }

  Widget _buildHeader() {
    if (mode == DealCardMode.business) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deal image (business mode)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surfaceVariant,
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(80, 80),
          ),
          
          const SizedBox(width: 12),
          
          // Deal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        deal.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor().withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        deal.status.displayName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (deal.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    deal.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    // Customer/Search/List modes
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            deal.title,
            style: _getTitleStyle(),
            maxLines: isCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (deal.discountPercentage > 0)
          _buildDiscountBadge(),
      ],
    );
  }

  Widget _buildBusinessName() {
    return Text(
      deal.restaurant!.name,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      deal.description!,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      maxLines: mode == DealCardMode.search ? 1 : 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDealDetails() {
    return Row(
      children: [
        if (deal.allergenInfo != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber,
                  size: 12,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'Contains allergens',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onWarningContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // Deal ID for reference
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '#${deal.id.substring(0, 8)}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    if (mode == DealCardMode.business) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        deal.formattedDiscountedPrice,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        deal.formattedOriginalPrice,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Save ${deal.formattedSavingsAmount} (${deal.formattedDiscountPercentage})',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Discount badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${deal.discountPercentage.round()}% OFF',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSuccess,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Customer/Search/List modes - compact pricing
    return Row(
      children: [
        Text(
          deal.formattedDiscountedPrice,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        if (deal.discountPercentage > 0)
          Text(
            deal.formattedOriginalPrice,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        const Spacer(),
        if (mode != DealCardMode.list)
          _buildQuantityBadge(),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Row(
      children: [
        if (showDistance && distance != null)
          _buildDistanceInfo()
        else
          _buildTimeInfo(),
        
        const Spacer(),
        
        if (mode != DealCardMode.list)
          _buildQuantityInfo(),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusItem(
            icon: Icons.inventory,
            label: 'Available',
            value: '${deal.remainingQuantity}/${deal.quantityAvailable}',
            color: deal.isAlmostSoldOut ? AppColors.warning : AppColors.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusItem(
            icon: Icons.schedule,
            label: 'Time Left',
            value: deal.timeRemainingText,
            color: deal.isExpiringSoon ? AppColors.error : AppColors.info,
          ),
        ),
        if (deal.quantitySold > 0) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatusItem(
              icon: Icons.shopping_cart,
              label: 'Sold',
              value: deal.quantitySold.toString(),
              color: AppColors.success,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionControls(BuildContext context, WidgetRef ref, int itemQuantityInCart) {
    if (mode == DealCardMode.business && showBusinessControls && !isReadOnly) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onDeactivate,
              icon: const Icon(Icons.visibility_off, size: 16),
              label: const Text('Deactivate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onError,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      );
    }

    if (showCartControls && (mode == DealCardMode.customer || mode == DealCardMode.search)) {
      return _buildCartControls(context, ref, itemQuantityInCart);
    }

    return const SizedBox.shrink();
  }

  Widget _buildCartControls(BuildContext context, WidgetRef ref, int itemQuantityInCart) {
    final isOutOfStock = (deal.quantityAvailable - deal.quantitySold) <= 0;
    final restaurant = deal.restaurant;
    
    if (isOutOfStock) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Out of Stock',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (itemQuantityInCart == 0) {
      return Row(
        children: [
          if (showQuickOrder) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleQuickOrder(context, ref, restaurant),
                icon: const Icon(Icons.flash_on, size: 16),
                label: const Text('Quick Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleAddToCart(context, ref, restaurant),
              icon: const Icon(Icons.shopping_bag_outlined, size: 16),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
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
            // Remove the most recent line item for this deal
            final cartItems = ref.read(cartProvider).getItemsForDeal(deal.id);
            if (cartItems.isNotEmpty) {
              final lastItem = cartItems.last;
              if (lastItem.quantity > 1) {
                ref.read(cartProvider.notifier).updateCartItemQuantity(lastItem.cartItemId, lastItem.quantity - 1);
              } else {
                ref.read(cartProvider.notifier).removeCartItem(lastItem.cartItemId);
              }
            }
          },
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.onSurfaceVariant,
          iconSize: 24,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$itemQuantityInCart in cart',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            // Add a new line item for this deal
            ref.read(cartProvider.notifier).addItem(
              dealId: deal.id,
              restaurantId: deal.businessId,
              restaurantName: deal.restaurant?.name ?? 'Restaurant',
              dealName: deal.title,
              dealDescription: deal.description ?? '',
              price: deal.discountedPrice,
              imageUrl: deal.imageUrl,
              quantity: 1,
            );
          },
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.primary,
          iconSize: 24,
        ),
      ],
    );
  }

  Widget _buildCompactCartButton(BuildContext context, WidgetRef ref, int itemQuantityInCart) {
    final isOutOfStock = (deal.quantityAvailable - deal.quantitySold) <= 0;
    
    if (isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Out of Stock',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    if (itemQuantityInCart == 0) {
      return ElevatedButton(
        onPressed: () => _handleAddToCart(context, ref, deal.restaurant),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Add',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              // Remove the most recent line item for this deal
              final cartItems = ref.read(cartProvider).getItemsForDeal(deal.id);
              if (cartItems.isNotEmpty) {
                final lastItem = cartItems.last;
                if (lastItem.quantity > 1) {
                  ref.read(cartProvider.notifier).updateCartItemQuantity(lastItem.cartItemId, lastItem.quantity - 1);
                } else {
                  ref.read(cartProvider.notifier).removeCartItem(lastItem.cartItemId);
                }
              }
            },
            icon: const Icon(Icons.remove),
            iconSize: 16,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            color: AppColors.primary,
          ),
          Text(
            '$itemQuantityInCart',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              // Add a new line item for this deal
              ref.read(cartProvider.notifier).addItem(
                dealId: deal.id,
                restaurantId: deal.businessId,
                restaurantName: deal.restaurant?.name ?? 'Restaurant',
                dealName: deal.title,
                dealDescription: deal.description ?? '',
                price: deal.discountedPrice,
                imageUrl: deal.imageUrl,
                quantity: 1,
              );
            },
            icon: const Icon(Icons.add),
            iconSize: 16,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountBadge() {
    if (deal.discountPercentage <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${deal.discountPercentage.round()}% OFF',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuantityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: deal.isAlmostSoldOut
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: deal.isAlmostSoldOut
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Text(
        '${deal.quantityAvailable} left',
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: deal.isAlmostSoldOut
              ? AppColors.error
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDistanceInfo() {
    if (distance == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 2),
          Text(
            distance! < 1
                ? '${(distance! * 1000).round()}m'
                : '${distance!.toStringAsFixed(1)}km',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    final now = DateTime.now();
    final hoursLeft = deal.expiresAt.difference(now).inHours;
    
    Color color = AppColors.onSurfaceVariant;
    String text = '';
    
    if (deal.isExpiringSoon) {
      color = AppColors.warning;
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
            ? AppColors.warning.withValues(alpha: 0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInfo() {
    return Text(
      '${deal.quantityAvailable} left',
      style: AppTextStyles.labelSmall.copyWith(
        fontSize: 10,
        color: deal.isAlmostSoldOut ? AppColors.error : AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
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

  // Helper methods for styling and behavior
  double _getCardElevation() {
    switch (mode) {
      case DealCardMode.business:
        return 2;
      case DealCardMode.customer:
        return 2;
      case DealCardMode.search:
        return 1;
      case DealCardMode.list:
        return 1;
    }
  }

  double _getContentPadding() {
    switch (mode) {
      case DealCardMode.business:
        return 16;
      case DealCardMode.customer:
        return 12;
      case DealCardMode.search:
        return 10;
      case DealCardMode.list:
        return 8;
    }
  }

  double _getVerticalSpacing() {
    return mode == DealCardMode.business ? 12 : 8;
  }

  TextStyle _getTitleStyle() {
    switch (mode) {
      case DealCardMode.business:
        return AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600);
      case DealCardMode.customer:
        return AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold);
      case DealCardMode.search:
        return AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600);
      case DealCardMode.list:
        return AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600);
    }
  }

  bool _shouldShowActions() {
    if (mode == DealCardMode.business) {
      return showBusinessControls && !isReadOnly;
    }
    return showCartControls && (mode == DealCardMode.customer || mode == DealCardMode.search);
  }

  Color _getStatusColor() {
    switch (deal.status) {
      case DealStatus.active:
        return AppColors.success;
      case DealStatus.expired:
        return AppColors.error;
      case DealStatus.soldOut:
        return AppColors.warning;
    }
  }

  double? _getCardWidth() {
    // Return null for infinite width, or specific width for constrained layouts
    switch (mode) {
      case DealCardMode.customer:
        return 280.0; // Fixed width for horizontal scrolling
      case DealCardMode.search:
        return null; // Full width in vertical lists
      case DealCardMode.business:
        return null; // Full width in business screens  
      case DealCardMode.list:
        return 80.0; // Small width for list mode
    }
  }
}