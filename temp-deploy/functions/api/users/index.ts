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

  const supabase = getDBClient(env, 'Users.GET');

  // Get authentication token
  const token = getAuthFromRequest(request);
  if (!token) {
    return errorResponse('No token provided', 401, request, env);
  }

  const authResult = await verifyToken(token, supabase, env);
  if (!authResult) {
    return errorResponse('Invalid token', 401, request, env);
  }
  
  try {
    const { data, error } = await supabase
      .from('app_users')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) {
      return errorResponse(`Database error: ${error.message}`, 500, request, env);
    }

    return jsonResponse(data, 200, request, env);
  } catch (error: any) {
    return errorResponse(`Failed to fetch users: ${error.message}`, 500, request, env);
  }
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    const userData = await request.json();
    
    // Validate required fields
    if (!userData.name || !userData.email || !userData.user_type) {
      return createErrorResponse('Missing required fields: name, email, user_type', 400, corsHeaders);
    }

    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    const { data, error } = await supabase
      .from('app_users')
      .insert([{
        ...userData,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();
    
    if (error) {
      if (error.code === '23505') {
        return createErrorResponse('User with this email already exists', 409, corsHeaders);
      }
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to create user: ${error.message}`, 500, corsHeaders);
  }
}