import axios from 'axios';
import { supabase } from '../lib/supabase';

const API_BASE_URL = 'http://localhost:8788/api';

const onboardingApi = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

// Add request interceptor to include auth token
onboardingApi.interceptors.request.use(async (config) => {
  const { data: { session } } = await supabase.auth.getSession();
  if (session?.access_token) {
    config.headers.Authorization = `Bearer ${session.access_token}`;
  }
  return config;
});

export interface OnboardingRequest {
  id: string;
  restaurant_name: string;
  cuisine_type: string;
  restaurant_description?: string;
  restaurant_photo_url?: string;
  owner_name: string;
  owner_email: string;
  owner_phone: string;
  address: string;
  zip_code: string;
  latitude: number;
  longitude: number;
  business_license: string;
  status: 'pending' | 'approved' | 'rejected';
  admin_notes?: string;
  user_id: string;
  restaurant_id?: string;
  created_at: string;
  updated_at: string;
  reviewed_at?: string;
}

export const onboardingApiService = {
  // Get pending onboarding requests
  getPendingRequests: async (): Promise<OnboardingRequest[]> => {
    try {
      const response = await onboardingApi.get('/restaurant-onboarding-requests');
      return response.data.data || response.data;
    } catch (error: any) {
      console.error('Error fetching onboarding requests:', error);
      throw new Error(error.response?.data?.message || 'Failed to fetch onboarding requests');
    }
  },

  // Approve a business onboarding request
  approveRequest: async (requestId: string): Promise<{ success: boolean; message: string }> => {
    try {
      const response = await onboardingApi.post('/restaurant-onboarding-requests', {
        action: 'approve',
        requestId
      });
      return response.data;
    } catch (error: any) {
      console.error('Error approving request:', error);
      throw new Error(error.response?.data?.message || 'Failed to approve request');
    }
  },

  // Reject a business onboarding request
  rejectRequest: async (requestId: string): Promise<{ success: boolean; message: string }> => {
    try {
      const response = await onboardingApi.post('/restaurant-onboarding-requests', {
        action: 'reject',
        requestId
      });
      return response.data;
    } catch (error: any) {
      console.error('Error rejecting request:', error);
      throw new Error(error.response?.data?.message || 'Failed to reject request');
    }
  },
};