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
          const SizedBox(height: 12),
          _buildDealInfo(),
          const SizedBox(height: 12),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Deal Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildDealImage(),
        ),
        const SizedBox(width: 12),
        // Order Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deal Title
              Text(
                order.dealTitle,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Order ID and Date - Fix overflow
              Text(
                'Order #${order.id.substring(0, 8).toUpperCase()}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _formatOrderDate(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[500],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Status Chip
        Flexible(child: _buildStatusChip()),
      ],
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

  Widget _buildDealInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deal Price',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
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
          ),
          // Business info column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Business',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                order.businessName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantity',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${order.totalQuantity}x',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Unit Price',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                order.formattedTotal,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
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
      ),
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