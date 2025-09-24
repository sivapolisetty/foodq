/**
 * Notifications API - Main endpoint
 * Handles notification CRUD operations
 */

import { createClient } from '@supabase/supabase-js';
import { createE2ELogger } from '../../utils/e2e-logger.js';

/**
 * Get user notifications with filtering
 */
export async function onRequestGet(context: any) {
  const { env, request } = context;
  const logger = createE2ELogger(request, env);
  
  logger.logRequestStart(request.method, '/api/notifications');
  
  try {
    // Get user from JWT token
    const authHeader = request.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response('Unauthorized', { status: 401 });
    }

    const token = authHeader.substring(7);
    
    // Initialize Supabase client
    const supabase = createClient(
      env.SUPABASE_URL,
      env.SUPABASE_SERVICE_ROLE_KEY
    );

    // Verify JWT and get user
    const { data: user, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user.user) {
      return new Response('Invalid token', { status: 401 });
    }

    // Parse query parameters
    const url = new URL(request.url);
    const limit = parseInt(url.searchParams.get('limit') || '50');
    const offset = parseInt(url.searchParams.get('offset') || '0');
    const unreadOnly = url.searchParams.get('unread_only') === 'true';

    // Build query
    let query = supabase
      .from('notifications')
      .select('id, event_type, title, body, data, image_url, action_url, priority, is_read, created_at, expires_at')
      .eq('recipient_id', user.user.id);

    if (unreadOnly) {
      query = query.eq('is_read', false);
    }

    // Apply pagination and ordering
    const { data, error } = await query
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) {
      console.error('Error fetching notifications:', error);
      return new Response('Failed to fetch notifications', { status: 500 });
    }

    // Filter out expired notifications
    const activeNotifications = (data || []).filter(notification => {
      if (!notification.expires_at) return true;
      return new Date(notification.expires_at) > new Date();
    });

    return new Response(JSON.stringify({
      success: true,
      data: activeNotifications,
      count: activeNotifications.length,
      pagination: {
        limit,
        offset,
        has_more: data?.length === limit,
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Get notifications error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}