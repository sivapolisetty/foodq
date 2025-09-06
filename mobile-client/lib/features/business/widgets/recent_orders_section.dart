import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/order.dart';
import '../../orders/providers/order_provider.dart';
import '../../orders/services/order_service.dart';

/// Section showing recent orders for the business
/// Displays latest orders with status and quick actions
class RecentOrdersSection extends ConsumerWidget {
  final AppUser businessUser;

  const RecentOrdersSection({
    Key? key,
    required this.businessUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Recent Orders',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/orders'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                      color: Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Orders list
          _buildOrdersList(context),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    // Use Riverpod to watch business orders
    return Consumer(
      builder: (context, ref, child) {
        final ordersAsync = ref.watch(businessOrdersProvider(businessUser.businessId!));

        return ordersAsync.when(
          data: (orders) {
            // Show only recent orders (last 10)
            final recentOrders = orders.take(10).toList();
            
            if (recentOrders.isEmpty) {
              return _buildEmptyState(context);
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentOrders.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Color(0xFFF0F0F0),
                ),
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return _buildOrderCard(context, order, ref);
                },
              ),
            );
          },
          loading: () => Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
          ),
          error: (error, _) => Container(
            height: 120,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 32,
                  color: Color(0xFFE53935),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Error loading orders',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, WidgetRef ref) {
    final status = order.status.name;
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customer?.displayName ?? order.customer?.fullName ?? 'Customer Order',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimeAgo(order.createdAt),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Order items
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: order.orderItems.map((item) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${item.quantity}x ${item.deals?.title ?? 'Item'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF757575),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Order footer
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF757575),
                      ),
                    ),
                    Text(
                      order.formattedTotal,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Estimated',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF757575),
                      ),
                    ),
                    Text(
                      _getEstimatedReadyText(order),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: status == 'ready' 
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF212121),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (status == 'pending' || status == 'preparing' || status == 'ready')
                _buildOrderActions(context, order, ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(BuildContext context, Order order, WidgetRef ref) {
    final status = order.status.name;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == 'pending')
          TextButton(
            onPressed: () => _confirmOrder(context, order, ref),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Accept',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        if (status == 'preparing')
          TextButton(
            onPressed: () => _markOrderReady(context, order, ref),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Ready',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        if (status == 'ready')
          TextButton(
            onPressed: () => _markOrderDelivered(context, order, ref),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Deliver',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 28,
            color: Color(0xFF9E9E9E),
          ),
          SizedBox(height: 6),
          Text(
            'No recent orders',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757575),
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Orders will appear here as they come in',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF9E9E9E),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'preparing':
        return const Color(0xFFFF9800);
      case 'ready':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF757575);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Future<void> _confirmOrder(BuildContext context, Order order, WidgetRef ref) async {
    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(order.id, OrderStatus.completed);
      
      // Refresh the orders list
      ref.invalidate(businessOrdersProvider(businessUser.businessId!));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.id.substring(0, 8).toUpperCase()} accepted and being prepared'),
            backgroundColor: const Color(0xFF2196F3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept order: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  Future<void> _markOrderReady(BuildContext context, Order order, WidgetRef ref) async {
    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(order.id, OrderStatus.completed);
      
      // Refresh the orders list
      ref.invalidate(businessOrdersProvider(businessUser.businessId!));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.id.substring(0, 8).toUpperCase()} marked as ready'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  Future<void> _markOrderDelivered(BuildContext context, Order order, WidgetRef ref) async {
    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(order.id, OrderStatus.completed);
      
      // Refresh the orders list
      ref.invalidate(businessOrdersProvider(businessUser.businessId!));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.id.substring(0, 8).toUpperCase()} marked as delivered'),
            backgroundColor: const Color(0xFF2196F3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getEstimatedReadyText(Order order) {
    switch (order.status) {
      case OrderStatus.confirmed:
        return '15 min'; // Estimated prep time
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}