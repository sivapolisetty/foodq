# FoodQ Deployment Instructions

## 🏗️ Architecture Overview

```
foodq.pages.dev/
├── /                    → Landing Website (React/HTML)
└── /api/*              → API Functions (Cloudflare Functions)

foodq-admin.pages.dev/   → Admin Dashboard (React)
                        → Connects to foodq.pages.dev/api/*

Mobile App              → Separate deployment (App stores or subdomain)
                        → Connects to foodq.pages.dev/api/*
```

## 🚀 Quick Deployment Commands

### Deploy Main Site (Landing + API)
```bash
npm run deploy
```

### Deploy Admin Dashboard
```bash
npm run deploy:admin
```

## 📋 Detailed Deployment Steps

### 1. Main Site Deployment (`foodq.pages.dev`)

**What gets deployed**: Landing website + API functions

```bash
# Clean build
rm -rf dist/

# Build landing website and API functions
npm run build

# Deploy to production
npx wrangler pages deploy dist --project-name=foodq --commit-dirty=true
```

**Verify deployment**:
```bash
# Test landing site
curl https://foodq.pages.dev/

# Test API
curl https://foodq.pages.dev/api/health
```

### 2. Admin Dashboard Deployment (`foodq-admin.pages.dev`)

```bash
# Go to admin client directory
cd admin-client/

# Build admin dashboard
npm run build

# Deploy admin dashboard
npx wrangler pages deploy dist --project-name=foodq-admin --commit-dirty=true
```

**Verify deployment**:
```bash
# Test admin dashboard
curl https://foodq-admin.pages.dev/

# Test API connectivity from admin
curl -X POST -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}' \
  https://foodq.pages.dev/api/admin/check
```

### 3. Mobile App Deployment

**For App Stores**:
```bash
cd mobile-client/

# iOS
flutter build ios --release
# Follow iOS deployment guide

# Android  
flutter build appbundle
# Upload to Google Play Console
```

**For Web (alternative)**:
```bash
cd mobile-client/
flutter build web
# Deploy to separate subdomain like app.foodq.pages.dev
```

## ⚙️ Configuration Management

### Environment Variables

**Main Site** (`wrangler.toml`):
```toml
[env.production.vars]
NODE_ENV = "production"
ENVIRONMENT = "production"
SUPABASE_URL = "https://zobhorsszzthyljriiim.supabase.co"
SUPABASE_SERVICE_ROLE_KEY = "your-service-role-key"
GOOGLE_PLACES_API_KEY = "your-google-places-key"
API_KEY = "your-api-key"
```

**Admin Dashboard** (`admin-client/wrangler.toml`):
```toml
[vars]
VITE_API_BASE_URL = "https://foodq.pages.dev"
VITE_SUPABASE_URL = "https://zobhorsszzthyljriiim.supabase.co"
VITE_SUPABASE_ANON_KEY = "your-supabase-anon-key"
```

**Mobile App** (`mobile-client/lib/core/config/api_config.dart`):
```dart
static const String _prodApiUrl = 'https://foodq.pages.dev';
```

## 🔍 Troubleshooting

### Common Issues

**1. Functions not working on main domain**
```bash
# Ensure functions are in correct directory
ls dist/_functions/api/
# Should show: health.ts, admin/, businesses/, etc.

# Redeploy with functions
npm run build:functions
npx wrangler pages deploy dist --project-name=foodq
```

**2. Admin dashboard can't connect to API**
```bash
# Check admin config
cat admin-client/wrangler.toml | grep VITE_API_BASE_URL
# Should be: VITE_API_BASE_URL = "https://foodq.pages.dev"

# Test API endpoint manually
curl https://foodq.pages.dev/api/health
```

**3. CORS issues**
```bash
# Check API CORS configuration in functions/utils/auth.ts
# Ensure foodq-admin.pages.dev is in allowedOrigins
```

### Environment Verification

**After each deployment, verify**:
```bash
# 1. Landing site loads
curl -I https://foodq.pages.dev/

# 2. API health check
curl https://foodq.pages.dev/api/health

# 3. Admin dashboard loads
curl -I https://foodq-admin.pages.dev/

# 4. Admin can connect to API
curl -X POST -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}' \
  https://foodq.pages.dev/api/admin/check
```

## 📁 Project Structure

```
foodqapp/
├── landing-client/         # Landing website source
│   ├── src/
│   ├── dist/              # Built landing site
│   ├── package.json
│   └── wrangler.toml
├── admin-client/          # Admin dashboard source
│   ├── src/
│   ├── dist/              # Built admin dashboard
│   ├── package.json
│   └── wrangler.toml
├── mobile-client/         # Flutter mobile app
│   ├── lib/
│   ├── pubspec.yaml
│   └── build/
├── functions/             # API functions source
│   ├── api/
│   └── utils/
├── dist/                  # Main deployment directory
│   ├── index.html         # Landing site
│   ├── _functions/        # API functions (copied)
│   └── assets/
├── package.json           # Root build scripts
├── wrangler.toml         # Main deployment config
└── DEPLOYMENT_INSTRUCTIONS.md  # This file
```

## 🚨 Important Rules

1. **Never use deployment-specific URLs** like `abc123.foodq.pages.dev`
2. **Always use production domains**: 
   - `https://foodq.pages.dev` for API
   - `https://foodq-admin.pages.dev` for admin
3. **Test all endpoints after deployment**
4. **Keep environment variables synchronized**
5. **Deploy landing + API together** to maintain consistency

## 🎯 Success Checklist

After deployment, verify:
- [ ] Landing site loads at `https://foodq.pages.dev/`
- [ ] API health check works: `https://foodq.pages.dev/api/health`
- [ ] Admin dashboard loads at `https://foodq-admin.pages.dev/`
- [ ] Admin can authenticate via Google OAuth
- [ ] Admin can fetch restaurant onboarding requests
- [ ] Mobile app can connect to API (if deployed)
- [ ] All CORS origins are properly configured

---

**Last Updated**: September 2025
**Next Steps**: Deploy landing website to replace current Flutter web app