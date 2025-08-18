import { validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { createServiceRoleClient, createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    // Require authentication for user listing
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = createServiceRoleClient(env);
    const { data, error } = await supabase
      .from('app_users')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch users: ${error.message}`, 500, corsHeaders);
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

    const supabase = createServiceRoleClient(env);
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