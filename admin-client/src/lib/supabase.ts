import { createClient } from '@supabase/supabase-js';

// Environment-based configuration
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://zobhorsszzthyljriiim.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5ODIzNzYsImV4cCI6MjA2OTU1ODM3Nn0.91GlHZxmJGg5E-T2iR5rzgLrQJzNPNW-SzS2VhqlymA';
const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || 'https://grabeat-api.pages.dev';
const environment = import.meta.env.VITE_ENVIRONMENT || 'production';

console.log('Admin Client Environment Configuration:');
console.log(`- Environment: ${environment}`);
console.log(`- Supabase URL: ${supabaseUrl}`);
console.log(`- API Base URL: ${apiBaseUrl}`);

// Create Supabase client
export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Cache the last admin check result
let lastAdminCheck: { email: string; result: any; timestamp: number } | null = null;
const CACHE_DURATION = 5000; // 5 seconds cache

const checkAdminStatus = async (email: string) => {
  const now = Date.now();
  
  // Check if we have a recent cached result for this email
  if (lastAdminCheck && 
      lastAdminCheck.email === email && 
      now - lastAdminCheck.timestamp < CACHE_DURATION) {
    console.log(`Admin check result cached for email: ${email}`);
    return lastAdminCheck.result;
  }
  
  console.log(`Checking admin status for email: ${email}`);
  
  // Call the API endpoint (environment-aware)
  const apiUrl = `${apiBaseUrl}/api/admin/check`;
  
  const response = await fetch(apiUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email }),
  });

  const result = await response.json();
  
  // Cache the result
  lastAdminCheck = {
    email,
    result,
    timestamp: now
  };
  
  return result;
};

// Admin authentication service
export const adminAuth = {
  // Sign in with email and password
  signIn: async (email: string, password: string) => {
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError || !authData.user) {
      throw new Error('Invalid email or password');
    }

    // Check if user is an admin
    const result = await checkAdminStatus(email);

    if (!result.isAdmin) {
      await supabase.auth.signOut();
      throw new Error(result.message || 'Access denied. You are not authorized to access the admin panel.');
    }

    // Store in localStorage
    localStorage.setItem('admin_logged_in', 'true');
    localStorage.setItem('admin_email', email);

    return { success: true };
  },

  // Sign in with Google OAuth
  signInWithGoogle: async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/callback`,
      },
    });

    if (error) {
      throw error;
    }

    return data;
  },

  // Handle OAuth callback
  handleOAuthCallback: async () => {
    const { data: { session }, error } = await supabase.auth.getSession();
    
    if (error || !session?.user?.email) {
      throw new Error('Failed to get session after OAuth login');
    }

    // Check if user is an admin
    const result = await checkAdminStatus(session.user.email);

    if (!result.isAdmin) {
      await supabase.auth.signOut();
      throw new Error(result.message || 'Access denied. Your Google account is not authorized for admin access.');
    }

    // Store in localStorage
    localStorage.setItem('admin_logged_in', 'true');
    localStorage.setItem('admin_email', session.user.email);

    return { success: true };
  },

  // Sign out
  signOut: async () => {
    await supabase.auth.signOut();
    localStorage.removeItem('admin_logged_in');
    localStorage.removeItem('admin_email');
  },

  // Check if logged in
  isLoggedIn: () => {
    return localStorage.getItem('admin_logged_in') === 'true';
  },

  // Get current user email
  getCurrentUserEmail: () => {
    return localStorage.getItem('admin_email') || '';
  },

  // Reset password
  resetPassword: async (email: string) => {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });

    if (error) {
      throw error;
    }

    return {
      message: 'Password reset email sent! Check your inbox.',
    };
  },
};