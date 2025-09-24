#!/usr/bin/env node

const API_BASE_URL = 'http://localhost:8788/api';
const API_KEY = 'test-api-key-2024';

// Simulate Flutter E2E Request ID generation
function generateFlutterE2ERequestId(action = 'user_action') {
  const timestamp = Date.now();
  const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
  return `${timestamp}_${uuid}`;
}

// Simulate Flutter HTTP client headers
function getFlutterHeaders(requestId) {
  return {
    'Content-Type': 'application/json',
    'X-API-Key': API_KEY,
    'X-E2E-Request-ID': requestId,
    'X-App-Version': '1.0.0+16',
    'X-Platform': 'flutter-web',
    'User-Agent': 'FoodQ-Flutter/1.0.0+16 (dart:io HttpClient)',
  };
}

async function simulateFlutterUserFlow() {
  console.log('🎯 Simulating Complete Flutter User Flow with E2E Tracking\n');
  
  // Simulate user opening the deals screen
  const dealsRequestId = generateFlutterE2ERequestId('load_deals_screen');
  console.log('👤 USER ACTION: Opening Deals Screen');
  console.log(`   📱 Flutter E2E Request ID: ${dealsRequestId}`);
  console.log('   🔄 Expected Flow: Flutter → HTTP Client → Backend → Grafana\n');

  try {
    // 1. Load active deals
    console.log('📞 FLUTTER → BACKEND: GET /api/deals?status=active&limit=10');
    const dealsResponse = await fetch(`${API_BASE_URL}/deals?status=active&limit=10`, {
      method: 'GET',
      headers: getFlutterHeaders(dealsRequestId)
    });

    console.log(`   ✅ Response Status: ${dealsResponse.status}`);
    console.log(`   🔗 Backend E2E ID: ${dealsResponse.headers.get('X-E2E-Request-ID')}`);
    console.log(`   ⏱️ API Version: ${dealsResponse.headers.get('X-API-Version')}`);
    console.log(`   📅 Timestamp: ${dealsResponse.headers.get('X-Timestamp')}`);
    
    const dealsData = await dealsResponse.json();
    console.log(`   📊 Deals Loaded: ${dealsData?.length || 0}\n`);

    // Simulate user viewing their profile
    const profileRequestId = generateFlutterE2ERequestId('load_user_profile');
    console.log('👤 USER ACTION: Loading User Profile');
    console.log(`   📱 Flutter E2E Request ID: ${profileRequestId}`);
    
    console.log('📞 FLUTTER → BACKEND: GET /api/users');
    const usersResponse = await fetch(`${API_BASE_URL}/users`, {
      method: 'GET',
      headers: getFlutterHeaders(profileRequestId)
    });

    console.log(`   ✅ Response Status: ${usersResponse.status}`);
    console.log(`   🔗 Backend E2E ID: ${usersResponse.headers.get('X-E2E-Request-ID')}`);
    
    if (usersResponse.ok) {
      const usersData = await usersResponse.json();
      console.log(`   👥 Users Found: ${usersData?.length || 0}\n`);
    }

    // Simulate user attempting to view orders (will fail, but shows error tracking)
    const ordersRequestId = generateFlutterE2ERequestId('load_user_orders');
    console.log('👤 USER ACTION: Loading Order History');
    console.log(`   📱 Flutter E2E Request ID: ${ordersRequestId}`);
    
    console.log('📞 FLUTTER → BACKEND: GET /api/orders');
    const ordersResponse = await fetch(`${API_BASE_URL}/orders`, {
      method: 'GET',
      headers: getFlutterHeaders(ordersRequestId)
    });

    console.log(`   ❌ Response Status: ${ordersResponse.status} (Expected Error)`);
    console.log(`   🔗 Backend E2E ID: ${ordersResponse.headers.get('X-E2E-Request-ID') || 'Missing'}`);
    
    if (!ordersResponse.ok) {
      const errorData = await ordersResponse.json();
      console.log(`   💥 Error Message: ${errorData?.error || 'Unknown error'}\n`);
    }

    // Simulate user searching for nearby deals
    const nearbyRequestId = generateFlutterE2ERequestId('search_nearby_deals');
    console.log('👤 USER ACTION: Searching Nearby Deals');
    console.log(`   📱 Flutter E2E Request ID: ${nearbyRequestId}`);
    
    console.log('📞 FLUTTER → BACKEND: GET /api/deals?filter=nearby&lat=37.7749&lng=-122.4194');
    const nearbyResponse = await fetch(`${API_BASE_URL}/deals?filter=nearby&lat=37.7749&lng=-122.4194&radius=5`, {
      method: 'GET',
      headers: getFlutterHeaders(nearbyRequestId)
    });

    console.log(`   ❌ Response Status: ${nearbyResponse.status} (Expected Error - Missing DB Function)`);
    console.log(`   🔗 Backend E2E ID: ${nearbyResponse.headers.get('X-E2E-Request-ID')}`);

    console.log('\n🎯 FLUTTER E2E TRACKING SIMULATION COMPLETE!\n');
    
    console.log('🔍 Log Analysis Instructions:');
    console.log('═══════════════════════════════════════');
    console.log('Search your logs for these Request IDs to see complete user flows:\n');
    console.log(`1. 📱 Deals Screen: "${dealsRequestId}"`);
    console.log('   Expected logs: API start → business logic → DB query → API end\n');
    console.log(`2. 👤 Profile Screen: "${profileRequestId}"`); 
    console.log('   Expected logs: API start → auth verification → DB query → API end\n');
    console.log(`3. 📋 Orders Screen: "${ordersRequestId}"`);
    console.log('   Expected logs: API start → auth verification → ERROR → API end\n');
    console.log(`4. 🗺️ Nearby Search: "${nearbyRequestId}"`);
    console.log('   Expected logs: API start → geospatial logic → DB RPC error → API end\n');

    console.log('📊 Each flow demonstrates:');
    console.log('   ✅ Request correlation from Flutter to Backend');
    console.log('   ✅ Authentication tracking');
    console.log('   ✅ Database operation logging');
    console.log('   ✅ Business logic operations');
    console.log('   ✅ Error correlation with context');
    console.log('   ✅ Response timing and status codes');

    console.log('\n🌟 Next Steps:');
    console.log('   1. Open Grafana Faro dashboard');
    console.log('   2. Search for any of the above Request IDs');
    console.log('   3. Verify complete end-to-end trace correlation');
    console.log('   4. Deploy to production for live monitoring');

  } catch (error) {
    console.error('❌ Simulation failed:', error.message);
  }
}

// Run the simulation
simulateFlutterUserFlow();