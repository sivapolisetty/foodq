# FoodQ Environment Setup Guide

## 🎯 Environment Strategy

### QA Environment ✅ (Ready)
- **URL:** `https://foodq.pages.dev/api`
- **Purpose:** Development, testing, staging, debugging
- **Status:** ✅ Working with CORS fixed
- **Mobile Config:** Use `.env.qa` file

### Production Environment 🚀 (Setup Required)  
- **URL:** `https://api.foodqapp.com`
- **Purpose:** Live mobile app production traffic
- **Status:** ⚠️ DNS + Custom domain setup needed
- **Mobile Config:** Use `.env.production` file

## 📱 Mobile App Configuration

Your mobile app is already perfectly configured for this approach!

### For QA/Development Testing:
```bash
# Copy the QA environment file
cp .env.qa .env

# Content of .env.qa:
API_BASE_URL=https://foodq.pages.dev
ENVIRONMENT=qa
DEBUG_API_CALLS=true
```

### For Production Deployment:
```bash
# Copy the production environment file  
cp .env.production .env

# Content of .env.production:
API_BASE_URL=https://api.foodqapp.com
ENVIRONMENT=production  
DEBUG_API_CALLS=false
```

## 🔧 Required Setup for Production API

### Step 1: Add DNS Record in Cloudflare
1. Go to **Cloudflare Dashboard** → **foodqapp.com** → **DNS** → **Records**
2. Click **Add record**
3. Configure:
   - **Type:** CNAME
   - **Name:** `api`  
   - **Target:** `foodq-api-router.sivapolisetty813.workers.dev`
   - **Proxy status:** ✅ Proxied (orange cloud)
   - **TTL:** Auto
4. Click **Save**

### Step 2: Add Custom Domain to Worker
1. Go to **Cloudflare Dashboard** → **Workers & Pages**
2. Click on **foodq-api-router** worker
3. Go to **Settings** → **Triggers**
4. Under **Custom Domains**, click **Add Custom Domain**
5. Enter: `api.foodqapp.com`
6. Click **Add Custom Domain**

### Step 3: Verify Production API
```bash
# After DNS setup, test the production API
curl https://api.foodqapp.com/health

# Should return the same as QA:
curl https://foodq.pages.dev/api/health
```

## 🧪 Testing Strategy

### Development Workflow:
1. **Development:** Use QA environment (`foodq.pages.dev/api`)
2. **Testing:** Use QA environment with full testing suite
3. **Staging:** Use QA environment with production-like data
4. **Production:** Use production environment (`api.foodqapp.com`)

### Mobile App Testing:
```dart
// Your ApiConfig automatically handles this
static String get baseUrl => EnvironmentConfig.apiBaseUrl;

// Prints different URLs based on .env file:
// QA: https://foodq.pages.dev/api
// Production: https://api.foodqapp.com
```

### Quick Environment Switch:
```bash
# Switch to QA
cp .env.qa .env
flutter run

# Switch to Production  
cp .env.production .env
flutter run --release
```

## 🎛️ Environment-Specific Features

### QA Environment Features:
- ✅ Debug API calls enabled
- ✅ Detailed logging
- ✅ Test data and sandbox mode
- ✅ CORS headers for web testing
- ✅ No rate limiting

### Production Environment Features:
- 🔒 Debug calls disabled
- 📊 Production analytics
- 💳 Live Stripe payments
- 🚀 Optimized performance
- 🛡️ Security hardened

## 📊 Current Status

| Component | QA Environment | Production Environment |
|-----------|----------------|------------------------|
| **API URL** | ✅ `foodq.pages.dev/api` | ⏳ `api.foodqapp.com` (needs DNS) |
| **CORS Fixed** | ✅ Working | ✅ Will inherit fix |
| **Mobile Config** | ✅ `.env.qa` created | ✅ `.env.production` created |
| **Endpoints** | ✅ All working | ⏳ Same endpoints via proxy |
| **Authentication** | ✅ Supabase JWT | ✅ Same Supabase |
| **Database** | ✅ Production DB | ✅ Same DB |

## 🚦 Deployment Process

### For QA/Testing:
```bash
# 1. Use QA environment
cp .env.qa .env

# 2. Test your changes
flutter test
flutter run

# 3. Deploy when ready
# QA environment is always live at foodq.pages.dev/api
```

### For Production Release:
```bash
# 1. Complete DNS setup (one-time)
# Add CNAME: api → foodq-api-router.sivapolisetty813.workers.dev
# Add custom domain to worker

# 2. Test with production config
cp .env.production .env
flutter run --release

# 3. Deploy to app stores
flutter build ios --release
flutter build apk --release
```

## 🔍 Verification Commands

```bash
# Test both environments
echo "Testing QA API:"
curl https://foodq.pages.dev/api/health

echo "Testing Production API (after DNS setup):"
curl https://api.foodqapp.com/health

# Both should return identical responses
```

## 🎉 Benefits of This Setup

✅ **Clear Separation:** QA vs Production environments  
✅ **Easy Switching:** Just change `.env` file  
✅ **Same Codebase:** No code changes needed  
✅ **Rollback Safety:** QA always available as backup  
✅ **Team Workflow:** Developers use QA, users get Production  
✅ **CORS Fixed:** Both environments have proper CORS  

Your mobile app is ready for both environments - just complete the DNS setup for production! 🚀