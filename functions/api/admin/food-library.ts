import { validateAuth, handleCors, getCorsHeaders } from '../../utils/auth.js';
import { getDBClient } from '../../utils/db-client.js';
import { Env, createSuccessResponse, createErrorResponse } from '../../utils/supabase.js';
import { 
  generateCompleteFoodItem, 
  generateFoodDataOnly,
  batchGenerateFoodItems,
  batchGenerateFoodDataOnly,
  generateFoodData,
  generateFoodImage,
  downloadImage
} from '../../services/openai-food-generator.js';
import { indianCuisineList } from '../../data/indian-cuisine-list.js';

export async function onRequestOptions(context: { request: Request; env: Env }) {
  return handleCors(context.request, context.env);
}

// GET - Fetch all food library items
export async function onRequestGet(context: { request: Request; env: Env }) {
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

    const supabase = getDBClient(env, 'FoodLibrary.GET');
    const url = new URL(request.url);
    
    // Search parameters
    const search = url.searchParams.get('search');
    const tags = url.searchParams.get('tags')?.split(',').filter(Boolean);
    const limit = parseInt(url.searchParams.get('limit') || '50');
    const offset = parseInt(url.searchParams.get('offset') || '0');

    let query = supabase
      .from('food_library_items')
      .select('*')
      .eq('is_active', true)
      .order('usage_count', { ascending: false })
      .limit(limit)
      .range(offset, offset + limit - 1);

    // Apply search filter
    if (search) {
      query = query.ilike('name', `%${search}%`);
    }

    // Apply tag filters (PostgreSQL array operations)
    if (tags && tags.length > 0) {
      query = query.contains('tags', tags);
    }

    const { data, error } = await query;

    if (error) {
      return createErrorResponse(`Database error: ${error.message}`, 500, corsHeaders);
    }

    return createSuccessResponse(data || [], corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Failed to fetch food library: ${error.message}`, 500, corsHeaders);
  }
}

// POST - Generate new food item or batch generate
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

    // Check if user is admin (you may want to add proper admin check)
    const supabase = getDBClient(env, 'FoodLibrary.POST');
    const body = await request.json();
    
    // Get OpenAI API key from environment
    const openaiApiKey = env.OPENAI_API_KEY;
    if (!openaiApiKey) {
      return createErrorResponse('OpenAI API key not configured', 500, corsHeaders);
    }

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
      const cdnUrl = `https://cdn.foodqapp.com/${r2Key}`;
      
      return { r2Key, cdnUrl };
    };

    // Single item generation
    if (body.prompt) {
      console.log(`Generating single item: ${body.prompt}`);
      
      // Check if user wants data only or complete generation
      const dataOnly = body.dataOnly === true;
      
      let foodItem;
      if (dataOnly) {
        foodItem = await generateFoodDataOnly(body.prompt, openaiApiKey);
      } else {
        foodItem = await generateCompleteFoodItem(body.prompt, openaiApiKey, uploadToStorage);
      }

      // Save to database
      const { data, error } = await supabase
        .from('food_library_items')
        .insert({
          ...foodItem,
          created_by_admin_id: auth.user.id
        })
        .select()
        .single();

      if (error) {
        return createErrorResponse(`Failed to save food item: ${error.message}`, 500, corsHeaders);
      }

      return createSuccessResponse(data, corsHeaders);
    }

    // Batch generation
    if (body.batch === true) {
      const prompts = body.prompts || indianCuisineList.slice(0, body.count || 50);
      const dataOnly = body.dataOnly === true;
      console.log(`Starting ${dataOnly ? 'data-only' : 'complete'} batch generation for ${prompts.length} items`);

      let results;
      if (dataOnly) {
        results = await batchGenerateFoodDataOnly(
          prompts,
          openaiApiKey,
          (current, total, item) => {
            console.log(`Progress: ${current}/${total} - ${item?.name || 'Processing...'}`);
          }
        );
      } else {
        results = await batchGenerateFoodItems(
          prompts,
          openaiApiKey,
          uploadToStorage,
          (current, total, item) => {
            console.log(`Progress: ${current}/${total} - ${item?.name || 'Processing...'}`);
          }
        );
      }

      // Save all to database
      const itemsToInsert = results.map(item => ({
        ...item,
        created_by_admin_id: auth.user.id
      }));

      const { data, error } = await supabase
        .from('food_library_items')
        .insert(itemsToInsert)
        .select();

      if (error) {
        return createErrorResponse(`Failed to save batch items: ${error.message}`, 500, corsHeaders);
      }

      return createSuccessResponse({
        message: `Successfully generated ${data.length} items`,
        items: data
      }, corsHeaders);
    }

    return createErrorResponse('Invalid request. Provide "prompt" for single item or "batch: true" for batch generation', 400, corsHeaders);
  } catch (error: any) {
    console.error('Food library generation error:', error);
    return createErrorResponse(`Generation failed: ${error.message}`, 500, corsHeaders);
  }
}

// PUT - Update/Regenerate existing item
export async function onRequestPut(context: { request: Request; env: Env }) {
  const { request, env } = context;
  const corsResponse = handleCors(request, env);
  if (corsResponse) return corsResponse;
  const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');

  try {
    const auth = await validateAuth(request, env);
    if (!auth.isAuthenticated) {
      return createErrorResponse('Authentication required', 401, corsHeaders);
    }

    const supabase = getDBClient(env, 'FoodLibrary.PUT');
    const url = new URL(request.url);
    const itemId = url.pathname.split('/').pop();
    const body = await request.json();

    if (!itemId) {
      return createErrorResponse('Item ID required', 400, corsHeaders);
    }

    // Manual update (no AI)
    if (body.manual) {
      const { data, error } = await supabase
        .from('food_library_items')
        .update({
          name: body.name,
          description: body.description,
          prep_time_minutes: body.prep_time_minutes,
          serving_size: body.serving_size,
          base_price_range: body.base_price_range,
          tags: body.tags,
          updated_at: new Date().toISOString()
        })
        .eq('id', itemId)
        .select()
        .single();

      if (error) {
        return createErrorResponse(`Update failed: ${error.message}`, 500, corsHeaders);
      }

      return createSuccessResponse(data, corsHeaders);
    }

    // Regenerate with AI
    if (body.regenerate) {
      const openaiApiKey = env.OPENAI_API_KEY;
      if (!openaiApiKey) {
        return createErrorResponse('OpenAI API key not configured', 500, corsHeaders);
      }

      const prompt = body.prompt || body.name;
      console.log(`Regenerating item with prompt: ${prompt}`);

      // Generate new data
      const foodData = await generateFoodData(prompt, openaiApiKey);
      
      let updateData: any = {
        ...foodData,
        ai_prompt_used: prompt,
        updated_at: new Date().toISOString()
      };

      // Regenerate image if requested
      if (body.regenerateImage) {
        const imageUrl = await generateFoodImage(foodData, openaiApiKey);
        const imageBuffer = await downloadImage(imageUrl);
        
        const filename = `food-library/${itemId}-${Date.now()}.jpg`;
        const uploadToStorageForRegen = async (buffer: Uint8Array, filename: string): Promise<{ r2Key: string, cdnUrl: string }> => {
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
          
          // Generate CDN URL using custom domain
          const cdnUrl = `https://cdn.foodqapp.com/${r2Key}`;
          
          return { r2Key, cdnUrl };
        };

        const { r2Key, cdnUrl } = await uploadToStorageForRegen(imageBuffer, filename);
        updateData.image_url = imageUrl;
        updateData.r2_image_key = r2Key;
        updateData.cdn_url = cdnUrl;
      }

      // Update in database
      const { data, error } = await supabase
        .from('food_library_items')
        .update(updateData)
        .eq('id', itemId)
        .select()
        .single();

      if (error) {
        return createErrorResponse(`Regeneration failed: ${error.message}`, 500, corsHeaders);
      }

      return createSuccessResponse(data, corsHeaders);
    }

    return createErrorResponse('Invalid update request', 400, corsHeaders);
  } catch (error: any) {
    return createErrorResponse(`Update failed: ${error.message}`, 500, corsHeaders);
  }
}

// DELETE - Soft delete item
export async function onRequestDelete(context: { request: Request; env: Env }) {
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

    const supabase = getDBClient(env, 'FoodLibrary.DELETE');
    const url = new URL(request.url);
    const itemId = url.pathname.split('/').pop();

    if (!itemId) {
      return createErrorResponse('Item ID required', 400, corsHeaders);
    }

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