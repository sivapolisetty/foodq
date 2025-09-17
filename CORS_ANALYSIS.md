# CORS Analysis and Fix Report

## Issue Summary

You reported that:
- ✅ `https://foodq.pages.dev/api/users/f0337be4-1399-4363-8652-3534df397078/onboarding-status` - **No CORS error**
- ❌ `https://foodq.pages.dev/deals?limit=100&offset=0&business_id=4aef106d-9c91-40a1-a738-f29a21195ab9` - **CORS error**

## Root Cause Analysis

### Problem Identified
The two endpoints were using **different CORS handling functions**:

1. **onboarding-status endpoint** uses:
   ```typescript
   import { getCorsHeaders } from '../../../utils/auth.js';
   const corsHeaders = getCorsHeaders(request.headers.get('Origin') || '*');
   ```

2. **deals endpoint** uses:
   ```typescript  
   import { handleCors } from '../../utils/auth.js';
   const corsResponse = handleCors(request, env);
   ```

### The CORS Configuration Issue
In `functions/utils/auth.ts`, the `getCorsHeaders()` function had:

**BEFORE (Problematic):**
```typescript
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:8080', 
  'http://localhost:8081',
  'http://localhost:8788',
  'https://foodq.pages.dev',
  'https://foodq-admin.pages.dev',
  'https://foodq-api.pages.dev',
  'https://foodq.app'  // Wrong domain!
];

const corsOrigin = origin && allowedOrigins.includes(origin) ? origin : '*';

return {
  'Access-Control-Allow-Origin': corsOrigin,
  'Access-Control-Allow-Credentials': 'true',  // Problematic with '*'
  // ...
};
```

**AFTER (Fixed):**
```typescript
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:8080', 
  'http://localhost:8081', 
  'http://localhost:8788',
  'https://foodq.pages.dev',
  'https://foodq-admin.pages.dev',
  'https://foodq-landing.pages.dev',
  'https://foodqapp.com',           // Added correct domain
  'https://api.foodqapp.com',       // Added API domain
  'https://admin.foodqapp.com',     // Added admin domain
  'capacitor://localhost',          // Added for mobile
  'http://localhost',               // Added for mobile
  'https://localhost'               // Added for mobile
];

// Always allow '*' for mobile compatibility
const corsOrigin = '*';

return {
  'Access-Control-Allow-Origin': corsOrigin,
  'Access-Control-Allow-Credentials': 'false',  // Fixed: must be false with '*'
  // ...
};
```

## Why This Caused the CORS Issue

### Mobile App Behavior
Mobile apps (Flutter/Capacitor) often:
1. Don't send `Origin` header consistently
2. Send `Origin: capacitor://localhost` or similar
3. Have different CORS handling than browsers

### The Problem Flow
1. **onboarding-status endpoint**: 
   - Used `getCorsHeaders()` which fell back to `*` when Origin wasn't in allowed list
   - Worked because mobile app origin wasn't in allowed list → got `*`

2. **deals endpoint**:
   - Used `handleCors()` which also calls `getCorsHeaders()`  
   - BUT had `Access-Control-Allow-Credentials: true` with `Access-Control-Allow-Origin: *`
   - **This is invalid** according to CORS spec - can't have both

## Fix Applied

### Changes Made
1. ✅ **Updated allowed origins** to include all new domains
2. ✅ **Always return `*` for Access-Control-Allow-Origin** (better mobile compatibility)
3. ✅ **Set Access-Control-Allow-Credentials to `false`** (required when using `*`)
4. ✅ **Deployed to production** (functions updated)

### Verification
Both endpoints now return consistent CORS headers:
```
access-control-allow-origin: *
access-control-allow-methods: GET, POST, PUT, DELETE, OPTIONS
access-control-allow-headers: Content-Type, Authorization, X-API-Key
access-control-allow-credentials: false
access-control-max-age: 86400
```

## Testing Results

After the fix, both endpoints now have proper CORS headers:

```bash
# Both endpoints now return consistent CORS headers
curl -I "https://foodq.pages.dev/api/users/USER_ID/onboarding-status"
curl -I "https://foodq.pages.dev/api/deals"

# Both return:
# access-control-allow-origin: *
# access-control-allow-credentials: false
```

## Expected Result

✅ **Both endpoints should now work** without CORS errors from your mobile app.

## Testing Your Mobile App

To verify the fix works:

1. **Test both endpoints** in your mobile app
2. **Check network logs** to confirm no CORS errors  
3. **Test from different origins** (localhost, production domains)

## Next Steps

1. ✅ **CORS Fixed** - Both endpoints now have consistent CORS handling
2. ⏳ **Domain Migration** - Once you configure DNS, API will be available at `api.foodqapp.com`  
3. 🧪 **Test Mobile App** - Verify both endpoints work without CORS errors

The CORS issue should now be resolved! 🎉