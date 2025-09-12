/**
 * Cloudflare Worker to add CORS headers to R2 bucket requests
 * This worker sits in front of the R2 bucket and adds necessary CORS headers
 * for cross-origin requests from the Flutter web app.
 */

export default {
  async fetch(request, env, ctx) {
    // Handle preflight OPTIONS requests
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 200,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          'Access-Control-Max-Age': '86400', // 24 hours
        },
      });
    }

    // Only allow GET and HEAD requests
    if (request.method !== 'GET' && request.method !== 'HEAD') {
      return new Response('Method not allowed', { status: 405 });
    }

    try {
      // Extract the path from the request URL
      const url = new URL(request.url);
      const objectKey = url.pathname.substring(1); // Remove leading slash

      // Validate the object key (basic security)
      if (!objectKey || objectKey.includes('..') || objectKey.includes('//')) {
        return new Response('Invalid path', { status: 400 });
      }

      // Get the object from R2
      const object = await env.FOOD_IMAGES.get(objectKey);

      if (!object) {
        return new Response('Object not found', { 
          status: 404,
          headers: {
            'Access-Control-Allow-Origin': '*',
          },
        });
      }

      // Determine content type based on file extension
      const contentType = getContentType(objectKey);

      // Create response with CORS headers
      const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        'Content-Type': contentType,
        'Cache-Control': 'public, max-age=31536000', // 1 year cache
        'ETag': object.etag,
      };

      // Add content-length if available
      if (object.size) {
        headers['Content-Length'] = object.size.toString();
      }

      // Add last-modified if available
      if (object.uploaded) {
        headers['Last-Modified'] = object.uploaded.toUTCString();
      }

      return new Response(object.body, {
        status: 200,
        headers: headers,
      });

    } catch (error) {
      console.error('CDN Worker error:', error);
      return new Response('Internal server error', { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
  },
};

/**
 * Get content type based on file extension
 */
function getContentType(filename) {
  const ext = filename.split('.').pop()?.toLowerCase();
  
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'svg':
      return 'image/svg+xml';
    case 'ico':
      return 'image/x-icon';
    default:
      return 'application/octet-stream';
  }
}