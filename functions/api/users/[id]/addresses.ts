import { validateAuth, getCorsHeaders } from '../../../utils/auth.js';
import { getDBClient } from '../../../utils/db-client.js';
import { createSuccessResponse, createErrorResponse, Env } from '../../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

// GET /api/users/{id}/addresses - Get user's saved addresses
export async function onRequestGet(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const userId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    // Debug logging to understand the auth issue
    console.log('🔍 Auth Debug:', {
      requestedUserId: userId,
      authUserId: auth.user?.id,
      isApiKeyAuth: auth.isApiKeyAuth,
      isAuthenticated: auth.isAuthenticated,
      userIdsMatch: userId === auth.user?.id
    });
    
    // Users can only access their own addresses unless using API key
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      console.log('❌ Access denied - user ID mismatch');
      return createErrorResponse('Access denied: You can only access your own addresses', 403, corsHeaders);
    }

    const supabase = getDBClient(env, 'Users.GET_ADDRESSES');
    
    // Get user's saved addresses from JSONB column
    const { data: user, error } = await supabase
      .from('app_users')
      .select('saved_addresses')
      .eq('id', userId)
      .single();
    
    if (error) {
      console.error('Database error:', error);
      return createErrorResponse('Failed to fetch addresses', 500, corsHeaders);
    }

    const savedAddresses = user?.saved_addresses || { addresses: [], primary_address: null };
    
    return createSuccessResponse({
      addresses: savedAddresses.addresses || [],
      primary_address: savedAddresses.primary_address || null
    }, corsHeaders);
  } catch (error: any) {
    console.error('Error fetching addresses:', error);
    return createErrorResponse(`Failed to fetch addresses: ${error.message}`, 500, corsHeaders);
  }
}

// POST /api/users/{id}/addresses - Save/update user's address
export async function onRequestPost(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const userId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    // Users can only update their own addresses unless using API key
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      return createErrorResponse('Access denied: You can only update your own addresses', 403, corsHeaders);
    }

    const body = await request.json();
    const {
      formatted_address,
      street,
      city,
      state,
      zip_code,
      country,
      latitude,
      longitude,
      place_id,
      is_primary = true, // Default to primary address
      address_type = 'takeaway' // Default type
    } = body;

    if (!formatted_address) {
      return createErrorResponse('Formatted address is required', 400, corsHeaders);
    }

    const supabase = getDBClient(env, 'Users.POST_ADDRESS');
    
    // Get current user's saved addresses
    const { data: user, error: fetchError } = await supabase
      .from('app_users')
      .select('saved_addresses')
      .eq('id', userId)
      .single();
    
    if (fetchError) {
      throw fetchError;
    }

    const currentSavedAddresses = user?.saved_addresses || { addresses: [], primary_address: null };
    const addresses = currentSavedAddresses.addresses || [];

    // Create new address object
    const newAddress = {
      id: `addr_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      formatted_address,
      street: street || '',
      city: city || '',
      state: state || '',
      zip_code: zip_code || '',
      country: country || 'US',
      latitude: latitude || null,
      longitude: longitude || null,
      place_id: place_id || null,
      is_primary,
      address_type,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    // Check if address already exists
    const existingIndex = addresses.findIndex(addr => 
      addr.formatted_address === formatted_address
    );

    let updatedAddresses;
    let message;

    if (existingIndex >= 0) {
      // Update existing address
      updatedAddresses = [...addresses];
      updatedAddresses[existingIndex] = {
        ...updatedAddresses[existingIndex],
        ...newAddress,
        id: updatedAddresses[existingIndex].id, // Keep original ID
        created_at: updatedAddresses[existingIndex].created_at // Keep original created_at
      };
      message = 'Address updated successfully';
    } else {
      // Add new address
      updatedAddresses = [...addresses, newAddress];
      message = 'Address saved successfully';
    }

    // If this is being set as primary, unset other primary addresses
    if (is_primary) {
      updatedAddresses = updatedAddresses.map(addr => ({
        ...addr,
        is_primary: addr.id === newAddress.id || addr.id === updatedAddresses[existingIndex >= 0 ? existingIndex : updatedAddresses.length - 1].id
      }));
    }

    // Update primary address reference
    const primaryAddress = updatedAddresses.find(addr => addr.is_primary);
    const primaryAddressRef = primaryAddress ? {
      id: primaryAddress.id,
      formatted_address: primaryAddress.formatted_address,
      latitude: primaryAddress.latitude,
      longitude: primaryAddress.longitude
    } : null;

    const newSavedAddresses = {
      addresses: updatedAddresses,
      primary_address: primaryAddressRef
    };

    // Update user's saved addresses
    const { data: updatedUser, error: updateError } = await supabase
      .from('app_users')
      .update({ saved_addresses: newSavedAddresses })
      .eq('id', userId)
      .select('saved_addresses')
      .single();

    if (updateError) {
      throw updateError;
    }

    const resultAddress = existingIndex >= 0 
      ? updatedAddresses[existingIndex] 
      : updatedAddresses[updatedAddresses.length - 1];

    console.log('Address saved successfully:', resultAddress);
    return createSuccessResponse({
      address: resultAddress,
      message
    }, corsHeaders);

  } catch (error: any) {
    console.error('Error saving address:', error);
    return createErrorResponse(`Failed to save address: ${error.message}`, 500, corsHeaders);
  }
}

// DELETE /api/users/{id}/addresses/{addressId} - Delete a specific address
export async function onRequestDelete(context: { 
  request: Request; 
  env: Env; 
  params: { id: string } 
}) {
  const { request, env, params } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  const userId = params.id;
  
  try {
    const auth = await validateAuth(request, env);
    
    // Users can only delete their own addresses unless using API key
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      return createErrorResponse('Access denied: You can only delete your own addresses', 403, corsHeaders);
    }

    const url = new URL(request.url);
    const pathParts = url.pathname.split('/');
    const addressId = pathParts[pathParts.length - 1];

    if (!addressId) {
      return createErrorResponse('Address ID is required', 400, corsHeaders);
    }

    const supabase = getDBClient(env, 'Users.DELETE_ADDRESS');
    
    // Get current user's saved addresses
    const { data: user, error: fetchError } = await supabase
      .from('app_users')
      .select('saved_addresses')
      .eq('id', userId)
      .single();
    
    if (fetchError) {
      throw fetchError;
    }

    const currentSavedAddresses = user?.saved_addresses || { addresses: [], primary_address: null };
    const addresses = currentSavedAddresses.addresses || [];

    // Find the address to delete
    const addressIndex = addresses.findIndex(addr => addr.id === addressId);
    
    if (addressIndex === -1) {
      return createErrorResponse('Address not found', 404, corsHeaders);
    }

    const deletedAddress = addresses[addressIndex];
    const updatedAddresses = addresses.filter(addr => addr.id !== addressId);

    // Update primary address if the deleted address was primary
    let primaryAddressRef = currentSavedAddresses.primary_address;
    if (deletedAddress.is_primary && updatedAddresses.length > 0) {
      // Set first remaining address as primary
      updatedAddresses[0].is_primary = true;
      primaryAddressRef = {
        id: updatedAddresses[0].id,
        formatted_address: updatedAddresses[0].formatted_address,
        latitude: updatedAddresses[0].latitude,
        longitude: updatedAddresses[0].longitude
      };
    } else if (deletedAddress.is_primary) {
      primaryAddressRef = null;
    }

    const newSavedAddresses = {
      addresses: updatedAddresses,
      primary_address: primaryAddressRef
    };

    // Update user's saved addresses
    const { error: updateError } = await supabase
      .from('app_users')
      .update({ saved_addresses: newSavedAddresses })
      .eq('id', userId);

    if (updateError) {
      throw updateError;
    }

    return createSuccessResponse({
      message: 'Address deleted successfully',
      deleted_address: deletedAddress
    }, corsHeaders);

  } catch (error: any) {
    console.error('Error deleting address:', error);
    return createErrorResponse(`Failed to delete address: ${error.message}`, 500, corsHeaders);
  }
}