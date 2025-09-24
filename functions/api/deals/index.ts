import { getAuthFromRequest, verifyToken, handleCors, jsonResponse, errorResponse } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env } from '../../utils/supabase.js';
import { createE2ELogger } from '../../utils/e2e-logger.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const logger = createE2ELogger(request, env);
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const supabase = getDBClient(env, 'Deals.GET');
  logger.logRequestStart(request.method, '/api/deals');
  
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
      logger.logBusinessLogic('geospatial_query', { lat, lng, radius: radius || 10 });
      
      const userLat = parseFloat(lat);
      const userLng = parseFloat(lng);
      const radiusKm = radius ? parseFloat(radius) : 10.0;
      const resultLimit = limit ? parseInt(limit) : 20;
      
      // Validate coordinates
      if (isNaN(userLat) || isNaN(userLng) || userLat < -90 || userLat > 90 || userLng < -180 || userLng > 180) {
        logger.logValidationError('coordinates', { lat: userLat, lng: userLng }, 'Invalid coordinate range');
        logger.logRequestEnd(request.method, '/api/deals', 400, { error: 'Invalid coordinates' });
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
      
      logger.logDatabaseQuery('RPC', 'get_nearby_deals', { 
        paramCount: queryParams.length, 
        userLat, 
        userLng, 
        radiusMeters,
        businessId: businessId || null 
      });
      
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
          logger.logError('geospatial_query', sqlError, { userLat, userLng, radiusMeters });
          logger.logRequestEnd(request.method, '/api/deals', 500, { error: sqlError.message });
          return errorResponse(`Geospatial query failed: ${sqlError.message}. Please ensure PostgreSQL geospatial function is properly configured.`, 500, request, env);
        }
        
        // PostgreSQL function returns JSONB array, so we just return it directly
        const deals = rawResults || [];
        
        logger.logBusinessLogic('geospatial_query_success', { 
          dealCount: deals.length, 
          radiusKm,
          lat: userLat,
          lng: userLng 
        });
        logger.logRequestEnd(request.method, '/api/deals', 200, { dealCount: deals.length });
        return jsonResponse(deals, 200, request, env);
        
      } catch (error: any) {
        logger.logError('geospatial_query_execution', error, { userLat, userLng, radiusMeters });
        logger.logRequestEnd(request.method, '/api/deals', 500, { error: error.message });
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
      logger.logBusinessLogic('status_filter', { status, currentTime });
      
      if (status === 'expired') {
        // For expired deals, filter by expiration time regardless of status field
        logger.logBusinessLogic('expired_filter', { currentTime });
        query = query.lt('expires_at', currentTime);
      } else if (status === 'active') {
        // For active deals, must have active status AND not be expired
        logger.logBusinessLogic('active_filter', { currentTime });
        query = query.eq('status', 'active').gt('expires_at', currentTime);
      } else {
        // For other statuses (e.g., 'draft', 'paused'), use status field
        logger.logBusinessLogic('other_status_filter', { status });
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
    
    logger.logDatabaseQuery('SELECT', 'deals', { businessId, status, search, limit });
    const { data, error } = await query;
    
    if (error) {
      logger.logError('deals_query', error, { businessId, status, search, limit });
      logger.logRequestEnd(request.method, '/api/deals', 500, { error: error.message });
      return errorResponse(`Database error: ${error.message}`, 500, request, env);
    }

    logger.logRequestEnd(request.method, '/api/deals', 200, { dealCount: data?.length || 0 });
    return jsonResponse(data, 200, request, env);
  } catch (error: any) {
    logger.logError('deals_get', error);
    logger.logRequestEnd(request.method, '/api/deals', 500, { error: error.message });
    return errorResponse(`Failed to fetch deals: ${error.message}`, 500, request, env);
  }
}

// Helper function to convert degrees to radians
function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const logger = createE2ELogger(request, env);
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const supabase = getDBClient(env, 'Deals.POST');
  logger.logRequestStart(request.method, '/api/deals');

  // Get authentication token
  const token = getAuthFromRequest(request);
  if (!token) {
    logger.logAuthOperation('missing_token');
    logger.logRequestEnd(request.method, '/api/deals', 401, { error: 'No token provided' });
    return errorResponse('No token provided', 401, request, env);
  }

  const authResult = await verifyToken(token, supabase, env);
  logger.logAuthOperation('verify_token', authResult?.userId);
  
  if (!authResult) {
    logger.logError('deals_post_auth', new Error('Invalid token'));
    logger.logRequestEnd(request.method, '/api/deals', 401, { error: 'Invalid token' });
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
      logger.logValidationError('required_fields', dealData, 'Missing title, description, or business_id');
      logger.logRequestEnd(request.method, '/api/deals', 400, { error: 'Missing required fields' });
      return errorResponse('Missing required fields: title, description, business_id', 400, request, env);
    }
    
    // Validate pricing fields
    if (!dealData.original_price && !dealData.discounted_price && !dealData.price) {
      logger.logValidationError('pricing_fields', dealData, 'Missing pricing information');
      logger.logRequestEnd(request.method, '/api/deals', 400, { error: 'Missing pricing' });
      return errorResponse('Missing pricing: provide either original_price/discounted_price or price', 400, request, env);
    }
    
    // Validate and set expires_at - required for future_expiration constraint
    let expiresAt = dealData.expires_at;
    if (!expiresAt) {
      // Default to 24 hours from now if not provided
      const defaultExpiry = new Date();
      defaultExpiry.setHours(defaultExpiry.getHours() + 24);
      expiresAt = defaultExpiry.toISOString();
    } else {
      // Validate that provided expiry is in the future
      const expiryDate = new Date(expiresAt);
      if (expiryDate <= new Date()) {
        logger.logValidationError('expires_at', expiresAt, 'Expiry date must be in the future');
        logger.logRequestEnd(request.method, '/api/deals', 400, { error: 'Invalid expiry date' });
        return errorResponse('expires_at must be in the future', 400, request, env);
      }
    }
    
    // Verify business exists and user has access (simplified for API key auth)
    logger.logDatabaseQuery('SELECT', 'businesses', { businessId: dealData.business_id });
    const { data: business, error: businessError } = await supabase
      .from('businesses')
      .select('owner_id')
      .eq('id', dealData.business_id)
      .single();
      
    if (businessError) {
      logger.logError('business_verification', businessError, { businessId: dealData.business_id });
      logger.logRequestEnd(request.method, '/api/deals', 404, { error: 'Business not found' });
      return errorResponse('Business not found', 404, request, env);
    }

    // Prepare deal data for insertion
    const dealRecord = {
      ...dealData,
      image_url: uploadedImageUrl || dealData.image_url || null,
      status: dealData.status || 'active',
      expires_at: expiresAt,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    logger.logBusinessLogic('creating_deal', { 
      businessId: dealData.business_id,
      title: dealData.title,
      status: dealRecord.status,
      hasImage: !!uploadedImageUrl 
    });
    logger.logDatabaseQuery('INSERT', 'deals', { businessId: dealData.business_id, userId });
    
    const { data, error } = await supabase
      .from('deals')
      .insert([dealRecord])
      .select()
      .single();
    
    if (error) {
      logger.logError('deal_creation', error, { dealRecord: { ...dealRecord, image_url: '[REDACTED]' } });
      logger.logRequestEnd(request.method, '/api/deals', 500, { error: error.message });
      return errorResponse(`Database error: ${error.message}`, 500, request, env);
    }

    logger.logBusinessLogic('deal_created_successfully', { dealId: data.id, businessId: data.business_id });
    logger.logRequestEnd(request.method, '/api/deals', 201, { dealId: data.id });
    return jsonResponse(data, 200, request, env);
  } catch (error: any) {
    logger.logError('deals_post', error);
    logger.logRequestEnd(request.method, '/api/deals', 500, { error: error.message });
    return errorResponse(`Failed to create deal: ${error.message}`, 500, request, env);
  }
}