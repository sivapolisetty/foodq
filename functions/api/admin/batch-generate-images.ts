import { validateAuth, handleCors, getCorsHeaders } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../utils/supabase.js';
import { generateFoodImage, downloadImage } from '../../services/openai-food-generator.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

// POST - Batch generate images for food library items without images
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
    const batchSize = body.batchSize || 10; // Default 10 images at a time

    // Get OpenAI API key
    const openaiApiKey = env.OPENAI_API_KEY;
    if (!openaiApiKey) {
      return createErrorResponse('OpenAI API key not configured', 500, corsHeaders);
    }

    const supabase = getDBClient(env, 'BatchGenerateImages');

    // Get food items without images (limit to batch size)
    const { data: foodItems, error: fetchError } = await supabase
      .from('food_library_items')
      .select('*')
      .is('image_url', null)
      .eq('is_active', true)
      .limit(batchSize);

    if (fetchError) {
      return createErrorResponse(`Failed to fetch food items: ${fetchError.message}`, 500, corsHeaders);
    }

    if (!foodItems || foodItems.length === 0) {
      return createSuccessResponse({
        message: 'No items found without images',
        processed: 0,
        items: []
      }, corsHeaders);
    }

    console.log(`Starting batch image generation for ${foodItems.length} items`);

    // Upload function for R2 storage
    const uploadToStorage = async (buffer: Uint8Array, filename: string): Promise<{ r2Key: string, cdnUrl: string }> => {
      // @ts-ignore - R2 binding will be available at runtime
      const r2Bucket = env.FOOD_IMAGES;
      
      if (!r2Bucket) {
        throw new Error('R2 bucket not configured');
      }
      
      const r2Key = filename;
      
      await r2Bucket.put(r2Key, buffer, {
        httpMetadata: {
          contentType: 'image/jpeg',
        },
      });
      
      const cdnUrl = `https://foodq-cdn.sivapolisetty813.workers.dev/${r2Key}`;
      return { r2Key, cdnUrl };
    };

    const results = [];
    const errors = [];

    // Process items one by one
    for (let i = 0; i < foodItems.length; i++) {
      const item = foodItems[i];
      try {
        console.log(`Processing ${i + 1}/${foodItems.length}: ${item.name}`);

        // Use stored image_prompt or generate a simple one
        const imagePrompt = item.image_prompt || `Traditional ${item.name} served in restaurant style`;

        // Generate image
        const imageUrl = await generateFoodImage({ 
          name: item.name, 
          description: item.description,
          image_prompt: imagePrompt 
        }, openaiApiKey);

        // Download and upload to R2
        const imageBuffer = await downloadImage(imageUrl);
        const filename = `food-library/${item.id}-${Date.now()}.jpg`;
        const { r2Key, cdnUrl } = await uploadToStorage(imageBuffer, filename);

        // Update database
        const { data: updatedItem, error: updateError } = await supabase
          .from('food_library_items')
          .update({
            image_url: imageUrl,
            r2_image_key: r2Key,
            cdn_url: cdnUrl,
            updated_at: new Date().toISOString()
          })
          .eq('id', item.id)
          .select()
          .single();

        if (updateError) {
          errors.push({ item: item.name, error: updateError.message });
          console.error(`Failed to update ${item.name}:`, updateError);
        } else {
          results.push(updatedItem);
          console.log(`✓ Successfully processed ${item.name}`);
        }

        // Small delay between items to respect API limits
        await new Promise(resolve => setTimeout(resolve, 2000));

      } catch (error: any) {
        errors.push({ item: item.name, error: error.message });
        console.error(`Failed to generate image for ${item.name}:`, error);
        
        // Continue with next item even if this one fails
        continue;
      }
    }

    return createSuccessResponse({
      message: `Batch processing completed`,
      processed: results.length,
      errors: errors.length,
      items: results,
      errorDetails: errors
    }, corsHeaders);

  } catch (error: any) {
    console.error('Batch image generation error:', error);
    return createErrorResponse(`Batch generation failed: ${error.message}`, 500, corsHeaders);
  }
}