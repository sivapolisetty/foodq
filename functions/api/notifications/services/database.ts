/**
 * Database service for notification system
 * Handles all database interactions
 */

import { UserToken, NotificationRecord, NearbyUser } from '../types';
import { getDBClient } from '../../../utils/db-client.js';

export class DatabaseService {
  private env: any;
  private supabase: any;

  constructor(env: any) {
    this.env = env;
    this.supabase = getDBClient(env, 'NotificationSystem');
  }

  // All database methods now use Supabase client directly

  /**
   * Find users near a specific location
   */
  async findNearbyUsers(
    latitude: number, 
    longitude: number, 
    radiusKm: number
  ): Promise<NearbyUser[]> {
    // First try the RPC function, fallback to empty array if not available
    try {
      const { data, error } = await this.supabase.rpc('find_users_near_location', {
        p_latitude: latitude,
        p_longitude: longitude,
        p_radius_km: radiusKm
      });
      
      if (error && !error.message.includes('Could not find the function')) {
        throw new Error(`Failed to find nearby users: ${error.message}`);
      }
      
      if (!error) {
        return data || [];
      }
    } catch (rpcError) {
      console.log('RPC function not available, using fallback');
    }
    
    // Fallback: Return empty array (location-based notifications disabled)
    console.log('Location-based user lookup not available, skipping location targeting');
    return [];
  }

  /**
   * Get active FCM tokens for a user
   */
  async getUserTokens(userId: string): Promise<UserToken[]> {
    const { data, error } = await this.supabase
      .from('push_tokens')
      .select('fcm_token, platform, device_model, last_used_at')
      .eq('user_id', userId)
      .eq('is_active', true)
      .lt('consecutive_failures', 3)
      .order('last_used_at', { ascending: false });
    
    if (error) {
      throw new Error(`Failed to get user tokens: ${error.message}`);
    }
    
    return data || [];
  }

  /**
   * Save notification to database
   */
  async saveNotification(notification: NotificationRecord): Promise<string> {
    const { data, error } = await this.supabase
      .from('notifications')
      .insert({
        event_id: notification.event_id,
        event_type: notification.event_type,
        recipient_id: notification.recipient_id,
        recipient_type: notification.recipient_type,
        title: notification.title,
        body: notification.body,
        data: notification.data || {},
        image_url: notification.image_url || null,
        action_url: notification.action_url || null,
        location_context: notification.location_context || null,
        channels: ['fcm', 'in_app'],
        priority: notification.priority || 'normal',
        expires_at: notification.expires_at || null
      })
      .select('id')
      .single();
    
    if (error) {
      throw new Error(`Failed to save notification: ${error.message}`);
    }
    
    return data.id;
  }

  /**
   * Log delivery attempt
   */
  async logDeliveryAttempt(
    notificationId: string,
    channel: string,
    status: string,
    provider: string,
    messageId: string | null,
    response: any
  ): Promise<void> {
    const { error } = await this.supabase
      .from('delivery_log')
      .insert({
        notification_id: notificationId,
        channel: channel,
        status: status,
        provider: provider,
        provider_message_id: messageId,
        provider_response: response
      });
    
    if (error) {
      throw new Error(`Failed to log delivery attempt: ${error.message}`);
    }
  }

  /**
   * Mark FCM token as failed
   */
  async markTokenFailed(token: string, reason: string): Promise<void> {
    const { error } = await this.supabase.rpc('mark_token_failed', {
      p_fcm_token: token,
      p_failure_reason: reason
    });
    
    if (error) {
      throw new Error(`Failed to mark token as failed: ${error.message}`);
    }
  }

  /**
   * Mark FCM token as successful
   */
  async markTokenSuccess(token: string): Promise<void> {
    const { error } = await this.supabase.rpc('mark_token_success', {
      p_fcm_token: token
    });
    
    if (error) {
      throw new Error(`Failed to mark token as successful: ${error.message}`);
    }
  }

  /**
   * Update event processing status
   */
  async updateEventStatus(
    eventId: string, 
    status: string, 
    errorMessage?: string
  ): Promise<void> {
    const updateData: any = {
      status: status
    };

    if (errorMessage) {
      updateData.error_message = errorMessage;
    }

    const { error } = await this.supabase
      .from('event_queue')
      .update(updateData)
      .eq('id', eventId);
    
    if (error) {
      throw new Error(`Failed to update event status: ${error.message}`);
    }
  }

  /**
   * Get event by ID from event_queue table
   */
  async getEventById(eventId: string): Promise<any> {
    const { data, error } = await this.supabase
      .from('event_queue')
      .select('*')
      .eq('id', eventId)
      .single();
    
    if (error) {
      if (error.code === 'PGRST116') {
        return null; // No rows found
      }
      throw new Error(`Database error: ${error.message}`);
    }

    if (!data) {
      return null;
    }

    // Transform to expected format
    return {
      eventId: data.id,
      eventType: data.event_type,
      eventName: data.event_name,
      eventVersion: data.event_version,
      payload: data.payload,
      metadata: data.metadata,
      timestamp: data.created_at,
      status: data.status
    };
  }
}