import { getCorsHeaders } from '../../utils/auth.js';
import { createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

export async function onRequestGet(context: { 
  request: Request; 
  env: Env; 
}) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const url = new URL(request.url);
  
  try {
    const input = url.searchParams.get('input');
    const language = url.searchParams.get('language') || 'en';
    const components = url.searchParams.get('components') || 'country:us';
    
    if (!input) {
      return createErrorResponse('Input parameter is required', 400, corsHeaders);
    }

    // Use Google Places API key from environment
    const apiKey = env.GOOGLE_PLACES_API_KEY;
    if (!apiKey) {
      return createErrorResponse('Google Places API key not configured', 500, corsHeaders);
    }

    const placesUrl = new URL('https://maps.googleapis.com/maps/api/place/autocomplete/json');
    placesUrl.searchParams.set('input', input);
    placesUrl.searchParams.set('key', apiKey);
    placesUrl.searchParams.set('language', language);
    placesUrl.searchParams.set('components', components);
    placesUrl.searchParams.set('types', 'address');

    console.log('Calling Google Places API:', placesUrl.toString().replace(apiKey, 'REDACTED'));
    
    const response = await fetch(placesUrl.toString());
    const data = await response.json();
    
    console.log('Google Places API response status:', data.status);
    if (data.error_message) {
      console.log('Google Places API error message:', data.error_message);
    }
    
    // Handle different status codes
    if (data.status === 'REQUEST_DENIED') {
      return createErrorResponse(
        `Google Places API denied: ${data.error_message || 'API key may not have Places API enabled or has restrictions'}`,
        403,
        corsHeaders
      );
    }
    
    if (data.status === 'INVALID_REQUEST') {
      return createErrorResponse(
        `Invalid request: ${data.error_message || 'Check request parameters'}`,
        400,
        corsHeaders
      );
    }
    
    if (data.status !== 'OK' && data.status !== 'ZERO_RESULTS') {
      return createErrorResponse(
        `Google Places API error: ${data.status} - ${data.error_message || 'Unknown error'}`,
        500,
        corsHeaders
      );
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch place suggestions: ${error.message}`, 500, corsHeaders);
  }
}