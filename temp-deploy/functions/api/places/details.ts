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
    const placeId = url.searchParams.get('place_id');
    
    if (!placeId) {
      return createErrorResponse('place_id parameter is required', 400, corsHeaders);
    }

    // Use Google Places API key from environment
    const apiKey = env.GOOGLE_PLACES_API_KEY;
    if (!apiKey) {
      return createErrorResponse('Google Places API key not configured', 500, corsHeaders);
    }

    const placesUrl = new URL('https://maps.googleapis.com/maps/api/place/details/json');
    placesUrl.searchParams.set('place_id', placeId);
    placesUrl.searchParams.set('key', apiKey);
    placesUrl.searchParams.set('fields', 'formatted_address,address_components,geometry');

    console.log('Calling Google Places Details API:', placesUrl.toString().replace(apiKey, 'REDACTED'));
    
    const response = await fetch(placesUrl.toString());
    const data = await response.json();
    
    console.log('Google Places Details API response status:', data.status);
    if (data.error_message) {
      console.log('Google Places Details API error message:', data.error_message);
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
    
    if (data.status !== 'OK') {
      return createErrorResponse(
        `Google Places API error: ${data.status} - ${data.error_message || 'Unknown error'}`,
        500,
        corsHeaders
      );
    }

    // Parse address components into a structured format
    const result = data.result;
    const addressComponents = result.address_components || [];
    
    let street = '';
    let city = '';
    let state = '';
    let zipCode = '';
    let country = '';
    
    // Parse address components
    addressComponents.forEach((component: any) => {
      const types = component.types;
      
      if (types.includes('street_number')) {
        street = component.long_name + ' ';
      } else if (types.includes('route')) {
        street += component.long_name;
      } else if (types.includes('locality') || types.includes('sublocality_level_1')) {
        city = component.long_name;
      } else if (types.includes('administrative_area_level_1')) {
        state = component.short_name; // Use short name for state (e.g., "CA" instead of "California")
      } else if (types.includes('postal_code')) {
        zipCode = component.long_name;
      } else if (types.includes('country')) {
        country = component.long_name;
      }
    });

    // Create structured response
    const structuredData = {
      formatted_address: result.formatted_address,
      street: street.trim(),
      city,
      state,
      zip_code: zipCode,
      country,
      latitude: result.geometry?.location?.lat || null,
      longitude: result.geometry?.location?.lng || null,
      place_id: placeId,
      raw_data: data // Include raw data for debugging
    };

    return createSuccessResponse(structuredData, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch place details: ${error.message}`, 500, corsHeaders);
  }
}