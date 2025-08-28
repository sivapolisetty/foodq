import { getCorsHeaders, validateAuth } from '../utils/auth';
import { createClient } from '@supabase/supabase-js';

interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
  API_KEY: string;
  ENVIRONMENT: string;
}

export async function onRequestGet(context: {
  request: Request;
  env: Env;
}): Promise<Response> {
  const { request, env } = context;
  const origin = request.headers.get('Origin');
  const corsHeaders = getCorsHeaders(origin);

  try {
    // Handle preflight CORS request
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 200,
        headers: corsHeaders,
      });
    }

    // Validate authentication
    const auth = await validateAuth(request, env);
    if (!auth.isAuthenticated) {
      return new Response(
        JSON.stringify({
          success: false,
          message: 'Authentication required',
        }),
        {
          status: 401,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }

    // Get real stats from database
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    
    try {
      // Get total users count
      const { count: totalUsers, error: usersError } = await supabase
        .from('users')
        .select('*', { count: 'exact', head: true });
      
      if (usersError) {
        console.error('Error fetching users count:', usersError);
      }

      // Get total businesses count
      const { count: totalBusinesses, error: businessesError } = await supabase
        .from('businesses')
        .select('*', { count: 'exact', head: true });
      
      if (businessesError) {
        console.error('Error fetching businesses count:', businessesError);
      }

      // Orders table doesn't exist yet, set to 0
      const totalOrders = 0;
      const totalRevenue = 0;

      // Get pending onboarding requests count
      const { count: pendingRequests, error: requestsError } = await supabase
        .from('restaurant_onboarding_requests')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'pending');
      
      if (requestsError) {
        console.error('Error fetching pending requests:', requestsError);
      }

      const stats = {
        totalUsers: (totalUsers || 0).toLocaleString(),
        userGrowth: "+0%", // You can calculate this based on date ranges if needed
        totalBusinesses: (totalBusinesses || 0).toLocaleString(),
        businessGrowth: "+0%",
        totalOrders: (totalOrders || 0).toLocaleString(),
        orderGrowth: "+0%",
        totalRevenue: `$${totalRevenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
        revenueGrowth: "+0%",
        pendingOnboardingRequests: (pendingRequests || 0).toLocaleString()
      };

      return new Response(
        JSON.stringify(stats),
        {
          status: 200,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    } catch (dbError) {
      console.error('Database error in stats:', dbError);
      
      // Fallback to basic stats
      const fallbackStats = {
        totalUsers: "0",
        userGrowth: "+0%",
        totalBusinesses: "0",
        businessGrowth: "+0%",
        totalOrders: "0",
        orderGrowth: "+0%",
        totalRevenue: "$0.00",
        revenueGrowth: "+0%",
        pendingOnboardingRequests: "0"
      };

      return new Response(
        JSON.stringify(fallbackStats),
        {
          status: 200,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }
  } catch (error) {
    console.error('Stats error:', error);
    
    return new Response(
      JSON.stringify({
        success: false,
        message: 'Internal server error',
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    );
  }
}

// Handle OPTIONS request for CORS preflight
export async function onRequestOptions(context: {
  request: Request;
  env: Env;
}): Promise<Response> {
  const { request } = context;
  const origin = request.headers.get('Origin');
  const corsHeaders = getCorsHeaders(origin);
  
  return new Response(null, {
    status: 200,
    headers: corsHeaders,
  });
}