/**
 * Cloudflare Pages Function: GET /api/users/:id/onboarding-status
 * Returns onboarding status for a specific user
 */

interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
}

interface OnboardingStatus {
  needs_onboarding: boolean;
  pending_request?: any;
  approved_business?: any;
}

export async function onRequestGet(context: any): Promise<Response> {
  try {
    const { params, env } = context;
    const userId = params.id;

    if (!userId) {
      return new Response(JSON.stringify({
        success: false,
        error: 'User ID is required',
        code: 'MISSING_USER_ID'
      }), {
        status: 400,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Initialize Supabase client
    const { createClient } = await import('@supabase/supabase-js');
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);

    // Get JWT token from Authorization header
    const authHeader = context.request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Authorization required',
        code: 'UNAUTHORIZED'
      }), {
        status: 401,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    const token = authHeader.substring(7);
    
    // Set auth token for Supabase client
    await supabase.auth.setSession({
      access_token: token,
      refresh_token: ''
    });

    // Get user email first to query businesses table
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Invalid authentication token',
        code: 'INVALID_TOKEN'
      }), {
        status: 401,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Get user's onboarding requests to find the correct email for business lookup
    const { data: onboardingRequests, error: onboardingError } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('user_id', userId)
      .in('status', ['approved', 'pending']);

    if (onboardingError) {
      console.error('Error fetching onboarding requests:', onboardingError);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to fetch onboarding status',
        code: 'ONBOARDING_FETCH_ERROR'
      }), {
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Check if user has approved onboarding requests and corresponding business
    if (onboardingRequests && onboardingRequests.length > 0) {
      const approvedRequest = onboardingRequests.find(req => req.status === 'approved');
      const pendingRequest = onboardingRequests.find(req => req.status === 'pending');
      
      if (approvedRequest) {
        // Check if business exists for this approved request
        const { data: businesses, error: businessError } = await supabase
          .from('businesses')
          .select('*')
          .eq('email', approvedRequest.owner_email)
          .eq('is_approved', true)
          .eq('is_active', true);

        if (businessError) {
          console.error('Error fetching businesses:', businessError);
          return new Response(JSON.stringify({
            success: false,
            error: 'Failed to fetch business data',
            code: 'BUSINESS_FETCH_ERROR'
          }), {
            status: 500,
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, OPTIONS',
              'Access-Control-Allow-Headers': 'Content-Type, Authorization'
            }
          });
        }

        if (businesses && businesses.length > 0) {
          // User has approved onboarding and active business
          return new Response(JSON.stringify({
            success: true,
            data: {
              needs_onboarding: false,
              has_business: true,
              business_status: businesses[0]
            }
          }), {
            status: 200,
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, OPTIONS',
              'Access-Control-Allow-Headers': 'Content-Type, Authorization'
            }
          });
        } else {
          // User has approved onboarding but no business record yet (pending business creation)
          return new Response(JSON.stringify({
            success: true,
            data: {
              needs_onboarding: false,
              has_business: false,
              business_status: {
                status: 'approved_pending_setup',
                name: approvedRequest.restaurant_name,
                is_approved: true,
                created_at: approvedRequest.updated_at,
                restaurant_id: null
              }
            }
          }), {
            status: 200,
            headers: { 
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, OPTIONS',
              'Access-Control-Allow-Headers': 'Content-Type, Authorization'
            }
          });
        }
      } else if (pendingRequest) {
        // User has pending onboarding request
        return new Response(JSON.stringify({
          success: true,
          data: {
            needs_onboarding: false,
            has_business: false,
            business_status: {
              status: 'pending_approval',
              name: pendingRequest.restaurant_name,
              is_approved: false,
              created_at: pendingRequest.created_at,
              restaurant_id: null
            }
          }
        }), {
          status: 200,
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
          }
        });
      }
    }


    // No approved business or pending request found
    return new Response(JSON.stringify({
      success: true,
      data: {
        needs_onboarding: true,
        has_business: false
      }
    }), {
      status: 200,
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
      }
    });

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(JSON.stringify({
      success: false,
      error: 'Internal server error',
      code: 'INTERNAL_ERROR'
    }), {
      status: 500,
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
      }
    });
  }
}

export async function onRequestOptions() {
  return new Response(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    }
  });
}