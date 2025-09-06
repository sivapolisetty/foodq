import { getDBClient } from '../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../utils/supabase.js';
import { handleCors, getCorsHeaders } from '../../utils/auth.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');

  try {
    const supabase = getDBClient(env, 'Debug.Orders');

    // Test 1: Get basic orders data
    console.log('Testing basic orders query...');
    const { data: orders, error: ordersError } = await supabase
      .from('orders')
      .select('id, user_id, business_id, total_amount, status, created_at')
      .limit(3);
    
    if (ordersError) {
      console.error('Orders query error:', ordersError);
    }

    // Test 2: Check app_users table
    console.log('Testing app_users query...');
    const { data: users, error: usersError } = await supabase
      .from('app_users')
      .select('id, email, display_name, full_name')
      .limit(3);
    
    if (usersError) {
      console.error('Users query error:', usersError);
    }

    // Test 3: Try to find matching users for order user_ids
    let userMatches = [];
    if (orders && orders.length > 0) {
      const userIds = orders.map(order => order.user_id);
      console.log('Looking for users with IDs:', userIds);
      
      const { data: matchingUsers, error: matchError } = await supabase
        .from('app_users')
        .select('id, email, display_name, full_name')
        .in('id', userIds);
      
      if (matchError) {
        console.error('User matching error:', matchError);
      } else {
        userMatches = matchingUsers || [];
      }
    }

    // Test 4: Check if there's a direct relationship
    console.log('Testing orders with join...');
    const { data: ordersWithJoin, error: joinError } = await supabase
      .from('orders')
      .select(`
        id, 
        user_id, 
        business_id, 
        total_amount,
        app_users (
          id,
          email,
          display_name,
          full_name
        )
      `)
      .limit(2);

    return createSuccessResponse({
      debug: 'Database structure analysis',
      tests: {
        orders: {
          success: !ordersError,
          error: ordersError?.message,
          count: orders?.length || 0,
          sample: orders?.[0]
        },
        users: {
          success: !usersError,
          error: usersError?.message,
          count: users?.length || 0,
          sample: users?.[0]
        },
        userMatching: {
          searchedFor: orders?.map(o => o.user_id) || [],
          found: userMatches.length,
          matches: userMatches
        },
        joinTest: {
          success: !joinError,
          error: joinError?.message,
          result: ordersWithJoin?.[0]
        }
      }
    }, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Debug error: ${error.message}`, 500, corsHeaders);
  }
}