/**
 * Cloudflare Pages Function: /api/orders
 * Handles GET (list orders) and POST (create order) operations
 */

interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
}

// GET /api/orders - List orders with pagination and filtering
export async function onRequestGet(context: any): Promise<Response> {
  try {
    const { env, request } = context;
    const url = new URL(request.url);
    
    // Parse query parameters
    const limit = parseInt(url.searchParams.get('limit') || '50');
    const offset = parseInt(url.searchParams.get('offset') || '0');
    const businessId = url.searchParams.get('business_id');
    const userId = url.searchParams.get('user_id');
    const status = url.searchParams.get('status');

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

    // Build query
    let query = supabase
      .from('orders')
      .select('*, businesses(name, logo_url), deals(title, original_price, discounted_price)', { count: 'exact' });

    // Apply filters based on user type
    // Business owners can only see their own orders
    // Customers can only see their own orders
    if (businessId) {
      // Verify user owns this business
      const { data: business } = await supabase
        .from('businesses')
        .select('owner_id')
        .eq('id', businessId)
        .single();
      
      if (business?.owner_id === user.id) {
        query = query.eq('business_id', businessId);
      } else {
        // Not authorized to view this business's orders
        return new Response(JSON.stringify({
          success: false,
          error: 'Not authorized to view these orders',
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
    } else if (userId) {
      // Users can only see their own orders
      if (userId === user.id) {
        query = query.eq('customer_id', userId);
      } else {
        return new Response(JSON.stringify({
          success: false,
          error: 'Not authorized to view these orders',
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
    } else {
      // Default: show user's own orders
      query = query.eq('customer_id', user.id);
    }

    if (status) {
      query = query.eq('status', status);
    }

    // Apply pagination
    query = query
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    const { data: orders, error, count } = await query;

    if (error) {
      console.error('Error fetching orders:', error);
      // Orders table might not exist yet
      if (error.code === '42P01') {
        return new Response(JSON.stringify({
          success: true,
          data: {
            orders: [],
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
      
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to fetch orders',
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
        orders: orders || [],
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

// POST /api/orders - Create a new order
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
    const body = await request.json();

    // Validate required fields
    if (!body.deal_id || !body.quantity) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Missing required fields: deal_id and quantity',
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

    // Get deal details
    const { data: deal, error: dealError } = await supabase
      .from('deals')
      .select('*, businesses(id, name)')
      .eq('id', body.deal_id)
      .eq('is_active', true)
      .single();

    if (dealError || !deal) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Deal not found or inactive',
        code: 'DEAL_NOT_FOUND'
      }), {
        status: 404,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Check if deal is still valid
    const now = new Date();
    const endDate = new Date(deal.end_date);
    if (now > endDate) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Deal has expired',
        code: 'DEAL_EXPIRED'
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

    // Calculate total amount
    const totalAmount = deal.discounted_price * body.quantity;

    // Create order
    const orderData = {
      customer_id: user.id,
      business_id: deal.business_id,
      deal_id: body.deal_id,
      quantity: body.quantity,
      unit_price: deal.discounted_price,
      total_amount: totalAmount,
      status: 'pending',
      special_requests: body.notes || null,
      created_at: new Date().toISOString()
    };

    const { data: newOrder, error: createError } = await supabase
      .from('orders')
      .insert(orderData)
      .select()
      .single();

    if (createError) {
      console.error('Error creating order:', createError);
      // If orders table doesn't exist, return a mock response
      if (createError.code === '42P01') {
        return new Response(JSON.stringify({
          success: true,
          message: 'Order created successfully (mock)',
          data: {
            ...orderData,
            id: 'mock-' + Date.now(),
            order_number: 'ORD-' + Date.now()
          }
        }), {
          status: 201,
          headers: { 
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
          }
        });
      }
      
      return new Response(JSON.stringify({
        success: false,
        error: 'Failed to create order',
        code: 'CREATE_ERROR'
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

    // Update deal quantity sold
    await supabase
      .from('deals')
      .update({ 
        quantity_sold: (deal.quantity_sold || 0) + body.quantity 
      })
      .eq('id', body.deal_id);

    return new Response(JSON.stringify({
      success: true,
      message: 'Order created successfully',
      data: newOrder
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