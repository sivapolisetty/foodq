import OpenAI from 'openai';
import { v4 as uuidv4 } from 'uuid';

// OpenAI client initialization
const initOpenAI = (apiKey: string) => {
  return new OpenAI({
    apiKey: apiKey,
  });
};

// Food item structure
interface FoodLibraryItem {
  id?: string;
  name: string;
  description: string;
  image_url?: string;
  image_prompt?: string;
  r2_image_key?: string;
  cdn_url?: string;
  prep_time_minutes: number;
  serving_size: string;
  base_price_range: string;
  tags: string[];
  ai_prompt_used?: string;
}

// Generate comprehensive food data using GPT-4
export async function generateFoodData(prompt: string, apiKey: string): Promise<FoodLibraryItem> {
  const openai = initOpenAI(apiKey);
  
  const systemPrompt = `You are an expert on Indian cuisine with deep knowledge of regional dishes, cooking methods, and restaurant operations in India. 
  Generate detailed, accurate food information for restaurant menus in India.
  
  Return a JSON object with these exact fields:
  - name: Proper food name in title case (be specific, e.g., "Hyderabadi Chicken Biryani" not just "Biryani")
  - description: Rich 2-3 sentence description focusing on ingredients, preparation method, taste profile, and what makes it special
  - image_prompt: Simple, realistic prompt for food photography (e.g., "Traditional Butter Chicken served in copper bowl with naan bread")
  - prep_time_minutes: Realistic cooking/preparation time (integer)
  - serving_size: Typical serving description (e.g., "1 plate", "serves 2-3", "4-5 pieces")
  - base_price_range: Realistic price range in INR for mid-range restaurants (e.g., "₹180-250")
  - tags: Array of 5-8 relevant tags from these categories:
    * Cuisine: north-indian, south-indian, bengali, punjabi, gujarati, rajasthani, kerala, goan, maharashtrian, etc.
    * Dietary: vegetarian, non-vegetarian, vegan, jain, gluten-free, dairy-free
    * Spice: mild, medium-spicy, spicy, extra-spicy
    * Protein: chicken, mutton, fish, prawns, egg, paneer, dal, soya
    * Course: appetizer, main-course, dessert, beverage, snack, breakfast
    * Method: tandoor, curry, grilled, fried, steamed, roasted, raw
    * Special: bestseller, healthy, kid-friendly, festive, street-food`;

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4-turbo-preview",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: `Generate comprehensive food data for: ${prompt}` }
      ],
      temperature: 0.7,
      response_format: { type: "json_object" }
    });

    const foodData = JSON.parse(completion.choices[0].message.content || '{}');
    return {
      ...foodData,
      ai_prompt_used: prompt
    };
  } catch (error) {
    console.error('Error generating food data:', error);
    throw new Error(`Failed to generate food data: ${error.message}`);
  }
}

// Generate food image using DALL-E 3
export async function generateFoodImage(foodItem: FoodLibraryItem, apiKey: string): Promise<string> {
  const openai = initOpenAI(apiKey);
  
  const imagePrompt = `Professional food photography of ${foodItem.name}. ${foodItem.description}
  Style: Appetizing restaurant presentation, traditional Indian serving style, vibrant colors, garnished beautifully, 
  bright natural lighting, shot from 45-degree angle, shallow depth of field, high-quality commercial food photography.
  Setting: Served on appropriate traditional dishware with authentic garnishes and accompaniments.`;

  try {
    const response = await openai.images.generate({
      model: "dall-e-3",
      prompt: imagePrompt,
      n: 1,
      size: "1024x1024",
      quality: "hd",
      style: "natural"
    });

    return response.data[0].url || '';
  } catch (error) {
    console.error('Error generating food image:', error);
    throw new Error(`Failed to generate image: ${error.message}`);
  }
}

// Download image from URL and prepare for CDN upload
export async function downloadImage(imageUrl: string): Promise<Uint8Array> {
  try {
    const response = await fetch(imageUrl);
    if (!response.ok) {
      throw new Error(`Failed to download image: ${response.statusText}`);
    }
    const arrayBuffer = await response.arrayBuffer();
    return new Uint8Array(arrayBuffer);
  } catch (error) {
    console.error('Error downloading image:', error);
    throw new Error(`Failed to download image: ${error.message}`);
  }
}

// Generate food data only (no image)
export async function generateFoodDataOnly(
  prompt: string, 
  apiKey: string
): Promise<FoodLibraryItem> {
  try {
    console.log(`Generating food data for: ${prompt}`);
    const foodData = await generateFoodData(prompt, apiKey);
    
    return {
      ...foodData,
      id: uuidv4(),
      image_url: null, // No image initially
      r2_image_key: null,
      cdn_url: null
    };
  } catch (error) {
    console.error(`Error in food data generation: ${error}`);
    throw error;
  }
}

// Complete generation pipeline (kept for backward compatibility)
export async function generateCompleteFoodItem(
  prompt: string, 
  apiKey: string,
  uploadToStorage: (buffer: Uint8Array, filename: string) => Promise<{ r2Key: string, cdnUrl: string }>
): Promise<FoodLibraryItem> {
  try {
    // Step 1: Generate food data
    console.log(`Generating food data for: ${prompt}`);
    const foodData = await generateFoodData(prompt, apiKey);
    
    // Step 2: Generate image
    console.log(`Generating image for: ${foodData.name}`);
    const imageUrl = await generateFoodImage(foodData, apiKey);
    
    // Step 3: Download and upload image
    console.log(`Downloading image from OpenAI...`);
    const imageBuffer = await downloadImage(imageUrl);
    
    // Generate unique filename
    const filename = `food-library/${uuidv4()}-${foodData.name.toLowerCase().replace(/\s+/g, '-')}.jpg`;
    
    console.log(`Uploading image to R2: ${filename}`);
    const { r2Key, cdnUrl } = await uploadToStorage(imageBuffer, filename);
    
    return {
      ...foodData,
      id: uuidv4(),
      image_url: imageUrl, // Keep original URL as backup
      r2_image_key: r2Key,
      cdn_url: cdnUrl
    };
  } catch (error) {
    console.error(`Error in complete generation pipeline: ${error}`);
    throw error;
  }
}

// Batch generation for food data only (no images)
export async function batchGenerateFoodDataOnly(
  prompts: string[],
  apiKey: string,
  onProgress?: (current: number, total: number, item?: FoodLibraryItem) => void
): Promise<FoodLibraryItem[]> {
  const results: FoodLibraryItem[] = [];
  const total = prompts.length;
  
  for (let i = 0; i < prompts.length; i++) {
    try {
      console.log(`\nProcessing ${i + 1}/${total}: ${prompts[i]}`);
      const item = await generateFoodDataOnly(prompts[i], apiKey);
      results.push(item);
      
      if (onProgress) {
        onProgress(i + 1, total, item);
      }
      
      // Small delay to be respectful to API
      await new Promise(resolve => setTimeout(resolve, 500));
    } catch (error) {
      console.error(`Failed to generate item ${prompts[i]}:`, error);
      // Continue with next item instead of failing entire batch
    }
  }
  
  return results;
}

// Batch generation for multiple items (with images)
export async function batchGenerateFoodItems(
  prompts: string[],
  apiKey: string,
  uploadToStorage: (buffer: Uint8Array, filename: string) => Promise<{ r2Key: string, cdnUrl: string }>,
  onProgress?: (current: number, total: number, item?: FoodLibraryItem) => void
): Promise<FoodLibraryItem[]> {
  const results: FoodLibraryItem[] = [];
  const total = prompts.length;
  
  for (let i = 0; i < prompts.length; i++) {
    try {
      console.log(`\nProcessing ${i + 1}/${total}: ${prompts[i]}`);
      const item = await generateCompleteFoodItem(prompts[i], apiKey, uploadToStorage);
      results.push(item);
      
      if (onProgress) {
        onProgress(i + 1, total, item);
      }
      
      // Small delay to be respectful to API
      await new Promise(resolve => setTimeout(resolve, 1000));
    } catch (error) {
      console.error(`Failed to generate item ${prompts[i]}:`, error);
      // Continue with next item instead of failing entire batch
    }
  }
  
  return results;
}