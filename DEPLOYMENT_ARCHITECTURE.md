# FoodQ Deployment Architecture

## 🏗️ Domain Structure

The FoodQ platform uses the following domain architecture:

### Primary Domains

1. **`foodq.pages.dev`** - Main Landing Website + API
   - **Root (`/`)**: Landing website (HTML/CSS/JS marketing site)
   - **API (`/api/*`)**: All backend API functions
   - **Purpose**: Public-facing website and API endpoints

2. **`foodq-admin.pages.dev`** - Admin Dashboard
   - **React-based admin interface**
   - **Connects to**: `foodq.pages.dev/api/*` endpoints
   - **Purpose**: Restaurant onboarding management, platform administration

3. **Flutter Mobile App** - Separate deployment (NOT on main domain)
   - **Deploy to**: App stores (iOS/Android) or separate subdomain
   - **Connects to**: `foodq.pages.dev/api/*` endpoints
   - **Purpose**: Mobile application for customers and restaurant owners

## 📁 Project Structure

```
foodqapp/
├── functions/               # API Functions (deployed to foodq.pages.dev/api/*)
├── landing-client/         # Landing website (deployed to foodq.pages.dev/)
├── admin-client/          # Admin dashboard (deployed to foodq-admin.pages.dev)
├── mobile-client/         # Flutter app (separate deployment)
└── wrangler.toml         # Main deployment config
```

## 🚀 Deployment Instructions

### 1. Main Site (`foodq.pages.dev`)

**Contains**: Landing website + API functions

```bash
# From project root
npm run build:landing     # Build landing website
npm run build:functions   # Copy functions to dist/_functions/
npx wrangler pages deploy dist --project-name=foodq
```

**Result**: 
- `foodq.pages.dev/` → Landing website
- `foodq.pages.dev/api/*` → API endpoints

### 2. Admin Dashboard (`foodq-admin.pages.dev`)

**Contains**: React admin interface

```bash
# From admin-client/
npm run build
npx wrangler pages deploy dist --project-name=foodq-admin
```

**Result**: 
- `foodq-admin.pages.dev/` → Admin dashboard
- Connects to `foodq.pages.dev/api/*` for data

### 3. Flutter Mobile App

**Deployment Options**:

**Option A**: App Stores
```bash
# From mobile-client/
flutter build ios --release     # For iOS App Store
flutter build appbundle        # For Google Play Store
```

**Option B**: Web Deployment (separate subdomain)
```bash
# From mobile-client/ 
flutter build web
# Deploy to app.foodq.pages.dev or similar
```

## ⚙️ Configuration

### Environment Variables

**Main Site (foodq.pages.dev)** - `wrangler.toml`:
```toml
[env.production.vars]
NODE_ENV = "production"
SUPABASE_URL = "https://your-project.supabase.co"
SUPABASE_SERVICE_ROLE_KEY = "your-service-role-key"
# ... other API vars
```

**Admin Dashboard** - `admin-client/wrangler.toml`:
```toml
[vars]
VITE_API_BASE_URL = "https://foodq.pages.dev"
VITE_SUPABASE_URL = "https://your-project.supabase.co"
VITE_SUPABASE_ANON_KEY = "your-anon-key"
```

**Flutter Mobile App** - `mobile-client/lib/core/config/api_config.dart`:
```dart
static const String _prodApiUrl = 'https://foodq.pages.dev';
```

## 🔄 Current Status & Migration Needed

### ❌ Current Issue
- `foodq.pages.dev` is serving Flutter web app instead of landing website
- No proper landing website exists

### ✅ Required Actions
1. **Create landing website** in `landing-client/` directory
2. **Update build process** to deploy landing + API to main domain  
3. **Move Flutter app** to separate deployment target
4. **Update all API references** to use `foodq.pages.dev/api/*`

## 📋 API Endpoints

All API endpoints are served from `foodq.pages.dev/api/*`:

- `GET /api/health` - Health check
- `POST /api/admin/check` - Admin authentication
- `GET /api/businesses` - Business listings
- `GET /api/deals` - Deal listings
- `POST /api/restaurant-onboarding-requests` - Restaurant onboarding
- `GET /api/users/{id}` - User management
- ... (all other endpoints)

## 🎯 Benefits of This Architecture

1. **Clear separation of concerns**
   - Landing site for marketing/SEO
   - Admin dashboard for management
   - Mobile app for users

2. **Centralized API**
   - Single API endpoint for all clients
   - Consistent authentication and data access
   - Easier maintenance and monitoring

3. **Scalable deployment**
   - Each component can be deployed independently
   - Easy to update without affecting other parts
   - Optimized for each use case

## 🚨 Important Notes

- **Never use deployment-specific URLs** like `abc123.foodq.pages.dev`
- **Always use production domains** for cross-service communication
- **Keep API and UI deployments synchronized**
- **Test all endpoints after deployment**

---

**Last Updated**: September 2025
**Status**: Migration in progress - landing website needed