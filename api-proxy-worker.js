/**
 * Simple Proxy Worker for api.foodqapp.com
 * Proxies requests to the existing foodq.pages.dev API
 */

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Replace domain with the original API
    const targetUrl = `https://foodq.pages.dev/api${url.pathname}${url.search}`;
    
    console.log(`Proxying: ${url.pathname} → ${targetUrl}`);
    
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 200,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          'Access-Control-Max-Age': '86400',
        },
      });
    }
    
    // Create new request with original headers
    const proxyRequest = new Request(targetUrl, {
      method: request.method,
      headers: request.headers,
      body: request.body,
      redirect: 'follow',
    });
    
    try {
      // Fetch from the original API
      const response = await fetch(proxyRequest);
      
      // Create new response with CORS headers
      const proxyResponse = new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: new Headers(response.headers),
      });
      
      // Add CORS headers
      proxyResponse.headers.set('Access-Control-Allow-Origin', '*');
      proxyResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      proxyResponse.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
      
      return proxyResponse;
    } catch (error) {
      console.error('Proxy error:', error);
      return new Response(
        JSON.stringify({
          error: 'Proxy failed',
          message: error.message,
          target: targetUrl,
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
  },
};