import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'order.freezed.dart';
part 'order.g.dart';

/// Simplified Order status enum - Only two states for streamlined flow
enum OrderStatus {
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

/// Payment status enum
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

/// Payment method enum
enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('digital')
  digital,
}

/// Extension methods for Order enums
extension OrderStatusExtension on OrderStatus {
  String get displayText {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  /// Get status description for customers
  String get customerDescription {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Your order is confirmed! Show the QR code or 6-digit code to the restaurant for pickup.';
      case OrderStatus.completed:
        return 'Order completed. Thank you for your business!';
      case OrderStatus.cancelled:
        return 'This order has been cancelled.';
    }
  }
  
  /// Get status color for UI
  String get statusColor {
    switch (this) {
      case OrderStatus.confirmed:
        return '#FF9800'; // Orange - action needed
      case OrderStatus.completed:
        return '#4CAF50'; // Green - success
      case OrderStatus.cancelled:
        return '#F44336'; // Red - error
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayText {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayText {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.digital:
        return 'Digital';
    }
  }
}

/// Order type enum
enum OrderType {
  @JsonValue('pickup')
  pickup,
  @JsonValue('delivery')
  delivery,
}

/// Business info for order
@freezed
class OrderBusiness with _$OrderBusiness {
  const factory OrderBusiness({
    required String id,
    required String name,
    String? phone,
    String? address,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _OrderBusiness;

  factory OrderBusiness.fromJson(Map<String, dynamic> json) => _$OrderBusinessFromJson(json);
}

/// Deal info for order item
@freezed
class OrderDeal with _$OrderDeal {
  const factory OrderDeal({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _OrderDeal;

  factory OrderDeal.fromJson(Map<String, dynamic> json) => _$OrderDealFromJson(json);
}

/// Order item
@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'deal_id') required String dealId,
    required int quantity,
    required double price,
    String? notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    OrderDeal? deals, // Nested deal info from API
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
}

/// Order model for pick-up orders with simplified flow
@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'business_id') required String businessId,
    @JsonKey(name: 'total_amount') required double totalAmount,
    required OrderStatus status,
    @JsonKey(name: 'delivery_address') String? deliveryAddress,
    @JsonKey(name: 'delivery_instructions') String? deliveryInstructions,
    @JsonKey(name: 'pickup_time') DateTime? pickupTime,
    @JsonKey(name: 'payment_method') required PaymentMethod paymentMethod,
    @JsonKey(name: 'payment_status') @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // New verification fields for simplified flow
    @JsonKey(name: 'verification_code') String? verificationCode,
    @JsonKey(name: 'qr_data') String? qrData,
    @JsonKey(name: 'confirmed_at') DateTime? confirmedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    // Nested data from API
    OrderBusiness? businesses,
    @JsonKey(name: 'order_items') @Default([]) List<OrderItem> orderItems,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  const Order._();

  /// Create a new pick-up order (immediately confirmed in simplified flow)
  factory Order.createPickupOrder({
    required String userId,
    required String businessId,
    required double totalAmount,
    DateTime? pickupTime,
    String? deliveryInstructions,
    PaymentMethod paymentMethod = PaymentMethod.cash,
  }) {
    return Order(
      id: '', // Will be generated by database
      userId: userId,
      businessId: businessId,
      totalAmount: totalAmount,
      status: OrderStatus.confirmed, // Immediately confirmed in simplified flow
      pickupTime: pickupTime,
      deliveryInstructions: deliveryInstructions,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      confirmedAt: DateTime.now(), // Set confirmation time
      orderItems: [],
    );
  }

  /// Get order status display text for simplified flow
  String get statusDisplay {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get payment status display text
  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  /// Get payment method display text
  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash on Pickup';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.digital:
        return 'Digital Payment';
    }
  }

  /// Check if order can be cancelled (only confirmed orders can be cancelled in simplified flow)
  bool get canBeCancelled {
    return status == OrderStatus.confirmed;
  }

  /// Check if order is active (not completed or cancelled)
  bool get isActive {
    return status != OrderStatus.completed && status != OrderStatus.cancelled;
  }

  /// Get formatted total amount
  String get formattedTotal {
    return '\$${totalAmount.toStringAsFixed(2)}';
  }

  /// Get the first deal title from order items
  String get dealTitle {
    if (orderItems.isNotEmpty && orderItems.first.deals != null) {
      return orderItems.first.deals!.title;
    }
    return 'Unknown Deal';
  }

  /// Get the first deal image URL from order items  
  String? get dealImageUrl {
    if (orderItems.isNotEmpty && orderItems.first.deals != null) {
      return orderItems.first.deals!.imageUrl;
    }
    return null;
  }

  /// Get business name
  String get businessName {
    return businesses?.name ?? 'Unknown Business';
  }

  /// Get total quantity from all order items
  int get totalQuantity {
    return orderItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get formatted pickup time
  String get formattedPickupTime {
    if (pickupTime == null) return 'Not specified';
    
    final now = DateTime.now();
    final pickup = pickupTime!;
    
    if (pickup.day == now.day && pickup.month == now.month && pickup.year == now.year) {
      // Today
      return 'Today at ${pickup.hour.toString().padLeft(2, '0')}:${pickup.minute.toString().padLeft(2, '0')}';
    } else if (pickup.day == now.day + 1 && pickup.month == now.month && pickup.year == now.year) {
      // Tomorrow
      return 'Tomorrow at ${pickup.hour.toString().padLeft(2, '0')}:${pickup.minute.toString().padLeft(2, '0')}';
    } else {
      // Other date
      return '${pickup.day}/${pickup.month}/${pickup.year} at ${pickup.hour.toString().padLeft(2, '0')}:${pickup.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Get order progress percentage for simplified flow
  double get progressPercentage {
    switch (status) {
      case OrderStatus.confirmed:
        return 0.5; // 50% - Order confirmed, waiting for pickup
      case OrderStatus.completed:
        return 1.0; // 100% - Order completed
      case OrderStatus.cancelled:
        return 0.0; // 0% - Order cancelled
    }
  }

  /// Get estimated preparation time in minutes
  int get estimatedPrepTime {
    // This could be enhanced to use deal-specific prep times
    return 15; // Default 15 minutes
  }
  
  /// Get formatted verification code for display (e.g., "A1B2C3")
  String get formattedVerificationCode {
    if (verificationCode == null || verificationCode!.isEmpty) {
      return 'No Code';
    }
    return verificationCode!.toUpperCase();
  }
  
  /// Check if order has verification code
  bool get hasVerificationCode {
    return verificationCode != null && verificationCode!.isNotEmpty;
  }
  
  /// Get QR code data as Map (parsed from JSON string)
  Map<String, dynamic>? get qrCodeData {
    if (qrData == null || qrData!.isEmpty) return null;
    try {
      return json.decode(qrData!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if order is ready for verification (has confirmation code)
  bool get isReadyForVerification {
    return status == OrderStatus.confirmed && hasVerificationCode;
  }
  
  /// Get verification instructions for customer
  String get verificationInstructions {
    if (!isReadyForVerification) {
      return 'Order not ready for verification';
    }
    return 'Show this QR code or tell the restaurant your pickup code: $formattedVerificationCode';
  }
  
  /// Get time since order was confirmed
  Duration? get timeSinceConfirmed {
    if (confirmedAt == null) return null;
    return DateTime.now().difference(confirmedAt!);
  }
  
  /// Get formatted time since confirmed
  String get timeSinceConfirmedFormatted {
    final duration = timeSinceConfirmed;
    if (duration == null) return 'Just now';
    
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ago';
    }
  }
}

/// Order with related data for display
@freezed
class OrderWithDetails with _$OrderWithDetails {
  const factory OrderWithDetails({
    required Order order,
    String? dealTitle,
    String? dealImageUrl,
    String? businessName,
    String? businessAddress,
    String? businessPhone,
  }) = _OrderWithDetails;

  factory OrderWithDetails.fromJson(Map<String, dynamic> json) => _$OrderWithDetailsFromJson(json);
}