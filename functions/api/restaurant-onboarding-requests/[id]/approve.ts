import { validateAuth, getCorsHeaders } from '../../../utils/auth.js';
import { getDBClient } from '../../../utils/db-client.js';
import { createSuccessResponse, createErrorResponse, Env } from '../../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

// PUT /api/restaurant-onboarding-requests/[id]/approve - Approve a request (admin only)
export async function onRequestPut(context: { request: Request; env: Env; params: { id: string } }) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const requestId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated && !auth.isApiKeyAuth) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }
    
    const supabase = getDBClient(env, 'RestaurantOnboarding.APPROVE');
    
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
    
    const body = await request.json().catch(() => ({}));
    const adminNotes = body.admin_notes || body.adminNotes || '';
    
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
    
    // Check if business already exists for this user
    const { data: existingBusiness } = await supabase
      .from('businesses')
      .select('id')
      .eq('owner_id', onboardingRequest.user_id)
      .single();
    
    let businessId = existingBusiness?.id;
    
    // Create business record if it doesn't exist
    if (!existingBusiness) {
      const { data: newBusiness, error: businessError } = await supabase
        .from('businesses')
        .insert([{
          owner_id: onboardingRequest.user_id,
          name: onboardingRequest.restaurant_name,
          description: onboardingRequest.restaurant_description || '',
          address: onboardingRequest.address,
          latitude: onboardingRequest.latitude || 0,
          longitude: onboardingRequest.longitude || 0,
          phone: onboardingRequest.owner_phone,
          email: onboardingRequest.owner_email,
          is_active: true,
          is_approved: true,
          onboarding_completed: true
        }])
        .select()
        .single();
      
      if (businessError) {
        console.error('Error creating business:', businessError);
        return createErrorResponse(`Failed to create business: ${businessError.message}`, 500, corsHeaders);
      }
      
      businessId = newBusiness.id;
    } else {
      // Update existing business to mark as approved and onboarding completed
      await supabase
        .from('businesses')
        .update({
          name: onboardingRequest.restaurant_name,
          description: onboardingRequest.restaurant_description || '',
          address: onboardingRequest.address,
          latitude: onboardingRequest.latitude || 0,
          longitude: onboardingRequest.longitude || 0,
          phone: onboardingRequest.owner_phone,
          email: onboardingRequest.owner_email,
          is_active: true,
          is_approved: true,
          onboarding_completed: true,
          updated_at: new Date().toISOString()
        })
        .eq('id', businessId);
    }
    
    // Update user's business_id and type
    await supabase
      .from('app_users')
      .update({ 
        business_id: businessId,
        user_type: 'business',
        updated_at: new Date().toISOString()
      })
      .eq('id', onboardingRequest.user_id);
    
    // Update the request status to approved and link to business
    const { data: approvedRequest, error: updateError } = await supabase
      .from('restaurant_onboarding_requests')
      .update({
        status: 'approved',
        admin_notes: adminNotes,
        restaurant_id: businessId,
        reviewed_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', requestId)
      .select()
      .single();
    
    if (updateError) {
      console.error('Database error:', updateError);
      return createErrorResponse(`Database error: ${updateError.message}`, 500, corsHeaders);
    }
    
    return createSuccessResponse({
      ...approvedRequest,
      business_created: !existingBusiness,
      business_id: businessId
    }, corsHeaders);
  } catch (error: any) {
    console.error('Error approving request:', error);
    return createErrorResponse(`Failed to approve request: ${error.message}`, 500, corsHeaders);
  }
}