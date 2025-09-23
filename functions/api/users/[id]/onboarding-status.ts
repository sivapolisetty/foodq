import { validateAuth, getCorsHeaders } from '../../../utils/auth.js';
import { getDBClient } from '../../../utils/db-client.js';
import { createSuccessResponse, createErrorResponse, Env } from '../../../utils/supabase.js';

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
    
    // Users can only check their own onboarding status unless using API key
    // Temporarily disabled for testing
    // if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
    //   return createErrorResponse('Access denied: You can only access your own onboarding status', 403, corsHeaders);
    // }

    const supabase = getDBClient(env, 'Users.GET_ONBOARDING_STATUS');
    
    // Get user data from app_users table
    const { data: userData, error: userError } = await supabase
      .from('app_users')
      .select('*')
      .eq('id', userId)
      .single();
    
    if (userError || !userData) {
      return createErrorResponse('User not found', 404, corsHeaders);
    }

    // Get business data if user has business_id
    let businessData = null;
    if (userData.business_id) {
      const { data: business, error: businessError } = await supabase
        .from('businesses')
        .select('*')
        .eq('id', userData.business_id)
        .single();
      
      if (businessError) {
        console.error('Business query error:', businessError);
      }
      
      businessData = business;
    }

    // Temporary fix: If user doesn't have businessData but we know they should, 
    // fetch the business by owner_id
    if (!businessData && userData.user_type === 'business') {
      const { data: business, error: businessError } = await supabase
        .from('businesses')
        .select('*')
        .eq('owner_id', userId)
        .single();
      
      if (!businessError && business) {
        businessData = business;
        
        // Update the user's business_id for future queries
        await supabase
          .from('app_users')
          .update({ business_id: business.id })
          .eq('id', userId);
      }
    }

    // Get restaurant onboarding request if exists
    let restaurantRequest = null;
    if (userData.user_type === 'business_pending' || userData.user_type === 'business') {
      const { data: request } = await supabase
        .from('restaurant_onboarding_requests')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single();
      
      restaurantRequest = request;
    }

    // Determine onboarding status in Flutter UI expected format
    const hasPendingRequest = restaurantRequest && restaurantRequest.status === 'pending';
    const isApproved = restaurantRequest && restaurantRequest.status === 'approved';
    const hasActiveBusiness = Boolean(businessData || isApproved); // Either has business record OR is approved
    
    // Determine if needs onboarding
    let needsOnboarding = true; // Default to true
    if (userData.user_type === 'customer') {
      needsOnboarding = !userData.name || !userData.email;
    } else if (userData.user_type === 'business') {
      // Business user needs onboarding only if they don't have an approved business OR completed onboarding
      // Check if they have approved restaurant request OR business with onboarding completed
      const hasApprovedRequest = isApproved && restaurantRequest;
      const hasCompletedBusiness = businessData && businessData.onboarding_completed;
      needsOnboarding = !(hasApprovedRequest || hasCompletedBusiness);
    } else if (userData.user_type === 'business_pending') {
      needsOnboarding = !restaurantRequest;
    }
    
    console.log('🔍 Debug onboarding logic:', {
      userId,
      userType: userData?.user_type,
      userBusinessId: userData?.business_id,
      hasRestaurantRequest: !!restaurantRequest,
      restaurantStatus: restaurantRequest?.status,
      restaurantId: restaurantRequest?.restaurant_id,
      hasPendingRequest,
      isApproved,
      businessData: !!businessData,
      businessDataDetails: businessData ? {
        id: businessData.id,
        name: businessData.name,
        is_approved: businessData.is_approved,
        onboarding_completed: businessData.onboarding_completed
      } : null,
      hasActiveBusiness,
      finalNeedsOnboarding: needsOnboarding
    });

    const status = {
      needs_onboarding: needsOnboarding,
      has_business: hasActiveBusiness,
      has_pending_request: hasPendingRequest,
      pending_request: hasPendingRequest ? {
        id: restaurantRequest.id,
        status: restaurantRequest.status,
        restaurant_name: restaurantRequest.restaurant_name,
        submission_date: restaurantRequest.created_at
      } : null,
      business_status: businessData ? {
        id: businessData.id,
        name: businessData.name,
        is_approved: businessData.is_approved || false,
        onboarding_completed: businessData.onboarding_completed || false,
        created_at: businessData.created_at
      } : (isApproved && restaurantRequest ? {
        // If no business record but has approved request, create a virtual business status
        id: restaurantRequest.restaurant_id || 'pending',
        name: restaurantRequest.restaurant_name,
        is_approved: true,
        onboarding_completed: true,
        created_at: restaurantRequest.updated_at
      } : null)
    };


    return createSuccessResponse(status, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch onboarding status: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestPost(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const userId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    // Users can only update their own onboarding status
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      return createErrorResponse('Access denied', 403, corsHeaders);
    }

    const { step, data } = await request.json();
    const supabase = getDBClient(env, 'Users.POST_ONBOARDING_STATUS');

    // Update based on step
    switch(step) {
      case 'complete':
        // Mark onboarding as complete
        const { error } = await supabase
          .from('app_users')
          .update({ 
            onboarding_completed: true,
            updated_at: new Date().toISOString()
          })
          .eq('id', userId);
        
        if (error) {
          return createErrorResponse(`Failed to update onboarding status: ${error.message}`, 500, corsHeaders);
        }
        
        return createSuccessResponse({ success: true, message: 'Onboarding completed' }, corsHeaders);
        
      default:
        return createErrorResponse(`Unknown onboarding step: ${step}`, 400, corsHeaders);
    }
  } catch (error: any) {
    return createErrorResponse(`Failed to update onboarding status: ${error.message}`, 500, corsHeaders);
  }
}