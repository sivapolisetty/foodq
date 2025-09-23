/**
 * Type definitions for the notification system
 */

export interface EventPayload {
  eventId: string;
  eventType: string;
  eventName: string;
  eventVersion?: string;
  payload: any;
  metadata: any;
  timestamp: string;
  status?: string;
}

export interface NotificationMessage {
  title: string;
  body: string;
  data?: Record<string, string>;
  image?: string;
  actionUrl?: string;
}

export interface UserToken {
  fcm_token: string;
  platform: string;
  device_model?: string;
  last_used_at: string;
}

export interface LocationContext {
  distance_km: number;
  user_location_type: string;
  business_location: {
    latitude: number;
    longitude: number;
    address: string;
  };
}

export interface NotificationRecord {
  event_id: string;
  event_type: string;
  recipient_id: string;
  recipient_type: 'customer' | 'business' | 'staff';
  title: string;
  body: string;
  data?: Record<string, any>;
  image_url?: string;
  action_url?: string;
  location_context?: any;
  priority: 'low' | 'normal' | 'high' | 'urgent';
  expires_at?: string;
}

export interface ProcessingResult {
  success: boolean;
  recipients: number;
  fcmSent?: number;
  fcmSuccess?: number;
  notifications?: any[];
  reason?: string;
  [key: string]: any;
}

export interface NearbyUser {
  user_id: string;
  distance_km: number;
  location_type: string;
  notification_radius_km: number;
}

export type NotificationPriority = 'low' | 'normal' | 'high' | 'urgent';
export type EventType = 
  | 'ORDER_CREATED' 
  | 'ORDER_PAID' 
  | 'ORDER_CONFIRMED' 
  | 'ORDER_PREPARING'
  | 'ORDER_READY' 
  | 'ORDER_COMPLETED' 
  | 'ORDER_CANCELLED'
  | 'DEAL_CREATED' 
  | 'DEAL_UPDATED'
  | 'DEAL_EXPIRING' 
  | 'DEAL_EXPIRED'
  | 'LOCATION_BASED_DEAL'
  | 'BUSINESS_UPDATE'
  | 'SYSTEM_ANNOUNCEMENT';