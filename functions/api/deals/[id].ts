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
  const dealId = params.id;
  
  try {
    const supabase = createServiceRoleClient(env);
    
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
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const dealId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const updates = await request.json();
    updates.updated_at = new Date().toISOString();

    const supabase = createServiceRoleClient(env);
    
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

    const supabase = createServiceRoleClient(env);
    
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