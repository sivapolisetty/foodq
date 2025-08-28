import { validateAuth, getCorsHeaders } from '../../../utils/auth.js';
import { createSuccessResponse, createErrorResponse, Env } from '../../../utils/supabase.js';
import { createClient } from '@supabase/supabase-js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

// GET /api/restaurant-onboarding-requests/[id] - Get specific request
export async function onRequestGet(context: { request: Request; env: Env; params: { id: string } }) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const requestId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated && !auth.isApiKeyAuth) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }
    
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    // Get the request
    const { data, error } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('id', requestId)
      .single();
    
    if (error) {
      console.error('Database error:', error);
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }
    
    if (!data) {
      return createErrorResponse('Request not found', 404, corsHeaders);
    }
    
    // Check permissions - users can only see their own requests, admins can see all
    if (!auth.isApiKeyAuth && data.user_id !== auth.user?.id) {
      const { data: adminData } = await supabase
        .from('admins')
        .select('*')
        .eq('email', auth.user?.email)
        .single();
      
      if (!adminData) {
        return createErrorResponse('You can only view your own applications', 403, corsHeaders);
      }
    }
    
    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    console.error('Error fetching request:', error);
    return createErrorResponse(`Failed to fetch request: ${error.message}`, 500, corsHeaders);
  }
}