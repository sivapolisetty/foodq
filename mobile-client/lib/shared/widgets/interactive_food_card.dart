import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/food_animations.dart';
import '../models/deal.dart';

/// Enhanced interactive food card with advanced micro-interactions
/// Designed for appetite psychology and FOMO motivation
class InteractiveFoodCard extends StatefulWidget {
  final Deal deal;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onQuickView;
  final bool showDistance;
  final double? distance;
  final bool isUrgent;
  final bool isMissed;
  final CardSize size;
  
  const InteractiveFoodCard({
    super.key,
    required this.deal,
    required this.onTap,
    this.onAddToCart,
    this.onQuickView,
    this.showDistance = false,
    this.distance,
    this.isUrgent = false,
    this.isMissed = false,
    this.size = CardSize.medium,
  });

  @override
  State<InteractiveFoodCard> createState() => _InteractiveFoodCardState();
}

class _InteractiveFoodCardState extends State<InteractiveFoodCard>
    with TickerProviderStateMixin {
  
  late AnimationController _hoverController;
  late AnimationController _urgencyController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _urgencyAnimation;
  late Animation<Color?> _pulseAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _urgencyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
    
    _shadowAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
    
    _urgencyAnimation = FoodAnimations.urgencyPulse(_urgencyController);
    _pulseAnimation = FoodAnimations.satisfactionPulse(_pulseController);
    
    // Start urgency animation if needed
    if (widget.isUrgent && !widget.isMissed) {
      _urgencyController.repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    _hoverController.dispose();
    _urgencyController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _onHoverStart() {
    if (!_isHovered) {
      setState(() => _isHovered = true);
      _hoverController.forward();
      HapticFeedback.selectionClick();
    }
  }
  
  void _onHoverEnd() {
    if (_isHovered) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }
  
  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }
  
  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }
  
  void _onTapCancel() {
    setState(() => _isPressed = false);
  }
  
  void _onAddToCart() {
    _pulseController.reset();
    _pulseController.forward();
    InteractionFeedback.provideFeedback(FeedbackType.success);
    widget.onAddToCart?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _hoverController,
        _urgencyController,
        _pulseController,
      ]),
      builder: (context, child) {
        double finalScale = _scaleAnimation.value;
        if (widget.isUrgent && !widget.isMissed) {
          finalScale *= _urgencyAnimation.value;
        }
        
        return MouseRegion(
          onEnter: (_) => _onHoverStart(),
          onExit: (_) => _onHoverEnd(),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            onLongPress: widget.onQuickView,
            child: Transform.scale(
              scale: _isPressed ? finalScale * 0.95 : finalScale,
              child: Container(
                width: _getCardWidth(),
                height: _getCardHeight(),
                child: Card(
                  elevation: _shadowAnimation.value,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: widget.isUrgent && !widget.isMissed
                        ? BorderSide(
                            color: AppColors.urgentPulse,
                            width: 2.0,
                          )
                        : BorderSide.none,
                  ),
                  child: Stack(
                    children: [
                      // Background pulse for satisfaction feedback
                      if (_pulseAnimation.value != Colors.transparent)
                        Positioned.fill(
                          child: Container(
                            color: _pulseAnimation.value,
                          ),
                        ),
                      
                      // Main card content
                      _buildCardContent(),
                      
                      // Overlay effects
                      if (widget.isMissed) _buildMissedOverlay(),
                      if (widget.isUrgent && !widget.isMissed) _buildUrgencyIndicator(),
                      if (widget.showDistance) _buildDistanceChip(),
                      
                      // Interactive elements
                      _buildInteractiveOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food image with shimmer loading
        Expanded(
          flex: 3,
          child: _buildFoodImage(),
        ),
        
        // Content section
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and restaurant
                Text(
                  widget.deal.title,
                  style: widget.isMissed 
                      ? AppTextStyles.missedOpportunity.copyWith(
                          color: AppColors.missedGray,
                        )
                      : AppTextStyles.dealTitle.copyWith(
                          color: AppColors.onSurface,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Price section with emphasis
                Row(
                  children: [
                    Text(
                      widget.deal.formattedDiscountedPrice,
                      style: widget.isUrgent 
                          ? AppTextStyles.savingsPrice.copyWith(
                              color: AppColors.hungerRed,
                            )
                          : AppTextStyles.priceDiscounted.copyWith(
                              color: AppColors.primary,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.deal.formattedOriginalPrice,
                      style: AppTextStyles.priceOriginal.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isUrgent 
                            ? AppColors.urgentPulse.withOpacity(0.1)
                            : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.deal.formattedDiscountPercentage,
                        style: AppTextStyles.discountPercentage.copyWith(
                          color: widget.isUrgent 
                              ? AppColors.urgentPulse
                              : AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Urgency information
                if (widget.isUrgent && !widget.isMissed) _buildUrgencyText(),
                if (widget.deal.isAlmostSoldOut) _buildAlmostSoldOutText(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFoodImage() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.deal.imageUrl ?? '',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          colorFilter: widget.isMissed 
              ? ColorFilter.mode(
                  AppColors.missedGray.withOpacity(0.5),
                  BlendMode.saturation,
                )
              : null,
          placeholder: (context, url) => _buildShimmerLoader(),
          errorWidget: (context, url, error) => _buildImagePlaceholder(),
        ),
        
        // Appetite enhancement gradient
        if (!widget.isMissed)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildShimmerLoader() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceVariant,
                AppColors.surfaceVariant.withOpacity(0.5),
                AppColors.surfaceVariant,
              ],
              stops: [
                _pulseController.value - 0.3,
                _pulseController.value,
                _pulseController.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
          size: 48,
        ),
      ),
    );
  }
  
  Widget _buildMissedOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.missedGray.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'MISSED',
              style: AppTextStyles.urgentAction.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildUrgencyIndicator() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.urgentPulse.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'URGENT',
          style: AppTextStyles.timeLeft.copyWith(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDistanceChip() {
    if (!widget.showDistance || widget.distance == null) return const SizedBox();
    
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.distance!.toStringAsFixed(1)}km',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUrgencyText() {
    return Text(
      widget.deal.timeRemainingText,
      style: AppTextStyles.timeLeft.copyWith(
        color: AppColors.urgentPulse,
        fontSize: 12,
      ),
    );
  }
  
  Widget _buildAlmostSoldOutText() {
    return Text(
      '${widget.deal.remainingQuantity} left!',
      style: AppTextStyles.urgentAction.copyWith(
        color: AppColors.almostGone,
        fontSize: 12,
      ),
    );
  }
  
  Widget _buildInteractiveOverlay() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onAddToCart != null)
              _buildActionButton(
                icon: Icons.add_shopping_cart,
                color: AppColors.primary,
                onTap: _onAddToCart,
              ),
            if (widget.onQuickView != null)
              const SizedBox(width: 8),
            if (widget.onQuickView != null)
              _buildActionButton(
                icon: Icons.visibility,
                color: AppColors.secondary,
                onTap: widget.onQuickView!,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
  
  double _getCardWidth() {
    switch (widget.size) {
      case CardSize.small:
        return 140;
      case CardSize.medium:
        return 180;
      case CardSize.large:
        return 220;
    }
  }
  
  double _getCardHeight() {
    switch (widget.size) {
      case CardSize.small:
        return 200;
      case CardSize.medium:
        return 260;
      case CardSize.large:
        return 300;
    }
  }
}

enum CardSize {
  small,
  medium,
  large,
}