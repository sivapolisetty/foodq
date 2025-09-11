// API Configuration
const getApiBaseUrl = (): string => {
  // Check if we're in development
  if (import.meta.env.DEV) {
    return 'http://localhost:8080';
  }
  
  // Production API endpoint - Cloudflare Pages deployment
  return 'https://foodq.pages.dev';
};

export const API_BASE_URL = getApiBaseUrl();
export const API_KEY = 'test-api-key-2024';

// API Endpoints
export const API_ENDPOINTS = {
  FOOD_LIBRARY: `${API_BASE_URL}/api/admin/food-library`,
  GENERATE_IMAGE: `${API_BASE_URL}/api/admin/generate-image`,
  BATCH_GENERATE_IMAGES: `${API_BASE_URL}/api/admin/batch-generate-images`,
} as const;