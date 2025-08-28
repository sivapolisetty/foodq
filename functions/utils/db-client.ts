import { createServiceRoleClient } from './supabase';

/**
 * Centralized database client wrapper for consistent Supabase access
 * This provides a single point of configuration for all database operations
 * Always uses service role client to avoid RLS policy conflicts
 */
export class DBClient {
  private static instance: any;
  private static currentEnv: any;

  /**
   * Get a configured Supabase client instance
   * Automatically handles environment configuration and caching
   */
  static getInstance(env?: any): any {
    // If environment changed or no instance exists, create new one
    if (!this.instance || (env && env !== this.currentEnv)) {
      try {
        this.instance = createServiceRoleClient(env);
        this.currentEnv = env;
        
        if (env?.NODE_ENV === 'development' || env?.ENVIRONMENT === 'local') {
          console.log('DBClient initialized for local development', {
            supabaseUrl: env?.SUPABASE_URL || env?.LOCAL_SUPABASE_URL || 'default',
            environment: env?.ENVIRONMENT || 'unknown'
          });
        }
      } catch (error) {
        console.error('Failed to initialize DBClient:', error);
        throw error;
      }
    }
    
    return this.instance;
  }

  /**
   * Force refresh the client instance (useful for environment changes)
   */
  static refresh(env?: any): any {
    this.instance = null;
    this.currentEnv = null;
    return this.getInstance(env);
  }

  /**
   * Get client with automatic error handling and component context
   */
  static getClient(env?: any, component?: string): any {
    try {
      const client = this.getInstance(env);
      
      if (component && (env?.NODE_ENV === 'development' || env?.ENVIRONMENT === 'local')) {
        console.log(`DBClient accessed by: ${component}`);
      }
      
      return client;
    } catch (error) {
      console.error(`DBClient error in ${component || 'unknown'}:`, error);
      throw error;
    }
  }
}

/**
 * Convenience function for getting database client
 * Usage: const supabase = getDBClient(env, 'ComponentName');
 */
export const getDBClient = (env?: any, component?: string) => {
  return DBClient.getClient(env, component);
};