import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/models/app_user.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    
    return OverflowSafeWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (cart.isNotEmpty)
              TextButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).clearCart();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: cart.isEmpty ? _buildEmptyCart(context) : _buildCartContent(context, ref, cart),
        bottomNavigationBar: cart.isNotEmpty 
          ? _buildCheckoutBar(context, ref, cart)
          : _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Browse deals and add items to your cart for pickup.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Browse Deals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, cart) {
    return Column(
      children: [
        if (cart.currentRestaurantName != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ordering from',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cart.currentRestaurantName!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Item image
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.imageUrl?.isNotEmpty == true
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildDefaultItemImage(),
                                )
                              : _buildDefaultItemImage(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.dealName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.restaurantName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.dealDescription.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.dealDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '\$${item.price.toStringAsFixed(2)} each',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  ref.read(cartProvider.notifier).updateCartItemQuantity(
                                    item.cartItemId, 
                                    item.quantity - 1,
                                  );
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.grey.shade600,
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ref.read(cartProvider.notifier).updateCartItemQuantity(
                                    item.cartItemId, 
                                    item.quantity + 1,
                                  );
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                color: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, WidgetRef ref, cart) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total (${cart.items.length} line items, ${cart.itemCount} quantity)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _proceedToCheckout(context, ref, cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultItemImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.3),
            const Color(0xFF2E7D32).withOpacity(0.3),
          ],
        ),
      ),
      child: const Icon(
        Icons.restaurant_menu,
        size: 32,
        color: Color(0xFF4CAF50),
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, WidgetRef ref, cart) {
    context.push('/checkout');
  }

  Widget _buildBottomNavigation() {
    return Consumer(
      builder: (context, ref, child) {
        final currentUserAsync = ref.watch(authenticatedUserProvider);
        
        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Center(
                    child: Text(
                      'Select a user to access navigation',
                      style: TextStyle(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }
            
            return CustomBottomNav(
              currentIndex: 3, // Orders tab index
              currentUser: currentUser,
              onTap: (index) => _handleBottomNavTap(context, index, currentUser),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleBottomNavTap(BuildContext context, int index, AppUser currentUser) {
    switch (index) {
      case 0:
        if (currentUser.isBusiness) {
          context.go('/business-home');
        } else {
          context.go('/home');
        }
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        if (currentUser.isBusiness) {
          context.go('/deals');
        } else {
          context.go('/favorites');
        }
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}