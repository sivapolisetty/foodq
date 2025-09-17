import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/business.dart';
import '../../../shared/models/order.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../orders/services/order_service.dart';
import '../widgets/order_placement_bottom_sheet.dart';
import '../../../services/business_service.dart';
import '../services/deal_service.dart';
import '../../cart/services/cart_validation_service.dart';
import '../../cart/providers/cart_provider.dart';
import '../../../shared/services/user_interactions_service.dart';

class DealDetailsScreen extends ConsumerStatefulWidget {
  final Deal? deal;
  final String? dealId;

  const DealDetailsScreen({
    Key? key,
    this.deal,
    this.dealId,
  }) : assert(deal != null || dealId != null, 'Either deal or dealId must be provided'),
       super(key: key);

  @override
  ConsumerState<DealDetailsScreen> createState() => _DealDetailsScreenState();
}

class _DealDetailsScreenState extends ConsumerState<DealDetailsScreen> {
  Deal? currentDeal;
  Business? business;
  bool isLoadingDeal = true;
  bool isLoadingBusiness = true;
  String? dealError;
  String? businessError;
  int _viewCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDealData();
  }

  Future<void> _loadDealData() async {
    try {
      // If deal is provided, use it directly, otherwise fetch by ID
      if (widget.deal != null) {
        currentDeal = widget.deal;
        setState(() {
          isLoadingDeal = false;
        });
        _trackDealView();
        _loadBusinessDetails();
      } else if (widget.dealId != null) {
        // Check if DealService exists, otherwise create a simple HTTP client approach
        final dealService = DealService();
        final dealData = await dealService.getDealById(widget.dealId!);
        
        if (dealData != null) {
          setState(() {
            currentDeal = dealData;
            isLoadingDeal = false;
          });
          _trackDealView();
          _loadBusinessDetails();
        } else {
          setState(() {
            dealError = 'Deal not found';
            isLoadingDeal = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        dealError = 'Failed to load deal: $e';
        isLoadingDeal = false;
      });
    }
  }

  Future<void> _loadBusinessDetails() async {
    if (currentDeal == null) return;
    
    try {
      final businessService = BusinessService();
      final businessData = await businessService.getBusinessById(currentDeal!.businessId);
      setState(() {
        business = businessData;
        isLoadingBusiness = false;
      });
    } catch (e) {
      setState(() {
        businessError = e.toString();
        isLoadingBusiness = false;
      });
    }
  }

  void _trackDealView() {
    if (currentDeal == null) return;
    
    // Simple tracking - let backend handle all the complex logic
    _viewCount++;
    UserInteractionsService.trackDealViewed(currentDeal!.id);
  }

  @override
  void didUpdateWidget(DealDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Track additional views if user navigates back to same deal
    if (oldWidget.dealId != widget.dealId || oldWidget.deal != widget.deal) {
      _viewCount = 0;
      _loadDealData();
    } else if (currentDeal != null && !currentDeal!.isExpired) {
      _trackDealView();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while deal is being fetched
    if (isLoadingDeal) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => NavigationHelper.safePopOrGoHome(context),
          ),
          title: const Text('Deal Details', style: TextStyle(color: Colors.black)),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      );
    }

    // Show error state if deal loading failed
    if (dealError != null || currentDeal == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => NavigationHelper.safePopOrGoHome(context),
          ),
          title: const Text('Deal Not Found', style: TextStyle(color: Colors.black)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                dealError ?? 'Deal not found',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => NavigationHelper.safePopOrGoHome(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(),
                _buildContentSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildOrderButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {
              // TODO: Implement favorites functionality
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: currentDeal!.imageUrl != null && currentDeal!.imageUrl!.isNotEmpty
                ? Image.network(
                    currentDeal!.imageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
                  )
                : _buildFallbackImage(),
          ),
          
          // Discount badge in top right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${currentDeal!.discountPercentage}% OFF',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
      ),
      child: const Icon(
        Icons.restaurant,
        size: 80,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildBusinessInfo(),
          const SizedBox(height: 24),
          _buildDealDetails(),
          const SizedBox(height: 24),
          _buildAllergenInfo(),
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentDeal!.title,
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (currentDeal!.description != null && currentDeal!.description!.isNotEmpty)
          Text(
            currentDeal!.description!,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.black54,
              height: 1.5,
            ),
          ),
      ],
    );
  }

  Widget _buildBusinessInfo() {
    if (isLoadingBusiness) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 16),
            Text('Loading restaurant info...'),
          ],
        ),
      );
    }

    if (businessError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Unable to load restaurant info',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.red[700]),
        ),
      );
    }

    if (business == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  business!.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      business!.rating.toStringAsFixed(1),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  business!.address,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          if (business!.phone != null && business!.phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  business!.phone!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDealDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deal Details',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Original Price',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '\$${currentDeal!.originalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Deal Price',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '\$${currentDeal!.discountedPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.inventory,
                  label: '${currentDeal!.quantityAvailable} available',
                  color: currentDeal!.quantityAvailable > 5 
                      ? AppColors.success 
                      : currentDeal!.quantityAvailable > 0 
                          ? Colors.orange 
                          : AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.access_time,
                  label: _getTimeRemaining(),
                  color: _getTimeRemainingColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenInfo() {
    if (currentDeal!.allergenInfo == null || currentDeal!.allergenInfo!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Allergen Information',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentDeal!.allergenInfo!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton() {
    final currentUser = ref.watch(currentAuthUserProvider).value;
    final canOrder = currentDeal!.quantityAvailable > 0 && 
                    currentDeal!.status == DealStatus.active &&
                    currentDeal!.expiresAt.isAfter(DateTime.now());

    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => context.go('/profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Login to Place Order',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (!currentUser.isCustomer) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'Switch to Customer Account to Order',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: canOrder
            ? Row(
                children: [
                  // Quick Order Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleQuickOrder(),
                      icon: const Icon(Icons.flash_on, size: 20),
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Quick Order',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${currentDeal!.discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add to Cart Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAddToCart(),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${currentDeal!.discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deal Not Available',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final expiresAt = currentDeal!.expiresAt;
    
    if (expiresAt.isBefore(now)) {
      return 'Expired';
    }
    
    final difference = expiresAt.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    } else {
      return '${difference.inMinutes}m left';
    }
  }

  Color _getTimeRemainingColor() {
    final now = DateTime.now();
    final expiresAt = currentDeal!.expiresAt;
    
    if (expiresAt.isBefore(now)) {
      return AppColors.error;
    }
    
    final difference = expiresAt.difference(now);
    
    if (difference.inHours < 1) {
      return AppColors.error;
    } else if (difference.inHours < 3) {
      return Colors.orange;
    } else {
      return AppColors.success;
    }
  }

  void _showOrderBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderPlacementBottomSheet(
        deal: currentDeal!,
        business: business,
        onOrderPlaced: _handleOrderPlaced,
      ),
    );
  }

  void _handleOrderPlaced(Order order) {
    debugPrint('🚀 HANDLE ORDER PLACED: ID=${order.id}');
    
    // Track deal purchase - backend handles removing from missed deals
    if (currentDeal != null) {
      UserInteractionsService.trackDealPurchased(currentDeal!.id, order.id);
    }
    
    // Use a post frame callback to ensure the modal is fully dismissed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        debugPrint('📍 NAVIGATING TO /orders');
        
        try {
          // Navigate to orders screen
          context.go('/orders');
        } catch (e) {
          debugPrint('❌ NAVIGATION ERROR: $e');
          // Fallback navigation
          if (context.mounted) {
            context.pushReplacementNamed('orders');
          }
        }
        
        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            debugPrint('📢 SHOWING SUCCESS SNACKBAR');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Order #${order.id.substring(0, 8).toUpperCase()} placed successfully!'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'View Details',
                  textColor: Colors.white,
                  onPressed: () {
                    context.go('/order-details', extra: order);
                  },
                ),
              ),
            );
          }
        });
      }
    });
  }

  void _handleQuickOrder() {
    if (currentDeal == null || business == null) return;
    
    // Show the order placement bottom sheet for quick order
    _showOrderBottomSheet();
  }

  void _handleAddToCart() async {
    if (currentDeal == null || business == null) return;
    
    await CartValidationService.validateAndAddToCart(
      context: context,
      ref: ref,
      dealId: currentDeal!.id,
      restaurantId: business!.id,
      restaurantName: business!.name,
      dealName: currentDeal!.title,
      dealDescription: currentDeal!.description ?? '',
      price: currentDeal!.discountedPrice,
      imageUrl: currentDeal!.imageUrl,
    );
  }
}