/**
 * Cloudflare Pages Function: POST /api/restaurant-onboarding
 * Creates a new restaurant onboarding request
 */

interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
}

interface OnboardingRequest {
  restaurant_name: string;
  restaurant_address: string;
  phone: string;
  email: string;
  cuisine_type: string;
  description?: string;
  operating_hours?: any;
}

export async function onRequestPost(context: any): Promise<Response> {
  try {
    const { env, request } = context;

    // Get JWT token from Authorization header
    const authHeader = request.headers.get('Authorization');
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
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    const token = authHeader.substring(7);
    
    // Parse request body
    const body: OnboardingRequest = await request.json();

    // Initialize Supabase client
    const { createClient } = await import('@supabase/supabase-js');
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);

    // Set auth token for Supabase client
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Invalid authentication token',
        code: 'INVALID_TOKEN'
      }), {
        status: 401,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Check if user already has a pending request
    const { data: existingRequests, error: checkError } = await supabase
      .from('restaurant_onboarding_requests')
      .select('*')
      .eq('user_id', user.id)
      .eq('status', 'pending');

    if (checkError) {
      console.error('Error checking existing requests:', checkError);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to check existing requests',
        code: 'CHECK_ERROR'
      }), {
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    if (existingRequests && existingRequests.length > 0) {
      return new Response(JSON.stringify({
        success: false,
        error: 'You already have a pending onboarding request',
        code: 'DUPLICATE_REQUEST',
        data: {
          existing_request: existingRequests[0]
        }
      }), {
        status: 409,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Create new onboarding request
    const { data: newRequest, error: createError } = await supabase
      .from('restaurant_onboarding_requests')
      .insert({
        user_id: user.id,
        restaurant_name: body.restaurant_name,
        restaurant_address: body.restaurant_address,
        phone: body.phone,
        email: body.email,
        cuisine_type: body.cuisine_type,
        description: body.description,
        operating_hours: body.operating_hours,
        status: 'pending'
      })
      .select()
      .single();

    if (createError) {
      console.error('Error creating onboarding request:', createError);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to create onboarding request',
        code: 'CREATE_ERROR'
      }), {
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    return new Response(JSON.stringify({
      success: true,
      message: 'Onboarding request created successfully',
      data: {
        request: newRequest
      }
    }), {
      status: 201,
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
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
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
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
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    }
  });
}