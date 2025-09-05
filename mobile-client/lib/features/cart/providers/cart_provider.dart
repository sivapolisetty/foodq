import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_models.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem({
    required String dealId,
    required String restaurantId,
    required String restaurantName,
    required String dealName,
    required String dealDescription,
    required double price,
    String? imageUrl,
    int quantity = 1,
  }) {
    // ALWAYS add as a new separate line item - never consolidate
    final newItem = CartItem(
      dealId: dealId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      dealName: dealName,
      dealDescription: dealDescription,
      price: price,
      quantity: quantity,
      imageUrl: imageUrl,
    );

    final updatedItems = [...state.items, newItem];
    
    state = state.copyWith(
      items: updatedItems,
      currentRestaurantId: restaurantId,
      currentRestaurantName: restaurantName,
    );

    print('🛒 CART: Added separate line item - $dealName x$quantity (\$${price.toStringAsFixed(2)}) from $restaurantName [${newItem.cartItemId}]');
    print('🛒 CART: Total line items: ${state.items.length}, Total quantity: ${state.itemCount}, Total: \$${state.totalAmount.toStringAsFixed(2)}');
  }

  void removeItem(String dealId) {
    final updatedItems = state.items.where((item) => item.dealId != dealId).toList();
    
    if (updatedItems.isEmpty) {
      state = CartState();
      print('🛒 CART: Cleared - no items remaining');
    } else {
      state = state.copyWith(items: updatedItems);
      print('🛒 CART: Removed item $dealId');
    }
  }

  void removeCartItem(String cartItemId) {
    final updatedItems = state.items.where((item) => item.cartItemId != cartItemId).toList();
    
    if (updatedItems.isEmpty) {
      state = CartState();
      print('🛒 CART: Cleared - no items remaining');
    } else {
      state = state.copyWith(items: updatedItems);
      print('🛒 CART: Removed cart item $cartItemId');
    }
  }

  void updateQuantity(String dealId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(dealId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.dealId == dealId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    print('🛒 CART: Updated quantity for $dealId to $newQuantity');
  }

  void updateCartItemQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeCartItem(cartItemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.cartItemId == cartItemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    print('🛒 CART: Updated quantity for cart item $cartItemId to $newQuantity');
  }

  void clearCart() {
    state = CartState();
    print('🛒 CART: Cleared all items');
  }

  void replaceWithNewRestaurant({
    required String dealId,
    required String restaurantId,
    required String restaurantName,
    required String dealName,
    required String dealDescription,
    required double price,
    String? imageUrl,
    int quantity = 1,
  }) {
    print('🛒 CART: Switching from ${state.currentRestaurantName} to $restaurantName');
    clearCart();
    addItem(
      dealId: dealId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      dealName: dealName,
      dealDescription: dealDescription,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
    );
  }

  bool canAddItemFromRestaurant(String restaurantId) {
    return state.canAddItemFromRestaurant(restaurantId);
  }

  bool hasItemsFromDifferentRestaurant(String restaurantId) {
    return state.hasItemsFromDifferentRestaurant(restaurantId);
  }

  int getItemQuantity(String dealId) {
    final item = state.findItem(dealId);
    return item?.quantity ?? 0;
  }

  int getCartItemQuantity(String cartItemId) {
    final item = state.findItemById(cartItemId);
    return item?.quantity ?? 0;
  }

  // Get total quantity for a specific deal (across all line items)
  int getDealTotalQuantity(String dealId) {
    return state.getItemsForDeal(dealId).fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.itemCount;
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalAmount;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.isEmpty;
});