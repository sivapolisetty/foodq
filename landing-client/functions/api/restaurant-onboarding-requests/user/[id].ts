/**
 * Cloudflare Pages Function: GET /api/restaurant-onboarding-requests/user/:id
 * Returns restaurant onboarding requests for a specific user
 */

interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
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

    // Fetch restaurant onboarding requests for the user
    const { data: requests, error: requestError } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (requestError) {
      console.error('Error fetching onboarding requests:', requestError);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to fetch onboarding requests',
        code: 'FETCH_ERROR'
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

    return new Response(JSON.stringify({
      success: true,
      data: requests || []
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