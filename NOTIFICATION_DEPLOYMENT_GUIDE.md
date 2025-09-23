# FoodQ Notification System - Deployment & Testing Guide

## 🚀 Quick Deployment Checklist

### Phase 1: Database Setup (15 minutes)

1. **Run Database Migrations**
```bash
# Navigate to your Supabase project
cd supabase

# Apply all notification migrations
supabase migration up

# Or apply individually in order:
supabase migration up --target 20250923000001  # Event queue
supabase migration up --target 20250923000002  # User locations  
supabase migration up --target 20250923000003  # Notifications
supabase migration up --target 20250923000004  # Push tokens
supabase migration up --target 20250923000005  # Delivery log
supabase migration up --target 20250923000006  # Event triggers
supabase migration up --target 20250923000007  # Location functions
```

2. **Verify Tables Created**
```sql
-- Check in Supabase SQL Editor
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
  'event_queue', 'user_locations', 'notifications', 
  'push_tokens', 'delivery_log'
);
```

3. **Enable PostGIS Extension** (if not already enabled)
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

### Phase 2: Firebase Setup (10 minutes)

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project or use existing
   - Enable Cloud Messaging

2. **Generate Service Account Key**
   - Go to Project Settings → Service Accounts
   - Generate new private key
   - Download JSON file

3. **Extract Firebase Credentials**
```javascript
// From downloaded JSON file, extract:
const FIREBASE_PROJECT_ID = "your-project-id";
const FIREBASE_CLIENT_EMAIL = "firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com";
const FIREBASE_PRIVATE_KEY = "-----BEGIN PRIVATE KEY-----\n....\n-----END PRIVATE KEY-----\n";
```

### Phase 3: Cloudflare Worker Setup (10 minutes)

1. **Install Wrangler CLI**
```bash
npm install -g wrangler
wrangler login
```

2. **Create Worker Configuration**
```toml
# wrangler.toml for notification worker
name = "foodq-notification-processor"
main = "functions/api/notifications/process.ts"
compatibility_date = "2024-09-23"

[env.production]
name = "foodq-notification-processor"

[[env.production.d1_databases]]
binding = "DB"
database_name = "foodq-notifications"
database_id = "your-d1-database-id"
```

3. **Set Environment Variables**
```bash
# Set in Cloudflare dashboard or via CLI
wrangler secret put FIREBASE_PROJECT_ID
wrangler secret put FIREBASE_CLIENT_EMAIL  
wrangler secret put FIREBASE_PRIVATE_KEY
wrangler secret put WEBHOOK_SECRET
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
```

4. **Deploy Worker**
```bash
wrangler deploy --env production
```

### Phase 4: Configure Webhook URL (5 minutes)

1. **Update Supabase Settings**
```sql
-- Set webhook URL in Supabase
ALTER DATABASE postgres SET "app.webhook_url" = 'https://foodq-notification-processor.your-worker.workers.dev/api/notifications/process';
ALTER DATABASE postgres SET "app.webhook_secret" = 'your-webhook-secret-here';
```

### Phase 5: Flutter App Setup (15 minutes)

1. **Add Firebase to Flutter**
```bash
# In mobile-client directory
flutter pub get

# Add Firebase config files:
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist
```

2. **Initialize Firebase in App**
```dart
// In main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // ... rest of app initialization
}
```

3. **Update Supabase Configuration**
```dart
// Ensure Supabase is configured with correct URL and keys
await Supabase.initialize(
  url: 'https://your-project.supabase.co',
  anonKey: 'your-anon-key',
);
```

## 🧪 Testing the Complete System

### Step 1: Import Postman Collection

1. **Import Collection**
   - Open Postman
   - Import `FoodQ_Notification_System.postman_collection.json`

2. **Configure Environment Variables**
```json
{
  "base_url": "https://your-project.supabase.co/rest/v1",
  "webhook_url": "https://your-worker.workers.dev/api/notifications/process",
  "supabase_anon_key": "your-anon-key",
  "supabase_service_role_key": "your-service-role-key", 
  "webhook_secret": "your-webhook-secret",
  "test_user_id": "test_user_123",
  "test_business_id": "test_business_456"
}
```

### Step 2: Basic Functionality Tests

#### Test 1: Database Health Check
```bash
# Run: Setup & Authentication → Health Check - Supabase
# Expected: 200 OK
```

#### Test 2: Webhook Health Check  
```bash
# Run: Setup & Authentication → Health Check - Webhook
# Expected: 200 OK with health status
```

#### Test 3: Location Setup
```bash
# Run: Location Management → Create/Update User Home Location
# Expected: 201 Created, location stored in database
```

#### Test 4: FCM Token Registration
```bash
# Run: FCM Token Management → Register FCM Token  
# Expected: 201 Created, token stored for user
```

### Step 3: Event Queue Tests

#### Test 5: Direct Event Insertion
```bash
# Run: Event Queue Tests → Create Order Event
# Expected: 
# - 201 Created (event in queue)
# - Webhook automatically triggered
# - Notification created in database
# - FCM notification sent (if token exists)
```

**Verification Steps:**
1. Check event_queue table: `status = 'processed'`
2. Check notifications table: New notification created
3. Check delivery_log table: FCM delivery attempt logged

#### Test 6: Location-Based Deal
```bash
# Run: Event Queue Tests → Create Deal Event with Location
# Expected:
# - Event created
# - Users within 5km radius found
# - Location-based notifications created
```

### Step 4: Direct Webhook Tests

#### Test 7: Direct Webhook Processing
```bash
# Run: Direct Webhook Tests → Test Webhook - Order Notification
# Expected: 
# - 200 OK from webhook
# - Notification processed and saved
# - FCM notification sent
```

#### Test 8: Order Confirmation Flow
```bash
# Run: Direct Webhook Tests → Test Webhook - Order Confirmed  
# Expected:
# - Customer receives confirmation notification
# - Includes verification code and QR code
# - High priority notification
```

### Step 5: End-to-End Testing

#### Test 9: Complete Order Flow
```bash
# Run: End-to-End Tests → Complete Order Flow Test
# Expected: Full order lifecycle notifications:
# 1. Order Created → Business owner notified
# 2. Order Confirmed → Customer notified
# 3. Auto-progression through order states
```

#### Test 10: Location-Based Deal Flow
```bash
# Run: End-to-End Tests → Location-Based Deal Flow Test
# Expected:
# 1. User location set
# 2. Deal created near user
# 3. Location-aware notification sent
# 4. Distance calculated correctly
```

## 📊 Monitoring & Verification

### Database Queries for Verification

```sql
-- Check recent events
SELECT 
  event_type, status, created_at, processed_at,
  (payload->>'businessName') as business,
  (payload->>'amount') as amount
FROM event_queue 
ORDER BY created_at DESC 
LIMIT 10;

-- Check notifications created
SELECT 
  event_type, recipient_type, title, body, 
  created_at, is_read, priority
FROM notifications 
ORDER BY created_at DESC 
LIMIT 10;

-- Check FCM delivery success
SELECT 
  n.title, dl.channel, dl.status, dl.attempted_at,
  dl.provider_response->>'successCount' as fcm_success
FROM notifications n
JOIN delivery_log dl ON n.id = dl.notification_id
WHERE dl.channel = 'fcm'
ORDER BY dl.attempted_at DESC
LIMIT 10;

-- Check location-based notifications
SELECT 
  title, body, 
  (location_context->>'distance_km')::float as distance,
  location_context->>'user_location_type' as location_type,
  created_at
FROM notifications 
WHERE location_context IS NOT NULL
ORDER BY created_at DESC;
```

### Real-time Monitoring

```sql
-- Event processing rate (last hour)
SELECT 
  DATE_TRUNC('minute', created_at) as minute,
  COUNT(*) as events_created,
  COUNT(*) FILTER (WHERE status = 'processed') as events_processed,
  COUNT(*) FILTER (WHERE status = 'failed') as events_failed
FROM event_queue 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY DATE_TRUNC('minute', created_at)
ORDER BY minute DESC;

-- Notification delivery stats
SELECT 
  channel,
  COUNT(*) as total_attempts,
  COUNT(*) FILTER (WHERE status = 'sent') as successful,
  ROUND(
    COUNT(*) FILTER (WHERE status = 'sent')::numeric / 
    COUNT(*) * 100, 2
  ) as success_rate
FROM delivery_log 
WHERE attempted_at > NOW() - INTERVAL '24 hours'
GROUP BY channel;
```

## 🔧 Troubleshooting Common Issues

### Issue 1: Webhook Not Triggering

**Symptoms:** Events created but webhook never called

**Solutions:**
```sql
-- Check if pg_net extension is available
SELECT * FROM pg_extension WHERE extname = 'pg_net';

-- If not available, webhook will use NOTIFY instead
LISTEN event_queue_webhook;

-- Check webhook URL configuration
SELECT current_setting('app.webhook_url', true);
```

### Issue 2: FCM Notifications Not Sent

**Symptoms:** Delivery log shows failed FCM attempts

**Solutions:**
1. Check Firebase credentials in Cloudflare Worker
2. Verify FCM tokens are valid and active
3. Check Firebase project settings

```sql
-- Check FCM token status
SELECT 
  platform, is_active, failure_count, last_failure_reason
FROM push_tokens 
WHERE user_id = 'your-test-user-id';
```

### Issue 3: Location Functions Not Working

**Symptoms:** Location-based notifications not triggered

**Solutions:**
```sql
-- Check PostGIS extension
SELECT PostGIS_Version();

-- Test location function
SELECT * FROM find_users_near_location(37.7749, -122.4194, 5);

-- Check user locations
SELECT 
  location_type, latitude, longitude, 
  notification_radius_km, active
FROM user_locations 
WHERE user_id = 'your-test-user-id';
```

### Issue 4: Performance Issues

**Solutions:**
```sql
-- Check index usage
EXPLAIN ANALYZE 
SELECT * FROM notifications 
WHERE recipient_id = 'user_id' AND is_read = false;

-- Monitor query performance
SELECT 
  query, calls, total_time, mean_time
FROM pg_stat_statements 
WHERE query LIKE '%notifications%'
ORDER BY total_time DESC;
```

## 📈 Performance Optimization

### Database Optimization

1. **Partition Large Tables** (if needed)
```sql
-- Partition notifications by month
CREATE TABLE notifications_2024_12 PARTITION OF notifications
FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');
```

2. **Add Additional Indexes** (if needed)
```sql
-- For heavy notification filtering
CREATE INDEX CONCURRENTLY idx_notifications_recipient_type_created
ON notifications(recipient_id, type, created_at DESC)
WHERE is_read = false;
```

### Webhook Optimization

1. **Batch Processing**
   - Process multiple events in single webhook call
   - Implement exponential backoff for retries

2. **Caching**
   - Cache user tokens in worker
   - Cache location lookups

## 🔒 Security Considerations

### Webhook Security
```typescript
// Always verify webhook secret
const webhookSecret = request.headers.get('X-Webhook-Secret');
if (webhookSecret !== env.WEBHOOK_SECRET) {
  return new Response('Unauthorized', { status: 401 });
}
```

### Database Security
```sql
-- Ensure RLS is enabled on all tables
SELECT 
  schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('notifications', 'user_locations', 'push_tokens');
```

### FCM Security
- Store Firebase credentials securely in Cloudflare
- Rotate tokens regularly
- Monitor for suspicious notification patterns

## 🎯 Success Criteria

✅ **System is working correctly when:**

1. **Events Process Within 5 Seconds**
   - Event inserted → Webhook triggered → Notification sent

2. **Location Notifications Are Accurate**
   - Distance calculations within 100m accuracy
   - Only users within specified radius receive notifications

3. **FCM Delivery Rate > 95%**
   - Most notifications successfully delivered
   - Failed tokens automatically deactivated

4. **Real-time Updates Work**
   - Flutter app receives notifications immediately
   - UI updates without manual refresh

5. **Analytics Are Available**
   - Delivery statistics accessible
   - Event processing metrics visible
   - Location-based performance tracked

## 📋 Daily Operations Checklist

### Daily Health Checks
- [ ] Check event queue processing rate
- [ ] Verify FCM delivery success rate
- [ ] Monitor webhook response times
- [ ] Review failed notifications
- [ ] Check database performance

### Weekly Maintenance
- [ ] Clean up old processed events
- [ ] Update inactive push tokens
- [ ] Review location notification effectiveness
- [ ] Update notification templates if needed
- [ ] Check Firebase quota usage

### Monthly Reviews
- [ ] Analyze notification engagement rates
- [ ] Review and optimize location targeting
- [ ] Update user preferences based on feedback
- [ ] Performance optimization review
- [ ] Security audit of notification data

---

## 🚀 You're Ready to Go!

Your FoodQ notification system is now fully deployed and tested. The system will automatically:

- **Process all order events** and notify relevant parties
- **Send location-based deal notifications** to nearby users  
- **Handle FCM push notifications** across all platforms
- **Track delivery and engagement** metrics
- **Scale automatically** with your user base

Monitor the system using the provided Postman collection and database queries. The notification system will grow with your app and provide excellent user engagement through timely, relevant notifications!