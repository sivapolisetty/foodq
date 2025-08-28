import { validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

// POST /api/restaurant-onboarding-requests/migrate-approved - Create business records for approved requests (admin only)
export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated && !auth.isApiKeyAuth) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }
    
    const supabase = getDBClient(env, 'RestaurantOnboarding.MIGRATE_APPROVED');
    
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
    
    // Get all approved onboarding requests that don't have a restaurant_id
    const { data: approvedRequests, error: fetchError } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('status', 'approved')
      .is('restaurant_id', null);
    
    if (fetchError) {
      return createErrorResponse(`Failed to fetch approved requests: ${fetchError.message}`, 500, corsHeaders);
    }
    
    const results = [];
    
    for (const request of approvedRequests || []) {
      try {
        // Check if business already exists for this user
        const { data: existingBusiness } = await supabase
          .from('businesses')
          .select('id')
          .eq('owner_id', request.user_id)
          .single();
        
        let businessId = existingBusiness?.id;
        let businessCreated = false;
        
        // Create business record if it doesn't exist
        if (!existingBusiness) {
          const { data: newBusiness, error: businessError } = await supabase
            .from('businesses')
            .insert([{
              owner_id: request.user_id,
              name: request.restaurant_name,
              description: request.restaurant_description || '',
              address: request.address,
              latitude: request.latitude || 0,
              longitude: request.longitude || 0,
              phone: request.owner_phone,
              email: request.owner_email,
              is_active: true
            }])
            .select()
            .single();
          
          if (businessError) {
            console.error('Error creating business for request', request.id, ':', businessError);
            results.push({
              request_id: request.id,
              restaurant_name: request.restaurant_name,
              success: false,
              error: businessError.message
            });
            continue;
          }
          
          businessId = newBusiness.id;
          businessCreated = true;
        }
        
        // Update the onboarding request to link to the business
        const { error: updateError } = await supabase
          .from('restaurant_onboarding_requests')
          .update({
            restaurant_id: businessId,
            updated_at: new Date().toISOString()
          })
          .eq('id', request.id);
        
        if (updateError) {
          console.error('Error updating request', request.id, ':', updateError);
          results.push({
            request_id: request.id,
            restaurant_name: request.restaurant_name,
            success: false,
            error: updateError.message
          });
        } else {
          results.push({
            request_id: request.id,
            restaurant_name: request.restaurant_name,
            business_id: businessId,
            business_created: businessCreated,
            success: true
          });
        }
      } catch (error: any) {
        console.error('Error processing request', request.id, ':', error);
        results.push({
          request_id: request.id,
          restaurant_name: request.restaurant_name,
          success: false,
          error: error.message
        });
      }
    }
    
    return createSuccessResponse({
      total_processed: results.length,
      successful: results.filter(r => r.success).length,
      failed: results.filter(r => !r.success).length,
      results
    }, corsHeaders);
  } catch (error: any) {
    console.error('Error in migration:', error);
    return createErrorResponse(`Migration failed: ${error.message}`, 500, corsHeaders);
  }
}