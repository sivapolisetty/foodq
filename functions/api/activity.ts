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

    // Get real activity data from database
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    const activities = [];

    try {
      // Helper function to format time ago
      const timeAgo = (timestamp: string) => {
        const now = new Date();
        const past = new Date(timestamp);
        const diffInMs = now.getTime() - past.getTime();
        const diffInMinutes = Math.floor(diffInMs / (1000 * 60));
        const diffInHours = Math.floor(diffInMs / (1000 * 60 * 60));
        const diffInDays = Math.floor(diffInMs / (1000 * 60 * 60 * 24));

        if (diffInMinutes < 60) {
          return `${diffInMinutes} minutes ago`;
        } else if (diffInHours < 24) {
          return `${diffInHours} hours ago`;
        } else {
          return `${diffInDays} days ago`;
        }
      };

      // Get recent business registrations
      const { data: recentBusinesses, error: businessError } = await supabase
        .from('businesses')
        .select('id, name, created_at')
        .order('created_at', { ascending: false })
        .limit(5);

      if (!businessError && recentBusinesses) {
        recentBusinesses.forEach((business, index) => {
          activities.push({
            id: `business_${business.id}`,
            type: "business_registration",
            title: "New Business Registered",
            description: `${business.name} joined the platform`,
            timestamp: business.created_at,
            timeAgo: timeAgo(business.created_at),
            icon: "store"
          });
        });
      }

      // Skip orders and deals queries for now since tables don't exist or have issues

      // Get recent user signups
      const { data: recentUsers, error: userError } = await supabase
        .from('users')
        .select('id, name, created_at')
        .order('created_at', { ascending: false })
        .limit(5);

      if (!userError && recentUsers) {
        recentUsers.forEach((user) => {
          activities.push({
            id: `user_${user.id}`,
            type: "user_signup",
            title: "New User Signup",
            description: `${user.name || 'New user'} joined the community`,
            timestamp: user.created_at,
            timeAgo: timeAgo(user.created_at),
            icon: "user-plus"
          });
        });
      }

      // Get recent restaurant onboarding requests
      const { data: recentRequests, error: requestError } = await supabase
        .from('restaurant_onboarding_requests')
        .select('id, restaurant_name, status, created_at, reviewed_at')
        .order('updated_at', { ascending: false })
        .limit(5);

      if (!requestError && recentRequests) {
        recentRequests.forEach((request) => {
          if (request.status === 'pending') {
            activities.push({
              id: `request_${request.id}`,
              type: "onboarding_request",
              title: "New Onboarding Request",
              description: `${request.restaurant_name} submitted application`,
              timestamp: request.created_at,
              timeAgo: timeAgo(request.created_at),
              icon: "file-text"
            });
          } else if (request.reviewed_at) {
            activities.push({
              id: `reviewed_${request.id}`,
              type: "onboarding_reviewed",
              title: `Onboarding Request ${request.status}`,
              description: `${request.restaurant_name} application ${request.status}`,
              timestamp: request.reviewed_at,
              timeAgo: timeAgo(request.reviewed_at),
              icon: request.status === 'approved' ? "check-circle" : "x-circle"
            });
          }
        });
      }

      // Sort all activities by timestamp (most recent first)
      activities.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());

      // Return only the most recent 10 activities
      const recentActivities = activities.slice(0, 10);

      return new Response(
        JSON.stringify(recentActivities),
        {
          status: 200,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    } catch (dbError) {
      console.error('Database error in activity:', dbError);
      
      // Fallback to empty activities
      return new Response(
        JSON.stringify([]),
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
    console.error('Activity error:', error);
    
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