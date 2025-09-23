/**
 * User Location Management API
 * Handles location storage and location-based notification preferences
 */

import { createClient } from '@supabase/supabase-js';

interface LocationRequest {
  latitude: number;
  longitude: number;
  location_type: 'home' | 'work' | 'other';
  address?: string;
  notification_radius_km?: number;
  label?: string;
  city?: string;
  state?: string;
  country?: string;
}

/**
 * Update user location
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
    const locationData: LocationRequest = await request.json();
    
    // Validate required fields
    if (!locationData.latitude || !locationData.longitude || !locationData.location_type) {
      return new Response('Missing required fields: latitude, longitude, location_type', { status: 400 });
    }

    // Validate coordinates
    if (locationData.latitude < -90 || locationData.latitude > 90) {
      return new Response('Invalid latitude. Must be between -90 and 90', { status: 400 });
    }
    
    if (locationData.longitude < -180 || locationData.longitude > 180) {
      return new Response('Invalid longitude. Must be between -180 and 180', { status: 400 });
    }

    // Validate location type
    if (!['home', 'work', 'other'].includes(locationData.location_type)) {
      return new Response('Invalid location_type. Must be: home, work, other', { status: 400 });
    }

    // Validate notification radius
    const radius = locationData.notification_radius_km || 5;
    if (radius < 1 || radius > 50) {
      return new Response('Invalid notification_radius_km. Must be between 1 and 50', { status: 400 });
    }

    // Upsert user location
    const { data, error } = await supabase
      .from('user_locations')
      .upsert({
        user_id: user.user.id,
        location_type: locationData.location_type,
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        address: locationData.address || '',
        notification_radius_km: radius,
        label: locationData.label,
        city: locationData.city,
        state: locationData.state,
        country: locationData.country || 'US',
        active: true,
      }, {
        onConflict: 'user_id,location_type'
      })
      .select()
      .single();

    if (error) {
      console.error('Error upserting user location:', error);
      return new Response('Failed to update user location', { status: 500 });
    }

    // Check for nearby deals after location update
    await checkNearbyDeals(supabase, user.user.id, locationData.latitude, locationData.longitude);

    return new Response(JSON.stringify({
      success: true,
      message: 'Location updated successfully',
      data: {
        id: data.id,
        location_type: data.location_type,
        latitude: data.latitude,
        longitude: data.longitude,
        address: data.address,
        notification_radius_km: data.notification_radius_km,
        city: data.city,
        state: data.state,
        updated_at: data.updated_at,
      }
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Location update error:', error);
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
 * Get user's saved locations
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

    // Get user's active locations
    const { data, error } = await supabase
      .from('user_locations')
      .select('id, location_type, latitude, longitude, address, notification_radius_km, label, city, state, country, active, created_at, updated_at')
      .eq('user_id', user.user.id)
      .eq('active', true)
      .order('updated_at', { ascending: false });

    if (error) {
      console.error('Error fetching user locations:', error);
      return new Response('Failed to fetch user locations', { status: 500 });
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
    console.error('Get user locations error:', error);
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
 * Delete user location
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

    // Parse request body to get location type to delete
    const { location_type } = await request.json();
    
    if (!location_type) {
      return new Response('Missing location_type', { status: 400 });
    }

    // Deactivate the location
    const { error } = await supabase
      .from('user_locations')
      .update({ active: false })
      .eq('user_id', user.user.id)
      .eq('location_type', location_type);

    if (error) {
      console.error('Error deactivating user location:', error);
      return new Response('Failed to delete user location', { status: 500 });
    }

    return new Response(JSON.stringify({
      success: true,
      message: 'Location deleted successfully'
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Delete user location error:', error);
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
 * Check for nearby deals after location update
 */
async function checkNearbyDeals(supabase: any, userId: string, latitude: number, longitude: number) {
  try {
    // Find nearby deals using PostGIS
    const { data: deals, error } = await supabase.rpc('find_deals_near_location', {
      p_latitude: latitude,
      p_longitude: longitude,
      p_radius_km: 5,
      p_limit: 10,
    });

    if (error) {
      console.error('Error finding nearby deals:', error);
      return;
    }

    if (deals && deals.length > 0) {
      console.log(`Found ${deals.length} nearby deals for user ${userId}`);
      
      // Create location-based deal event for processing
      await supabase.from('event_queue').insert({
        event_type: 'LOCATION_BASED_DEAL',
        event_name: 'User location updated - nearby deals available',
        payload: {
          userId: userId,
          deals: deals.slice(0, 5).map((deal: any) => ({
            dealId: deal.deal_id,
            title: deal.title,
            businessName: deal.business_name,
            discountPercent: deal.discount_percent,
            distance: deal.distance_km,
          })),
          userLocation: {
            latitude: latitude,
            longitude: longitude,
          },
        },
        metadata: {
          source: 'location_api',
          version: '1.0',
          timestamp: new Date().toISOString(),
        },
      });

      console.log('Location-based deal event created successfully');
    }
  } catch (error) {
    console.error('Error checking nearby deals:', error);
  }
}