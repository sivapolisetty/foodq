import { validateAuth, getCorsHeaders } from '../../utils/auth.js';
import { createServiceRoleClient, createSuccessResponse, createErrorResponse, Env } from '../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    const userData = await request.json();
    
    // Validate required fields
    if (!userData.id || !userData.email || !userData.user_type) {
      return createErrorResponse('Missing required fields: id, email, user_type', 400, corsHeaders);
    }

    // Map Flutter field names to database field names
    const mappedData = {
      id: userData.id,
      email: userData.email,
      name: userData.full_name || userData.name, // Flutter sends full_name, DB expects name
      user_type: userData.user_type,
      profile_image_url: userData.avatar_url || userData.profile_image_url, // Flutter sends avatar_url, DB expects profile_image_url
      phone: userData.phone,
      business_id: userData.business_id || null
    };

    const supabase = createServiceRoleClient(env);
    
    // Check if user already exists
    const { data: existingUser } = await supabase
      .from('app_users')
      .select('*')
      .eq('id', mappedData.id)
      .single();

    if (existingUser) {
      // User exists, update their profile
      const { data, error } = await supabase
        .from('app_users')
        .update({
          ...mappedData,
          updated_at: new Date().toISOString()
        })
        .eq('id', mappedData.id)
        .select()
        .single();
      
      if (error) {
        return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
      }

      return createSuccessResponse(data, corsHeaders);
    } else {
      // User doesn't exist, create new profile
      const { data, error } = await supabase
        .from('app_users')
        .insert([{
          ...mappedData,
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
    }
  } catch (error: any) {
    return createErrorResponse(`Failed to create/update user profile: ${error.message}`, 500, corsHeaders);
  }
}

export async function onRequestPut(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
  
  try {
    const auth = await validateAuth(request, env);
    const userData = await request.json();
    
    // For PUT, we need user ID from the auth context or from the body
    const userId = auth.user?.id || userData.id;
    
    if (!userId) {
      return createErrorResponse('User ID is required', 400, corsHeaders);
    }

    // Users can only update their own profile unless using API key
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      return createErrorResponse('Access denied: You can only update your own profile', 403, corsHeaders);
    }

    // Map Flutter field names to database field names
    const updates = {
      email: userData.email,
      name: userData.full_name || userData.name, // Flutter sends full_name, DB expects name
      user_type: userData.user_type,
      profile_image_url: userData.avatar_url || userData.profile_image_url, // Flutter sends avatar_url, DB expects profile_image_url
      phone: userData.phone,
      business_id: userData.business_id || null,
      updated_at: new Date().toISOString()
    };

    // Remove undefined values
    Object.keys(updates).forEach(key => updates[key] === undefined && delete updates[key]);

    const supabase = createServiceRoleClient(env);
    const { data, error } = await supabase
      .from('app_users')
      .update(updates)
      .eq('id', userId)
      .select()
      .single();
    
    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    if (!data) {
      return createErrorResponse('User not found', 404, corsHeaders);
    }

    return createSuccessResponse(data, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to update user profile: ${error.message}`, 500, corsHeaders);
  }
}