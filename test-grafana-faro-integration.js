#!/usr/bin/env node

const API_BASE_URL = 'http://localhost:8788/api';
const API_KEY = 'test-api-key-2024';

// Generate E2E Request ID with clear identifier for testing
function generateTestE2ERequestId() {
  const timestamp = Date.now();
  const uuid = 'test-faro-integration-' + Math.random().toString(36).substr(2, 9);
  return `${timestamp}_${uuid}`;
}

async function testGrafanaFaroIntegration() {
  console.log('🎯 Testing Grafana Faro Integration - Backend Logging\n');
  
  const requestId = generateTestE2ERequestId();
  console.log(`📋 Test E2E Request ID: ${requestId}`);
  console.log(`🔍 Search for this ID in your Grafana Faro dashboard\n`);

  const headers = {
    'Content-Type': 'application/json',
    'X-API-Key': API_KEY,
    'X-E2E-Request-ID': requestId,
    'X-App-Version': '1.0.0+16',
    'X-Platform': 'faro-test-client',
  };

  console.log('📊 Testing Backend → Grafana Faro Log Transmission...\n');

  try {
    // Test 1: Simple successful API call
    console.log('🧪 TEST 1: Successful API Call');
    console.log(`   Making request to: GET /api/users`);
    console.log(`   Expected: Request start → Auth → DB → Request end`);
    
    const response = await fetch(`${API_BASE_URL}/users`, {
      method: 'GET',
      headers
    });
    
    console.log(`   ✅ Status: ${response.status}`);
    console.log(`   📋 Response E2E ID: ${response.headers.get('X-E2E-Request-ID')}`);
    console.log(`   ⏱️ Response time: ${response.headers.get('X-Timestamp')}\n`);

    // Test 2: API call with error
    const errorRequestId = generateTestE2ERequestId();
    console.log('🧪 TEST 2: API Call with Error');
    console.log(`   Request ID: ${errorRequestId}`);
    console.log(`   Making request to: GET /api/orders`);
    console.log(`   Expected: Request start → Auth → ERROR → Request end`);
    
    const errorResponse = await fetch(`${API_BASE_URL}/orders`, {
      method: 'GET',
      headers: {
        ...headers,
        'X-E2E-Request-ID': errorRequestId
      }
    });
    
    console.log(`   ❌ Status: ${errorResponse.status} (Expected)`);
    console.log(`   📋 Response E2E ID: ${errorResponse.headers.get('X-E2E-Request-ID') || 'Missing'}\n`);

    // Test 3: Check if logs reached Grafana
    console.log('🎯 GRAFANA FARO VERIFICATION:\n');
    console.log('═══════════════════════════════════════');
    console.log('To verify logs reached Grafana Faro:');
    console.log(`\n1. 🌐 Open: https://adminfoodq.grafana.net`);
    console.log('2. 📊 Navigate to: Explore → Logs');
    console.log('3. 🔍 Search for these Request IDs:');
    console.log(`   • "${requestId}"`);
    console.log(`   • "${errorRequestId}"`);
    console.log('\n4. 📋 You should see log entries with:');
    console.log('   • Component: cloudflare-worker');
    console.log('   • App: FoodQ-Backend');
    console.log('   • E2E Request ID correlation');
    console.log('   • Request start/end timing');
    console.log('   • Authentication operations');
    console.log('   • Database queries');
    console.log('   • Error details (for orders call)');
    
    console.log('\n5. 🎭 If logs appear in Grafana:');
    console.log('   ✅ Backend → Grafana Faro integration is WORKING');
    console.log('   ✅ E2E request correlation is FUNCTIONAL');
    console.log('   ✅ Ready for production deployment');
    
    console.log('\n6. 🚨 If logs do NOT appear:');
    console.log('   • Check Grafana Faro collector URL configuration');
    console.log('   • Verify API key permissions');
    console.log('   • Check network connectivity from Workers');
    console.log('   • Review Faro payload format compatibility');

    console.log('\n📱 Next Step: Test Flutter → Grafana Integration');
    console.log('   Open http://localhost:8081 and interact with the app');
    console.log('   Check Grafana for Frontend logs with matching E2E Request IDs');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

testGrafanaFaroIntegration();