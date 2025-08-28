import { validateAuth, handleCors, getCorsHeaders } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../utils/supabase.js';

// Handle OPTIONS requests for CORS preflight
export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

// Handle GET requests for specific order
export async function onRequestGet(context: { request: Request; env: Env; params: { id: string } }) {
  const { request, env, params } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = getDBClient(env, 'Orders.GET_BY_ID');

    const orderId = params.id;
    if (!orderId) {
      return createErrorResponse('Order ID is required', 400, corsHeaders);
    }
    
    const { data: order, error } = await supabase
      .from('orders')
      .select(`
        *,
        businesses (
          id,
          name,
          address,
          phone,
          logo_url,
          cover_image_url
        ),
        order_items (
          *,
          deals (
            id,
            title,
            description,
            image_url
          )
        )
      `)
      .eq('id', orderId)
      .single();
    
    if (error || !order) {
      return createErrorResponse('Order not found', 404, corsHeaders);
    }

    // Fetch user's business_id from the database
    const { data: userData, error: userError } = await supabase
      .from('app_users')
      .select('business_id')
      .eq('id', auth.user.id)
      .single();

    // Check if user has permission to view this order
    const userBusinessId = userData?.business_id;
    const isBusinessOwner = userBusinessId && order.business_id === userBusinessId;
    const isCustomer = order.user_id === auth.user.id;

    if (!isBusinessOwner && !isCustomer) {
      return createErrorResponse('You do not have permission to view this order', 403, corsHeaders);
    }

    return createSuccessResponse(order, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch order: ${error.message}`, 500, corsHeaders);
  }
}

// Handle PUT requests for updating specific order
export async function onRequestPut(context: { request: Request; env: Env; params: { id: string } }) {
  const { request, env, params } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = getDBClient(env, 'Orders.PUT_BY_ID');

    const orderId = params.id;
    if (!orderId) {
      return createErrorResponse('Order ID is required', 400, corsHeaders);
    }

    const updateData = await request.json();

    // Get the order first to verify ownership/permissions
    const { data: existingOrder, error: fetchError } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (fetchError || !existingOrder) {
      return createErrorResponse('Order not found', 404, corsHeaders);
    }

    // Fetch user's business_id from the database
    const { data: userData, error: userError } = await supabase
      .from('app_users')
      .select('business_id')
      .eq('id', auth.user.id)
      .single();

    // Check if user has permission to update this order
    const userBusinessId = userData?.business_id;
    const isBusinessOwner = userBusinessId && existingOrder.business_id === userBusinessId;
    const isCustomer = existingOrder.user_id === auth.user.id;

    if (!isBusinessOwner && !isCustomer) {
      return createErrorResponse('You do not have permission to update this order', 403, corsHeaders);
    }

    // Prepare update data based on user type
    const allowedUpdates: any = {
      updated_at: new Date().toISOString()
    };

    if (isBusinessOwner) {
      // Business can update status, pickup_time, delivery_instructions
      if (updateData.status) {
        const validStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled'];
        if (validStatuses.includes(updateData.status)) {
          allowedUpdates.status = updateData.status;
        }
      }
      if (updateData.pickup_time) {
        allowedUpdates.pickup_time = updateData.pickup_time;
      }
      if (updateData.delivery_instructions !== undefined) {
        allowedUpdates.delivery_instructions = updateData.delivery_instructions;
      }
    } else if (isCustomer) {
      // Customer can only cancel their own order if it's still pending
      if (updateData.status === 'cancelled' && existingOrder.status === 'pending') {
        allowedUpdates.status = 'cancelled';
      }
    }

    // Update the order
    const { data: updatedOrder, error: updateError } = await supabase
      .from('orders')
      .update(allowedUpdates)
      .eq('id', orderId)
      .select(`
        *,
        businesses (
          id,
          name,
          address,
          phone,
          logo_url,
          cover_image_url
        ),
        order_items (
          *,
          deals (
            id,
            title,
            description,
            image_url
          )
        )
      `)
      .single();

    if (updateError) {
      return createErrorResponse(`Failed to update order: ${updateError.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(updatedOrder, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to update order: ${error.message}`, 500, corsHeaders);
  }
}

// Handle DELETE requests for cancelling specific order
export async function onRequestDelete(context: { request: Request; env: Env; params: { id: string } }) {
  const { request, env, params } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = getDBClient(env, 'Orders.DELETE_BY_ID');

    const orderId = params.id;
    if (!orderId) {
      return createErrorResponse('Order ID is required', 400, corsHeaders);
    }

    // Get the order first to verify ownership/permissions
    const { data: existingOrder, error: fetchError } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (fetchError || !existingOrder) {
      return createErrorResponse('Order not found', 404, corsHeaders);
    }

    // Fetch user's business_id from the database
    const { data: userData, error: userError } = await supabase
      .from('app_users')
      .select('business_id')
      .eq('id', auth.user.id)
      .single();

    // Check if user has permission to delete this order
    const userBusinessId = userData?.business_id;
    const isBusinessOwner = userBusinessId && existingOrder.business_id === userBusinessId;
    const isCustomer = existingOrder.user_id === auth.user.id;

    if (!isBusinessOwner && !isCustomer) {
      return createErrorResponse('You do not have permission to delete this order', 403, corsHeaders);
    }

    // Only allow cancellation if order is still pending or confirmed
    if (!['pending', 'confirmed'].includes(existingOrder.status)) {
      return createErrorResponse('Order cannot be cancelled in its current status', 400, corsHeaders);
    }

    // Update the order status to cancelled
    const { data: updatedOrder, error: updateError } = await supabase
      .from('orders')
      .update({ 
        status: 'cancelled',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)
      .select(`
        *,
        businesses (
          id,
          name,
          address,
          phone,
          logo_url,
          cover_image_url
        ),
        order_items (
          *,
          deals (
            id,
            title,
            description,
            image_url
          )
        )
      `)
      .single();

    if (updateError) {
      return createErrorResponse(`Failed to cancel order: ${updateError.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(updatedOrder, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to cancel order: ${error.message}`, 500, corsHeaders);
  }
}