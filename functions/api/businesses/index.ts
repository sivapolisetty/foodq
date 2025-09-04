import { getAuthFromRequest, verifyToken, handleCors, jsonResponse, errorResponse } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env } from '../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const supabase = getDBClient(env, 'Businesses.GET');
  
  try {
    const url = new URL(request.url);
    const limit = url.searchParams.get('limit');
    const filter = url.searchParams.get('filter');
    
    // Location-based query parameters
    const lat = url.searchParams.get('lat');
    const lng = url.searchParams.get('lng');
    const radius = url.searchParams.get('radius');
    
    // Check if this is a location-based query using PostgreSQL geospatial functions
    if (filter === 'nearby' && lat && lng) {
      console.log(`🌍 Location-based businesses query: lat=${lat}, lng=${lng}, radius=${radius || 10}km`);
      
      const userLat = parseFloat(lat);
      const userLng = parseFloat(lng);
      const radiusKm = radius ? parseFloat(radius) : 10.0;
      const resultLimit = limit ? parseInt(limit) : 20;
      
      // Validate coordinates
      if (isNaN(userLat) || isNaN(userLng) || userLat < -90 || userLat > 90 || userLng < -180 || userLng > 180) {
        return errorResponse('Invalid coordinates provided', 400, request, env);
      }
      
      // Use PostgreSQL geospatial function with proper SQL query
      // ST_DWithin uses meters, so convert km to meters
      const radiusMeters = radiusKm * 1000;
      
      console.log(`🔍 Executing geospatial query for businesses with ${radiusMeters}m radius`);
      
      try {
        // Create a stored procedure call for geospatial query
        const { data: rawResults, error: sqlError } = await supabase
          .rpc('get_nearby_businesses', {
            user_lat: userLat,
            user_lng: userLng, 
            radius_meters: radiusMeters,
            result_limit: resultLimit
          });
          
        if (sqlError) {
          console.error('PostgreSQL geospatial query error:', sqlError);
          console.error('SQL Error details:', sqlError);
          return errorResponse(`Geospatial query failed: ${sqlError.message}. Please ensure PostgreSQL geospatial function is properly configured.`, 500, request, env);
        }
        
        // PostgreSQL function returns JSONB array, so we just return it directly
        const businesses = rawResults || [];
        
        console.log(`📍 PostgreSQL geospatial query found ${businesses.length} businesses within ${radiusKm}km`);
        return jsonResponse(businesses, 200, request, env);
        
      } catch (error: any) {
        console.error('Geospatial query execution error:', error);
        return errorResponse(`Geospatial query failed: ${error.message}`, 500, request, env);
      }
    }
    
    // Standard query
    let query = supabase
      .from('businesses')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (limit) {
      query = query.limit(parseInt(limit));
    }
    
    const { data, error } = await query;
    
    if (error) {
      return errorResponse(`Database error: ${error.message}`, 500, request, env);
    }

    return jsonResponse(data, 200, request, env);
  } catch (error: any) {
    return errorResponse(`Failed to fetch businesses: ${error.message}`, 500, request, env);
  }
}

// Helper function to convert degrees to radians
function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

// POST /api/businesses - Create business record
// Used for: Admin business creation, Flutter business enrollment, and all business creation flows
export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const supabase = getDBClient(env, 'Businesses.POST');

  // Get authentication token
  const token = getAuthFromRequest(request);
  if (!token) {
    return errorResponse('No token provided', 401, request, env);
  }

  const authResult = await verifyToken(token, supabase, env);
  if (!authResult) {
    return errorResponse('Invalid token', 401, request, env);
  }

  const { userId } = authResult;
  
  try {
    const businessData = await request.json();
    
    // Validate required fields
    if (!businessData.name || !businessData.description) {
      return errorResponse('Missing required fields: name, description', 400, request, env);
    }
    const { data, error } = await supabase
      .from('businesses')
      .insert([{
        ...businessData,
        owner_id: userId, // Use authenticated user's ID
        is_approved: businessData.is_approved ?? true, // Default to approved for direct creation
        onboarding_completed: businessData.onboarding_completed ?? true, // Default to completed
        is_active: businessData.is_active ?? true, // Default to active
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();
    
    if (error) {
      if (error.code === '23505') {
        return errorResponse('Business with this name already exists', 409, request, env);
      }
      return errorResponse(`Database error: ${error.message}`, 500, request, env);
    }

    return jsonResponse(data, 200, request, env);
  } catch (error: any) {
    return errorResponse(`Failed to create business: ${error.message}`, 500, request, env);
  }
}