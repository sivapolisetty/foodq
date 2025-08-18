import { useState, useEffect } from 'react';
import { adminAuth } from '../lib/supabase';

export const useAuth = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check authentication status on mount
    setIsAuthenticated(adminAuth.isLoggedIn());
    setIsLoading(false);

    // Listen for storage changes (for cross-tab logout)
    const handleStorageChange = () => {
      setIsAuthenticated(adminAuth.isLoggedIn());
    };

    window.addEventListener('storage', handleStorageChange);

    return () => {
      window.removeEventListener('storage', handleStorageChange);
    };
  }, []);

  const login = async (email: string, password: string) => {
    await adminAuth.signIn(email, password);
    setIsAuthenticated(true);
  };

  const loginWithGoogle = async () => {
    const result = await adminAuth.signInWithGoogle();
    return result;
  };

  const handleOAuthCallback = async () => {
    await adminAuth.handleOAuthCallback();
    setIsAuthenticated(true);
  };

  const logout = async () => {
    await adminAuth.signOut();
    setIsAuthenticated(false);
  };

  const resetPassword = async (email: string) => {
    return await adminAuth.resetPassword(email);
  };

  return {
    isAuthenticated,
    isLoading,
    login,
    loginWithGoogle,
    handleOAuthCallback,
    logout,
    resetPassword,
    currentUserEmail: adminAuth.getCurrentUserEmail(),
  };
};