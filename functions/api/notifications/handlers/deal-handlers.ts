/**
 * Deal event handlers
 * Handles all deal-related notification events including location-based notifications
 */

import { NotificationService } from '../services/notification';
import { EventPayload, NotificationMessage, NotificationRecord, ProcessingResult } from '../types';

export class DealHandlers {
  private notificationService: NotificationService;

  constructor(notificationService: NotificationService) {
    this.notificationService = notificationService;
  }

  /**
   * Handle DEAL_CREATED event
   * Notifies nearby users about new deals
   */
  async handleDealCreated(event: EventPayload): Promise<ProcessingResult> {
    const { 
      dealId, businessId, title, description, discount, expiresAt, location 
    } = event.payload;
    
    const radiusKm = event.metadata.notificationRadius || 5;
    
    // Message generator for each nearby user
    const messageGenerator = async (userId: string, userData: any): Promise<NotificationMessage> => ({
      title: `🔥 ${discount}% OFF Near You!`,
      body: `${title} - Only ${userData.distance_km.toFixed(1)}km away! ${description}`,
      data: {
        type: 'deal_nearby',
        dealId,
        businessId,
        distance: userData.distance_km.toString(),
        discount: discount.toString(),
        expiresAt,
      },
      image: event.payload.imageUrl,
      actionUrl: `/deals/${dealId}`,
    });
    
    // Notification record generator
    const notificationRecordGenerator = async (userId: string, userData: any): Promise<Omit<NotificationRecord, 'title' | 'body'>> => ({
      event_id: event.eventId,
      event_type: 'DEAL_CREATED',
      recipient_id: userId,
      recipient_type: 'customer',
      location_context: {
        distance_km: userData.distance_km,
        user_location_type: userData.location_type,
        business_location: location,
      },
      data: {
        type: 'deal_nearby',
        dealId,
        businessId,
        distance: userData.distance_km.toString(),
        discount: discount.toString(),
        expiresAt,
      },
      image_url: event.payload.imageUrl,
      action_url: `/deals/${dealId}`,
      priority: 'normal',
    });
    
    return await this.notificationService.sendLocationBasedNotifications(
      location.latitude,
      location.longitude,
      radiusKm,
      messageGenerator,
      notificationRecordGenerator,
      'normal'
    );
  }

  /**
   * Handle LOCATION_BASED_DEAL event
   * Processes user location updates and sends relevant deals
   */
  async handleLocationBasedDeal(event: EventPayload): Promise<ProcessingResult> {
    const { userId, deals, userLocation } = event.payload;
    
    if (!deals || deals.length === 0) {
      return { 
        success: true, 
        recipients: 0, 
        reason: 'No deals provided' 
      };
    }
    
    const topDeals = deals.slice(0, 3); // Top 3 deals
    const maxDiscount = Math.max(...deals.map((d: any) => d.discountPercent));
    
    const message: NotificationMessage = {
      title: `📍 ${deals.length} Deal${deals.length > 1 ? 's' : ''} Near You!`,
      body: `Save up to ${maxDiscount}% at nearby restaurants. Closest deal just ${topDeals[0].distance}km away!`,
      data: {
        type: 'location_deals',
        dealCount: deals.length.toString(),
        maxDiscount: maxDiscount.toString(),
        topDeals: JSON.stringify(topDeals),
      },
      actionUrl: '/deals/nearby',
    };
    
    const notificationRecord: Omit<NotificationRecord, 'title' | 'body'> = {
      event_id: event.eventId,
      event_type: event.eventType,
      recipient_id: userId,
      recipient_type: 'customer',
      location_context: {
        user_location: userLocation,
        deal_count: deals.length,
        max_discount: maxDiscount,
      },
      data: message.data,
      action_url: message.actionUrl,
      priority: 'normal',
    };
    
    const result = await this.notificationService.sendToUser(
      userId, 
      message, 
      notificationRecord, 
      'normal'
    );
    
    return {
      ...result,
      dealCount: deals.length,
    };
  }

  /**
   * Handle DEAL_EXPIRING event
   * Notifies nearby users about deals expiring soon
   */
  async handleDealExpiring(event: EventPayload): Promise<ProcessingResult> {
    const { dealId, title, discount, expiresIn, location } = event.payload;
    
    const radiusKm = event.metadata.notificationRadius || 3; // Smaller radius for urgent notifications
    
    const expiresInHours = Math.floor(expiresIn / 3600);
    const expiresInMinutes = Math.floor((expiresIn % 3600) / 60);
    
    let timeText: string;
    if (expiresInHours > 0) {
      timeText = `${expiresInHours}h ${expiresInMinutes}m`;
    } else {
      timeText = `${expiresInMinutes} minutes`;
    }
    
    // Message generator for each nearby user
    const messageGenerator = async (userId: string, userData: any): Promise<NotificationMessage> => ({
      title: '⏰ Deal Expiring Soon!',
      body: `${title} (${discount}% OFF) expires in ${timeText}. Only ${userData.distance_km.toFixed(1)}km away!`,
      data: {
        type: 'deal_expiring',
        dealId,
        discount: discount.toString(),
        expiresIn: expiresIn.toString(),
        distance: userData.distance_km.toString(),
      },
      actionUrl: `/deals/${dealId}`,
    });
    
    // Notification record generator
    const notificationRecordGenerator = async (userId: string, userData: any): Promise<Omit<NotificationRecord, 'title' | 'body'>> => ({
      event_id: event.eventId,
      event_type: event.eventType,
      recipient_id: userId,
      recipient_type: 'customer',
      location_context: {
        distance_km: userData.distance_km,
        user_location_type: userData.location_type,
        business_location: location,
      },
      data: {
        type: 'deal_expiring',
        dealId,
        discount: discount.toString(),
        expiresIn: expiresIn.toString(),
        distance: userData.distance_km.toString(),
      },
      action_url: `/deals/${dealId}`,
      priority: 'high',
      expires_at: new Date(Date.now() + expiresIn * 1000).toISOString(),
    });
    
    return await this.notificationService.sendLocationBasedNotifications(
      location.latitude,
      location.longitude,
      radiusKm,
      messageGenerator,
      notificationRecordGenerator,
      'high'
    );
  }
}