import axios from 'axios';
import { supabase } from '../lib/supabase';

const API_BASE_URL = 'http://localhost:8788/api';

const adminApi = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

// Add request interceptor to include auth token
adminApi.interceptors.request.use(async (config) => {
  const { data: { session } } = await supabase.auth.getSession();
  if (session?.access_token) {
    config.headers.Authorization = `Bearer ${session.access_token}`;
  }
  return config;
});

export interface DashboardStats {
  totalUsers: string;
  userGrowth: string;
  totalBusinesses: string;
  businessGrowth: string;
  totalOrders: string;
  orderGrowth: string;
  totalRevenue: string;
  revenueGrowth: string;
}

export interface Activity {
  id: string;
  type: string;
  title: string;
  description: string;
  timestamp: string;
  timeAgo: string;
  icon: string;
}

export const adminApiService = {
  // Get dashboard statistics
  getStats: async (): Promise<DashboardStats> => {
    try {
      const response = await adminApi.get('/stats');
      return response.data;
    } catch (error: any) {
      console.error('Error fetching stats:', error);
      throw new Error(error.response?.data?.message || 'Failed to fetch statistics');
    }
  },

  // Get recent activities
  getRecentActivities: async (): Promise<Activity[]> => {
    try {
      const response = await adminApi.get('/activity');
      return response.data;
    } catch (error: any) {
      console.error('Error fetching activities:', error);
      throw new Error(error.response?.data?.message || 'Failed to fetch activities');
    }
  },
};