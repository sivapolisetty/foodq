/**
 * Simple Node.js webhook server using built-in http module
 */
import http from 'http';
import url from 'url';

const port = 9999;

const server = http.createServer((req, res) => {
  const { pathname } = url.parse(req.url);
  const method = req.method;
  
  console.log(`${method} ${pathname}`);
  
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-Webhook-Secret, X-Event-Type');
  
  if (method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }
  
  if (method === 'POST' && pathname === '/api/notifications/process') {
    let body = '';
    
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        
        console.log('🔔 Webhook received:', JSON.stringify(data, null, 2));
        
        const { eventId, eventType, payload } = data;
        
        console.log(`\n🔄 Processing ${eventType} event: ${eventId}`);
        
        // Simulate modular processing flow
        if (eventType === 'ORDER_CREATED') {
          console.log('📋 OrderHandlers.handleOrderCreated()');
          console.log(`   👤 Business Owner: ${payload.businessOwnerId}`);
          console.log(`   💰 Amount: $${payload.amount}`);
          console.log('   📱 Notification: "New Order Received!"');
        } else if (eventType === 'DEAL_CREATED') {
          console.log('🏪 DealHandlers.handleDealCreated()');
          console.log(`   📍 Location: ${payload.location?.latitude}, ${payload.location?.longitude}`);
          console.log('   🌍 NotificationService.sendLocationBasedNotifications()');
        }
        
        console.log('✅ Event processed successfully\n');
        
        const response = {
          success: true,
          eventId,
          eventType,
          processed: true,
          timestamp: new Date().toISOString()
        };
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(response));
        
      } catch (error) {
        console.error('❌ Webhook processing failed:', error);
        
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: false,
          error: error.message
        }));
      }
    });
    
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(port, () => {
  console.log(`🚀 Test webhook server running at http://localhost:${port}`);
  console.log(`📍 Endpoint: http://localhost:${port}/api/notifications/process`);
});