/**
 * Device Token Management API
 * Handles FCM token registration and device info storage
 */

import { createClient } from '@supabase/supabase-js';

interface DeviceTokenRequest {
  fcm_token: string;
  platform: 'ios' | 'android' | 'web';
  device_id?: string;
  device_model?: string;
  device_name?: string;
  app_version?: string;
  os_version?: string;
}

/**
 * Register or update FCM device token
 */
export async function onRequestPost(context: any) {
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

    // Parse request body
    const deviceData: DeviceTokenRequest = await request.json();
    
    // Validate required fields
    if (!deviceData.fcm_token || !deviceData.platform) {
      return new Response('Missing required fields: fcm_token, platform', { status: 400 });
    }

    // Validate platform
    if (!['ios', 'android', 'web'].includes(deviceData.platform)) {
      return new Response('Invalid platform. Must be: ios, android, web', { status: 400 });
    }

    // Upsert device token
    const { data, error } = await supabase
      .from('push_tokens')
      .upsert({
        user_id: user.user.id,
        fcm_token: deviceData.fcm_token,
        platform: deviceData.platform,
        device_id: deviceData.device_id,
        device_model: deviceData.device_model,
        device_name: deviceData.device_name,
        app_version: deviceData.app_version,
        os_version: deviceData.os_version,
        is_active: true,
        last_used_at: new Date().toISOString(),
        failure_count: 0,
        consecutive_failures: 0,
      }, {
        onConflict: 'user_id,fcm_token'
      })
      .select()
      .single();

    if (error) {
      console.error('Error upserting device token:', error);
      return new Response('Failed to register device token', { status: 500 });
    }

    return new Response(JSON.stringify({
      success: true,
      message: 'Device token registered successfully',
      data: {
        id: data.id,
        platform: data.platform,
        device_model: data.device_model,
        last_used_at: data.last_used_at,
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Device token registration error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

/**
 * Get user's device tokens
 */
export async function onRequestGet(context: any) {
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

    // Get user's active device tokens
    const { data, error } = await supabase
      .from('push_tokens')
      .select('id, platform, device_model, device_name, last_used_at, created_at')
      .eq('user_id', user.user.id)
      .eq('is_active', true)
      .order('last_used_at', { ascending: false });

    if (error) {
      console.error('Error fetching device tokens:', error);
      return new Response('Failed to fetch device tokens', { status: 500 });
    }

    return new Response(JSON.stringify({
      success: true,
      data: data || [],
      count: data?.length || 0
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Get device tokens error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}

/**
 * Delete/deactivate device token
 */
export async function onRequestDelete(context: any) {
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

    // Parse request body to get FCM token to delete
    const { fcm_token } = await request.json();
    
    if (!fcm_token) {
      return new Response('Missing fcm_token', { status: 400 });
    }

    // Deactivate the specific token
    const { error } = await supabase
      .from('push_tokens')
      .update({ is_active: false })
      .eq('user_id', user.user.id)
      .eq('fcm_token', fcm_token);

    if (error) {
      console.error('Error deactivating device token:', error);
      return new Response('Failed to deactivate device token', { status: 500 });
    }

    return new Response(JSON.stringify({
      success: true,
      message: 'Device token deactivated successfully'
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Delete device token error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error'
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}