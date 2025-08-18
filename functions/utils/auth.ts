import { createClient } from '@supabase/supabase-js';

export interface AuthContext {
  user: any | null;
  isAuthenticated: boolean;
  isApiKeyAuth?: boolean;
}

export async function validateAuth(request: Request, env: any): Promise<AuthContext> {
  // Check API key first (for development)
  const apiKey = request.headers.get('X-API-Key');
  if (apiKey && env.API_KEY && apiKey === env.API_KEY) {
    return { 
      user: null, 
      isAuthenticated: true, 
      isApiKeyAuth: true 
    };
  }

  // Check JWT token
  const authHeader = request.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return { 
      user: null, 
      isAuthenticated: false 
    };
  }

  const token = authHeader.substring(7);
  
  try {
    // For NoenCircles pattern: Parse JWT payload directly for development
    // This allows production JWT tokens to work with local API
    if (env.ENVIRONMENT === 'local') {
      try {
        const [header, payload, signature] = token.split('.');
        const decodedPayload = JSON.parse(atob(payload));
        
        // Extract user info from JWT payload
        const user = {
          id: decodedPayload.sub,
          email: decodedPayload.email,
          app_metadata: decodedPayload.app_metadata || {},
          user_metadata: decodedPayload.user_metadata || {}
        };
        
        console.log('JWT Validation (Development):', {
          userId: user.id,
          email: user.email,
          exp: decodedPayload.exp,
          iss: decodedPayload.iss
        });
        
        // Check if token is expired
        if (decodedPayload.exp && decodedPayload.exp < Date.now() / 1000) {
          console.log('JWT token expired');
          return { user: null, isAuthenticated: false };
        }
        
        return {
          user,
          isAuthenticated: true,
          isApiKeyAuth: false
        };
      } catch (parseError) {
        console.error('JWT parsing error:', parseError);
        return { user: null, isAuthenticated: false };
      }
    } else {
      // Production: Use full JWT validation
      const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
      const { data: { user }, error } = await supabase.auth.getUser(token);
      
      return {
        user,
        isAuthenticated: !error && !!user,
        isApiKeyAuth: false
      };
    }
  } catch (error) {
    console.error('Auth validation error:', error);
    return { 
      user: null, 
      isAuthenticated: false 
    };
  }
}

export function getCorsHeaders(origin?: string) {
  const allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:8080', 
    'http://localhost:8081',
    'http://localhost:8788',
    'https://grabeat.pages.dev',
    'https://grabeat.app'
  ];
  
  const corsOrigin = origin && allowedOrigins.includes(origin) ? origin : '*';
  
  return {
    'Access-Control-Allow-Origin': corsOrigin,
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
    'Access-Control-Allow-Credentials': 'true',
    'Access-Control-Max-Age': '86400',
  };
}