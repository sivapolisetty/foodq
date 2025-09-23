/**
 * Simple test server to receive webhook calls and simulate processing
 */
import express from 'express';
const app = express();
const port = 8788;

app.use(express.json());

// Simulate the modular notification processing
app.post('/api/notifications/process', async (req, res) => {
  try {
    console.log('🔔 Webhook received:', JSON.stringify(req.body, null, 2));
    
    const { eventId, eventType, payload } = req.body;
    
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
    
    res.json({
      success: true,
      eventId,
      eventType,
      processed: true,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('❌ Webhook processing failed:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.listen(port, () => {
  console.log(`🚀 Test webhook server running at http://localhost:${port}`);
  console.log(`📍 Endpoint: http://localhost:${port}/api/notifications/process`);
});