import axios from 'axios';
import { supabase } from '../lib/supabase';

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || 'https://grabeat-api.pages.dev') + '/api';

console.log('Onboarding API Configuration:');
console.log('- API Base URL:', API_BASE_URL);

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
  // Get all onboarding requests
  getAllRequests: async (): Promise<OnboardingRequest[]> => {
    try {
      const response = await onboardingApi.get('/restaurant-onboarding-requests');
      const allRequests = response.data.data || response.data;
      return allRequests;
    } catch (error: any) {
      console.error('Error fetching onboarding requests:', error);
      throw new Error(error.response?.data?.message || 'Failed to fetch onboarding requests');
    }
  },

  // Get pending onboarding requests
  getPendingRequests: async (): Promise<OnboardingRequest[]> => {
    try {
      const response = await onboardingApi.get('/restaurant-onboarding-requests');
      const allRequests = response.data.data || response.data;
      // Filter to only return pending requests
      return allRequests.filter((req: OnboardingRequest) => req.status === 'pending');
    } catch (error: any) {
      console.error('Error fetching onboarding requests:', error);
      throw new Error(error.response?.data?.message || 'Failed to fetch onboarding requests');
    }
  },

  // Approve a business onboarding request
  approveRequest: async (requestId: string, adminNotes?: string): Promise<OnboardingRequest> => {
    try {
      const response = await onboardingApi.put(`/restaurant-onboarding-requests/${requestId}/approve`, {
        admin_notes: adminNotes || 'Approved by admin'
      });
      return response.data.data;
    } catch (error: any) {
      console.error('Error approving request:', error);
      throw new Error(error.response?.data?.error || 'Failed to approve request');
    }
  },

  // Reject a business onboarding request
  rejectRequest: async (requestId: string, adminNotes?: string): Promise<OnboardingRequest> => {
    try {
      const response = await onboardingApi.put(`/restaurant-onboarding-requests/${requestId}/reject`, {
        admin_notes: adminNotes || 'Rejected by admin'
      });
      return response.data.data;
    } catch (error: any) {
      console.error('Error rejecting request:', error);
      throw new Error(error.response?.data?.error || 'Failed to reject request');
    }
  },
};