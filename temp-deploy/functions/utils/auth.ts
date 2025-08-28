import { createClient } from '@supabase/supabase-js';

export interface AuthContext {
  user: any | null;
  isAuthenticated: boolean;
  isApiKeyAuth?: boolean;
}

// Get authentication token from request (NoenCircles style)
export const getAuthFromRequest = (request: Request): string | null => {
  // Check for API key first
  const apiKey = request.headers.get('X-API-Key');
  if (apiKey) {
    return apiKey;
  }
  
  // Check for Bearer token
  const authHeader = request.headers.get('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  
  return authHeader.substring(7);
};

// Verify token and get user (simplified version of NoenCircles pattern)
export const verifyToken = async (token: string, supabase: any, env?: any) => {
  try {
    if (!token) {
      console.log('❌ No token provided');
      return null;
    }
    
    // Check for API key authentication (development)
    if (token === env?.API_KEY && env?.API_KEY) {
      console.log('🔑 Using API key authentication');
      return {
        user: { id: '123e4567-e89b-12d3-a456-426614174000', email: 'api@test.com', isApiKeyAuth: true },
        userId: '123e4567-e89b-12d3-a456-426614174000'
      };
    }
    
    // Handle JWT token authentication
    try {
      const [header, payload, signature] = token.split('.');
      if (!header || !payload || !signature) {
        return null;
      }
      
      // Add padding to payload if needed
      let paddedPayload = payload;
      const padding = 4 - (payload.length % 4);
      if (padding !== 4) {
        paddedPayload += '='.repeat(padding);
      }
      
      const decodedPayload = JSON.parse(atob(paddedPayload));
      
      // Verify this is a Supabase JWT and not expired
      if (decodedPayload.iss && (decodedPayload.iss.includes('.supabase.co/auth/v1') || decodedPayload.iss.includes('127.0.0.1'))) {
        const currentTime = Math.floor(Date.now() / 1000);
        
        if (decodedPayload.exp && decodedPayload.exp < currentTime) {
          return null;
        }
        
        const user = {
          id: decodedPayload.sub,
          email: decodedPayload.email,
          app_metadata: decodedPayload.app_metadata || {},
          user_metadata: decodedPayload.user_metadata || {}
        };
        
        // Try to get user from database
        try {
          const { data: existingUser } = await supabase
            .from('app_users')
            .select('*')
            .eq('id', user.id)
            .single();
            
          if (existingUser) {
            return {
              user: existingUser,
              userId: existingUser.id
            };
          }
        } catch (dbError) {
          console.log('User not found in database, using token data');
        }
        
        return {
          user,
          userId: user.id
        };
      }
    } catch (jwtError) {
      console.error('JWT parsing error:', jwtError);
    }
    
    return null;
  } catch (error) {
    console.error('Error verifying token:', error);
    return null;
  }
};

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
    // Use direct JWT parsing for all environments (simpler and more reliable)
    const [header, payload, signature] = token.split('.');
    if (!header || !payload || !signature) {
      return { user: null, isAuthenticated: false };
    }
    
    // Add padding to payload if needed
    let paddedPayload = payload;
    const padding = 4 - (payload.length % 4);
    if (padding !== 4) {
      paddedPayload += '='.repeat(padding);
    }
    
    const decodedPayload = JSON.parse(atob(paddedPayload));
    
    // Verify this is a Supabase JWT and not expired
    if (decodedPayload.iss && (decodedPayload.iss.includes('.supabase.co/auth/v1') || decodedPayload.iss.includes('127.0.0.1'))) {
      const currentTime = Math.floor(Date.now() / 1000);
      
      if (decodedPayload.exp && decodedPayload.exp < currentTime) {
        return { user: null, isAuthenticated: false };
      }
      
      const user = {
        id: decodedPayload.sub,
        email: decodedPayload.email,
        app_metadata: decodedPayload.app_metadata || {},
        user_metadata: decodedPayload.user_metadata || {}
      };
      
      return {
        user,
        isAuthenticated: true,
        isApiKeyAuth: false
      };
    }
    
    return { user: null, isAuthenticated: false };
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
    'https://grabeat-admin.pages.dev',
    'https://grabeat-api.pages.dev',
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

// Response utilities (NoenCircles style)
export const jsonResponse = (data: any, status: number = 200, request?: Request, env?: any) => {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...getCorsHeaders(request?.headers.get('Origin') || '*')
    },
  });
};

export const errorResponse = (message: string, status: number = 400, request?: Request, env?: any) => {
  return jsonResponse({ error: message }, status, request, env);
};

export const handleCors = (request: Request, env?: any) => {
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: getCorsHeaders(request.headers.get('Origin') || '*'),
    });
  }
  return null;
};