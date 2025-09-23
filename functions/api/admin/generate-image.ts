import { validateAuth, handleCors, getCorsHeaders } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../utils/supabase.js';
import { generateFoodImage, downloadImage } from '../../services/openai-food-generator.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

// POST - Generate image for a specific food library item
export async function onRequestPost(context: { request: Request; env: Env }) {
  const { request, env } = context;
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
    const { itemId, customPrompt } = body;

    if (!itemId) {
      return createErrorResponse('itemId is required', 400, corsHeaders);
    }

    // Get OpenAI API key
    const openaiApiKey = env.OPENAI_API_KEY;
    if (!openaiApiKey) {
      return createErrorResponse('OpenAI API key not configured', 500, corsHeaders);
    }

    const supabase = getDBClient(env, 'GenerateImage');

    // Get food item from database
    const { data: foodItem, error: fetchError } = await supabase
      .from('food_library_items')
      .select('*')
      .eq('id', itemId)
      .single();

    if (fetchError || !foodItem) {
      return createErrorResponse('Food item not found', 404, corsHeaders);
    }

    // Use custom prompt if provided, otherwise use stored image_prompt, fallback to name
    const imagePrompt = customPrompt || foodItem.image_prompt || `Traditional ${foodItem.name} served in restaurant style`;

    console.log(`Generating image for: ${foodItem.name} with prompt: ${imagePrompt}`);

    // Upload function for R2 storage
    const uploadToStorage = async (buffer: Uint8Array, filename: string): Promise<{ r2Key: string, cdnUrl: string }> => {
      // @ts-ignore - R2 binding will be available at runtime
      const r2Bucket = env.FOOD_IMAGES;
      
      if (!r2Bucket) {
        throw new Error('R2 bucket not configured');
      }
      
      // Generate unique R2 key (filename already includes food-library prefix)
      const r2Key = filename;
      
      // Upload to R2
      await r2Bucket.put(r2Key, buffer, {
        httpMetadata: {
          contentType: 'image/jpeg',
        },
      });
      
      // Use custom domain for CDN
      const cdnUrl = `https://foodq-cdn.sivapolisetty813.workers.dev/${r2Key}`;
      
      return { r2Key, cdnUrl };
    };

    // Generate image
    const imageUrl = await generateFoodImage({ 
      name: foodItem.name, 
      description: foodItem.description,
      image_prompt: imagePrompt 
    }, openaiApiKey);

    // Download and upload to R2
    const imageBuffer = await downloadImage(imageUrl);
    const filename = `food-library/${itemId}-${Date.now()}.jpg`;
    const { r2Key, cdnUrl } = await uploadToStorage(imageBuffer, filename);

    // Update database with image information
    const { data: updatedItem, error: updateError } = await supabase
      .from('food_library_items')
      .update({
        image_url: imageUrl,
        r2_image_key: r2Key,
        cdn_url: cdnUrl,
        image_prompt: imagePrompt, // Store the prompt used
        updated_at: new Date().toISOString()
      })
      .eq('id', itemId)
      .select()
      .single();

    if (updateError) {
      return createErrorResponse(`Failed to update food item: ${updateError.message}`, 500, corsHeaders);
    }

    return createSuccessResponse({
      message: 'Image generated successfully',
      item: updatedItem
    }, corsHeaders);

  } catch (error: any) {
    console.error('Image generation error:', error);
    return createErrorResponse(`Image generation failed: ${error.message}`, 500, corsHeaders);
  }
}