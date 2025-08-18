import { validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { createServiceRoleClient, createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { 
    status: 200,
    headers: {
      ...corsHeaders,
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    }
  });
}

export async function onRequestGet(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const url = new URL(request.url);
    const customerId = url.searchParams.get('customer_id');
    const businessId = url.searchParams.get('business_id');

    const supabase = createServiceRoleClient(env);
    
    let query = supabase
      .from('orders')
      .select(`
        *,
        businesses (
          id,
          name,
          address,
          phone,
          image_url
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
      `);

    // Filter by user type and ID
    if (customerId) {
      // Get orders for a specific customer
      query = query.eq('user_id', customerId);
    } else if (businessId) {
      // Get orders for a specific business
      query = query.eq('business_id', businessId);
    } else {
      // Default: get orders for the authenticated user
      query = query.eq('user_id', auth.user.id);
    }
    
    const { data, error } = await query.order('created_at', { ascending: false });
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(data || [], corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch orders: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const orderData = await request.json();
    
    // Support both formats: flat structure (single deal) and items array (multiple items)
    let items = [];
    let businessId = orderData.business_id;
    let totalAmount = orderData.total_amount;
    
    if (orderData.items && Array.isArray(orderData.items)) {
      // Multiple items format
      if (!businessId || orderData.items.length === 0) {
        return createErrorResponse('Missing required fields: business_id and items', 400, corsHeaders);
      }
      items = orderData.items;
      
      // Calculate total amount if not provided
      if (!totalAmount) {
        totalAmount = 0;
        for (const item of items) {
          totalAmount += (item.price || 0) * (item.quantity || 1);
        }
      }
    } else if (orderData.deal_id) {
      // Single deal format (flat structure from Flutter app)
      if (!businessId) {
        return createErrorResponse('Missing required field: business_id', 400, corsHeaders);
      }
      
      // Convert flat structure to items array
      items = [{
        deal_id: orderData.deal_id,
        quantity: orderData.quantity || 1,
        price: orderData.unit_price || 0,
        notes: orderData.special_requests
      }];
      
      // Use provided total or calculate
      totalAmount = totalAmount || (orderData.unit_price || 0) * (orderData.quantity || 1);
    } else {
      return createErrorResponse('Invalid order format: must include either deal_id or items array', 400, corsHeaders);
    }

    const supabase = createServiceRoleClient(env);
    
    // Create the order
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert([{
        user_id: auth.user.id,
        business_id: businessId,
        status: 'pending',
        total_amount: totalAmount,
        delivery_address: orderData.delivery_address,
        delivery_instructions: orderData.delivery_instructions || orderData.pickup_instructions,
        payment_method: orderData.payment_method || 'cash',
        pickup_time: orderData.pickup_time || null,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();
    
    if (orderError) {
      return createErrorResponse(`Failed to create order: ${orderError.message}`, 500, corsHeaders);
    }

    // Create order items
    const orderItems = items.map((item: any) => ({
      order_id: order.id,
      deal_id: item.deal_id,
      quantity: item.quantity || 1,
      price: item.price || 0,
      notes: item.notes,
      created_at: new Date().toISOString()
    }));

    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems);
    
    if (itemsError) {
      // Rollback order if items creation fails
      await supabase.from('orders').delete().eq('id', order.id);
      return createErrorResponse(`Failed to create order items: ${itemsError.message}`, 500, corsHeaders);
    }

    // Fetch complete order with items
    const { data: completeOrder } = await supabase
      .from('orders')
      .select(`
        *,
        businesses (
          id,
          name,
          address,
          phone,
          image_url
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
      .eq('id', order.id)
      .single();

    return createSuccessResponse(completeOrder, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to create order: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestPut(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const url = new URL(request.url);
    const pathSegments = url.pathname.split('/');
    const orderId = pathSegments[pathSegments.length - 1];

    if (!orderId || orderId === 'orders') {
      return createErrorResponse('Order ID is required', 400, corsHeaders);
    }

    const updateData = await request.json();
    const supabase = createServiceRoleClient(env);

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
    // Business users can update orders for their business
    // Customers can only update their own orders (limited fields)
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
        const validStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'];
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
          image_url
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