/**
 * Cloudflare Worker for API subdomain routing
 * Routes api.foodqapp.com to the main API functions
 * This worker handles the transition from foodq.pages.dev to api.foodqapp.com
 */

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Log the incoming request for debugging
    console.log(`API Worker: ${request.method} ${url.pathname} from ${url.hostname}`);
    
    // Handle CORS preflight requests
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 200,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          'Access-Control-Max-Age': '86400', // 24 hours
        },
      });
    }

    // Extract the API path (everything after the domain)
    const apiPath = url.pathname;
    
    // Map common API endpoints to the correct handler
    const routeHandlers = {
      // Health check
      '/health': () => handleHealthCheck(),
      
      // User endpoints
      '/users': () => forwardToFunction('api/users/index', request, env),
      '/users/profile': () => forwardToFunction('api/users/profile', request, env),
      
      // Deal endpoints
      '/deals': () => forwardToFunction('api/deals/index', request, env),
      '/deals/nearby': () => forwardToFunction('api/deals/index', request, env), // Handle with filter param
      
      // Business endpoints
      '/businesses': () => forwardToFunction('api/businesses/index', request, env),
      
      // Order endpoints
      '/orders': () => forwardToFunction('api/orders/index', request, env),
      
      // Admin endpoints
      '/admin/food-library': () => forwardToFunction('api/admin/food-library', request, env),
      '/admin/generate-image': () => forwardToFunction('api/admin/generate-image', request, env),
      '/admin/batch-generate-images': () => forwardToFunction('api/admin/batch-generate-images', request, env),
      '/admin/check': () => forwardToFunction('api/admin/check', request, env),
      
      // Stats endpoint
      '/stats': () => forwardToFunction('api/stats', request, env),
      '/activity': () => forwardToFunction('api/activity', request, env),
      
      // Places API
      '/places/autocomplete': () => forwardToFunction('api/places/autocomplete', request, env),
      '/places/details': () => forwardToFunction('api/places/details', request, env),
      
      // Restaurant onboarding
      '/restaurant-onboarding': () => forwardToFunction('api/restaurant-onboarding/index', request, env),
      '/restaurant-onboarding-requests': () => forwardToFunction('api/restaurant-onboarding-requests/index', request, env),
    };

    // Check for direct route match
    if (routeHandlers[apiPath]) {
      return await routeHandlers[apiPath]();
    }

    // Handle dynamic routes with IDs
    const dynamicRoutes = [
      { pattern: /^\/users\/([^\/]+)$/, handler: 'api/users/[id]' },
      { pattern: /^\/users\/([^\/]+)\/addresses$/, handler: 'api/users/[id]/addresses' },
      { pattern: /^\/users\/([^\/]+)\/complete-onboarding$/, handler: 'api/users/[id]/complete-onboarding' },
      { pattern: /^\/users\/([^\/]+)\/onboarding-status$/, handler: 'api/users/[id]/onboarding-status' },
      { pattern: /^\/deals\/([^\/]+)$/, handler: 'api/deals/[id]' },
      { pattern: /^\/businesses\/([^\/]+)$/, handler: 'api/businesses/[id]' },
      { pattern: /^\/orders\/([^\/]+)$/, handler: 'api/orders/[id]' },
      { pattern: /^\/orders\/([^\/]+)\/verify$/, handler: 'api/orders/verify' },
      { pattern: /^\/restaurant-onboarding-requests\/([^\/]+)$/, handler: 'api/restaurant-onboarding-requests/[id]/index' },
      { pattern: /^\/restaurant-onboarding-requests\/([^\/]+)\/approve$/, handler: 'api/restaurant-onboarding-requests/[id]/approve' },
      { pattern: /^\/restaurant-onboarding-requests\/([^\/]+)\/reject$/, handler: 'api/restaurant-onboarding-requests/[id]/reject' },
      { pattern: /^\/restaurant-onboarding-requests\/user\/([^\/]+)$/, handler: 'api/restaurant-onboarding-requests/user/[id]' },
    ];

    // Try to match dynamic routes
    for (const route of dynamicRoutes) {
      const match = apiPath.match(route.pattern);
      if (match) {
        return await forwardToFunction(route.handler, request, env, match[1]);
      }
    }

    // If no route matches, return 404
    return new Response(
      JSON.stringify({ 
        error: 'API endpoint not found',
        path: apiPath,
        available_endpoints: Object.keys(routeHandlers)
      }), 
      { 
        status: 404, 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        } 
      }
    );
  },
};

/**
 * Health check endpoint
 */
function handleHealthCheck() {
  return new Response(
    JSON.stringify({
      status: 'healthy',
      service: 'FoodQ API Router',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
    }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    }
  );
}

/**
 * Forward request to the appropriate function
 */
async function forwardToFunction(functionPath, request, env, dynamicParam = null) {
  try {
    // Import the function dynamically
    const functionModule = await import(`./functions/${functionPath}.ts`);
    
    // Create a new request object with the dynamic parameter if needed
    let modifiedRequest = request;
    if (dynamicParam) {
      const url = new URL(request.url);
      // Store the dynamic parameter for the function to access
      modifiedRequest = new Request(request.url, {
        method: request.method,
        headers: request.headers,
        body: request.body,
      });
      // Add the dynamic parameter to the URL context
      modifiedRequest.params = { id: dynamicParam };
    }

    // Call the function's default export
    const response = await functionModule.default.fetch(modifiedRequest, env);
    
    // Ensure CORS headers are set
    const corsResponse = new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: {
        ...Object.fromEntries(response.headers),
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });

    return corsResponse;
  } catch (error) {
    console.error(`Error forwarding to ${functionPath}:`, error);
    
    return new Response(
      JSON.stringify({
        error: 'Internal server error',
        message: error.message,
        function: functionPath,
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    );
  }
}