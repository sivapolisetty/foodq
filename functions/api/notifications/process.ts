/**
 * Cloudflare Worker - Modular Notification Event Processor
 * Clean, maintainable, and testable notification system
 */

import { EventProcessor } from './services/event-processor';
import { EventPayload } from './types';
import { validateWebhookSecret, validateEventPayload } from './utils/validation';
import { createE2ELogger } from '../../utils/e2e-logger.js';
import { createClient } from '@supabase/supabase-js';

/**
 * Find original E2E Request ID from the triggering event
 * This correlates notification webhooks with original user actions
 */
async function findOriginalE2ERequestId(eventId: string, env: any): Promise<string | null> {
  try {
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);
    
    // First, get the notification event to understand what triggered it
    const { data: event, error } = await supabase
      .from('notification_events')
      .select('event_type, related_id, user_id')
      .eq('id', eventId)
      .single();
      
    if (error || !event) return null;
    
    // Based on event type, look up the original E2E Request ID
    switch (event.event_type) {
      case 'order_confirmed':
      case 'order_ready':
      case 'order_completed':
        // Look up order's original E2E Request ID
        const { data: order } = await supabase
          .from('orders')
          .select('e2e_request_id')
          .eq('id', event.related_id)
          .single();
        return order?.e2e_request_id || null;
        
      case 'deal_created':
      case 'deal_expires_soon':
        // Look up deal's original E2E Request ID  
        const { data: deal } = await supabase
          .from('deals')
          .select('e2e_request_id')
          .eq('id', event.related_id)
          .single();
        return deal?.e2e_request_id || null;
        
      default:
        return null;
    }
  } catch (error) {
    console.error('Error finding original E2E Request ID:', error);
    return null;
  }
}

/**
 * Main request handler for POST requests (webhook events)
 */
export async function onRequestPost(context: any) {
  const { env, request } = context;
  
  // Create notification-specific E2E logger
  // Generate new E2E ID for notification flow or use existing one from webhook
  const notificationE2EId = request.headers.get('X-E2E-Request-ID') || 
                            `notification_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  // Create request-like object for logger
  const mockRequest = {
    headers: {
      get: (key: string) => key === 'X-E2E-Request-ID' ? notificationE2EId : request.headers.get(key)
    }
  } as Request;
  
  const logger = createE2ELogger(mockRequest, env);
  logger.logRequestStart('WEBHOOK', '/api/notifications/process');
  
  try {
    // Verify webhook secret
    const webhookSecret = request.headers.get('X-Webhook-Secret');
    if (!validateWebhookSecret(webhookSecret, env.WEBHOOK_SECRET)) {
      logger.logError('webhook_auth', new Error('Invalid webhook secret'));
      logger.logRequestEnd('WEBHOOK', '/api/notifications/process', 401);
      return new Response('Unauthorized', { status: 401 });
    }
    
    logger.logBusinessLogic('webhook_authenticated', { source: 'database_trigger' });
    
    // Parse request body
    const body = await request.json();
    
    // Check if it's a simple eventId request or full event payload
    if (body.eventId && typeof body.eventId === 'string' && Object.keys(body).length === 1) {
      // Simple eventId-only request - fetch event from database
      logger.logBusinessLogic('processing_event_by_id', { eventId: body.eventId });
      
      // Try to find original E2E Request ID from related order/deal
      const originalE2EId = await findOriginalE2ERequestId(body.eventId, env);
      if (originalE2EId) {
        logger.logBusinessLogic('found_original_e2e_id', { 
          originalE2EId, 
          notificationE2EId: notificationE2EId 
        });
      }
      
      const processor = new EventProcessor(env);
      const result = await processor.processEventById(body.eventId);
      
      logger.logBusinessLogic('event_processed', { 
        eventId: body.eventId, 
        success: result?.success,
        notificationsSent: result?.notificationCount || 0
      });
      
      logger.logRequestEnd('WEBHOOK', '/api/notifications/process', 200, {
        eventId: body.eventId,
        notificationsSent: result?.notificationCount || 0
      });
      
      return new Response(JSON.stringify({
        success: true,
        eventId: body.eventId,
        result,
        processedAt: new Date().toISOString(),
        e2eRequestId: notificationE2EId
      }), {
        status: 200,
        headers: { 
          'Content-Type': 'application/json',
          'X-E2E-Request-ID': notificationE2EId
        },
      });
    } else {
      // Full event payload - validate and process
      const event: EventPayload = body;
      logger.logBusinessLogic('processing_full_event', { 
        eventType: event.type,
        targetUserId: event.user_id,
        hasCustomData: !!event.custom_data 
      });
      
      // Validate event structure
      if (!validateEventPayload(event)) {
        logger.logValidationError('event_payload', event, 'Invalid event structure');
        logger.logRequestEnd('WEBHOOK', '/api/notifications/process', 400);
        return new Response('Invalid event data', { status: 400 });
      }
      
      // Process event
      const processor = new EventProcessor(env);
      const result = await processor.process(event);
      
      logger.logBusinessLogic('full_event_processed', { 
        eventType: event.type,
        success: result?.success,
        notificationsSent: result?.notificationCount || 0
      });
      
      logger.logRequestEnd('WEBHOOK', '/api/notifications/process', 200, {
        eventType: event.type,
        notificationsSent: result?.notificationCount || 0
      });
      
      return new Response(JSON.stringify({
        success: true,
        eventId: event.eventId,
        eventType: event.eventType,
        result,
        processedAt: new Date().toISOString(),
        e2eRequestId: notificationE2EId
      }), {
        status: 200,
        headers: { 
          'Content-Type': 'application/json',
          'X-E2E-Request-ID': notificationE2EId
        },
      });
    }
    
    return new Response(JSON.stringify({
      success: true,
      eventId: event.eventId,
      eventType: event.eventType,
      result,
      processedAt: new Date().toISOString(),
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
    
  } catch (error) {
    logger.logError('notification_webhook', error);
    logger.logRequestEnd('WEBHOOK', '/api/notifications/process', 500, { error: error.message });
    
    return new Response(JSON.stringify({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString(),
      e2eRequestId: notificationE2EId
    }), {
      status: 500,
      headers: { 
        'Content-Type': 'application/json',
        'X-E2E-Request-ID': notificationE2EId
      },
    });
  }
}

/**
 * Health check endpoint for GET requests
 */
export async function onRequestGet(context: any) {
  return new Response(JSON.stringify({
    status: 'healthy',
    service: 'notification-processor',
    version: '2.0.0',
    architecture: 'modular',
    timestamp: new Date().toISOString(),
    components: {
      'event-processor': 'active',
      'database-service': 'active',
      'firebase-service': 'active',
      'notification-service': 'active',
      'order-handlers': 'active',
      'deal-handlers': 'active',
    },
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
}