import { validateAuth, handleCors, getCorsHeaders } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../utils/supabase.js';

/**
 * Order Verification API - Simplified Order Flow
 * POST /api/orders/verify
 * 
 * Verifies an order using QR code data or 6-character verification code
 * Only businesses can verify orders for completion
 */

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  
  // Handle CORS preflight
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;

  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');

  try {
    console.log('Order verification API called');
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = getDBClient(env, 'Orders.Verify');
    const userId = auth.user.id;
    
    const requestData = await request.json();
    console.log('Verification request data:', requestData);

    // Extract verification data
    const { verification_code, qr_data, order_id } = requestData;

    if (!verification_code && !qr_data && !order_id) {
      return createErrorResponse('Must provide verification_code, qr_data, or order_id', 400, corsHeaders);
    }

    // Get user's business to ensure they can only verify their own orders
    const { data: userData, error: userError } = await supabase
      .from('app_users')
      .select('business_id')
      .eq('id', userId)
      .single();

    if (userError || !userData?.business_id) {
      return createErrorResponse('Only business users can verify orders', 403, corsHeaders);
    }

    const userBusinessId = userData.business_id;

    // Find the order to verify
    let orderQuery = supabase
      .from('orders')
      .select(`
        *,
        businesses (
          id,
          name,
          address,
          phone
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
      .eq('business_id', userBusinessId)
      .eq('status', 'confirmed');

    // Search by verification code, QR data, or order ID
    if (verification_code) {
      orderQuery = orderQuery.eq('verification_code', verification_code.toUpperCase());
    } else if (order_id) {
      orderQuery = orderQuery.eq('id', order_id);
    } else if (qr_data) {
      // Parse QR data to get order ID
      try {
        const qrJson = typeof qr_data === 'string' ? JSON.parse(qr_data) : qr_data;
        if (qrJson.order_id) {
          orderQuery = orderQuery.eq('id', qrJson.order_id);
          // Also verify the verification code matches
          if (qrJson.verification_code && qrJson.verification_code !== verification_code) {
            return createErrorResponse('QR code verification mismatch', 400, corsHeaders);
          }
        } else {
          return createErrorResponse('Invalid QR code data', 400, corsHeaders);
        }
      } catch (e) {
        return createErrorResponse('Invalid QR code format', 400, corsHeaders);
      }
    }

    const { data: orders, error: findError } = await orderQuery;

    if (findError) {
      console.error('Find order error:', findError);
      return createErrorResponse(`Database error: ${findError.message}`, 500, corsHeaders);
    }

    if (!orders || orders.length === 0) {
      return createErrorResponse('Order not found or already completed', 404, corsHeaders);
    }

    const order = orders[0];
    console.log('Found order to verify:', order.id);

    // Update order status to completed
    const { data: updatedOrder, error: updateError } = await supabase
      .from('orders')
      .update({
        status: 'completed',
        completed_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .eq('id', order.id)
      .select(`
        *,
        businesses (
          id,
          name,
          address,
          phone
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
      console.error('Update order error:', updateError);
      return createErrorResponse(`Failed to complete order: ${updateError.message}`, 500, corsHeaders);
    }

    console.log('Order verified and completed successfully:', updatedOrder.id);

    return createSuccessResponse({
      order: updatedOrder,
      message: 'Order verified and completed successfully',
      verification_method: verification_code ? 'code' : (qr_data ? 'qr' : 'order_id')
    }, corsHeaders);

  } catch (error: any) {
    console.error('Order verification error:', error);
    return createErrorResponse(`Failed to verify order: ${error.message}`, 500, corsHeaders);
  }
}