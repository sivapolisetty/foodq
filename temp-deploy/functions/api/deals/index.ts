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
    
    let query = supabase
      .from('deals')
      .select(`
        *,
        businesses (
          id,
          name,
          description,
          owner_id
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