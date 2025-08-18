import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/order.dart';
import '../services/order_service.dart';

/// Provider for order service
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

/// Provider for customer orders
final customerOrdersProvider = FutureProvider.family<List<Order>, String>((ref, customerId) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getCustomerOrders(customerId);
});

/// Provider for business orders
final businessOrdersProvider = FutureProvider.family<List<Order>, String>((ref, businessId) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getBusinessOrders(businessId);
});

/// Provider for a single order by ID
final orderByIdProvider = FutureProvider.family<Order?, String>((ref, orderId) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getOrderById(orderId);
});

/// Provider for orders with details (joined data)
final ordersWithDetailsProvider = FutureProvider.family<List<OrderWithDetails>, String>((ref, customerId) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getOrdersWithDetails(customerId);
});

/// State notifier for managing order operations
class OrderNotifier extends StateNotifier<AsyncValue<Order?>> {
  OrderNotifier(this._orderService) : super(const AsyncValue.data(null));

  final OrderService _orderService;

  /// Create a new order
  Future<Order?> createOrder(Map<String, dynamic> orderData) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.createOrder(orderData);
      state = AsyncValue.data(order);
      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Update order status
  Future<Order?> updateOrderStatus(String orderId, OrderStatus status) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.updateOrderStatus(orderId, status);
      state = AsyncValue.data(order);
      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Cancel an order
  Future<Order?> cancelOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.cancelOrder(orderId);
      state = AsyncValue.data(order);
      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Confirm an order (business side)
  Future<Order?> confirmOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.confirmOrder(orderId);
      state = AsyncValue.data(order);
      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Mark order as ready for pickup
  Future<Order?> markOrderReady(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.markOrderReady(orderId);
      state = AsyncValue.data(order);
      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Complete an order
  Future<Order?> completeOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.completeOrder(orderId);
      state = AsyncValue.data(order);
      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Update pickup time
  Future<Order?> updatePickupTime(String orderId, DateTime pickupTime) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.updatePickupTime(orderId, pickupTime);
      state = AsyncValue.data(order);
      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Update payment status
  Future<Order?> updatePaymentStatus(String orderId, PaymentStatus paymentStatus) async {
    state = const AsyncValue.loading();
    try {
      final order = await _orderService.updatePaymentStatus(orderId, paymentStatus);
      state = AsyncValue.data(order);
      return order;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Clear the current state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for order notifier
final orderNotifierProvider = StateNotifierProvider<OrderNotifier, AsyncValue<Order?>>((ref) {
  final orderService = ref.read(orderServiceProvider);
  return OrderNotifier(orderService);
});