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
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const url = new URL(request.url);
    const status = url.searchParams.get('status');
    const userId = url.searchParams.get('user_id');
    const limit = url.searchParams.get('limit');

    const supabase = createServiceRoleClient(env);
    let query = supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .order('created_at', { ascending: false });

    // Apply filters
    if (status) {
      query = query.eq('status', status);
    }
    
    if (userId && (auth.isApiKeyAuth || userId === auth.user?.id)) {
      query = query.eq('user_id', userId);
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
    return createErrorResponse(`Failed to fetch restaurant onboarding requests: ${error.message}`, 500, corsHeaders);
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
    const supabase = createServiceRoleClient(env);
    
    // Handle admin actions (approve/reject)
    if (requestData.action && requestData.requestId) {
      const { action, requestId } = requestData;
      
      if (action !== 'approve' && action !== 'reject') {
        return createErrorResponse('Invalid action. Must be "approve" or "reject"', 400, corsHeaders);
      }

      // Update the request status
      const { data, error } = await supabase
        .from('restaurant_onboarding_requests')
        .update({
          status: action === 'approve' ? 'approved' : 'rejected',
          reviewed_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .eq('id', requestId)
        .select()
        .single();
      
      if (error) {
        return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
      }

      if (!data) {
        return createErrorResponse('Request not found', 404, corsHeaders);
      }

      // If approved, create a business record
      if (action === 'approve' && data) {
        const businessData = {
          name: data.restaurant_name,
          description: data.restaurant_description || '',
          cuisine_type: data.cuisine_type,
          address: data.address,
          latitude: data.latitude,
          longitude: data.longitude,
          phone: data.owner_phone,
          email: data.owner_email,
          business_license: data.business_license,
          image_url: data.restaurant_photo_url,
          owner_id: data.user_id,
          is_approved: true,
          onboarding_completed: true,
          postal_code: data.zip_code,
          zip_code: data.zip_code,
          category: data.cuisine_type,
          is_active: true,
          rating: 0,
          total_reviews: 0,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };

        const { data: businessRecord, error: businessError } = await supabase
          .from('businesses')
          .insert([businessData])
          .select()
          .single();

        if (businessError) {
          console.error('Error creating business record:', businessError);
          // Don't fail the approval if business creation fails
        } else {
          // Update the onboarding request with the business ID
          await supabase
            .from('restaurant_onboarding_requests')
            .update({ restaurant_id: businessRecord.id })
            .eq('id', requestId);
          
          console.log('Business record created successfully:', businessRecord.id);
        }
      }

      return createSuccessResponse({
        success: true,
        message: `Request ${action}d successfully`,
        data
      }, corsHeaders);
    }
    
    // Handle creating new requests
    if (!requestData.restaurant_name || !requestData.user_id) {
      return createErrorResponse('Missing required fields: restaurant_name, user_id', 400, corsHeaders);
    }

    // Users can only create requests for themselves unless using API key
    if (!auth.isApiKeyAuth && requestData.user_id !== auth.user?.id) {
      return createErrorResponse('Access denied: You can only create requests for yourself', 403, corsHeaders);
    }

    const { data, error } = await supabase
      .from('restaurant_onboarding_requests')
      .insert([{
        ...requestData,
        status: requestData.status || 'pending',
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
    return createErrorResponse(`Failed to process restaurant onboarding request: ${error.message}`, 500, corsHeaders);
  }
}