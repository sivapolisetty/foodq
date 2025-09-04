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
    
    // Check if this is a location-based query
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
      
      // Create a custom query for location-based deals with current schema
      let locationQuery = supabase
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
        .eq('status', 'active')
        // Temporarily remove expiry filter for debugging
        //.gt('expires_at', new Date().toISOString())
        .not('businesses.latitude', 'is', null)
        .not('businesses.longitude', 'is', null);
      
      // Filter by business_id if provided
      if (businessId) {
        locationQuery = locationQuery.eq('business_id', businessId);
      }
      
      // Add search functionality
      if (search && search.trim()) {
        const searchTerm = search.trim();
        locationQuery = locationQuery.or(`title.ilike.*${searchTerm}*,description.ilike.*${searchTerm}*`);
      }
      
      locationQuery = locationQuery
        .limit(resultLimit)
        .order('created_at', { ascending: false });
      
      const { data: deals, error: dealsError } = await locationQuery;
      
      if (dealsError) {
        console.error('Database error in nearby deals query:', dealsError);
        return errorResponse(`Database error: ${dealsError.message}`, 500, request, env);
      }
      
      console.log(`📊 Initial query returned ${deals?.length || 0} deals before distance filtering`);
      
      if (deals && deals.length > 0) {
        console.log(`📍 First deal business location: lat=${deals[0].businesses?.latitude}, lng=${deals[0].businesses?.longitude}`);
        console.log(`📍 User location: lat=${userLat}, lng=${userLng}`);
      }
      
      // DEBUG: Return raw results if debug parameter is present
      if (url.searchParams.get('debug') === 'raw') {
        return jsonResponse({
          debug: true,
          query_params: { lat, lng, radius, filter },
          raw_deals_count: deals?.length || 0,
          raw_deals: deals || []
        }, 200, request, env);
      }
      
      // Calculate distances and filter by radius
      const dealsWithDistance = deals
        .map((deal: any) => {
          const business = deal.businesses;
          if (!business.latitude || !business.longitude) return null;
          
          // Calculate distance using Haversine formula
          const earthRadiusKm = 6371;
          const dLat = toRadians(business.latitude - userLat);
          const dLng = toRadians(business.longitude - userLng);
          const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(toRadians(userLat)) * Math.cos(toRadians(business.latitude)) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);
          const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
          const distanceKm = earthRadiusKm * c;
          
          // Convert to miles for mobile app compatibility
          const distanceMiles = distanceKm * 0.621371;
          
          return {
            ...deal,
            distance_km: distanceKm,
            distance_miles: distanceMiles,
            businesses: {
              ...business,
              distance_km: distanceKm,
              distance_miles: distanceMiles
            }
          };
        })
        .filter((deal: any) => deal && deal.distance_km <= radiusKm)
        .sort((a: any, b: any) => a.distance_km - b.distance_km);
      
      console.log(`📍 Found ${dealsWithDistance.length} deals within ${radiusKm}km`);
      
      return jsonResponse(dealsWithDistance, 200, request, env);
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
      query = query.eq('status', status);
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