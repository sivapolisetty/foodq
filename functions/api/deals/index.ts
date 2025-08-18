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
    const url = new URL(request.url);
    const businessId = url.searchParams.get('business_id');
    const status = url.searchParams.get('status');
    const limit = url.searchParams.get('limit');
    
    const supabase = createServiceRoleClient(env);
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
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch deals: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const dealData = await request.json();
    
    // Validate required fields
    if (!dealData.title || !dealData.description || !dealData.business_id) {
      return createErrorResponse('Missing required fields: title, description, business_id', 400, corsHeaders);
    }
    
    // Validate pricing fields
    if (!dealData.original_price && !dealData.discounted_price && !dealData.price) {
      return createErrorResponse('Missing pricing: provide either original_price/discounted_price or price', 400, corsHeaders);
    }

    const supabase = createServiceRoleClient(env);
    
    // Verify business exists and user has access (unless using API key)
    if (!auth.isApiKeyAuth) {
      const { data: business, error: businessError } = await supabase
        .from('businesses')
        .select('owner_id')
        .eq('id', dealData.business_id)
        .single();
        
      if (businessError || business?.owner_id !== auth.user?.id) {
        return createErrorResponse('Access denied: You can only create deals for your own business', 403, corsHeaders);
      }
    }

    const { data, error } = await supabase
      .from('deals')
      .insert([{
        ...dealData,
        status: dealData.status || 'active',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to create deal: ${error.message}`, 500, corsHeaders);
  }
}