// API Configuration
const getApiBaseUrl = (): string => {
  // Check if we're in development
  if (import.meta.env.DEV) {
    return 'http://localhost:8080';
  }
  
  // Production API endpoint - using foodq.pages.dev/api
  return 'https://foodq.pages.dev/api';
};

export const API_BASE_URL = getApiBaseUrl();
export const API_KEY = 'test-api-key-2024';

// API Endpoints - removed /api prefix since now handled by subdomain
export const API_ENDPOINTS = {
  FOOD_LIBRARY: `${API_BASE_URL}/admin/food-library`,
  GENERATE_IMAGE: `${API_BASE_URL}/admin/generate-image`,
  BATCH_GENERATE_IMAGES: `${API_BASE_URL}/admin/batch-generate-images`,
} as const;