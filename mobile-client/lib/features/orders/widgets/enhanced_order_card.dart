import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../deals/services/deal_service.dart';

/// Provider for deal by ID
final dealByIdProvider = FutureProvider.family<Deal?, String>((ref, dealId) async {
  final dealService = DealService();
  return await dealService.getDealById(dealId);
});

/// Enhanced order card that shows deal information (name and image)
class EnhancedOrderCard extends ConsumerWidget {
  final Order order;
  final bool isBusinessView;
  final VoidCallback? onTap;

  const EnhancedOrderCard({
    super.key,
    required this.order,
    this.isBusinessView = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: _buildOrderContent(context),
      ),
    );
  }

  Widget _buildOrderContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(),
          const SizedBox(height: 16),
          _buildOrderDetails(),
          const SizedBox(height: 12),
          _buildStatusSection(),
          if (order.pickupTime != null) ...[
            const SizedBox(height: 12),
            _buildPickupInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeaderWithoutDeal(),
          const SizedBox(height: 12),
          _buildDealLoadingPlaceholder(),
          const SizedBox(height: 12),
          _buildOrderDetails(),
          const SizedBox(height: 12),
          _buildStatusSection(),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeaderWithoutDeal(),
          const SizedBox(height: 12),
          _buildDealErrorPlaceholder(),
          const SizedBox(height: 12),
          _buildOrderDetails(),
          const SizedBox(height: 12),
          _buildStatusSection(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with name and status
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                isBusinessView 
                    ? (order.customer?.displayName ?? order.customer?.fullName ?? 'Customer')
                    : (order.businesses?.name ?? 'Restaurant'),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildStatusChip(),
          ],
        ),
        const SizedBox(height: 8),
        
        // Compact order details row
        Row(
          children: [
            Expanded(
              child: Text(
                'Order #${order.id.substring(0, 8).toUpperCase()} • ${_formatOrderDate()}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Deal total row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBusinessView ? 'Deal Total' : 'Deal Price',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              order.formattedTotal,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderOrderImage() {
    // Use business logo if available, otherwise use generic order icon
    final businessImageUrl = order.businesses?.imageUrl;
    
    if (businessImageUrl != null && businessImageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: businessImageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant_menu, color: Colors.grey, size: 32),
        ),
        errorWidget: (context, url, error) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.restaurant_menu, color: AppColors.primary, size: 32),
        ),
      );
    }

    // Generic order icon
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.restaurant_menu, color: AppColors.primary, size: 32),
    );
  }

  Widget _buildOrderHeaderWithoutDeal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.id.substring(0, 8).toUpperCase()}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatOrderDate(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(),
      ],
    );
  }

  Widget _buildDealImage() {
    if (order.dealImageUrl != null && order.dealImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: order.dealImageUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant, color: Colors.grey, size: 32),
        ),
        errorWidget: (context, url, error) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.restaurant, color: AppColors.primary, size: 32),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.restaurant, color: AppColors.primary, size: 32),
    );
  }


  Widget _buildDealLoadingPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealErrorPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 16),
          const SizedBox(width: 8),
          Text(
            'Could not load item details',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Items (${order.orderItems.length})',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                order.formattedTotal,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          if (order.orderItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: Colors.grey[200],
            ),
            const SizedBox(height: 12),
            
            // Individual line items
            ...order.orderItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildCompactOrderLineItem(item),
                  if (index < order.orderItems.length - 1) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      color: Colors.grey[100],
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactOrderLineItem(OrderItem item) {
    final dealTitle = item.deals?.title ?? 'Unknown Deal';
    final unitPrice = '\$${item.price.toStringAsFixed(2)}';
    final lineTotal = '\$${(item.price * item.quantity).toStringAsFixed(2)}';
    final dealImageUrl = item.deals?.imageUrl;
    
    return Row(
      children: [
        // Quantity badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '${item.quantity}',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Deal image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildCompactLineItemImage(dealImageUrl),
        ),
        const SizedBox(width: 12),
        
        // Deal title and price info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dealTitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$unitPrice each',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Line total
        Text(
          lineTotal,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLineItemImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant, color: Colors.grey, size: 18),
        ),
        errorWidget: (context, url, error) => Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.restaurant, color: AppColors.primary, size: 18),
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, color: AppColors.primary, size: 18),
    );
  }

  Widget _buildOrderLineItem(OrderItem item) {
    final dealTitle = item.deals?.title ?? 'Unknown Deal';
    final unitPrice = '\$${item.price.toStringAsFixed(2)}';
    final lineTotal = '\$${(item.price * item.quantity).toStringAsFixed(2)}';
    final dealImageUrl = item.deals?.imageUrl;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Quantity badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${item.quantity}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Deal image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildLineItemImage(dealImageUrl),
          ),
          const SizedBox(width: 8),
          
          // Deal title and price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dealTitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$unitPrice each',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Line total
          Text(
            lineTotal,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant, color: Colors.grey, size: 16),
        ),
        errorWidget: (context, url, error) => Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.restaurant, color: AppColors.primary, size: 16),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, color: AppColors.primary, size: 16),
    );
  }

  Widget _buildStatusSection() {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleStatus(),
        ),
        const SizedBox(width: 12),
        _buildPaymentStatus(),
      ],
    );
  }

  Widget _buildSimpleStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          order.statusDisplay,
          style: AppTextStyles.bodyMedium.copyWith(
            color: _getStatusColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPaymentStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getPaymentStatusColor().withOpacity(0.3),
        ),
      ),
      child: Text(
        order.paymentMethodDisplay,
        style: AppTextStyles.labelSmall.copyWith(
          color: _getPaymentStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPickupInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Text(
            'Pickup: ${order.formattedPickupTime}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          order.status.displayText,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.pending:
        return Colors.amber; // Amber - pending
      case OrderStatus.paid:
        return Colors.blue; // Blue - paid
      case OrderStatus.confirmed:
        return AppColors.primary; // Orange - action needed
      case OrderStatus.completed:
        return Colors.green[700]!; // Green - completed
      case OrderStatus.cancelled:
        return Colors.red; // Red - cancelled
    }
  }

  Color _getPaymentStatusColor() {
    switch (order.paymentStatus) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.grey;
    }
  }

  String _formatOrderDate() {
    if (order.createdAt == null) return 'Unknown date';
    
    final now = DateTime.now();
    final orderDate = order.createdAt!;
    final difference = now.difference(orderDate);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${orderDate.day}/${orderDate.month}/${orderDate.year}';
    }
  }
}