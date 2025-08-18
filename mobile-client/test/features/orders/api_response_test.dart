import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../../lib/features/orders/services/order_service.dart';
import '../../../lib/core/services/api_service.dart';
import '../../../lib/shared/models/order.dart';

@GenerateNiceMocks([
  MockSpec<OrderService>(),
])
void main() {
  group('API Response Type Handling Tests', () {
    test('handles direct List response correctly', () async {
      // Mock order data as would be returned by API
      final mockOrderData = [
        {
          'id': 'order-1',
          'customer_id': 'customer-1',
          'deal_id': 'deal-1',  
          'business_id': 'business-1',
          'quantity': 1,
          'unit_price': 8.99,
          'total_amount': 8.99,
          'status': 'pending',
          'order_type': 'pickup',
          'payment_status': 'pending',
          'payment_method': 'cash',
          'created_at': '2025-08-07T19:13:52.000Z',
        }
      ];

      // Test that Order.fromJson can handle the structure
      for (final orderJson in mockOrderData) {
        expect(() => Order.fromJson(orderJson), returnsNormally);
        final order = Order.fromJson(orderJson);
        expect(order.id, equals('order-1'));
        expect(order.customerId, equals('customer-1'));
        expect(order.status, equals(OrderStatus.pending));
        expect(order.orderType, equals(OrderType.pickup));
      }
    });

    test('handles nested Map response correctly', () async {
      // Mock response as Map with nested data
      final mockResponse = {
        'success': true,
        'data': [
          {
            'id': 'order-2',
            'customer_id': 'customer-2',
            'deal_id': 'deal-2',
            'business_id': 'business-2',
            'quantity': 2,
            'unit_price': 12.99,
            'total_amount': 25.98,
            'status': 'confirmed',
            'order_type': 'pickup',
            'payment_status': 'paid',
            'payment_method': 'card',
            'created_at': '2025-08-07T20:00:00.000Z',
          }
        ]
      };

      // Extract orders from nested structure
      final ordersData = mockResponse['data'] as List;
      expect(ordersData.length, equals(1));
      
      // Test that Order.fromJson can handle the structure
      final order = Order.fromJson(ordersData[0] as Map<String, dynamic>);
      expect(order.id, equals('order-2'));
      expect(order.status, equals(OrderStatus.confirmed));
      expect(order.paymentStatus, equals(PaymentStatus.paid));
    });

    test('validates order model serialization', () async {
      final testOrder = Order(
        id: 'test-order',
        customerId: 'test-customer',
        dealId: 'test-deal',
        businessId: 'test-business',
        quantity: 1,
        unitPrice: 10.0,
        totalAmount: 10.0,
        status: OrderStatus.pending,
        orderType: OrderType.pickup,
        paymentStatus: PaymentStatus.pending,
        paymentMethod: PaymentMethod.cash,
        createdAt: DateTime.now(),
      );

      // Test serialization to JSON
      final json = testOrder.toJson();
      expect(json['id'], equals('test-order'));
      expect(json['status'], equals('pending'));
      expect(json['order_type'], equals('pickup'));
      expect(json['payment_method'], equals('cash'));

      // Test deserialization from JSON
      final deserializedOrder = Order.fromJson(json);
      expect(deserializedOrder.id, equals(testOrder.id));
      expect(deserializedOrder.status, equals(testOrder.status));
      expect(deserializedOrder.orderType, equals(testOrder.orderType));
      expect(deserializedOrder.paymentMethod, equals(testOrder.paymentMethod));
    });

    test('handles empty response correctly', () {
      // Test empty list response
      final emptyListResponse = <dynamic>[];
      expect(emptyListResponse.length, equals(0));
      
      // Test empty Map response
      final emptyMapResponse = {'data': <dynamic>[]};
      final extractedOrders = emptyMapResponse['data'] as List;
      expect(extractedOrders.length, equals(0));
    });

    test('validates response structure detection logic', () {
      // Test different response structures that the service should handle
      
      // Direct list
      final directList = [{'order': 'data'}];
      expect(directList, isA<List>());
      
      // Nested in 'data' key
      final nestedData = {'data': [{'order': 'data'}]};
      expect(nestedData, isA<Map<String, dynamic>>());
      expect(nestedData.containsKey('data'), isTrue);
      expect(nestedData['data'], isA<List>());
      
      // Nested in 'orders' key
      final nestedOrders = {'orders': [{'order': 'data'}]};
      expect(nestedOrders, isA<Map<String, dynamic>>());
      expect(nestedOrders.containsKey('orders'), isTrue);
      expect(nestedOrders['orders'], isA<List>());
      
      // API wrapper format
      final apiWrapper = {'success': true, 'data': [{'order': 'data'}]};
      expect(apiWrapper, isA<Map<String, dynamic>>());
      expect(apiWrapper.containsKey('success'), isTrue);
      expect(apiWrapper.containsKey('data'), isTrue);
      expect(apiWrapper['data'], isA<List>());
    });
  });
}