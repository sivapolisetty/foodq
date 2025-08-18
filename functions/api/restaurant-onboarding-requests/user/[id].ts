import { validateAuth, getCorsHeaders } from '../../../utils/auth.js';
import { createServiceRoleClient, createSuccessResponse, createErrorResponse, Env } from '../../../utils/supabase.js';

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
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    // Users can only check their own requests unless using API key
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      return createErrorResponse('Access denied: You can only access your own onboarding requests', 403, corsHeaders);
    }

    const supabase = createServiceRoleClient(env);
    
    // Fetch restaurant onboarding requests for the user
    const { data: requests, error: requestError } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (requestError) {
      console.error('Error fetching onboarding requests:', requestError);
      return createErrorResponse('Failed to fetch onboarding requests', 500, corsHeaders);
    }

    return createSuccessResponse({
      success: true,
      data: requests || []
    }, corsHeaders);

  } catch (error: any) {
    console.error('Unexpected error:', error);
    return createErrorResponse(`Internal server error: ${error.message}`, 500, corsHeaders);
  }
}