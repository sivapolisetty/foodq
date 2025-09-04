import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../widgets/restaurant_switch_modal.dart';
import '../../deals/widgets/order_placement_bottom_sheet.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/business.dart';
import '../../../shared/models/order.dart';
import 'package:go_router/go_router.dart';

class CartValidationService {
  
  static Future<bool> validateAndAddToCart({
    required BuildContext context,
    required WidgetRef ref,
    required String dealId,
    required String restaurantId,
    required String restaurantName,
    required String dealName,
    required String dealDescription,
    required double price,
    String? imageUrl,
    int quantity = 1,
  }) async {
    final cartNotifier = ref.read(cartProvider.notifier);
    final currentCart = ref.read(cartProvider);

    // Check if we can add directly (empty cart or same restaurant)
    if (cartNotifier.canAddItemFromRestaurant(restaurantId)) {
      cartNotifier.addItem(
        dealId: dealId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        dealName: dealName,
        dealDescription: dealDescription,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity,
      );
      
      // Cart bar will show automatically when item is added, no need for notification
      return true;
    }

    // Cart has items from different restaurant - show confirmation modal
    if (cartNotifier.hasItemsFromDifferentRestaurant(restaurantId)) {
      final shouldSwitch = await RestaurantSwitchModal.show(
        context,
        currentCart: currentCart,
        newRestaurantName: restaurantName,
        newDealName: dealName,
      );

      if (shouldSwitch == true) {
        cartNotifier.replaceWithNewRestaurant(
          dealId: dealId,
          restaurantId: restaurantId,
          restaurantName: restaurantName,
          dealName: dealName,
          dealDescription: dealDescription,
          price: price,
          imageUrl: imageUrl,
          quantity: quantity,
        );
        
        // Cart bar will show automatically when item is added, no need for notification
        return true;
      }
    }

    return false;
  }

  static Future<bool> quickOrder({
    required BuildContext context,
    required WidgetRef ref,
    required String dealId,
    required String restaurantId,
    required String restaurantName,
    required String dealName,
    required String dealDescription,
    required double price,
    String? imageUrl,
  }) async {
    try {
      // Create Deal object for the popup
      final deal = Deal(
        id: dealId,
        title: dealName,
        description: dealDescription,
        originalPrice: price * 1.2, // Assume 20% discount for display
        discountedPrice: price,
        quantityAvailable: 10, // Default availability
        quantitySold: 0,
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        imageUrl: imageUrl,
        businessId: restaurantId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        restaurant: null, // Will set business separately
      );
      
      // Create Business object for the popup
      final business = Business(
        id: restaurantId,
        ownerId: 'temp-owner', // Temporary owner ID for popup
        name: restaurantName,
        address: 'Pickup Location', // Default address text
        email: '',
        phone: '',
        latitude: 0.0,
        longitude: 0.0,
      );

      // Show the same order placement bottom sheet
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => OrderPlacementBottomSheet(
          deal: deal,
          business: business,
          onOrderPlaced: (Order order) {
            // Navigate to orders screen after order is placed
            context.go('/orders');
          },
        ),
      );
      
      return true;
    } catch (e) {
      _showErrorSnackbar(context, 'Failed to show quick order');
      return false;
    }
  }


  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}