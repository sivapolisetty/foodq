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
      return new Response('Unauthorized', { status: 401 });
    }

    const token = authHeader.substring(7);
    const notificationId = params.id;
    
    if (!notificationId) {
      return new Response('Missing notification ID', { status: 400 });
    }

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
        return new Response('Notification not found', { status: 404 });
      }
      return new Response('Failed to mark notification as read', { status: 500 });
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