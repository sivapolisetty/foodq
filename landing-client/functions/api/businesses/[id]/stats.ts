/**
 * Cloudflare Pages Function: GET /api/businesses/:id/stats
 * Returns business statistics for dashboard
 */

interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
}

export async function onRequestGet(context: any): Promise<Response> {
  try {
    const { params, env, request } = context;
    const businessId = params.id;

    if (!businessId) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Business ID is required',
        code: 'MISSING_BUSINESS_ID'
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

    // Get JWT token from Authorization header (optional for stats)
    const authHeader = request.headers.get('Authorization');
    let userId = null;
    
    // Initialize Supabase client
    const { createClient } = await import('@supabase/supabase-js');
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);

    // If auth token provided, verify it
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const { data: { user }, error: authError } = await supabase.auth.getUser(token);
      if (!authError && user) {
        userId = user.id;
      }
    }

    // Get business details
    const { data: business, error: businessError } = await supabase
      .from('businesses')
      .select('*')
      .eq('id', businessId)
      .single();

    if (businessError || !business) {
      return new Response(JSON.stringify({
        success: false,
        error: 'Business not found',
        code: 'NOT_FOUND'
      }), {
        status: 404,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
      });
    }

    // Get active deals count
    const { count: activeDealsCount } = await supabase
      .from('deals')
      .select('*', { count: 'exact', head: true })
      .eq('business_id', businessId)
      .eq('status', 'active')
      .gte('expires_at', new Date().toISOString());

    // Get total deals count
    const { count: totalDealsCount } = await supabase
      .from('deals')
      .select('*', { count: 'exact', head: true })
      .eq('business_id', businessId);

    // Get deals performance (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const { data: recentDeals } = await supabase
      .from('deals')
      .select('quantity_sold, created_at')
      .eq('business_id', businessId)
      .gte('created_at', thirtyDaysAgo.toISOString());

    // Calculate total redemptions
    const totalRedemptions = recentDeals?.reduce((sum, deal) => 
      sum + (deal.quantity_sold || 0), 0) || 0;

    // Get orders count (if orders table exists)
    let ordersCount = 0;
    let recentOrdersCount = 0;
    try {
      const { count: totalOrders } = await supabase
        .from('orders')
        .select('*', { count: 'exact', head: true })
        .eq('business_id', businessId);
      
      ordersCount = totalOrders || 0;

      const { count: recentOrders } = await supabase
        .from('orders')
        .select('*', { count: 'exact', head: true })
        .eq('business_id', businessId)
        .gte('created_at', thirtyDaysAgo.toISOString());
      
      recentOrdersCount = recentOrders || 0;
    } catch (e) {
      // Orders table might not exist yet
      console.log('Orders table not available');
    }

    // Get customer count (unique users who made orders)
    let uniqueCustomers = 0;
    try {
      const { data: orders } = await supabase
        .from('orders')
        .select('customer_id')
        .eq('business_id', businessId);
      
      if (orders) {
        uniqueCustomers = new Set(orders.map(o => o.customer_id)).size;
      }
    } catch (e) {
      // Orders table might not exist yet
      console.log('Orders table not available');
    }

    // Calculate revenue (mock data for now - would come from payment integration)
    const mockRevenue = {
      today: Math.floor(Math.random() * 1000) + 500,
      thisWeek: Math.floor(Math.random() * 5000) + 2000,
      thisMonth: Math.floor(Math.random() * 20000) + 10000,
      lastMonth: Math.floor(Math.random() * 20000) + 8000,
    };

    // Prepare statistics response
    const stats = {
      business: {
        id: business.id,
        name: business.name,
        is_active: business.is_active,
        created_at: business.created_at,
      },
      deals: {
        active: activeDealsCount || 0,
        total: totalDealsCount || 0,
        redemptions_last_30_days: totalRedemptions,
      },
      orders: {
        total: ordersCount,
        last_30_days: recentOrdersCount,
      },
      customers: {
        unique_count: uniqueCustomers,
      },
      revenue: mockRevenue,
      performance: {
        conversion_rate: totalDealsCount ? (totalRedemptions / (totalDealsCount * 100)) * 100 : 0,
        avg_redemptions_per_deal: totalDealsCount ? totalRedemptions / totalDealsCount : 0,
      }
    };

    return new Response(JSON.stringify({
      success: true,
      data: stats
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

// OPTIONS handler for CORS preflight
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