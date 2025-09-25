import { createClient } from '@supabase/supabase-js';
import { createE2ELogger } from './e2e-logger.js';

export interface Env {
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  SUPABASE_SERVICE_ROLE_KEY?: string;
  LOCAL_SUPABASE_URL?: string;
  LOCAL_SUPABASE_SERVICE_ROLE_KEY?: string;
  API_KEY?: string;
  ENVIRONMENT?: string;
}

export function createSupabaseClient(env: Env, useServiceRole = false) {
  const key = useServiceRole ? env.SUPABASE_SERVICE_ROLE_KEY : env.SUPABASE_ANON_KEY;
  return createClient(env.SUPABASE_URL, key);
}

export function createServiceRoleClient(env: Env) {
  // Use local Supabase for development, production Supabase for production
  if (env.ENVIRONMENT === 'local' && env.LOCAL_SUPABASE_URL && env.LOCAL_SUPABASE_SERVICE_ROLE_KEY) {
    return createClient(env.LOCAL_SUPABASE_URL, env.LOCAL_SUPABASE_SERVICE_ROLE_KEY);
  }
  
  // Production: use production Supabase
  const key = env.SUPABASE_SERVICE_ROLE_KEY;
  if (!key) {
    throw new Error('SUPABASE_SERVICE_ROLE_KEY is required');
  }
  
  return createClient(env.SUPABASE_URL, key);
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  code?: string;
}

export function createSuccessResponse<T>(data: T, headers: any = {}, request?: Request): Response {
  const response: ApiResponse<T> = {
    success: true,
    data
  };
  
  // Add E2E tracking headers if request is provided
  let responseHeaders = {
    ...headers,
    'Content-Type': 'application/json'
  };
  
  if (request) {
    const logger = createE2ELogger(request);
    responseHeaders = {
      ...responseHeaders,
      ...logger.getResponseHeaders(responseHeaders)
    };
  }
  
  return new Response(JSON.stringify(response), {
    headers: responseHeaders
  });
}

export function createErrorResponse(error: string, status = 500, headers: any = {}, request?: Request): Response {
  const response: ApiResponse = {
    success: false,
    error
  };
  
  // Add E2E tracking headers if request is provided
  let responseHeaders = {
    ...headers,
    'Content-Type': 'application/json'
  };
  
  if (request) {
    const logger = createE2ELogger(request);
    responseHeaders = {
      ...responseHeaders,
      ...logger.getResponseHeaders(responseHeaders)
    };
  }
  
  return new Response(JSON.stringify(response), {
    status,
    headers: responseHeaders
  });
}