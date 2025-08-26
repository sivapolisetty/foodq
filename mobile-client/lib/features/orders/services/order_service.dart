import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/order.dart';

/// Service for managing orders (pick-up only)
class OrderService {
  static const String _endpoint = '/api/orders';

  /// Create a new order
  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      debugPrint('🔧 OrderService.createOrder: Starting with data: $orderData');
      
      final response = await ApiService.post<Map<String, dynamic>>(
        _endpoint,
        body: orderData,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      debugPrint('🔧 OrderService.createOrder: Response success=${response.success}');
      debugPrint('🔧 OrderService.createOrder: Response data=${response.data}');

      if (response.success && response.data != null) {
        // Try to access data from response.data['data'] first (nested)
        var orderResult = response.data!['data'];
        
        // If that's null, try response.data directly (flat structure)
        if (orderResult == null) {
          debugPrint('🔧 OrderService.createOrder: No nested data, trying flat structure');
          orderResult = response.data!;
        }
        
        if (orderResult != null) {
          debugPrint('🔧 OrderService.createOrder: Creating Order from: $orderResult');
          return Order.fromJson(orderResult as Map<String, dynamic>);
        } else {
          debugPrint('🔧 OrderService.createOrder: orderResult is null');
        }
      }
      
      debugPrint('🔧 OrderService.createOrder: Failed - ${response.error}');
      throw Exception('Failed to create order: ${response.error}');
    } catch (e) {
      debugPrint('🔧 OrderService.createOrder: Exception - $e');
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get orders for a customer
  Future<List<Order>> getCustomerOrders(String customerId) async {
    try {
      debugPrint('🛒 OrderService: Getting orders for customer: $customerId');
      
      // Use GET without customer_id param - API will use authenticated user's ID by default
      final response = await ApiService.get<dynamic>(
        _endpoint,
        fromJson: (data) => data, // Accept any type
      );
      
      debugPrint('🛒 OrderService: API response success: ${response.success}');
      debugPrint('🛒 OrderService: API response data type: ${response.data.runtimeType}');
      debugPrint('🛒 OrderService: API response data: ${response.data}');

      if (response.success && response.data != null) {
        List<dynamic> orders = [];
        
        // Handle different response structures
        if (response.data is List) {
          debugPrint('🛒 OrderService: Response is direct list');
          orders = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          debugPrint('🛒 OrderService: Response is Map, extracting orders');
          final responseMap = response.data as Map<String, dynamic>;
          
          // Try different possible keys
          if (responseMap.containsKey('data')) {
            var dataValue = responseMap['data'];
            if (dataValue is List) {
              orders = dataValue;
            } else if (dataValue is Map && (dataValue as Map).containsKey('orders')) {
              orders = (dataValue as Map)['orders'] ?? [];
            }
          } else if (responseMap.containsKey('orders')) {
            orders = responseMap['orders'] ?? [];
          } else if (responseMap.containsKey('success') && responseMap.containsKey('data')) {
            // API wrapper format: {success: true, data: [...]}
            var dataValue = responseMap['data'];
            if (dataValue is List) {
              orders = dataValue;
            }
          }
        }
        
        debugPrint('🛒 OrderService: Found ${orders.length} orders');
        
        if (orders.isEmpty) {
          debugPrint('🛒 OrderService: No orders found, returning empty list');
          return [];
        }
        
        final parsedOrders = <Order>[];
        for (int i = 0; i < orders.length; i++) {
          try {
            final orderData = orders[i];
            debugPrint('🛒 OrderService: Parsing order $i type: ${orderData.runtimeType}');
            
            if (orderData is Map<String, dynamic>) {
              debugPrint('🛒 OrderService: Order $i data: $orderData');
              
              // Sanitize the order data to handle type mismatches
              final sanitizedData = _sanitizeOrderData(orderData);
              
              final order = Order.fromJson(sanitizedData);
              parsedOrders.add(order);
              debugPrint('🛒 OrderService: Successfully parsed order $i: ${order.id}');
            } else {
              debugPrint('🛒 OrderService: Order $i is not a Map, skipping');
            }
          } catch (e, stackTrace) {
            debugPrint('🛒 OrderService: Failed to parse order $i: $e');
            debugPrint('🛒 OrderService: Stack trace for order $i: $stackTrace');
            // Skip invalid orders rather than failing the entire request
            continue;
          }
        }
        
        debugPrint('🛒 OrderService: Successfully parsed ${parsedOrders.length} orders');
        return parsedOrders;
      }
      
      debugPrint('🛒 OrderService: API failed - ${response.error}');
      throw Exception('Failed to load orders: ${response.error}');
    } catch (e, stackTrace) {
      debugPrint('🛒 OrderService: Exception - $e');
      debugPrint('🛒 OrderService: Stack trace - $stackTrace');
      throw Exception('Failed to load orders: $e');
    }
  }

  /// Get orders for a business
  Future<List<Order>> getBusinessOrders(String businessId) async {
    try {
      debugPrint('🛒 OrderService: Getting orders for business: $businessId');
      
      // Use business_id query parameter for business orders
      final response = await ApiService.get<dynamic>(
        '$_endpoint?business_id=$businessId',
        fromJson: (data) => data, // Accept any type
      );
      
      debugPrint('🛒 OrderService: Business API response success: ${response.success}');
      debugPrint('🛒 OrderService: Business API response data type: ${response.data.runtimeType}');
      debugPrint('🛒 OrderService: Business API response data: ${response.data}');

      if (response.success && response.data != null) {
        List<dynamic> orders = [];
        
        // Handle different response structures (same logic as customer orders)
        if (response.data is List) {
          debugPrint('🛒 OrderService: Business response is direct list');
          orders = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          debugPrint('🛒 OrderService: Business response is Map, extracting orders');
          final responseMap = response.data as Map<String, dynamic>;
          
          // Try different possible keys
          if (responseMap.containsKey('data')) {
            var dataValue = responseMap['data'];
            if (dataValue is List) {
              orders = dataValue;
            } else if (dataValue is Map && (dataValue as Map).containsKey('orders')) {
              orders = (dataValue as Map)['orders'] ?? [];
            }
          } else if (responseMap.containsKey('orders')) {
            orders = responseMap['orders'] ?? [];
          } else if (responseMap.containsKey('success') && responseMap.containsKey('data')) {
            var dataValue = responseMap['data'];
            if (dataValue is List) {
              orders = dataValue;
            }
          }
        }
        
        debugPrint('🛒 OrderService: Found ${orders.length} business orders');
        
        if (orders.isEmpty) {
          debugPrint('🛒 OrderService: No business orders found, returning empty list');
          return [];
        }
        
        final parsedOrders = <Order>[];
        for (int i = 0; i < orders.length; i++) {
          try {
            final orderData = orders[i];
            if (orderData is Map<String, dynamic>) {
              // Sanitize the order data to handle type mismatches
              final sanitizedData = _sanitizeOrderData(orderData);
              
              final order = Order.fromJson(sanitizedData);
              parsedOrders.add(order);
              debugPrint('🛒 OrderService: Successfully parsed business order $i: ${order.id}');
            } else {
              debugPrint('🛒 OrderService: Business order $i is not a Map, skipping');
            }
          } catch (e, stackTrace) {
            debugPrint('🛒 OrderService: Failed to parse business order $i: $e');
            continue;
          }
        }
        
        debugPrint('🛒 OrderService: Successfully parsed ${parsedOrders.length} business orders');
        return parsedOrders;
      }
      
      debugPrint('🛒 OrderService: Business API failed - ${response.error}');
      throw Exception('Failed to load business orders: ${response.error}');
    } catch (e, stackTrace) {
      debugPrint('🛒 OrderService: Business Exception - $e');
      debugPrint('🛒 OrderService: Business Stack trace - $stackTrace');
      throw Exception('Failed to load business orders: $e');
    }
  }

  /// Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        '$_endpoint/$orderId',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final orderData = response.data!['data'];
        if (orderData != null) {
          return Order.fromJson(orderData as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update order status
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      debugPrint('🔄 OrderService: Updating order $orderId to status ${status.name}');
      
      final response = await ApiService.put<dynamic>(
        '$_endpoint/$orderId',
        body: {'status': status.name},
        fromJson: (data) => data, // Accept any type
      );

      debugPrint('🔄 OrderService: Update response success: ${response.success}');
      debugPrint('🔄 OrderService: Update response data: ${response.data}');

      if (response.success && response.data != null) {
        // Handle different response structures
        Map<String, dynamic> orderData;
        
        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          
          // Try different possible keys for the order data
          if (responseMap.containsKey('data')) {
            orderData = responseMap['data'] as Map<String, dynamic>;
          } else {
            orderData = responseMap;
          }
        } else {
          throw Exception('Invalid response format');
        }
        
        // Sanitize the order data
        final sanitizedData = _sanitizeOrderData(orderData);
        
        return Order.fromJson(sanitizedData);
      }
      throw Exception('Failed to update order status: ${response.error}');
    } catch (e, stackTrace) {
      debugPrint('🔄 OrderService: Update order status error: $e');
      debugPrint('🔄 OrderService: Stack trace: $stackTrace');
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Cancel an order
  Future<Order> cancelOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  /// Confirm an order (business side)
  Future<Order> confirmOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.confirmed);
  }

  /// Mark order as ready for pickup
  Future<Order> markOrderReady(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.ready);
  }

  /// Complete an order
  Future<Order> completeOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.completed);
  }

  /// Update pickup time
  Future<Order> updatePickupTime(String orderId, DateTime pickupTime) async {
    try {
      final response = await ApiService.put<Map<String, dynamic>>(
        '$_endpoint/$orderId',
        body: {'pickup_time': pickupTime.toIso8601String()},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final orderData = response.data!['data'];
        if (orderData != null) {
          return Order.fromJson(orderData as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to update pickup time: ${response.error}');
    } catch (e) {
      throw Exception('Failed to update pickup time: $e');
    }
  }

  /// Update payment status
  Future<Order> updatePaymentStatus(String orderId, PaymentStatus paymentStatus) async {
    try {
      final response = await ApiService.put<Map<String, dynamic>>(
        '$_endpoint/$orderId',
        body: {'payment_status': paymentStatus.name},
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final orderData = response.data!['data'];
        if (orderData != null) {
          return Order.fromJson(orderData as Map<String, dynamic>);
        }
      }
      throw Exception('Failed to update payment status: ${response.error}');
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Get orders with details (joined with deals and businesses)
  Future<List<OrderWithDetails>> getOrdersWithDetails(String customerId) async {
    try {
      final response = await ApiService.get<List<dynamic>>(
        '$_endpoint/with-details?customer_id=eq.$customerId',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => OrderWithDetails.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load orders with details: ${response.error}');
    } catch (e) {
      throw Exception('Failed to load orders with details: $e');
    }
  }

  /// Calculate estimated pickup time based on current time and prep time
  DateTime calculateEstimatedPickupTime({int prepTimeMinutes = 15}) {
    return DateTime.now().add(Duration(minutes: prepTimeMinutes));
  }

  /// Validate order data before creation
  Map<String, String> validateOrderData({
    required String customerId,
    required String dealId,
    required String businessId,
    required int quantity,
    required double unitPrice,
    DateTime? pickupTime,
  }) {
    final errors = <String, String>{};

    if (customerId.isEmpty) {
      errors['customerId'] = 'Customer ID is required';
    }

    if (dealId.isEmpty) {
      errors['dealId'] = 'Deal ID is required';
    }

    if (businessId.isEmpty) {
      errors['businessId'] = 'Business ID is required';
    }

    if (quantity <= 0) {
      errors['quantity'] = 'Quantity must be greater than 0';
    }

    if (quantity > 10) {
      errors['quantity'] = 'Maximum quantity is 10 per order';
    }

    if (unitPrice <= 0) {
      errors['unitPrice'] = 'Unit price must be greater than 0';
    }

    if (pickupTime != null && pickupTime.isBefore(DateTime.now())) {
      errors['pickupTime'] = 'Pickup time must be in the future';
    }

    return errors;
  }

  /// Sanitize order data to handle potential type mismatches from API
  Map<String, dynamic> _sanitizeOrderData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    
    // Ensure string fields are not null for required fields
    if (sanitized['status'] == null) {
      sanitized['status'] = 'pending';
    }
    
    if (sanitized['payment_method'] == null) {
      sanitized['payment_method'] = 'cash';
    }
    
    if (sanitized['payment_status'] == null) {
      sanitized['payment_status'] = 'pending';
    }
    
    // Convert numeric fields that might be strings
    final numericFields = ['total_amount'];
    for (final field in numericFields) {
      if (sanitized[field] != null) {
        if (sanitized[field] is String) {
          try {
            sanitized[field] = double.parse(sanitized[field] as String);
          } catch (e) {
            debugPrint('🛒 OrderService: Failed to parse $field as double: ${sanitized[field]}');
            sanitized[field] = 0.0;
          }
        } else if (sanitized[field] is int) {
          sanitized[field] = (sanitized[field] as int).toDouble();
        }
      }
    }
    
    // Sanitize nested businesses data
    if (sanitized['businesses'] != null && sanitized['businesses'] is Map) {
      final business = sanitized['businesses'] as Map<String, dynamic>;
      
      // Ensure required business fields
      business['id'] = business['id'] ?? '';
      business['name'] = business['name'] ?? 'Unknown Business';
    }
    
    // Sanitize nested order_items data
    if (sanitized['order_items'] != null && sanitized['order_items'] is List) {
      final items = sanitized['order_items'] as List;
      
      for (int i = 0; i < items.length; i++) {
        if (items[i] is Map<String, dynamic>) {
          final item = items[i] as Map<String, dynamic>;
          
          // Ensure required item fields
          item['id'] = item['id'] ?? '';
          item['order_id'] = item['order_id'] ?? '';
          item['deal_id'] = item['deal_id'] ?? '';
          item['quantity'] = item['quantity'] ?? 1;
          
          // Convert price to double if it's a string or int
          if (item['price'] != null) {
            if (item['price'] is String) {
              try {
                item['price'] = double.parse(item['price'] as String);
              } catch (e) {
                item['price'] = 0.0;
              }
            } else if (item['price'] is int) {
              item['price'] = (item['price'] as int).toDouble();
            }
          } else {
            item['price'] = 0.0;
          }
          
          // Sanitize nested deals data
          if (item['deals'] != null && item['deals'] is Map) {
            final deal = item['deals'] as Map<String, dynamic>;
            deal['id'] = deal['id'] ?? '';
            deal['title'] = deal['title'] ?? 'Unknown Deal';
          }
        }
      }
    }
    
    return sanitized;
  }
}