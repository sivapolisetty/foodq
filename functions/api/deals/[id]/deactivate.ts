import { validateAuth, handleCors, getCorsHeaders } from '../../../utils/auth.js';
import { getDBClient } from '../../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
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
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = getDBClient(env, 'Deals.DEACTIVATE_BY_ID');

    // Check if user owns the business that owns this deal (unless using API key)
    if (!auth.isApiKeyAuth) {
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
        
      if (checkError || deal?.businesses?.owner_id !== auth.user.id) {
        return createErrorResponse('Access denied: You can only deactivate deals for your own business', 403, corsHeaders);
      }
    }

    // Deactivate: Set status to expired
    const { data, error } = await supabase
      .from('deals')
      .update({
        status: 'expired',
        updated_at: new Date().toISOString()
      })
      .eq('id', dealId)
      .select()
      .single();
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    if (!data) {
      return createErrorResponse('Deal not found', 404, corsHeaders);
    }

    return createSuccessResponse({ message: 'Deal deactivated successfully', deal: data }, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to deactivate deal: ${error.message}`, 500, corsHeaders);
  }
}