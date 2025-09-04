import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/business.dart';
import '../../../services/business_service.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/models/cart_models.dart';
import '../../location/services/customer_address_service.dart';
import '../../orders/providers/order_provider.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Business? _pickupBusiness;
  bool _isLoadingBusiness = false;
  bool _isPlacingOrder = false;
  final BusinessService _businessService = BusinessService();

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
  }

  Future<void> _loadBusinessDetails() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty || cart.currentRestaurantId == null) return;

    setState(() => _isLoadingBusiness = true);
    
    try {
      final business = await _businessService.getBusinessById(cart.currentRestaurantId!);
      setState(() {
        _pickupBusiness = business;
        _isLoadingBusiness = false;
      });
    } catch (e) {
      print('❌ Error loading business details: $e');
      setState(() {
        _isLoadingBusiness = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    
    if (cart.isEmpty) {
      return OverflowSafeWrapper(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text('Your cart is empty'),
          ),
        ),
      );
    }

    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(cart),
                    const SizedBox(height: 24),
                    _buildPickupAddressSection(),
                    const SizedBox(height: 24),
                    _buildPaymentSection(),
                  ],
                ),
              ),
            ),
            _buildPlaceOrderButton(cart),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartState cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.store, color: Color(0xFF4CAF50), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    cart.currentRestaurantName ?? 'Restaurant',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${item.quantity}x ${item.dealName}'),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )),
            
            const Divider(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                const Text(
                  'Pickup Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_isLoadingBusiness)
              const Center(child: CircularProgressIndicator())
            else if (_pickupBusiness != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4CAF50)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pickupBusiness!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _pickupBusiness!.address,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Unable to load pickup location',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: const Color(0xFF4CAF50)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay at Pickup',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Cash or card payment when you collect your order',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(CartState cart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPlacingOrder || _pickupBusiness == null 
                ? null 
                : () => _placeOrder(cart),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isPlacingOrder
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Placing Order...'),
                    ],
                  )
                : Text(
                    _pickupBusiness == null
                      ? 'Loading pickup location...'
                      : 'Place Order • \$${cart.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder(CartState cart) async {
    if (_pickupBusiness == null) return;
    
    setState(() => _isPlacingOrder = true);
    
    try {
      final currentUser = ref.read(authenticatedUserProvider).valueOrNull;
      if (currentUser == null) throw Exception('User not authenticated');
      
      final orderData = {
        'customer_id': currentUser.id,
        'business_id': cart.currentRestaurantId, // API expects business_id, not restaurant_id
        'items': cart.items.map((item) => {
          'deal_id': item.dealId,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
        'total_amount': cart.totalAmount,
        'pickup_address': {
          'formatted_address': _pickupBusiness!.address,
          'latitude': _pickupBusiness!.latitude,
          'longitude': _pickupBusiness!.longitude,
          'business_name': _pickupBusiness!.name,
        },
        'payment_method': 'cash', // Pay at pickup using cash
        'notes': '',
      };

      final order = await ref.read(orderNotifierProvider.notifier).createOrder(orderData);
      
      if (order != null) {
        ref.read(cartProvider.notifier).clearCart();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          context.go('/orders');
        }
      } else {
        throw Exception('Failed to create order');
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }
}