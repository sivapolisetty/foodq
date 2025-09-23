/**
 * Mark All Notifications as Read API
 */

import { createClient } from '@supabase/supabase-js';

/**
 * Mark all notifications as read for user
 */
export async function onRequestPatch(context: any) {
  const { env, request } = context;
  
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

    // Mark all unread notifications as read
    const { data, error } = await supabase
      .from('notifications')
      .update({
        is_read: true,
        read_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('recipient_id', user.user.id)
      .eq('is_read', false)
      .select('id');

    if (error) {
      console.error('Error marking all notifications as read:', error);
      return new Response('Failed to mark all notifications as read', { status: 500 });
    }

    const markedCount = data?.length || 0;

    return new Response(JSON.stringify({
      success: true,
      message: `${markedCount} notifications marked as read`,
      data: {
        count: markedCount
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Mark all as read error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}