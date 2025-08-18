import { validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { createServiceRoleClient, createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

export async function onRequestGet(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const userId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    // Users can only access their own profile unless using API key
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      return createErrorResponse('Access denied: You can only access your own profile', 403, corsHeaders);
    }

    const supabase = createServiceRoleClient(env);
    
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
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const userId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    // Users can only update their own profile unless using API key
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      return createErrorResponse('Access denied: You can only update your own profile', 403, corsHeaders);
    }

    const updates = await request.json();
    updates.updated_at = new Date().toISOString();

    const supabase = createServiceRoleClient(env);
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