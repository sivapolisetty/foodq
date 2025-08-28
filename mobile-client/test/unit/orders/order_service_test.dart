import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grabeat/features/orders/services/order_service.dart';
import 'package:grabeat/features/orders/models/order.dart';
import 'package:grabeat/features/orders/models/order_item.dart';
import 'package:grabeat/features/orders/models/payment_intent.dart';
import 'package:grabeat/shared/models/deal.dart';

@GenerateMocks([SupabaseClient])
import 'order_service_test.mocks.dart';

void main() {
  late OrderService orderService;
  late MockSupabaseClient mockSupabaseClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    orderService = OrderService(supabaseClient: mockSupabaseClient);
  });

  group('OrderService Tests', () {
    group('createOrder', () {
      test('should create order with valid items and return order ID', () async {
        // Arrange
        final dealId = 'deal-123';
        final customerId = 'customer-456';
        final quantity = 2;
        
        final mockDeal = Deal(
          id: dealId,
          businessId: 'business-789',
          title: 'Test Pizza Deal',
          description: 'Delicious pizza',
          originalPrice: 15.0,
          discountedPrice: 10.0,
          quantityAvailable: 5,
          quantitySold: 0,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final expectedOrderId = 'order-abc123';
        final mockOrderResponse = {
          'id': expectedOrderId,
          'customer_id': customerId,
          'status': 'pending',
          'total_amount': 20.0,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Mock Supabase calls
        when(mockSupabaseClient.from('orders')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('orders').insert(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').insert(any).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').insert(any).select().single()).thenAnswer((_) async => mockOrderResponse);

        // Act
        final result = await orderService.createOrder(
          customerId: customerId,
          items: [
            OrderItem(
              dealId: dealId,
              deal: mockDeal,
              quantity: quantity,
              unitPrice: mockDeal.discountedPrice,
            ),
          ],
        );

        // Assert
        expect(result.id, expectedOrderId);
        expect(result.customerId, customerId);
        expect(result.status, OrderStatus.pending);
        expect(result.totalAmount, 20.0);
        expect(result.items.length, 1);
        expect(result.items.first.quantity, quantity);
      });

      test('should throw exception when deal is out of stock', () async {
        // Arrange
        final dealId = 'deal-123';
        final customerId = 'customer-456';
        final quantity = 3;
        
        final mockDeal = Deal(
          id: dealId,
          businessId: 'business-789',
          title: 'Out of Stock Deal',
          description: 'No longer available',
          originalPrice: 15.0,
          discountedPrice: 10.0,
          quantityAvailable: 0, // Out of stock
          quantitySold: 5,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => orderService.createOrder(
            customerId: customerId,
            items: [
              OrderItem(
                dealId: dealId,
                deal: mockDeal,
                quantity: quantity,
                unitPrice: mockDeal.discountedPrice,
              ),
            ],
          ),
          throwsA(isA<OrderValidationException>()),
        );
      });

      test('should throw exception when deal has expired', () async {
        // Arrange
        final dealId = 'deal-123';
        final customerId = 'customer-456';
        final quantity = 1;
        
        final mockDeal = Deal(
          id: dealId,
          businessId: 'business-789',
          title: 'Expired Deal',
          description: 'This deal has expired',
          originalPrice: 15.0,
          discountedPrice: 10.0,
          quantityAvailable: 5,
          quantitySold: 0,
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)), // Expired
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => orderService.createOrder(
            customerId: customerId,
            items: [
              OrderItem(
                dealId: dealId,
                deal: mockDeal,
                quantity: quantity,
                unitPrice: mockDeal.discountedPrice,
              ),
            ],
          ),
          throwsA(isA<OrderValidationException>()),
        );
      });

      test('should handle insufficient quantity gracefully', () async {
        // Arrange
        final dealId = 'deal-123';
        final customerId = 'customer-456';
        final requestedQuantity = 10;
        
        final mockDeal = Deal(
          id: dealId,
          businessId: 'business-789',
          title: 'Limited Stock Deal',
          description: 'Only few left',
          originalPrice: 15.0,
          discountedPrice: 10.0,
          quantityAvailable: 3, // Less than requested
          quantitySold: 2,
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => orderService.createOrder(
            customerId: customerId,
            items: [
              OrderItem(
                dealId: dealId,
                deal: mockDeal,
                quantity: requestedQuantity,
                unitPrice: mockDeal.discountedPrice,
              ),
            ],
          ),
          throwsA(isA<OrderValidationException>()),
        );
      });
    });

    group('processPayment', () {
      test('should create Stripe payment intent successfully', () async {
        // Arrange
        final orderId = 'order-123';
        final amount = 2550; // $25.50 in cents
        final currency = 'usd';

        final mockPaymentIntent = PaymentIntent(
          id: 'pi_1234567890',
          clientSecret: 'pi_1234567890_secret_abc123',
          amount: amount,
          currency: currency,
          status: PaymentIntentStatus.requiresPaymentMethod,
        );

        // Mock Stripe API call (would be handled by a service)
        // For now, we'll mock the OrderService method directly

        // Act
        final result = await orderService.createPaymentIntent(
          orderId: orderId,
          amount: amount,
          currency: currency,
        );

        // Assert
        expect(result.amount, amount);
        expect(result.currency, currency);
        expect(result.status, PaymentIntentStatus.requiresPaymentMethod);
        expect(result.clientSecret.isNotEmpty, true);
      });

      test('should handle payment confirmation', () async {
        // Arrange
        final paymentIntentId = 'pi_1234567890';
        final orderId = 'order-123';

        final mockUpdatedOrder = {
          'id': orderId,
          'payment_intent_id': paymentIntentId,
          'payment_status': 'paid',
          'status': 'confirmed',
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Mock database update
        when(mockSupabaseClient.from('orders')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('orders').update(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').update(any).eq('id', orderId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').update(any).eq('id', orderId).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').update(any).eq('id', orderId).select().single()).thenAnswer((_) async => mockUpdatedOrder);

        // Act
        final result = await orderService.confirmPayment(
          orderId: orderId,
          paymentIntentId: paymentIntentId,
        );

        // Assert
        expect(result.paymentStatus, PaymentStatus.paid);
        expect(result.status, OrderStatus.confirmed);
        expect(result.paymentIntentId, paymentIntentId);
      });

      test('should handle payment failure gracefully', () async {
        // Arrange
        final paymentIntentId = 'pi_failed_payment';
        final orderId = 'order-123';

        // Act & Assert
        expect(
          () => orderService.handlePaymentFailure(
            orderId: orderId,
            paymentIntentId: paymentIntentId,
            failureReason: 'Card declined',
          ),
          returnsNormally,
        );
      });
    });

    group('getOrderById', () {
      test('should return order with items when found', () async {
        // Arrange
        final orderId = 'order-123';
        final mockOrderResponse = {
          'id': orderId,
          'customer_id': 'customer-456',
          'status': 'confirmed',
          'total_amount': 25.50,
          'payment_status': 'paid',
          'created_at': DateTime.now().toIso8601String(),
          'order_items': [
            {
              'id': 'item-1',
              'deal_id': 'deal-123',
              'quantity': 2,
              'unit_price': 10.0,
              'deals': {
                'id': 'deal-123',
                'title': 'Pizza Deal',
                'description': 'Delicious pizza',
              }
            }
          ]
        };

        // Mock database query
        when(mockSupabaseClient.from('orders')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('orders').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').select(any).eq('id', orderId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').select(any).eq('id', orderId).single()).thenAnswer((_) async => mockOrderResponse);

        // Act
        final result = await orderService.getOrderById(orderId);

        // Assert
        expect(result?.id, orderId);
        expect(result?.status, OrderStatus.confirmed);
        expect(result?.totalAmount, 25.50);
        expect(result?.items.length, 1);
        expect(result?.items.first.quantity, 2);
      });

      test('should return null when order not found', () async {
        // Arrange
        final orderId = 'non-existent-order';

        // Mock database query returning null
        when(mockSupabaseClient.from('orders')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('orders').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').select(any).eq('id', orderId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').select(any).eq('id', orderId).single()).thenThrow(Exception('Not found'));

        // Act
        final result = await orderService.getOrderById(orderId);

        // Assert
        expect(result, isNull);
      });
    });

    group('getOrdersByCustomer', () {
      test('should return customer orders sorted by date', () async {
        // Arrange
        final customerId = 'customer-456';
        final mockOrdersResponse = [
          {
            'id': 'order-1',
            'customer_id': customerId,
            'status': 'completed',
            'total_amount': 15.0,
            'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'id': 'order-2', 
            'customer_id': customerId,
            'status': 'confirmed',
            'total_amount': 25.0,
            'created_at': DateTime.now().toIso8601String(),
          }
        ];

        // Mock database query
        when(mockSupabaseClient.from('orders')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('orders').select(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').select(any).eq('customer_id', customerId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').select(any).eq('customer_id', customerId).order('created_at')).thenAnswer((_) async => mockOrdersResponse);

        // Act
        final result = await orderService.getOrdersByCustomer(customerId);

        // Assert
        expect(result.length, 2);
        expect(result.first.id, 'order-1');
        expect(result.last.id, 'order-2');
      });
    });

    group('cancelOrder', () {
      test('should cancel pending order successfully', () async {
        // Arrange
        final orderId = 'order-123';
        final mockCancelledOrder = {
          'id': orderId,
          'status': 'cancelled',
          'cancelled_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Mock database update
        when(mockSupabaseClient.from('orders')).thenReturn(MockPostgrestQueryBuilder());
        when(mockSupabaseClient.from('orders').update(any)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').update(any).eq('id', orderId)).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').update(any).eq('id', orderId).select()).thenReturn(MockPostgrestFilterBuilder());
        when(mockSupabaseClient.from('orders').update(any).eq('id', orderId).select().single()).thenAnswer((_) async => mockCancelledOrder);

        // Act
        final result = await orderService.cancelOrder(orderId);

        // Assert
        expect(result.status, OrderStatus.cancelled);
        expect(result.cancelledAt, isNotNull);
      });

      test('should not allow cancelling completed orders', () async {
        // Arrange
        final orderId = 'order-completed';

        // Act & Assert
        expect(
          () => orderService.cancelOrder(orderId),
          throwsA(isA<OrderValidationException>()),
        );
      });
    });
  });
}

// Mock classes for Supabase
class MockPostgrestQueryBuilder extends Mock {}
class MockPostgrestFilterBuilder extends Mock {}

// Custom exceptions for testing
class OrderValidationException implements Exception {
  final String message;
  OrderValidationException(this.message);
}