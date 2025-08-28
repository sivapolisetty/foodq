import { getAuthFromRequest, verifyToken, handleCors, getCorsHeaders } from '../../utils/auth.js';
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
  const dealId = params.id;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const supabase = getDBClient(env, 'Deals.GET_BY_ID');
    
    // Get deal data with business information
    const { data: dealData, error: dealError } = await supabase
      .from('deals')
      .select(`
        *,
        businesses (
          id,
          name,
          description,
          owner_id,
          location,
          contact_email,
          contact_phone
        )
      `)
      .eq('id', dealId)
      .single();
    
    if (dealError) {
      if (dealError.code === 'PGRST116') {
        return createErrorResponse('Deal not found', 404, corsHeaders);
      }
      return createErrorResponse(`Database error: ${dealError.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(dealData, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch deal: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestPut(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const dealId = params.id;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const supabase = getDBClient(env, 'Deals.PUT_BY_ID');

    // Get authentication token
    const token = getAuthFromRequest(request);
    if (!token) {
      return createErrorResponse('No token provided', 401, corsHeaders);
    }

    const authResult = await verifyToken(token, supabase, env);
    if (!authResult) {
      return createErrorResponse('Invalid token', 401, corsHeaders);
    }

    const updates = await request.json();
    updates.updated_at = new Date().toISOString();
    
    // Check if user owns the business that owns this deal (unless using API key)
    if (!authResult.user.isApiKeyAuth) {
      const { data: deal, error: checkError } = await supabase
        .from('deals')
        .select(`
          business_id,
          businesses!inner (
            owner_id
          )
        `)
        .eq('id', dealId)
        .single();
        
      if (checkError || deal?.businesses?.owner_id !== authResult.userId) {
        return createErrorResponse('Access denied: You can only update deals for your own business', 403, corsHeaders);
      }
    }

    const { data, error } = await supabase
      .from('deals')
      .update(updates)
      .eq('id', dealId)
      .select()
      .single();
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    if (!data) {
      return createErrorResponse('Deal not found', 404, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to update deal: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestDelete(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const dealId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    // Check if user owns the business that owns this deal (unless using API key)
    if (!auth.isApiKeyAuth) {
      const { data: deal, error: checkError } = await supabase
        .from('deals')
        .select(`
          business_id,
          businesses (
            owner_id
          )
        `)
        .eq('id', dealId)
        .single();
        
      if (checkError || deal?.businesses?.owner_id !== auth.user?.id) {
        return createErrorResponse('Access denied: You can only delete deals for your own business', 403, corsHeaders);
      }
    }

    const { error } = await supabase
      .from('deals')
      .delete()
      .eq('id', dealId);
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse({ message: 'Deal deleted successfully' }, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to delete deal: ${error.message}`, 500, corsHeaders);
  }
}