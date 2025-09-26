/**
 * Order event handlers
 * Handles all order-related notification events
 */

import { NotificationService } from '../services/notification';
import { EventPayload, NotificationMessage, NotificationRecord, ProcessingResult } from '../types';

export class OrderHandlers {
  private notificationService: NotificationService;

  constructor(notificationService: NotificationService) {
    this.notificationService = notificationService;
  }

  /**
   * Handle ORDER_CREATED and ORDER_PAID events
   * Notifies business owner about new order
   */
  async handleOrderCreated(event: EventPayload): Promise<ProcessingResult> {
    const { orderId, businessOwnerId, customerName, amount, businessName } = event.payload;
    
    const message: NotificationMessage = {
      title: '🔔 New Order Received!',
      body: `Order from ${customerName} - $${amount.toFixed(2)}`,
      data: {
        type: 'order_new',
        orderId,
        customerId: event.payload.customerId,
        amount: amount.toString(),
        businessName,
      },
      actionUrl: `/business/orders/${orderId}`,
    };
    
    const notificationRecord: Omit<NotificationRecord, 'title' | 'body'> = {
      event_id: event.eventId,
      event_type: event.eventType,
      recipient_id: businessOwnerId,
      recipient_type: 'business',
      data: message.data,
      action_url: message.actionUrl,
      priority: 'high',
    };
    
    return await this.notificationService.sendToUser(
      businessOwnerId, 
      message, 
      notificationRecord, 
      'high'
    );
  }

  /**
   * Handle ORDER_CONFIRMED event
   * Notifies customer that their order was confirmed
   */
  async handleOrderConfirmed(event: EventPayload): Promise<ProcessingResult> {
    const { 
      orderId, customerId, verificationCode, businessName, 
      pickupTime, qrCode 
    } = event.payload;
    
    // Generate pickup code if not provided
    const pickupCode = verificationCode || orderId?.substring(0, 8).toUpperCase() || 'PICKUP';
    
    const message: NotificationMessage = {
      title: '✅ Order Confirmed!',
      body: `${businessName} confirmed your order. Pickup code: ${pickupCode}`,
      data: {
        type: 'order_confirmed',
        orderId,
        verificationCode: pickupCode,
        qrCode: qrCode || '',
        pickupTime: pickupTime || '',
        businessName,
      },
      actionUrl: `/orders/${orderId}`,
      image: event.payload.businessLogo,
    };
    
    const notificationRecord: Omit<NotificationRecord, 'title' | 'body'> = {
      event_id: event.eventId,
      event_type: event.eventType,
      recipient_id: customerId,
      recipient_type: 'customer',
      data: message.data,
      action_url: message.actionUrl,
      image_url: message.image,
      priority: 'high',
    };
    
    return await this.notificationService.sendToUser(
      customerId, 
      message, 
      notificationRecord, 
      'high'
    );
  }

  /**
   * Handle ORDER_READY event
   * Notifies customer that their order is ready for pickup
   */
  async handleOrderReady(event: EventPayload): Promise<ProcessingResult> {
    const { orderId, customerId, verificationCode, businessName } = event.payload;
    
    // Generate pickup code if not provided
    const pickupCode = verificationCode || orderId?.substring(0, 8).toUpperCase() || 'READY';
    
    const message: NotificationMessage = {
      title: '🍽️ Order Ready for Pickup!',
      body: `Your order from ${businessName} is ready! Show code: ${pickupCode}`,
      data: {
        type: 'order_ready',
        orderId,
        verificationCode: pickupCode,
        businessName,
      },
      actionUrl: `/orders/${orderId}`,
    };
    
    const notificationRecord: Omit<NotificationRecord, 'title' | 'body'> = {
      event_id: event.eventId,
      event_type: event.eventType,
      recipient_id: customerId,
      recipient_type: 'customer',
      data: message.data,
      action_url: message.actionUrl,
      priority: 'urgent',
    };
    
    return await this.notificationService.sendToUser(
      customerId, 
      message, 
      notificationRecord, 
      'urgent'
    );
  }

  /**
   * Handle ORDER_COMPLETED event
   * Notifies both customer and business owner
   */
  async handleOrderCompleted(event: EventPayload): Promise<ProcessingResult> {
    const { orderId, customerId, businessOwnerId, amount, businessName } = event.payload;
    
    // Customer notification
    const customerMessage: NotificationMessage = {
      title: '🎉 Order Complete!',
      body: `Thank you for your order from ${businessName}! We hope you enjoyed your meal.`,
      data: {
        type: 'order_completed',
        orderId,
        businessName,
      },
      actionUrl: `/orders/${orderId}/rate`,
    };
    
    const customerNotificationRecord: Omit<NotificationRecord, 'title' | 'body'> = {
      event_id: event.eventId,
      event_type: event.eventType,
      recipient_id: customerId,
      recipient_type: 'customer',
      data: customerMessage.data,
      action_url: customerMessage.actionUrl,
      priority: 'normal',
    };
    
    // Business notification
    const businessMessage: NotificationMessage = {
      title: '✅ Order Completed',
      body: `Order #${orderId.substring(0, 8)} completed - $${amount.toFixed(2)}`,
      data: {
        type: 'order_completed',
        orderId,
        amount: amount.toString(),
      },
      actionUrl: `/business/orders/${orderId}`,
    };
    
    const businessNotificationRecord: Omit<NotificationRecord, 'title' | 'body'> = {
      event_id: event.eventId,
      event_type: event.eventType,
      recipient_id: businessOwnerId,
      recipient_type: 'business',
      data: businessMessage.data,
      action_url: businessMessage.actionUrl,
      priority: 'low',
    };
    
    // Send both notifications
    const customerResult = await this.notificationService.sendToUser(
      customerId, 
      customerMessage, 
      customerNotificationRecord, 
      'normal'
    );
    
    const businessResult = await this.notificationService.sendToUser(
      businessOwnerId, 
      businessMessage, 
      businessNotificationRecord, 
      'low'
    );
    
    return {
      success: true,
      recipients: 2,
      fcmSent: (customerResult.fcmSent || 0) + (businessResult.fcmSent || 0),
      fcmSuccess: (customerResult.fcmSuccess || 0) + (businessResult.fcmSuccess || 0),
      notifications: [
        { recipient: 'customer', id: customerResult.notificationId },
        { recipient: 'business', id: businessResult.notificationId },
      ],
    };
  }

  /**
   * Handle ORDER_CANCELLED event
   * Notifies customer about order cancellation
   */
  async handleOrderCancelled(event: EventPayload): Promise<ProcessingResult> {
    const { orderId, customerId, businessName, reason } = event.payload;
    
    const message: NotificationMessage = {
      title: '❌ Order Cancelled',
      body: `Your order from ${businessName} has been cancelled. ${reason || 'Please contact the restaurant for details.'}`,
      data: {
        type: 'order_cancelled',
        orderId,
        businessName,
        reason: reason || '',
      },
      actionUrl: `/orders/${orderId}`,
    };
    
    const notificationRecord: Omit<NotificationRecord, 'title' | 'body'> = {
      event_id: event.eventId,
      event_type: event.eventType,
      recipient_id: customerId,
      recipient_type: 'customer',
      data: message.data,
      action_url: message.actionUrl,
      priority: 'high',
    };
    
    return await this.notificationService.sendToUser(
      customerId, 
      message, 
      notificationRecord, 
      'high'
    );
  }
}