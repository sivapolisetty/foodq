/**
 * Cloudflare Pages Function: /api/deals
 * Handles GET (list deals) and POST (create deal) operations
 */

interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
}

interface Deal {
  id?: string;
  business_id: string;
  title: string;
  description: string;
  original_price: number;
  discounted_price: number;
  quantity_available?: number;
  quantity_sold?: number;
  image_url?: string;
  allergen_info?: string;
  expires_at: string;
  status?: string;
  created_at?: string;
  updated_at?: string;
}

// GET /api/deals - List deals with pagination and filtering
export async function onRequestGet(context: any): Promise<Response> {
  try {
    const { env, request } = context;
    const url = new URL(request.url);
    
    // Parse query parameters
    const limit = parseInt(url.searchParams.get('limit') || '50');
    const offset = parseInt(url.searchParams.get('offset') || '0');
    const businessId = url.searchParams.get('business_id');
    const isActive = url.searchParams.get('is_active');
    const search = url.searchParams.get('search');

    // Get JWT token from Authorization header (optional for public deals listing)
    const authHeader = request.headers.get('Authorization');
    let userId = null;

    // Initialize Supabase client
    const { createClient } = await import('@supabase/supabase-js');
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);

    // If auth token provided, verify it and get user ID
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const { data: { user }, error: authError } = await supabase.auth.getUser(token);
      if (!authError && user) {
        userId = user.id;
      }
    }

    // Build query
    let query = supabase
      .from('deals')
      .select('*, businesses(name, logo_url, address, phone, email, owner_id)', { count: 'exact' });

    // Apply business filter logic
    if (businessId) {
      // Specific business requested
      console.log('Filtering by specific business ID:', businessId);
      query = query.eq('business_id', businessId);
    } else if (userId) {
      // If user is authenticated, only show their business deals by default
      console.log('User authenticated, filtering by user businesses. User ID:', userId);
      // First get businesses owned by this user
      const { data: userBusinesses } = await supabase
        .from('businesses')
        .select('id')
        .eq('owner_id', userId);
      
      console.log('User businesses found:', userBusinesses);
      
      if (userBusinesses && userBusinesses.length > 0) {
        const businessIds = userBusinesses.map(b => b.id);
        console.log('Filtering by business IDs:', businessIds);
        query = query.in('business_id', businessIds);
      } else {
        // User has no businesses, return empty result
        console.log('User has no businesses, returning empty result');
        return new Response(JSON.stringify({
          success: true,
          data: {
            deals: [],
            pagination: {
              total: 0,
              limit,
              offset,
              hasMore: false
            }
          }
        }), {
          status: 200,
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
          }
        });
      }
    } else {
      console.log('No authentication or business filter, showing all public deals');
    }
    // If no auth token and no specific business_id, show all public deals
    
    if (isActive !== null && isActive !== undefined) {
      query = query.eq('status', isActive === 'true' ? 'active' : 'inactive');
    }

    // Only show active deals by default
    if (isActive === null || isActive === undefined) {
      query = query.eq('status', 'active');
    }

    // Apply search if provided
    if (search) {
      query = query.or(`title.ilike.%${search}%,description.ilike.%${search}%`);
    }

    // Apply pagination
    query = query
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    const { data: deals, error, count } = await query;

    if (error) {
      console.error('Error fetching deals:', error);
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to fetch deals',
        code: 'FETCH_ERROR'
      }), {
        status: 500,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    return new Response(JSON.stringify({
      success: true,
      data: {
        deals: deals || [],
        pagination: {
          total: count || 0,
          limit,
          offset,
          hasMore: (count || 0) > offset + limit
        }
      }
    }), {
      status: 200,
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
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
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
      }
    });
  }
}

// POST /api/deals - Create a new deal
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
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    const token = authHeader.substring(7);
    
    // Parse request body
    const body: Deal = await request.json();

    // Validate required fields
    if (!body.business_id || !body.title || !body.description || 
        !body.original_price || !body.discounted_price ||
        !body.expires_at) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Missing required fields',
        code: 'VALIDATION_ERROR'
      }), {
        status: 400,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Initialize Supabase client
    const { createClient } = await import('@supabase/supabase-js');
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);

    // Verify user authentication
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
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Verify user owns the business
    const { data: business, error: businessError } = await supabase
      .from('businesses')
      .select('id')
      .eq('id', body.business_id)
      .eq('owner_id', user.id)
      .single();

    if (businessError || !business) {
      return new Response(JSON.stringify({
        success: false,
        error: 'You do not have permission to create deals for this business',
        code: 'FORBIDDEN'
      }), {
        status: 403,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Create the deal
    const { data: newDeal, error: createError } = await supabase
      .from('deals')
      .insert({
        business_id: body.business_id,
        title: body.title,
        description: body.description,
        original_price: body.original_price,
        discounted_price: body.discounted_price,
        quantity_available: body.quantity_available || 100, // Default to 100 if not provided
        quantity_sold: 0,
        image_url: body.image_url,
        allergen_info: body.allergen_info,
        expires_at: body.expires_at,
        status: 'active'
      })
      .select()
      .single();

    if (createError) {
      console.error('Error creating deal:', createError);
      
      // Provide specific error messages for common constraint violations
      let errorMessage = 'Failed to create deal';
      let errorCode = 'CREATE_ERROR';
      
      if (createError.message?.includes('future_expiration')) {
        errorMessage = 'Deal expiration time must be in the future';
        errorCode = 'INVALID_EXPIRATION_TIME';
      } else if (createError.message?.includes('valid_discount')) {
        errorMessage = 'Discounted price must be less than original price';
        errorCode = 'INVALID_DISCOUNT';
      } else if (createError.message?.includes('positive_original_price')) {
        errorMessage = 'Original price must be greater than 0';
        errorCode = 'INVALID_ORIGINAL_PRICE';
      } else if (createError.message?.includes('positive_discounted_price')) {
        errorMessage = 'Discounted price must be greater than 0';
        errorCode = 'INVALID_DISCOUNTED_PRICE';
      } else if (createError.message?.includes('positive_quantities')) {
        errorMessage = 'Quantities must be positive numbers';
        errorCode = 'INVALID_QUANTITIES';
      } else if (createError.message?.includes('valid_quantities')) {
        errorMessage = 'Quantity sold cannot exceed quantity available';
        errorCode = 'INVALID_QUANTITY_RELATIONSHIP';
      } else if (createError.message?.includes('deals_business_id_fkey')) {
        errorMessage = 'Invalid business ID provided';
        errorCode = 'INVALID_BUSINESS_ID';
      }
      
      return new Response(JSON.stringify({
        success: false,
        error: errorMessage,
        code: errorCode,
        details: createError.message // Include technical details for debugging
      }), {
        status: 400,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    return new Response(JSON.stringify({
      success: true,
      message: 'Deal created successfully',
      data: newDeal
    }), {
      status: 201,
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
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
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
      }
    });
  }
}

// OPTIONS handler for CORS preflight
export async function onRequestOptions() {
  return new Response(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    }
  });
}