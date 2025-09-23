/**
 * Validation utilities for notification system
 */

import { EventPayload } from '../types';

/**
 * Validate webhook secret
 */
export function validateWebhookSecret(requestSecret: string | null, envSecret: string): boolean {
  if (!requestSecret || !envSecret) {
    return false;
  }
  return requestSecret === envSecret;
}

/**
 * Validate event payload structure
 */
export function validateEventPayload(payload: any): payload is EventPayload {
  if (!payload || typeof payload !== 'object') {
    return false;
  }

  const required = ['eventId', 'eventType', 'payload', 'metadata', 'timestamp'];
  return required.every(field => field in payload && payload[field] != null);
}

/**
 * Validate order event payload
 */
export function validateOrderEventPayload(payload: any): boolean {
  const requiredFields = ['orderId', 'businessOwnerId', 'customerId'];
  return requiredFields.every(field => field in payload && payload[field] != null);
}

/**
 * Validate deal event payload
 */
export function validateDealEventPayload(payload: any): boolean {
  const requiredFields = ['dealId', 'businessId', 'title', 'location'];
  return requiredFields.every(field => field in payload && payload[field] != null);
}

/**
 * Validate location coordinates
 */
export function validateLocation(location: any): boolean {
  if (!location || typeof location !== 'object') {
    return false;
  }
  
  const { latitude, longitude } = location;
  return (
    typeof latitude === 'number' && 
    typeof longitude === 'number' &&
    latitude >= -90 && latitude <= 90 &&
    longitude >= -180 && longitude <= 180
  );
}