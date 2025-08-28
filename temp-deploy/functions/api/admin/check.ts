import { getCorsHeaders } from '../../utils/auth';
import { createClient } from '@supabase/supabase-js';

interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
  API_KEY: string;
  ENVIRONMENT: string;
}

interface AdminCheckRequest {
  email: string;
}

export async function onRequestPost(context: {
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

    const body: AdminCheckRequest = await request.json();
    const { email } = body;

    if (!email) {
      return new Response(
        JSON.stringify({
          success: false,
          isAdmin: false,
          message: 'Email is required',
        }),
        {
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }

    // Create Supabase client with service role key for admin access
    const supabase = createClient(
      env.SUPABASE_URL,
      env.SUPABASE_SERVICE_ROLE_KEY || env.SUPABASE_ANON_KEY
    );

    // Hardcoded admin emails as fallback
    const adminEmails = [
      'sivapolisetty813@gmail.com'
    ];

    // Check if the email exists in the admins table
    const { data: adminData, error: adminError } = await supabase
      .from('admins')
      .select('*')
      .eq('email', email.toLowerCase())
      .single();

    let isAdmin = false;

    if (adminError) {
      if (adminError.code === '42P01') {
        // Table doesn't exist, use hardcoded list
        console.log('Admins table does not exist, using hardcoded list');
        isAdmin = adminEmails.includes(email.toLowerCase());
      } else if (adminError.code === 'PGRST116') {
        // No rows found, check hardcoded list as fallback
        isAdmin = adminEmails.includes(email.toLowerCase());
      } else {
        console.error('Admin check database error:', adminError);
        // Use hardcoded list as fallback
        isAdmin = adminEmails.includes(email.toLowerCase());
      }
    } else {
      // Table exists and user found
      isAdmin = !!adminData;
    }

    return new Response(
      JSON.stringify({
        success: true,
        isAdmin,
        message: isAdmin ? 'Admin access granted' : 'Not an admin user',
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    );
  } catch (error) {
    console.error('Admin check error:', error);
    
    return new Response(
      JSON.stringify({
        success: false,
        isAdmin: false,
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