/**
 * Cloudflare Worker - Modular Notification Event Processor
 * Clean, maintainable, and testable notification system
 */

import { EventProcessor } from './services/event-processor';
import { EventPayload } from './types';
import { validateWebhookSecret, validateEventPayload } from './utils/validation';

/**
 * Main request handler for POST requests (webhook events)
 */
export async function onRequestPost(context: any) {
  const { env, request } = context;
  
  try {
    // Verify webhook secret
    const webhookSecret = request.headers.get('X-Webhook-Secret');
    if (!validateWebhookSecret(webhookSecret, env.WEBHOOK_SECRET)) {
      return new Response('Unauthorized', { status: 401 });
    }
    
    // Parse request body
    const body = await request.json();
    
    // Check if it's a simple eventId request or full event payload
    if (body.eventId && typeof body.eventId === 'string' && Object.keys(body).length === 1) {
      // Simple eventId-only request - fetch event from database
      const processor = new EventProcessor(env);
      const result = await processor.processEventById(body.eventId);
      
      return new Response(JSON.stringify({
        success: true,
        eventId: body.eventId,
        result,
        processedAt: new Date().toISOString(),
      }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    } else {
      // Full event payload - validate and process
      const event: EventPayload = body;
      
      // Validate event structure
      if (!validateEventPayload(event)) {
        return new Response('Invalid event data', { status: 400 });
      }
      
      // Process event
      const processor = new EventProcessor(env);
      const result = await processor.process(event);
      
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
    console.error('Webhook processing error:', error);
    
    return new Response(JSON.stringify({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString(),
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
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