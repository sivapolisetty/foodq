import { validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { createServiceRoleClient, createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';
import { createClient } from '@supabase/supabase-js';

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
  const businessId = params.id;
  
  try {
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    // Get business data with related deals
    const { data: businessData, error: businessError } = await supabase
      .from('businesses')
      .select(`
        *,
        deals (
          id,
          title,
          description,
          price,
          status,
          created_at,
          updated_at
        )
      `)
      .eq('id', businessId)
      .single();
    
    if (businessError) {
      if (businessError.code === 'PGRST116') {
        return createErrorResponse('Business not found', 404, corsHeaders);
      }
      return createErrorResponse(`Database error: ${businessError.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(businessData, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch business: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestPut(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const businessId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const updates = await request.json();
    updates.updated_at = new Date().toISOString();

    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    // Check if user owns the business (unless using API key)
    if (!auth.isApiKeyAuth) {
      const { data: business, error: checkError } = await supabase
        .from('businesses')
        .select('owner_id')
        .eq('id', businessId)
        .single();
        
      if (checkError || business?.owner_id !== auth.user?.id) {
        return createErrorResponse('Access denied: You can only update your own business', 403, corsHeaders);
      }
    }

    const { data, error } = await supabase
      .from('businesses')
      .update(updates)
      .eq('id', businessId)
      .select()
      .single();
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    if (!data) {
      return createErrorResponse('Business not found', 404, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to update business: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestDelete(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const businessId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    // Check if user owns the business (unless using API key)
    if (!auth.isApiKeyAuth) {
      const { data: business, error: checkError } = await supabase
        .from('businesses')
        .select('owner_id')
        .eq('id', businessId)
        .single();
        
      if (checkError || business?.owner_id !== auth.user?.id) {
        return createErrorResponse('Access denied: You can only delete your own business', 403, corsHeaders);
      }
    }

    const { error } = await supabase
      .from('businesses')
      .delete()
      .eq('id', businessId);
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse({ message: 'Business deleted successfully' }, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to delete business: ${error.message}`, 500, corsHeaders);
  }
}