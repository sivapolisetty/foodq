import { validateAuth, getCorsHeaders } from '../../../utils/auth.js';
import { createServiceRoleClient, createSuccessResponse, createErrorResponse, Env } from '../../../utils/supabase.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  const corsHeaders = getCorsHeaders(context.request.headers.get('Origin') || '*');
  return new Response(null, { headers: corsHeaders });
}

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
    
    // Users can only complete their own onboarding
    if (!auth.isApiKeyAuth && userId !== auth.user?.id) {
      return createErrorResponse('Access denied', 403, corsHeaders);
    }

    const supabase = createServiceRoleClient(env);
    
    // Mark user onboarding as complete
    const { data, error } = await supabase
      .from('app_users')
      .update({ 
        onboarding_completed: true,
        updated_at: new Date().toISOString()
      })
      .eq('id', userId)
      .select()
      .single();
    
    if (error) {
      return createErrorResponse(`Failed to complete onboarding: ${error.message}`, 500, corsHeaders);
    }

    // If user is a business, also update business onboarding status
    if (data.user_type === 'business' && data.business_id) {
      await supabase
        .from('businesses')
        .update({ 
          onboarding_completed: true,
          updated_at: new Date().toISOString()
        })
        .eq('id', data.business_id);
    }

    return createSuccessResponse({ 
      success: true, 
      message: 'Onboarding completed successfully',
      user: data 
    }, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to complete onboarding: ${error.message}`, 500, corsHeaders);
  }
}