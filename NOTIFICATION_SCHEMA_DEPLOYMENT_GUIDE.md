# Notification Schema Deployment Guide

## 🚨 CRITICAL: Manual Deployment Required

The notification schema needs to be deployed to your production Supabase database. Automated deployment failed due to authentication requirements, so manual execution is necessary.

## Current Status
- ❌ **event_queue** table: Not found in production
- ❌ **notifications** table: Not found in production  
- ❌ **Database triggers**: Not deployed
- ❌ **Notification functions**: Not deployed

## Production Database Details
- **Project URL**: https://zobhorsszzthyljriiim.supabase.co
- **Project ID**: zobhorsszzthyljriiim
- **Dashboard**: https://supabase.com/dashboard/project/zobhorsszzthyljriiim

## Deployment Steps

### Step 1: Access Supabase SQL Editor
1. Go to [Supabase Dashboard](https://supabase.com/dashboard/project/zobhorsszzthyljriiim)
2. Navigate to **SQL Editor** in the left sidebar
3. Create a new query

### Step 2: Execute Migration Files in Order
Execute these migration files **in the exact order listed**:

#### 1. Event Queue Table (CRITICAL)
```sql
-- File: supabase/migrations/20250923000001_create_event_queue_table.sql
-- Copy and paste the ENTIRE contents of this file
```

#### 2. User Locations Table  
```sql
-- File: supabase/migrations/20250923000002_create_user_locations_table.sql
-- Copy and paste the ENTIRE contents of this file
```

#### 3. Notifications Table (CRITICAL)
```sql
-- File: supabase/migrations/20250923000003_create_notifications_table.sql  
-- Copy and paste the ENTIRE contents of this file
```

#### 4. Push Tokens Table
```sql
-- File: supabase/migrations/20250923000004_create_push_tokens_table.sql
-- Copy and paste the ENTIRE contents of this file
```

#### 5. Delivery Log Table
```sql
-- File: supabase/migrations/20250923000005_create_delivery_log_table.sql
-- Copy and paste the ENTIRE contents of this file
```

#### 6. Event Triggers (CRITICAL)
```sql
-- File: supabase/migrations/20250923000006_create_event_triggers.sql
-- Copy and paste the ENTIRE contents of this file
```

#### 7. Location Functions
```sql
-- File: supabase/migrations/20250923000007_create_location_functions.sql
-- Copy and paste the ENTIRE contents of this file
```

### Step 3: Verify Deployment

After executing all migrations, verify the deployment by running these queries:

```sql
-- Check if event_queue table exists
SELECT COUNT(*) FROM public.event_queue;

-- Check if notifications table exists  
SELECT COUNT(*) FROM public.notifications;

-- Check if triggers exist
SELECT tgname, tgrelid::regclass 
FROM pg_trigger 
WHERE tgname IN ('event_queue_webhook_trigger', 'order_event_trigger', 'deal_event_trigger');

-- Check if functions exist
SELECT proname, pronamespace::regnamespace
FROM pg_proc 
WHERE proname IN (
  'notify_event_queue_webhook',
  'create_order_event', 
  'create_deal_event',
  'mark_notification_read',
  'get_unread_notification_count'
);
```

Expected results:
- `event_queue` and `notifications` tables should return `0` (empty but existing)
- Should find 3 triggers
- Should find 5+ functions

### Step 4: Test Event Creation

Test the system by creating a test event:

```sql
-- Insert test event
INSERT INTO public.event_queue (
  event_type, 
  event_name, 
  payload,
  status
) VALUES (
  'SYSTEM_ANNOUNCEMENT',
  'Notification system deployed',
  jsonb_build_object(
    'message', 'Notification system is now active',
    'timestamp', CURRENT_TIMESTAMP
  ),
  'pending'
);

-- Check if event was created
SELECT * FROM public.event_queue ORDER BY created_at DESC LIMIT 1;
```

## Critical Migration Files Content

### Core Tables Required:
1. **event_queue** - Core event processing queue
2. **notifications** - User notification storage  
3. **user_locations** - Location tracking for proximity notifications
4. **push_tokens** - FCM device token management
5. **delivery_log** - Delivery tracking and analytics

### Core Functions Required:
1. **notify_event_queue_webhook()** - Webhook trigger function
2. **create_order_event()** - Order event creation
3. **create_deal_event()** - Deal event creation  
4. **mark_notification_read()** - Mark notifications as read
5. **get_unread_notification_count()** - Get unread count

### Core Triggers Required:
1. **event_queue_webhook_trigger** - Webhook notifications
2. **order_event_trigger** - Order status changes
3. **deal_event_trigger** - Deal creation/updates

## Post-Deployment Verification

### 1. Test Order Events
Create a test order and verify events are generated:
```sql
-- This should automatically create events via triggers
INSERT INTO public.orders (...) VALUES (...);
```

### 2. Test Deal Events  
Create a test deal and verify events are generated:
```sql
-- This should automatically create events via triggers  
INSERT INTO public.deals (...) VALUES (...);
```

### 3. Test Notification Creation
Verify notifications can be created:
```sql
INSERT INTO public.notifications (
  recipient_id,
  event_type, 
  title,
  body
) VALUES (
  auth.uid(),
  'SYSTEM_ANNOUNCEMENT',
  'Test Notification',
  'This is a test notification'
);
```

## Troubleshooting

### Common Issues:

1. **"relation does not exist"** - Table not created properly
   - Solution: Re-run the specific migration file

2. **"function does not exist"** - Functions not created
   - Solution: Re-run migration files 6 and 7

3. **"trigger does not exist"** - Triggers not created  
   - Solution: Re-run migration file 6

4. **Permission denied** - RLS policies issue
   - Solution: Check that all GRANT statements executed properly

### Migration File Locations:
All migration files are in: `/Users/sivapolisetty/vscode-workspace/claude_workspace/foodqapp/supabase/migrations/`

## Success Criteria

✅ **Deployment is successful when:**
- All 7 migration files executed without errors
- All tables exist and are accessible via REST API
- All triggers are created and functional  
- All functions are created and callable
- Test events can be created and processed
- Webhook notifications are triggered (check logs)

## Next Steps After Deployment

1. **Configure Webhooks**: Update webhook URLs in the notification processor
2. **Test FCM Integration**: Verify push notifications work end-to-end
3. **Monitor Event Queue**: Check that events are being processed
4. **Set up Monitoring**: Monitor notification delivery rates

## Emergency Rollback

If something goes wrong, you can drop the tables:
```sql
-- EMERGENCY ROLLBACK (use with caution)
DROP TABLE IF EXISTS public.delivery_log CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE; 
DROP TABLE IF EXISTS public.push_tokens CASCADE;
DROP TABLE IF EXISTS public.user_locations CASCADE;
DROP TABLE IF EXISTS public.event_queue CASCADE;
```

---

**⚠️ IMPORTANT**: This deployment is critical for the notification system to work in production. Without these tables and triggers, no notifications will be sent to users.

**🔗 Dashboard Link**: [Open Supabase Dashboard](https://supabase.com/dashboard/project/zobhorsszzthyljriiim/editor/sql)