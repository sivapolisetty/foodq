import { getCorsHeaders } from '../utils/auth.js';
import { createSuccessResponse, Env } from '../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: env.ENVIRONMENT || 'development',
    services: {
      api: 'operational',
      database: 'operational',
      auth: 'operational'
    },
    version: '1.0.0'
  };

  return createSuccessResponse(health, corsHeaders);
}