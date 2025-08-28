import { validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { createServiceRoleClient, createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';
import { createClient } from '@supabase/supabase-js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    // API key auth doesn't have a user, so return empty
    if (auth.isApiKeyAuth) {
      return createSuccessResponse(null, corsHeaders);
    }

    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    // Get onboarding status for authenticated user
    const { data, error } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('user_id', auth.user.id)
      .order('created_at', { ascending: false })
      .limit(1)
      .single();
    
    if (error && error.code !== 'PGRST116') { // PGRST116 = no rows found
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(data || null, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch onboarding status: ${error.message}`, 500, corsHeaders);
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

    const requestData = await request.json();
    
    // Validate required fields
    if (!requestData.restaurant_name || !requestData.restaurant_address) {
      return createErrorResponse('Missing required fields: restaurant_name and restaurant_address', 400, corsHeaders);
    }

    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    // Check if user already has a pending request
    const { data: existingRequest } = await supabase
      .from('restaurant_onboarding_requests')
      .select('id')
      .eq('user_id', auth.user.id)
      .eq('status', 'pending')
      .single();
    
    if (existingRequest) {
      return createErrorResponse('You already have a pending onboarding request', 409, corsHeaders);
    }

    // Create new onboarding request
    const { data, error } = await supabase
      .from('restaurant_onboarding_requests')
      .insert([{
        user_id: auth.user.id,
        restaurant_name: requestData.restaurant_name,
        restaurant_address: requestData.restaurant_address,
        restaurant_phone: requestData.restaurant_phone,
        restaurant_email: requestData.restaurant_email || auth.user.email,
        cuisine_type: requestData.cuisine_type,
        owner_name: requestData.owner_name,
        business_license: requestData.business_license,
        tax_id: requestData.tax_id,
        status: 'pending',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();
    
    if (error) {
      return createErrorResponse(`Failed to create onboarding request: ${error.message}`, 500, corsHeaders);
    }

    // Update user type to business_pending
    await supabase
      .from('app_users')
      .update({ 
        user_type: 'business_pending',
        updated_at: new Date().toISOString()
      })
      .eq('id', auth.user.id);

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to create onboarding request: ${error.message}`, 500, corsHeaders);
  }
}