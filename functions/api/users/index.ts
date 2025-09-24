import { getAuthFromRequest, verifyToken, handleCors, jsonResponse, errorResponse, validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../utils/supabase.js';
import { createE2ELogger } from '../../utils/e2e-logger.js';
import { createClient } from '@supabase/supabase-js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const logger = createE2ELogger(request, env);
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const supabase = getDBClient(env, 'Users.GET');
  logger.logRequestStart(request.method, '/api/users');

  // Get authentication token
  const token = getAuthFromRequest(request);
  if (!token) {
    logger.logAuthOperation('missing_token');
    logger.logRequestEnd(request.method, '/api/users', 401, { error: 'No token provided' });
    return errorResponse('No token provided', 401, request, env);
  }

  const authResult = await verifyToken(token, supabase, env);
  logger.logAuthOperation('verify_token', authResult?.userId);
  
  if (!authResult) {
    logger.logError('users_get_auth', new Error('Invalid token'));
    logger.logRequestEnd(request.method, '/api/users', 401, { error: 'Invalid token' });
    return errorResponse('Invalid token', 401, request, env);
  }
  
  try {
    logger.logDatabaseQuery('SELECT', 'app_users', { orderBy: 'created_at' });
    const { data, error } = await supabase
      .from('app_users')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) {
      logger.logError('users_query', error);
      logger.logRequestEnd(request.method, '/api/users', 500, { error: error.message });
      return errorResponse(`Database error: ${error.message}`, 500, request, env);
    }

    logger.logRequestEnd(request.method, '/api/users', 200, { userCount: data?.length || 0 });
    return jsonResponse(data, 200, request, env);
  } catch (error: any) {
    logger.logError('users_get', error);
    logger.logRequestEnd(request.method, '/api/users', 500, { error: error.message });
    return errorResponse(`Failed to fetch users: ${error.message}`, 500, request, env);
  }
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    const userData = await request.json();
    
    // Validate required fields
    if (!userData.name || !userData.email || !userData.user_type) {
      return createErrorResponse('Missing required fields: name, email, user_type', 400, corsHeaders);
    }

    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
    const { data, error } = await supabase
      .from('app_users')
      .insert([{
        ...userData,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();
    
    if (error) {
      if (error.code === '23505') {
        return createErrorResponse('User with this email already exists', 409, corsHeaders);
      }
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to create user: ${error.message}`, 500, corsHeaders);
  }
}