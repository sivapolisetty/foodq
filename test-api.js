// Test script to verify migration worked
const tests = [
  { name: 'API Health', url: 'http://localhost:8788/api/users' },
  { name: 'Business API', url: 'http://localhost:8788/api/businesses' },
  { name: 'Deals API', url: 'http://localhost:8788/api/deals' },
  { name: 'Supabase Health', url: 'http://127.0.0.1:58321/health' }
];

async function runTests() {
  console.log('🧪 Testing migration...\n');
  
  for (const test of tests) {
    try {
      const response = await fetch(test.url, {
        headers: { 'X-API-Key': 'test-api-key-2024' }
      });
      const status = response.ok ? '✅' : '❌';
      console.log(`${status} ${test.name}: ${response.status}`);
      
      if (response.ok && test.name.includes('API')) {
        const data = await response.json();
        console.log(`   Data: ${JSON.stringify(data).substring(0, 100)}...`);
      }
    } catch (error) {
      console.log(`❌ ${test.name}: ${error.message}`);
    }
  }
}

runTests();