class CartItem {
  final String dealId;
  final String restaurantId;
  final String restaurantName;
  final String dealName;
  final String dealDescription;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String cartItemId;  // Unique identifier for each cart addition

  CartItem({
    required this.dealId,
    required this.restaurantId,
    required this.restaurantName,
    required this.dealName,
    required this.dealDescription,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    String? cartItemId,
  }) : cartItemId = cartItemId ?? '${dealId}_${DateTime.now().millisecondsSinceEpoch}_${(price * 1000).toInt()}';

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? dealId,
    String? restaurantId,
    String? restaurantName,
    String? dealName,
    String? dealDescription,
    double? price,
    int? quantity,
    String? imageUrl,
    String? cartItemId,
  }) {
    return CartItem(
      dealId: dealId ?? this.dealId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      dealName: dealName ?? this.dealName,
      dealDescription: dealDescription ?? this.dealDescription,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      cartItemId: cartItemId ?? this.cartItemId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.cartItemId == cartItemId;  // Each cart addition is unique
  }

  @override
  int get hashCode => cartItemId.hashCode;

  @override
  String toString() {
    return 'CartItem(dealId: $dealId, restaurantName: $restaurantName, dealName: $dealName, quantity: $quantity, totalPrice: $totalPrice)';
  }
}

class CartState {
  final List<CartItem> items;
  final String? currentRestaurantId;
  final String? currentRestaurantName;

  CartState({
    this.items = const [],
    this.currentRestaurantId,
    this.currentRestaurantName,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool canAddItemFromRestaurant(String restaurantId) {
    return isEmpty || currentRestaurantId == restaurantId;
  }

  bool hasItemsFromDifferentRestaurant(String restaurantId) {
    return isNotEmpty && currentRestaurantId != restaurantId;
  }

  CartItem? findItem(String dealId) {
    try {
      return items.firstWhere((item) => item.dealId == dealId);
    } catch (e) {
      return null;
    }
  }

  CartItem? findItemById(String cartItemId) {
    try {
      return items.firstWhere((item) => item.cartItemId == cartItemId);
    } catch (e) {
      return null;
    }
  }

  List<CartItem> getItemsForDeal(String dealId) {
    return items.where((item) => item.dealId == dealId).toList();
  }

  CartState copyWith({
    List<CartItem>? items,
    String? currentRestaurantId,
    String? currentRestaurantName,
  }) {
    return CartState(
      items: items ?? this.items,
      currentRestaurantId: currentRestaurantId ?? this.currentRestaurantId,
      currentRestaurantName: currentRestaurantName ?? this.currentRestaurantName,
    );
  }

  @override
  String toString() {
    return 'CartState(items: ${items.length}, restaurant: $currentRestaurantName, total: \$${totalAmount.toStringAsFixed(2)})';
  }
}