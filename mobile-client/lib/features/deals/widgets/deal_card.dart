import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/deal.dart';

class DealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback? onEdit;
  final VoidCallback? onDeactivate;
  final bool showUrgencyIndicator;
  final bool isReadOnly;

  const DealCard({
    super.key,
    required this.deal,
    this.onEdit,
    this.onDeactivate,
    this.showUrgencyIndicator = false,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowSafeWrapper(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Urgency indicator bar
              if (showUrgencyIndicator && deal.urgency != DealUrgency.normal)
                _buildUrgencyIndicator(),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with image and basic info
                    _buildHeader(),
                    
                    const SizedBox(height: 12),
                    
                    // Deal details
                    _buildDealDetails(),
                    
                    const SizedBox(height: 12),
                    
                    // Pricing and savings
                    _buildPricingSection(),
                    
                    const SizedBox(height: 12),
                    
                    // Quantity and time remaining
                    _buildStatusSection(),
                    
                    if (!isReadOnly) ...[
                      const SizedBox(height: 16),
                      // Action buttons
                      _buildActionButtons(context),
                    ],
                  ],
                ),
              ),
            ],
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
            indicatorColor.withOpacity(0.8),
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
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Deal image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surfaceVariant,
          ),
          clipBehavior: Clip.antiAlias,
          child: deal.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: deal.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.fastfood,
                      color: AppColors.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.fastfood,
                      color: AppColors.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                )
              : Icon(
                  Icons.fastfood,
                  color: AppColors.onSurfaceVariant,
                  size: 24,
                ),
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
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor().withOpacity(0.3)),
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

  Widget _buildDealDetails() {
    return Row(
      children: [
        if (deal.allergenInfo != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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

  Widget _buildActionButtons(BuildContext context) {
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
}