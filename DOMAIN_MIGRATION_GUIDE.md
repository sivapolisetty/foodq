# FoodQ Domain Migration Guide

## Overview

This guide covers the complete migration from `foodq.pages.dev` to `foodqapp.com` with proper subdomain structure.

## Architecture

### Current State (foodq.pages.dev)
```
foodq.pages.dev/
├── / (landing page)
├── /api/* (API endpoints)
└── /admin/* (admin portal)
```

### Target State (foodqapp.com)
```
foodqapp.com (landing page)
├── api.foodqapp.com/* (API endpoints)
└── admin.foodqapp.com/* (admin portal)
```

## Components Updated

### 1. Mobile App API Configuration ✅
- **Files Updated:**
  - `mobile-client/lib/core/config/api_config.dart`
  - `mobile-client/lib/core/config/environment_config.dart`
  - `mobile-client/.env.example`
- **Changes:** Updated from `https://foodq.pages.dev` to `https://api.foodqapp.com`

### 2. Landing Page ✅
- **Location:** `landing-page/`
- **Files Created:**
  - `index.html` - Main landing page
  - `styles.css` - Professional styling
  - `script.js` - Interactive features
  - `_headers` - Security and caching headers
  - `_redirects` - URL redirects
- **Deployment:** Cloudflare Pages

### 3. Admin Portal ✅
- **Location:** `admin-client/`
- **Files Updated:**
  - `README.md` - Updated documentation
  - `src/config/api.ts` - API endpoint configuration
  - `src/services/adminApi.ts` - API service
  - `src/services/onboardingApi.ts` - Onboarding service
- **Changes:** Updated API URLs from `foodq.pages.dev` to `api.foodqapp.com`

### 4. API Routing Worker ✅
- **Files Created:**
  - `api-worker.js` - Main routing logic
  - `api-wrangler.toml` - Worker configuration
- **Purpose:** Routes `api.foodqapp.com` requests to appropriate functions

## Deployment Steps

### Prerequisites
1. Cloudflare account with domain `foodqapp.com` added
2. Wrangler CLI installed and authenticated
3. Node.js for building admin portal

### Step 1: Deploy API Router Worker
```bash
wrangler deploy --config api-wrangler.toml
```

### Step 2: Deploy Landing Page
```bash
cd landing-page
wrangler pages deploy . --project-name foodq-landing
cd ..
```

### Step 3: Deploy Admin Portal
```bash
cd admin-client
npm install
npm run build
wrangler pages deploy dist --project-name foodq-admin
cd ..
```

### Step 4: Configure DNS Records
In your Cloudflare dashboard, add these DNS records:

| Type  | Name  | Target                           | TTL  |
|-------|-------|----------------------------------|------|
| CNAME | @     | foodq-landing.pages.dev         | Auto |
| CNAME | api   | foodq-api-router.{domain}.workers.dev | Auto |
| CNAME | admin | foodq-admin.pages.dev           | Auto |

### Step 5: Custom Domain Configuration
For each Cloudflare Pages project:
1. Go to project settings
2. Add custom domain:
   - Landing: `foodqapp.com`
   - Admin: `admin.foodqapp.com`

## Testing

### Manual Testing
```bash
# Test health endpoints
curl https://api.foodqapp.com/health
curl https://foodqapp.com
curl https://admin.foodqapp.com

# Test API endpoints
curl https://api.foodqapp.com/deals
curl https://api.foodqapp.com/businesses
```

### Automated Testing
```bash
node test-endpoints.js
```

### Mobile App Testing
1. Update app configuration to use `https://api.foodqapp.com`
2. Test all API calls in development
3. Verify functionality before production release

## Migration Timeline

### Phase 1: Preparation ✅
- [x] Update mobile app configuration
- [x] Create landing page
- [x] Update admin portal
- [x] Create API routing worker

### Phase 2: Deployment
- [ ] Deploy all components to Cloudflare
- [ ] Configure DNS records
- [ ] Set up custom domains
- [ ] Test all endpoints

### Phase 3: Verification
- [ ] Comprehensive testing
- [ ] Mobile app testing
- [ ] Performance verification
- [ ] SSL certificate validation

### Phase 4: Cutover
- [ ] Update mobile app production build
- [ ] Monitor for issues
- [ ] Gradual traffic migration
- [ ] Deprecate old endpoints

## Rollback Plan

If issues arise, rollback steps:

1. **DNS Rollback:** Remove custom domain DNS records
2. **Mobile App:** Revert to `foodq.pages.dev` endpoints
3. **Admin Portal:** Use original configuration
4. **API:** Continue using original functions

## Environment Variables

### Production
```
API_BASE_URL=https://api.foodqapp.com
SUPABASE_URL=https://zobhorsszzthyljriiim.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Development
```
API_BASE_URL=http://localhost:8080
SUPABASE_URL=https://zobhorsszzthyljriiim.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Security Considerations

1. **HTTPS Only:** All domains use HTTPS with automatic certificates
2. **CORS:** Proper CORS headers configured
3. **Security Headers:** CSP, HSTS, and other security headers
4. **API Authentication:** Bearer token authentication maintained

## Performance Optimizations

1. **CDN:** Cloudflare global CDN for all endpoints
2. **Caching:** Appropriate cache headers for static assets
3. **Compression:** Automatic compression for text resources
4. **Image Optimization:** WebP support where available

## Monitoring

After migration, monitor:
- API response times
- Error rates
- DNS resolution times
- SSL certificate status
- Mobile app crash rates

## Support

For issues during migration:
1. Check Cloudflare dashboard for deployment status
2. Verify DNS propagation: `dig foodqapp.com`
3. Test endpoints individually
4. Check mobile app logs for API errors

## Completion Checklist

- [x] Mobile app API configuration updated
- [x] Landing page created and ready for deployment
- [x] Admin portal updated for new domain structure
- [x] API routing worker created
- [ ] All components deployed to Cloudflare
- [ ] DNS records configured
- [ ] Custom domains set up
- [ ] End-to-end testing completed
- [ ] Mobile app tested with new endpoints
- [ ] Production deployment approved