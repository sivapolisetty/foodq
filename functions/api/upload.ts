import { getAuthFromRequest, verifyToken, handleCors, getCorsHeaders } from '../utils/auth.js';
import { getDBClient } from '../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    // Get authentication token
    const token = getAuthFromRequest(request);
    if (!token) {
      return createErrorResponse('No token provided', 401, corsHeaders);
    }

    const supabase = getDBClient(env, 'Upload.POST');
    const authResult = await verifyToken(token, supabase, env);
    if (!authResult) {
      return createErrorResponse('Invalid token', 401, corsHeaders);
    }

    // Parse form data
    const formData = await request.formData();
    const file = formData.get('file') as File;
    
    if (!file) {
      return createErrorResponse('No file provided', 400, corsHeaders);
    }

    // Validate file type
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      return createErrorResponse('Invalid file type. Only JPEG, PNG, and WebP are allowed', 400, corsHeaders);
    }

    // Validate file size (max 5MB)
    const maxSize = 5 * 1024 * 1024;
    if (file.size > maxSize) {
      return createErrorResponse('File size too large. Maximum 5MB allowed', 400, corsHeaders);
    }

    // Generate unique filename
    const timestamp = Date.now();
    const fileExtension = file.name.split('.').pop() || 'jpg';
    const fileName = `deal-${timestamp}-${authResult.userId}.${fileExtension}`;
    const filePath = `deals/${fileName}`;

    // Convert file to arrayBuffer for Supabase storage
    const fileBuffer = await file.arrayBuffer();
    
    // Upload to Supabase storage
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from('deal-images')
      .upload(filePath, fileBuffer, {
        contentType: file.type,
        cacheControl: '3600',
        upsert: true
      });

    if (uploadError) {
      console.error('Storage upload error:', uploadError);
      return createErrorResponse(`Failed to upload image: ${uploadError.message}`, 500, corsHeaders);
    }

    // Get public URL
    const { data: publicData } = supabase.storage
      .from('deal-images')
      .getPublicUrl(filePath);

    const publicUrl = publicData.publicUrl;

    return createSuccessResponse({
      url: publicUrl,
      path: filePath,
      filename: fileName,
      size: file.size,
      type: file.type
    }, corsHeaders);

  } catch (error: any) {
    console.error('Upload error:', error);
    return createErrorResponse(`Failed to upload image: ${error.message}`, 500, corsHeaders);
  }
}