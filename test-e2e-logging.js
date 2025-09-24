#!/usr/bin/env node

const API_BASE_URL = 'http://localhost:8788/api';
const API_KEY = 'test-api-key-2024';

// Generate E2E Request ID (matching Flutter format)
function generateE2ERequestId() {
  const timestamp = Date.now();
  const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
  return `${timestamp}_${uuid}`;
}

async function testE2ELogging() {
  console.log('🧪 Testing E2E Request Logging Integration\n');
  
  const requestId = generateE2ERequestId();
  console.log(`📋 Using E2E Request ID: ${requestId}\n`);

  // Common headers for all requests
  const headers = {
    'Content-Type': 'application/json',
    'X-API-Key': API_KEY,
    'X-E2E-Request-ID': requestId,
    'X-App-Version': '1.0.0+16',
    'X-Platform': 'test-client',
  };

  try {
    // Test 1: Users GET endpoint (auth + database query)
    console.log('📞 Test 1: GET /api/users');
    console.log(`   Request ID: ${requestId}`);
    console.log(`   Expected logs: auth verification, database query, request timing\n`);
    
    const usersResponse = await fetch(`${API_BASE_URL}/users`, {
      method: 'GET',
      headers
    });
    
    console.log(`   ✅ Status: ${usersResponse.status}`);
    console.log(`   🔄 Response E2E ID: ${usersResponse.headers.get('X-E2E-Request-ID')}`);
    console.log(`   ⏰ API Version: ${usersResponse.headers.get('X-API-Version')}`);
    console.log(`   📅 Timestamp: ${usersResponse.headers.get('X-Timestamp')}\n`);

    // Test 2: Deals GET endpoint (with filters)
    console.log('📞 Test 2: GET /api/deals?status=active&limit=5');
    console.log(`   Request ID: ${requestId}`);
    console.log(`   Expected logs: business logic filtering, database query\n`);
    
    const dealsResponse = await fetch(`${API_BASE_URL}/deals?status=active&limit=5`, {
      method: 'GET',
      headers
    });
    
    console.log(`   ✅ Status: ${dealsResponse.status}`);
    console.log(`   🔄 Response E2E ID: ${dealsResponse.headers.get('X-E2E-Request-ID')}`);
    
    if (dealsResponse.ok) {
      const dealsData = await dealsResponse.json();
      console.log(`   📊 Deals returned: ${dealsData?.length || 0}\n`);
    }

    // Test 3: Orders GET endpoint (requires auth)
    console.log('📞 Test 3: GET /api/orders');
    console.log(`   Request ID: ${requestId}`);
    console.log(`   Expected logs: auth validation, database operations\n`);
    
    const ordersResponse = await fetch(`${API_BASE_URL}/orders`, {
      method: 'GET',
      headers
    });
    
    console.log(`   ✅ Status: ${ordersResponse.status}`);
    console.log(`   🔄 Response E2E ID: ${ordersResponse.headers.get('X-E2E-Request-ID')}`);

    // Test 4: Invalid endpoint (error logging test)
    console.log('📞 Test 4: GET /api/nonexistent (error test)');
    console.log(`   Request ID: ${requestId}`);
    console.log(`   Expected logs: 404 error with request correlation\n`);
    
    const errorResponse = await fetch(`${API_BASE_URL}/nonexistent`, {
      method: 'GET',
      headers
    });
    
    console.log(`   ✅ Status: ${errorResponse.status}`);
    console.log(`   🔄 Response E2E ID: ${errorResponse.headers.get('X-E2E-Request-ID') || 'Not set'}\n`);

    // Test 5: Geospatial deals query
    console.log('📞 Test 5: GET /api/deals?filter=nearby&lat=37.7749&lng=-122.4194');
    console.log(`   Request ID: ${requestId}`);
    console.log(`   Expected logs: geospatial query operations\n`);
    
    const geoResponse = await fetch(`${API_BASE_URL}/deals?filter=nearby&lat=37.7749&lng=-122.4194&radius=10`, {
      method: 'GET',
      headers
    });
    
    console.log(`   ✅ Status: ${geoResponse.status}`);
    console.log(`   🔄 Response E2E ID: ${geoResponse.headers.get('X-E2E-Request-ID')}`);

    console.log('🎯 All E2E logging tests completed!');
    console.log(`\n📋 Search for Request ID "${requestId}" in your logs to see end-to-end correlation`);
    console.log('\n🔍 Expected log entries:');
    console.log('   - Request start/end with timing');
    console.log('   - Authentication operations');
    console.log('   - Database query operations');
    console.log('   - Business logic operations');
    console.log('   - Error logging (where applicable)');
    console.log('   - Response correlation');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Run the test
testE2ELogging();