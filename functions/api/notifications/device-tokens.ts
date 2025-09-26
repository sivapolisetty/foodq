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

    // Parse request body
    const deviceData: DeviceTokenRequest = await request.json();
    
    // Validate required fields
    if (!deviceData.fcm_token || !deviceData.platform) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Missing required fields: fcm_token, platform',
        message: 'Both fcm_token and platform are required'
      }), { 
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Validate platform
    if (!['ios', 'android', 'web'].includes(deviceData.platform)) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Invalid platform. Must be: ios, android, web',
        message: `Platform '${deviceData.platform}' is not supported`
      }), { 
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // First, let's check what columns exist and insert only what we need
    const tokenRecord = {
      user_id: user.user.id,
      fcm_token: deviceData.fcm_token,
      platform: deviceData.platform,
      created_at: new Date().toISOString(),
    };

    // Add optional fields only if provided
    if (deviceData.device_id) tokenRecord.device_id = deviceData.device_id;
    if (deviceData.device_model) tokenRecord.device_model = deviceData.device_model;
    if (deviceData.device_name) tokenRecord.device_name = deviceData.device_name;
    if (deviceData.app_version) tokenRecord.app_version = deviceData.app_version;
    if (deviceData.os_version) tokenRecord.os_version = deviceData.os_version;

    // Try to upsert with minimal required columns
    const { data, error } = await supabase
      .from('push_tokens')
      .upsert(tokenRecord, {
        onConflict: 'user_id,fcm_token'
      })
      .select()
      .single();

    if (error) {
      console.error('Error upserting device token:', error);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to register device token',
        message: error.message || 'Database error occurred'
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
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

    // Get user's device tokens (using minimal columns)
    const { data, error } = await supabase
      .from('push_tokens')
      .select('id, platform, device_model, device_name, created_at')
      .eq('user_id', user.user.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching device tokens:', error);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to fetch device tokens',
        message: error.message || 'Database error occurred'
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
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

    // Parse request body to get FCM token to delete
    const { fcm_token } = await request.json();
    
    if (!fcm_token) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Missing fcm_token',
        message: 'FCM token is required to deactivate'
      }), { 
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Delete the specific token (since is_active column may not exist)
    const { error } = await supabase
      .from('push_tokens')
      .delete()
      .eq('user_id', user.user.id)
      .eq('fcm_token', fcm_token);

    if (error) {
      console.error('Error deactivating device token:', error);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to delete device token',
        message: error.message || 'Database error occurred'
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({
      success: true,
      message: 'Device token deleted successfully'
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