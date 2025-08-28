import { validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';
import { getDBClient } from '../../utils/db-client.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

// GET /api/restaurant-onboarding-requests - Get all requests (admin only)
export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    // Check if user is admin
    const supabase = getDBClient(env, 'RestaurantOnboardingRequests.GET');
    
    if (!auth.isApiKeyAuth) {
      // Check if user is admin
      const { data: adminData } = await supabase
        .from('admins')
        .select('*')
        .eq('email', auth.user?.email)
        .single();
      
      if (!adminData) {
        return createErrorResponse('Admin access required', 403, corsHeaders);
      }
    }
    
    // Get all onboarding requests
    const { data, error } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }
    
    return createSuccessResponse(data || [], corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch onboarding requests: ${error.message}`, 500, corsHeaders);
  }
}

// POST /api/restaurant-onboarding-requests - Submit new request
export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }
    
    const body = await request.json();
    // Use getDBClient for database operations
    const supabase = getDBClient(env, 'RestaurantOnboardingRequests.POST');
    
    // Check if user already has a pending request
    const { data: existingRequest } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('user_id', body.user_id)
      .in('status', ['pending', 'approved'])
      .single();
    
    if (existingRequest) {
      return createErrorResponse('You already have a pending or approved application', 400, corsHeaders);
    }
    
    // Create new request
    const { data, error } = await supabase
      .from('restaurant_onboarding_requests')
      .insert([{
        ...body,
        status: 'pending',
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
    return createErrorResponse(`Failed to submit onboarding request: ${error.message}`, 500, corsHeaders);
  }
}