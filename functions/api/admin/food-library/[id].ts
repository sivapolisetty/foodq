import { validateAuth, handleCors, getCorsHeaders } from '../../../utils/auth.js';
import { getDBClient } from '../../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

// PUT - Update food library item
export async function onRequestPut(context: { request: Request; env: Env; params: { id: string } }) {
  const { request, env, params } = context;
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');

  try {
    // Allow API key for testing (temporary)
    const apiKey = request.headers.get('X-API-Key');
    let auth = { isAuthenticated: false, user: { id: '00000000-0000-0000-0000-000000000000' } };
    
    if (apiKey === env.API_KEY) {
      auth = { isAuthenticated: true, user: { id: '00000000-0000-0000-0000-000000000000' } };
    } else {
      auth = await validateAuth(request, env);
      if (!auth.isAuthenticated) {
        return createErrorResponse('Authentication required', 401, corsHeaders);
      }
    }

    const body = await request.json();
    const itemId = params.id;

    if (!itemId) {
      return createErrorResponse('Item ID required', 400, corsHeaders);
    }

    // Extract updateable fields
    const {
      name,
      description,
      image_prompt,
      prep_time_minutes,
      serving_size,
      base_price_range,
      tags
    } = body;

    // Build update object with only provided fields
    const updateData: any = {
      updated_at: new Date().toISOString()
    };

    if (name !== undefined) updateData.name = name;
    if (description !== undefined) updateData.description = description;
    if (image_prompt !== undefined) updateData.image_prompt = image_prompt;
    if (prep_time_minutes !== undefined) updateData.prep_time_minutes = prep_time_minutes;
    if (serving_size !== undefined) updateData.serving_size = serving_size;
    if (base_price_range !== undefined) updateData.base_price_range = base_price_range;
    if (tags !== undefined) updateData.tags = tags;

    const supabase = getDBClient(env, 'FoodLibrary.PUT');

    const { data, error } = await supabase
      .from('food_library_items')
      .update(updateData)
      .eq('id', itemId)
      .select()
      .single();

    if (error) {
      return createErrorResponse(`Update failed: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse({ 
      message: 'Item updated successfully', 
      item: data 
    }, corsHeaders);

  } catch (error: any) {
    return createErrorResponse(`Update failed: ${error.message}`, 500, corsHeaders);
  }
}

// DELETE - Soft delete item
export async function onRequestDelete(context: { request: Request; env: Env; params: { id: string } }) {
  const { request, env, params } = context;
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');

  try {
    // Allow API key for testing (temporary)
    const apiKey = request.headers.get('X-API-Key');
    let auth = { isAuthenticated: false, user: { id: '00000000-0000-0000-0000-000000000000' } };
    
    if (apiKey === env.API_KEY) {
      auth = { isAuthenticated: true, user: { id: '00000000-0000-0000-0000-000000000000' } };
    } else {
      auth = await validateAuth(request, env);
      if (!auth.isAuthenticated) {
        return createErrorResponse('Authentication required', 401, corsHeaders);
      }
    }

    const itemId = params.id;

    if (!itemId) {
      return createErrorResponse('Item ID required', 400, corsHeaders);
    }

    const supabase = getDBClient(env, 'FoodLibrary.DELETE');

    // Soft delete
    const { data, error } = await supabase
      .from('food_library_items')
      .update({ is_active: false })
      .eq('id', itemId)
      .select()
      .single();

    if (error) {
      return createErrorResponse(`Delete failed: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse({ message: 'Item deleted successfully', item: data }, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Delete failed: ${error.message}`, 500, corsHeaders);
  }
}