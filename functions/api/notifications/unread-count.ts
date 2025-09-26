/**
 * Unread Notifications Count API
 */

import { createClient } from '@supabase/supabase-js';

/**
 * Get unread notification count for user
 */
export async function onRequestGet(context: any) {
  const { env, request } = context;
  
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

    // Get unread count using RPC function
    const { data: count, error } = await supabase.rpc('get_unread_notification_count', {
      user_id: user.user.id
    });

    if (error) {
      console.error('Error getting unread count:', error);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to get unread count',
        message: error.message || 'Database error occurred'
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({
      success: true,
      data: {
        count: count || 0
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Unread count error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}