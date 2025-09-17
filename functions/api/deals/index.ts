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

  const supabase = getDBClient(env, 'Deals.GET');
  
  try {
    const url = new URL(request.url);
    const businessId = url.searchParams.get('business_id');
    const status = url.searchParams.get('status');
    const limit = url.searchParams.get('limit');
    const filter = url.searchParams.get('filter');
    const search = url.searchParams.get('search');
    
    // Location-based query parameters
    const lat = url.searchParams.get('lat');
    const lng = url.searchParams.get('lng');
    const radius = url.searchParams.get('radius');
    
    // Check if this is a location-based query using PostgreSQL geospatial functions
    if (filter === 'nearby' && lat && lng) {
      console.log(`🌍 Location-based deals query: lat=${lat}, lng=${lng}, radius=${radius || 10}km`);
      
      const userLat = parseFloat(lat);
      const userLng = parseFloat(lng);
      const radiusKm = radius ? parseFloat(radius) : 10.0;
      const resultLimit = limit ? parseInt(limit) : 20;
      
      // Validate coordinates
      if (isNaN(userLat) || isNaN(userLng) || userLat < -90 || userLat > 90 || userLng < -180 || userLng > 180) {
        return errorResponse('Invalid coordinates provided', 400, request, env);
      }
      
      // Use PostgreSQL's geospatial functions with proper SQL query
      // ST_DWithin uses meters, so convert km to meters
      const radiusMeters = radiusKm * 1000;
      
      let sqlQuery = `
        SELECT 
          d.*,
          b.id as business_id,
          b.name as business_name,
          b.description as business_description,
          b.owner_id as business_owner_id,
          b.latitude as business_latitude,
          b.longitude as business_longitude,
          b.address as business_address,
          b.phone as business_phone,
          ST_Distance(
            ST_Point(b.longitude, b.latitude)::geography,
            ST_Point($3, $2)::geography
          ) / 1000.0 as distance_km,
          ST_Distance(
            ST_Point(b.longitude, b.latitude)::geography,
            ST_Point($3, $2)::geography
          ) / 1609.34 as distance_miles
        FROM deals d
        JOIN businesses b ON d.business_id = b.id
        WHERE d.status = 'active'
          AND d.expires_at > NOW()
          AND b.latitude IS NOT NULL
          AND b.longitude IS NOT NULL
          AND ST_DWithin(
            ST_Point(b.longitude, b.latitude)::geography,
            ST_Point($3, $2)::geography,
            $1
          )
      `;
      
      const queryParams = [radiusMeters, userLat, userLng];
      let paramIndex = 4;
      
      // Add business filter
      if (businessId) {
        sqlQuery += ` AND d.business_id = $${paramIndex}`;
        queryParams.push(businessId);
        paramIndex++;
      }
      
      // Add search filter
      if (search && search.trim()) {
        const searchTerm = search.trim();
        sqlQuery += ` AND (d.title ILIKE $${paramIndex} OR d.description ILIKE $${paramIndex})`;
        queryParams.push(`%${searchTerm}%`);
        paramIndex++;
      }
      
      sqlQuery += `
        ORDER BY distance_km ASC, d.created_at DESC
        LIMIT $${paramIndex}
      `;
      queryParams.push(resultLimit);
      
      console.log(`🔍 Executing geospatial query with ${queryParams.length} parameters`);
      
      try {
        // Create a stored procedure call for geospatial query
        const { data: rawResults, error: sqlError } = await supabase
          .rpc('get_nearby_deals', {
            user_lat: userLat,
            user_lng: userLng, 
            radius_meters: radiusMeters,
            result_limit: resultLimit,
            business_filter: businessId || null,
            search_term: (search && search.trim()) ? `%${search.trim()}%` : null
          });
          
        if (sqlError) {
          console.error('PostgreSQL geospatial query error:', sqlError);
          console.error('SQL Error details:', sqlError);
          return errorResponse(`Geospatial query failed: ${sqlError.message}. Please ensure PostgreSQL geospatial function is properly configured.`, 500, request, env);
        }
        
        // PostgreSQL function returns JSONB array, so we just return it directly
        const deals = rawResults || [];
        
        console.log(`📍 PostgreSQL geospatial query found ${deals.length} deals within ${radiusKm}km`);
        return jsonResponse(deals, 200, request, env);
        
      } catch (error: any) {
        console.error('Geospatial query execution error:', error);
        return errorResponse(`Geospatial query failed: ${error.message}`, 500, request, env);
      }
    }
    
    // Standard non-location query
    let query = supabase
      .from('deals')
      .select(`
        *,
        businesses (
          id,
          name,
          description,
          owner_id,
          latitude,
          longitude,
          address,
          phone
        )
      `)
      .order('created_at', { ascending: false });

    // Apply filters
    if (businessId) {
      query = query.eq('business_id', businessId);
    }
    
    if (status) {
      const currentTime = new Date().toISOString();
      console.log(`🕒 STATUS FILTER: status=${status}, currentTime=${currentTime}`);
      
      if (status === 'expired') {
        // For expired deals, filter by expiration time regardless of status field
        console.log(`🕒 EXPIRED FILTER: Looking for deals where expires_at < ${currentTime}`);
        query = query.lt('expires_at', currentTime);
      } else if (status === 'active') {
        // For active deals, must have active status AND not be expired
        console.log(`🕒 ACTIVE FILTER: Looking for deals where status=active AND expires_at > ${currentTime}`);
        query = query.eq('status', 'active').gt('expires_at', currentTime);
      } else {
        // For other statuses (e.g., 'draft', 'paused'), use status field
        console.log(`🕒 OTHER STATUS FILTER: Looking for deals where status=${status}`);
        query = query.eq('status', status);
      }
    }
    
    // Add search functionality  
    if (search && search.trim()) {
      const searchTerm = search.trim();
      query = query.or(`title.ilike.*${searchTerm}*,description.ilike.*${searchTerm}*`);
    }
    
    if (limit) {
      query = query.limit(parseInt(limit));
    }
    
    const { data, error } = await query;
    
    if (error) {
      return errorResponse(`Database error: ${error.message}`, 500, request, env);
    }

    return jsonResponse(data, 200, request, env);
  } catch (error: any) {
    return errorResponse(`Failed to fetch deals: ${error.message}`, 500, request, env);
  }
}

// Helper function to convert degrees to radians
function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const supabase = getDBClient(env, 'Deals.POST');

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
    const contentType = request.headers.get('content-type') || '';
    let dealData: any = {};
    let uploadedImageUrl: string | null = null;

    // Handle form data (with image upload)
    if (contentType.includes('multipart/form-data')) {
      const formData = await request.formData();
      
      // Extract text fields
      for (const [key, value] of formData.entries()) {
        if (typeof value === 'string') {
          dealData[key] = value;
        }
      }
      
      // Handle image upload
      const imageFile = formData.get('image') as File;
      if (imageFile) {
        // Validate file type
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
        if (!allowedTypes.includes(imageFile.type)) {
          return errorResponse('Invalid file type. Only JPEG, PNG, and WebP are allowed', 400, request, env);
        }

        // Validate file size (max 5MB)
        const maxSize = 5 * 1024 * 1024;
        if (imageFile.size > maxSize) {
          return errorResponse('File size too large. Maximum 5MB allowed', 400, request, env);
        }

        // Generate unique filename
        const timestamp = Date.now();
        const fileExtension = imageFile.name.split('.').pop() || 'jpg';
        const fileName = `deal-${timestamp}-${userId}.${fileExtension}`;
        const filePath = `deals/${fileName}`;

        // Convert file to arrayBuffer for Supabase storage
        const fileBuffer = await imageFile.arrayBuffer();
        
        // Upload to Supabase storage
        const { data: uploadData, error: uploadError } = await supabase.storage
          .from('deal-images')
          .upload(filePath, fileBuffer, {
            contentType: imageFile.type,
            cacheControl: '3600',
            upsert: true
          });

        if (uploadError) {
          console.error('Storage upload error:', uploadError);
          return errorResponse(`Failed to upload image: ${uploadError.message}`, 500, request, env);
        }

        // Get public URL
        const { data: publicData } = supabase.storage
          .from('deal-images')
          .getPublicUrl(filePath);

        uploadedImageUrl = publicData.publicUrl;
      }
    } else {
      // Handle JSON data (no image)
      dealData = await request.json();
    }
    
    // Validate required fields
    if (!dealData.title || !dealData.description || !dealData.business_id) {
      return errorResponse('Missing required fields: title, description, business_id', 400, request, env);
    }
    
    // Validate pricing fields
    if (!dealData.original_price && !dealData.discounted_price && !dealData.price) {
      return errorResponse('Missing pricing: provide either original_price/discounted_price or price', 400, request, env);
    }
    
    // Verify business exists and user has access (simplified for API key auth)
    const { data: business, error: businessError } = await supabase
      .from('businesses')
      .select('owner_id')
      .eq('id', dealData.business_id)
      .single();
      
    if (businessError) {
      return errorResponse('Business not found', 404, request, env);
    }

    // Prepare deal data for insertion
    const dealRecord = {
      ...dealData,
      image_url: uploadedImageUrl || dealData.image_url || null,
      status: dealData.status || 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const { data, error } = await supabase
      .from('deals')
      .insert([dealRecord])
      .select()
      .single();
    
    if (error) {
      return errorResponse(`Database error: ${error.message}`, 500, request, env);
    }

    return jsonResponse(data, 200, request, env);
  } catch (error: any) {
    return errorResponse(`Failed to create deal: ${error.message}`, 500, request, env);
  }
}