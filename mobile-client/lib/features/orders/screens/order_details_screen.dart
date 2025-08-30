import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/app_user.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../providers/order_provider.dart';
import '../widgets/order_verification_card.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    
    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          return _buildNoUserSelected(context);
        }
        
        return _buildOrderDetails(context, ref, currentUser);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildNoUserSelected(BuildContext context) {
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Select a user profile first',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/profile'),
                child: const Text('Go to Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, WidgetRef ref, AppUser currentUser) {
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          actions: [
            if (currentUser.isBusiness) ..._buildBusinessActions(context, ref),
            if (!currentUser.isBusiness && order.canBeCancelled) ..._buildCustomerActions(context, ref),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderStatusCard(),
              const SizedBox(height: 16),
              // Show verification card for confirmed orders (for customers)
              if (!currentUser.isBusiness && order.status == OrderStatus.confirmed) ...[
                OrderVerificationCard(
                  order: order,
                  onRefresh: () {
                    // Refresh order data
                    ref.invalidate(customerOrdersProvider(currentUser.id));
                  },
                ),
                const SizedBox(height: 16),
              ],
              _buildOrderInfoCard(),
              const SizedBox(height: 16),
              _buildPaymentInfoCard(),
              if (order.pickupTime != null) ...[
                const SizedBox(height: 16),
                _buildPickupInfoCard(),
              ],
              if (order.deliveryInstructions != null && order.deliveryInstructions!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPickupInstructionsCard(),
              ],
              const SizedBox(height: 24),
              _buildActionButtons(context, ref, currentUser),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Status',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.displayText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Simple status display for two-state flow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      order.statusDisplay,
                      style: TextStyle(
                        fontSize: 16,
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Quantity', '${order.totalQuantity}x'),
            const SizedBox(height: 12),
            _buildInfoRow('Deal', order.dealTitle),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            _buildInfoRow('Total Amount', order.formattedTotal, isTotal: true),
            const SizedBox(height: 12),
            _buildInfoRow('Order Type', 'Pickup'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Payment Method', order.paymentMethodDisplay),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPaymentStatusColor().withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    order.paymentStatusDisplay,
                    style: TextStyle(
                      color: _getPaymentStatusColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pickup Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Pickup Time', order.formattedPickupTime),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialRequestsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note,
                  color: Colors.orange[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Special Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              order.deliveryInstructions!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupInstructionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pickup Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              order.deliveryInstructions!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF2E2E2E) : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF4CAF50) : const Color(0xFF2E2E2E),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, AppUser currentUser) {
    final orderNotifier = ref.read(orderNotifierProvider.notifier);
    
    return Column(
      children: [
        if (currentUser.isBusiness) ..._buildBusinessActionButtons(context, ref, orderNotifier),
        if (!currentUser.isBusiness && order.canBeCancelled) ..._buildCustomerActionButtons(context, ref, orderNotifier),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/orders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.grey[700],
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Orders'),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBusinessActionButtons(BuildContext context, WidgetRef ref, OrderNotifier orderNotifier) {
    final buttons = <Widget>[];
    
    // In simplified flow, orders are immediately confirmed
    // Business can only mark confirmed orders as completed
    if (order.status == OrderStatus.confirmed) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _completeOrder(context, ref, orderNotifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Mark as Completed'),
          ),
        ),
      );
      
      buttons.add(const SizedBox(height: 12));
      
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/orders/verify'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Mark as Ready for Pickup'),
          ),
        ),
      );
    }
    
    if (order.status == OrderStatus.completed) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _completeOrder(context, ref, orderNotifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Complete Order'),
          ),
        ),
      );
    }
    
    return buttons.map((button) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: button,
    )).toList();
  }

  List<Widget> _buildCustomerActionButtons(BuildContext context, WidgetRef ref, OrderNotifier orderNotifier) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _cancelOrder(context, ref, orderNotifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel Order'),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildBusinessActions(BuildContext context, WidgetRef ref) {
    return [
      PopupMenuButton<String>(
        onSelected: (value) async {
          final orderNotifier = ref.read(orderNotifierProvider.notifier);
          switch (value) {
            case 'confirm':
              await _confirmOrder(context, ref, orderNotifier);
              break;
            case 'ready':
              await _markOrderReady(context, ref, orderNotifier);
              break;
            case 'complete':
              await _completeOrder(context, ref, orderNotifier);
              break;
          }
        },
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[];
          
          // Simplified flow - only allow completing confirmed orders
          if (order.status == OrderStatus.confirmed) {
            items.add(const PopupMenuItem(value: 'complete', child: Text('Mark Complete')));
          }
          
          return items;
        },
      ),
    ];
  }

  List<Widget> _buildCustomerActions(BuildContext context, WidgetRef ref) {
    return [
      IconButton(
        onPressed: () async {
          final orderNotifier = ref.read(orderNotifierProvider.notifier);
          await _cancelOrder(context, ref, orderNotifier);
        },
        icon: const Icon(Icons.cancel),
      ),
    ];
  }

  Future<void> _confirmOrder(BuildContext context, WidgetRef ref, OrderNotifier orderNotifier) async {
    final result = await orderNotifier.confirmOrder(order.id);
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order confirmed successfully')),
      );
      ref.invalidate(businessOrdersProvider);
    }
  }

  Future<void> _markOrderReady(BuildContext context, WidgetRef ref, OrderNotifier orderNotifier) async {
    final result = await orderNotifier.markOrderReady(order.id);
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as ready for pickup')),
      );
      ref.invalidate(businessOrdersProvider);
    }
  }

  Future<void> _completeOrder(BuildContext context, WidgetRef ref, OrderNotifier orderNotifier) async {
    final result = await orderNotifier.completeOrder(order.id);
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order completed successfully')),
      );
      ref.invalidate(businessOrdersProvider);
    }
  }

  Future<void> _cancelOrder(BuildContext context, WidgetRef ref, OrderNotifier orderNotifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await orderNotifier.cancelOrder(order.id);
      if (result != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
        ref.invalidate(customerOrdersProvider);
        ref.invalidate(businessOrdersProvider);
        context.go('/orders');
      }
    }
  }

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.confirmed:
        return Colors.orange; // Orange - action needed
      case OrderStatus.completed:
        return const Color(0xFF4CAF50); // Green - completed
      case OrderStatus.cancelled:
        return Colors.red; // Red - cancelled
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.confirmed:
        return Icons.qr_code; // QR code icon for verification
      case OrderStatus.completed:
        return Icons.check_circle; // Check circle for completed
      case OrderStatus.cancelled:
        return Icons.cancel; // Cancel icon
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
}