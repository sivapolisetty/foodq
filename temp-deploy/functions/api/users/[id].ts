import { getAuthFromRequest, verifyToken, handleCors, jsonResponse, errorResponse, getCorsHeaders } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

export async function onRequestGet(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const userId = params.id;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const supabase = getDBClient(env, 'Users.GET_BY_ID');

  // Get authentication token
  const token = getAuthFromRequest(request);
  if (!token) {
    return createErrorResponse('No token provided', 401, corsHeaders);
  }

  const authResult = await verifyToken(token, supabase, env);
  if (!authResult) {
    return createErrorResponse('Invalid token', 401, corsHeaders);
  }
  
  try {
    
    // Get user data
    const { data: userData, error: userError } = await supabase
      .from('app_users')
      .select('*')
      .eq('id', userId)
      .single();
    
    if (userError) {
      if (userError.code === 'PGRST116') {
        return createErrorResponse('User not found', 404, corsHeaders);
      }
      return createErrorResponse(`Database error: ${userError.message}`, 500, corsHeaders);
    }

    // If user has business_id, fetch business data
    if (userData.business_id) {
      const { data: businessData, error: businessError } = await supabase
        .from('businesses')
        .select('*')
        .eq('id', userData.business_id)
        .single();
      
      if (businessData && !businessError) {
        userData.business = businessData;
        userData.business_name = businessData.name;
      }
    }

    return createSuccessResponse(userData, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch user profile: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestPut(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const userId = params.id;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const supabase = getDBClient(env, 'Users.PUT_BY_ID');

  // Get authentication token
  const token = getAuthFromRequest(request);
  if (!token) {
    return createErrorResponse('No token provided', 401, corsHeaders);
  }

  const authResult = await verifyToken(token, supabase, env);
  if (!authResult) {
    return createErrorResponse('Invalid token', 401, corsHeaders);
  }
  
  try {
    const updates = await request.json();
    updates.updated_at = new Date().toISOString();

    const { data, error } = await supabase
      .from('app_users')
      .update(updates)
      .eq('id', userId)
      .select()
      .single();
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    if (!data) {
      return createErrorResponse('User not found', 404, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to update user profile: ${error.message}`, 500, corsHeaders);
  }
}