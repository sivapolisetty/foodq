/**
 * Test script for verifying API endpoints after domain migration
 */

const BASE_URLS = {
  old: 'https://foodq.pages.dev/api',
  new: 'https://api.foodqapp.com',
  local: 'http://localhost:8080'
};

const TEST_ENDPOINTS = [
  '/health',
  '/deals',
  '/businesses',
  '/stats',
  '/users/profile'
];

/**
 * Test a single endpoint
 */
async function testEndpoint(baseUrl, endpoint) {
  try {
    console.log(`Testing: ${baseUrl}${endpoint}`);
    
    const response = await fetch(`${baseUrl}${endpoint}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const result = {
      url: `${baseUrl}${endpoint}`,
      status: response.status,
      ok: response.ok,
      headers: Object.fromEntries(response.headers.entries()),
    };

    if (response.ok) {
      try {
        result.data = await response.json();
      } catch (e) {
        result.data = await response.text();
      }
    } else {
      result.error = await response.text();
    }

    return result;
  } catch (error) {
    return {
      url: `${baseUrl}${endpoint}`,
      status: 0,
      ok: false,
      error: error.message,
    };
  }
}

/**
 * Test all endpoints for a given base URL
 */
async function testAllEndpoints(baseUrl, label) {
  console.log(`\n🧪 Testing ${label} (${baseUrl})\n${'='.repeat(50)}`);
  
  const results = [];
  
  for (const endpoint of TEST_ENDPOINTS) {
    const result = await testEndpoint(baseUrl, endpoint);
    results.push(result);
    
    // Format output
    const status = result.ok ? '✅' : '❌';
    const statusCode = result.status || 'ERR';
    console.log(`${status} ${endpoint} - ${statusCode}`);
    
    if (!result.ok && result.error) {
      console.log(`   Error: ${result.error.substring(0, 100)}...`);
    }
  }
  
  const successCount = results.filter(r => r.ok).length;
  console.log(`\nResults: ${successCount}/${TEST_ENDPOINTS.length} endpoints working`);
  
  return results;
}

/**
 * Main test function
 */
async function runTests() {
  console.log('🚀 FoodQ API Endpoint Testing\n');
  
  const allResults = {};
  
  // Test old API (foodq.pages.dev)
  allResults.old = await testAllEndpoints(BASE_URLS.old, 'Old API (foodq.pages.dev)');
  
  // Test new API (api.foodqapp.com) - may not be deployed yet
  allResults.new = await testAllEndpoints(BASE_URLS.new, 'New API (api.foodqapp.com)');
  
  // Test local API if available
  try {
    const localTest = await fetch(`${BASE_URLS.local}/health`, { 
      method: 'GET',
      signal: AbortSignal.timeout(2000) // 2 second timeout
    });
    if (localTest.ok) {
      allResults.local = await testAllEndpoints(BASE_URLS.local, 'Local API (localhost:8080)');
    }
  } catch (e) {
    console.log('\n⚠️  Local API not running (this is normal if not in development)');
  }
  
  // Summary
  console.log('\n📊 Test Summary\n' + '='.repeat(50));
  Object.entries(allResults).forEach(([key, results]) => {
    const successCount = results.filter(r => r.ok).length;
    const total = results.length;
    const percentage = Math.round((successCount / total) * 100);
    console.log(`${key.padEnd(10)} ${successCount}/${total} (${percentage}%)`);
  });
  
  console.log('\n✨ Testing completed');
}

// Run tests if this script is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  runTests().catch(console.error);
}

export { runTests, testEndpoint, testAllEndpoints };