import { validateAuth, getCorsHeaders } from '../../../utils/auth.js';
import { createSuccessResponse, createErrorResponse, Env } from '../../../utils/supabase.js';
import { createClient } from '@supabase/supabase-js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

// PUT /api/restaurant-onboarding-requests/[id]/reject - Reject a request (admin only)
export async function onRequestPut(context: { request: Request; env: Env; params: { id: string } }) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const requestId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated && !auth.isApiKeyAuth) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }
    
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    // Check if user is admin (unless using API key)
    if (!auth.isApiKeyAuth) {
      const { data: adminData } = await supabase
        .from('admins')
        .select('*')
        .eq('email', auth.user?.email)
        .single();
      
      if (!adminData) {
        return createErrorResponse('Admin access required', 403, corsHeaders);
      }
    }
    
    // First, get the onboarding request details
    const { data: onboardingRequest, error: fetchError } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('id', requestId)
      .single();
    
    if (fetchError || !onboardingRequest) {
      return createErrorResponse('Request not found', 404, corsHeaders);
    }
    
    if (onboardingRequest.status === 'approved') {
      return createErrorResponse('This request has already been approved', 400, corsHeaders);
    }
    
    if (onboardingRequest.status === 'rejected') {
      return createErrorResponse('This request has already been rejected', 400, corsHeaders);
    }
    
    const body = await request.json().catch(() => ({}));
    const adminNotes = body.admin_notes || body.adminNotes || '';
    
    // Update the request status to rejected
    const { data, error } = await supabase
      .from('restaurant_onboarding_requests')
      .update({
        status: 'rejected',
        admin_notes: adminNotes,
        reviewed_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', requestId)
      .select()
      .single();
    
    if (error) {
      console.error('Database error:', error);
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }
    
    if (!data) {
      return createErrorResponse('Request not found', 404, corsHeaders);
    }
    
    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    console.error('Error rejecting request:', error);
    return createErrorResponse(`Failed to reject request: ${error.message}`, 500, corsHeaders);
  }
}