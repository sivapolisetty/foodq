/**
 * Main event processor - orchestrates all event handling
 * This is the central coordinator that routes events to appropriate handlers
 */

import { DatabaseService } from './database';
import { FirebaseService } from './firebase';
import { NotificationService } from './notification';
import { OrderHandlers } from '../handlers/order-handlers';
import { DealHandlers } from '../handlers/deal-handlers';
import { EventPayload, ProcessingResult } from '../types';
import { validateEventPayload, validateOrderEventPayload, validateDealEventPayload } from '../utils/validation';

export class EventProcessor {
  private db: DatabaseService;
  private firebase: FirebaseService;
  private notificationService: NotificationService;
  private orderHandlers: OrderHandlers;
  private dealHandlers: DealHandlers;

  constructor(env: any) {
    // Initialize services
    this.db = new DatabaseService(env);
    this.firebase = new FirebaseService(env);
    this.notificationService = new NotificationService(this.db, this.firebase);
    
    // Initialize handlers
    this.orderHandlers = new OrderHandlers(this.notificationService);
    this.dealHandlers = new DealHandlers(this.notificationService);
  }

  /**
   * Process event by ID - fetch from database and process
   */
  async processEventById(eventId: string): Promise<ProcessingResult> {
    console.log(`Processing event by ID: ${eventId}`);
    
    try {
      // Fetch event from database
      const event = await this.db.getEventById(eventId);
      if (!event) {
        throw new Error(`Event not found: ${eventId}`);
      }
      
      // Process the fetched event
      return await this.process(event);
    } catch (error) {
      console.error(`Error processing event by ID ${eventId}:`, error);
      
      // Update event status to failed
      await this.db.updateEventStatus(eventId, 'failed', error.message);
      
      throw error;
    }
  }

  /**
   * Main event processing method
   */
  async process(event: EventPayload): Promise<ProcessingResult> {
    console.log(`Processing event: ${event.eventType} (${event.eventId})`);
    
    // Validate event payload
    if (!validateEventPayload(event)) {
      throw new Error('Invalid event payload structure');
    }
    
    try {
      // Update event status to processing
      await this.db.updateEventStatus(event.eventId, 'processing');
      
      // Route to appropriate handler
      const result = await this.routeEvent(event);
      
      // Update event status to processed
      await this.db.updateEventStatus(event.eventId, 'processed');
      
      return result;
    } catch (error) {
      console.error(`Error processing event ${event.eventId}:`, error);
      
      // Update event status to failed
      await this.db.updateEventStatus(event.eventId, 'failed', error.message);
      
      throw error;
    }
  }

  /**
   * Route event to appropriate handler based on event type
   */
  private async routeEvent(event: EventPayload): Promise<ProcessingResult> {
    switch (event.eventType) {
      // Order events
      case 'ORDER_CREATED':
      case 'ORDER_PAID':
        this.validateOrderEvent(event);
        return await this.orderHandlers.handleOrderCreated(event);
      
      case 'ORDER_CONFIRMED':
        this.validateOrderEvent(event);
        return await this.orderHandlers.handleOrderConfirmed(event);
      
      case 'ORDER_READY':
        this.validateOrderEvent(event);
        return await this.orderHandlers.handleOrderReady(event);
        
      case 'ORDER_COMPLETED':
        this.validateOrderEvent(event);
        return await this.orderHandlers.handleOrderCompleted(event);
        
      case 'ORDER_CANCELLED':
        this.validateOrderEvent(event);
        return await this.orderHandlers.handleOrderCancelled(event);
      
      // Deal events
      case 'DEAL_CREATED':
        this.validateDealEvent(event);
        return await this.dealHandlers.handleDealCreated(event);
      
      case 'LOCATION_BASED_DEAL':
        return await this.dealHandlers.handleLocationBasedDeal(event);
        
      case 'DEAL_EXPIRING':
        this.validateDealEvent(event);
        return await this.dealHandlers.handleDealExpiring(event);
      
      // System events
      case 'SYSTEM_ANNOUNCEMENT':
        return await this.handleSystemAnnouncement(event);
      
      default:
        throw new Error(`Unknown event type: ${event.eventType}`);
    }
  }

  /**
   * Validate order event payload
   */
  private validateOrderEvent(event: EventPayload): void {
    if (!validateOrderEventPayload(event.payload)) {
      throw new Error(`Invalid order event payload for ${event.eventType}`);
    }
  }

  /**
   * Validate deal event payload
   */
  private validateDealEvent(event: EventPayload): void {
    if (!validateDealEventPayload(event.payload)) {
      throw new Error(`Invalid deal event payload for ${event.eventType}`);
    }
  }

  /**
   * Handle system announcement events
   */
  private async handleSystemAnnouncement(event: EventPayload): Promise<ProcessingResult> {
    // System announcements can be sent to all users or specific groups
    // This is a placeholder for future implementation
    console.log('System announcement received:', event.payload.message);
    
    return {
      success: true,
      recipients: 0,
      reason: 'System announcements not fully implemented yet',
    };
  }
}