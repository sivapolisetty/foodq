/**
 * Mark Notification as Read API
 */

import { createClient } from '@supabase/supabase-js';

/**
 * Mark specific notification as read
 */
export async function onRequestPatch(context: any) {
  const { env, request, params } = context;
  
  try {
    // Get user from JWT token
    const authHeader = request.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Unauthorized',
        message: 'Bearer token required'
      }), { 
        status: 401,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const token = authHeader.substring(7);
    const notificationId = params.id;
    
    if (!notificationId) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Missing notification ID',
        message: 'Notification ID is required'
      }), { 
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Initialize Supabase client
    const supabase = createClient(
      env.SUPABASE_URL,
      env.SUPABASE_SERVICE_ROLE_KEY
    );

    // Verify JWT and get user
    const { data: user, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user.user) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Invalid token',
        message: authError?.message || 'Token verification failed'
      }), { 
        status: 401,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Mark notification as read
    const { data, error } = await supabase
      .from('notifications')
      .update({
        is_read: true,
        read_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('id', notificationId)
      .eq('recipient_id', user.user.id) // Ensure user owns this notification
      .select()
      .single();

    if (error) {
      console.error('Error marking notification as read:', error);
      if (error.code === 'PGRST116') {
        return new Response(JSON.stringify({
          success: false,
          error: 'Notification not found',
          message: 'The specified notification was not found or you do not have access to it'
        }), {
          status: 404,
          headers: { 'Content-Type': 'application/json' },
        });
      }
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to mark notification as read',
        message: error.message || 'Database error occurred'
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({
      success: true,
      message: 'Notification marked as read',
      data: {
        id: data.id,
        is_read: data.is_read,
        read_at: data.read_at,
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Mark as read error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}