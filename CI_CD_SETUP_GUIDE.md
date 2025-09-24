# Complete CI/CD Pipeline Setup Guide

## Overview
This guide covers setting up automated deployment pipelines for:
1. Mobile App Distribution (iOS TestFlight & Android Play Store)
2. Cloudflare Functions Deployment
3. Admin Dashboard Deployment

## 1. Mobile App Distribution Pipeline

### Repository: `foodq-mobile-app`

### A. iOS TestFlight Deployment

#### Required Secrets:
1. **Get App Store Connect API Key:**
   - Go to [App Store Connect](https://appstoreconnect.apple.com) → Users and Access → Keys
   - Generate new API Key with "Developer" role
   - Download `.p8` file (save it securely!)
   
2. **Set GitHub Secrets:**
   ```
   APP_STORE_CONNECT_API_KEY_ID     → Key ID from App Store Connect
   APP_STORE_CONNECT_ISSUER_ID      → Issuer ID from App Store Connect  
   APP_STORE_CONNECT_API_KEY_CONTENT → Contents of .p8 file
   ```

#### Trigger Deployment:
```bash
# Tag release
git tag v1.0.20
git push origin v1.0.20

# Or manual trigger from GitHub Actions tab
```

### B. Android Play Store Deployment

#### Required Secrets:

1. **Generate Keystore (if not exists):**
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. **Encode Keystore:**
   ```bash
   base64 -i upload-keystore.jks -o keystore.txt
   ```

3. **Get Google Play Service Account:**
   - Go to [Google Play Console](https://play.google.com/console)
   - Settings → API access → Create new service account
   - Grant "Release Manager" permissions
   - Download JSON key

4. **Set GitHub Secrets:**
   ```
   ANDROID_KEYSTORE_BASE64          → Contents of keystore.txt
   ANDROID_KEYSTORE_PASSWORD        → Your keystore password
   ANDROID_KEY_ALIAS                → upload (or your alias)
   ANDROID_KEY_PASSWORD             → Your key password
   GOOGLE_PLAY_SERVICE_ACCOUNT_KEY  → JSON service account key
   ```

#### Trigger Deployment:
```bash
# Same as iOS - uses same tags
git tag v1.0.20
git push origin v1.0.20
```

### C. Firebase App Distribution (Alternative)

#### Required Secrets:
```
FIREBASE_APP_ID_ANDROID → From Firebase Console
FIREBASE_APP_ID_IOS     → From Firebase Console
FIREBASE_TOKEN          → Run: firebase login:ci
FIREBASE_PROJECT_ID     → Your Firebase project ID
```

#### Deploy to Firebase:
```bash
cd android
fastlane beta  # For Android

cd ../ios
fastlane firebase_beta  # For iOS (needs to be configured)
```

## 2. Cloudflare Functions Deployment

### Repository: `foodqapp` (main)

#### Required Secrets:

1. **Get Cloudflare API Token:**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
   - Create token with permissions:
     - Account: Cloudflare Pages:Edit
     - Account: Workers Scripts:Edit
     - Zone: Page Rules:Edit

2. **Set GitHub Secrets:**
   ```
   CLOUDFLARE_API_TOKEN    → Your API token
   CLOUDFLARE_ACCOUNT_ID   → Your account ID (from dashboard)
   ```

#### Trigger Deployment:
```bash
# Automatic on push to main
git push origin main

# Only deploys if functions/ or wrangler.toml changed
```

## 3. Admin Dashboard Deployment

### Deploy Admin Client:
```bash
cd admin-client
npm run build
npx wrangler pages deploy dist --project-name=foodq-admin
```

### Automate with GitHub Actions:

Create `.github/workflows/deploy-admin.yml`:
```yaml
name: Deploy Admin Dashboard

on:
  push:
    branches: [main]
    paths:
      - 'admin-client/**'
      
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v3
      - run: cd admin-client && npm ci && npm run build
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          command: pages deploy admin-client/dist --project-name=foodq-admin
```

## 4. Environment Configuration

### Mobile App Environments:

```bash
# Development
.env.development
API_BASE_URL=http://localhost:8787/api

# Staging  
.env.staging
API_BASE_URL=https://foodq-staging.pages.dev/api

# Production
.env.production
API_BASE_URL=https://foodq.pages.dev/api
```

### Function Environments:

```bash
# Local development
wrangler dev

# Staging deployment
wrangler deploy --env staging

# Production deployment
wrangler deploy --env production
```

## 5. Deployment Commands Quick Reference

### Mobile App:
```bash
# iOS TestFlight
cd ios && fastlane beta

# Android Internal Testing
cd android && fastlane internal

# Firebase App Distribution
cd android && fastlane beta
```

### Functions:
```bash
# Deploy all functions
wrangler deploy

# Deploy specific worker
wrangler deploy cdn-worker.js --name foodq-cdn

# Deploy to Pages
wrangler pages deploy functions --project-name=foodq
```

### Admin Dashboard:
```bash
cd admin-client
npm run build
wrangler pages deploy dist --project-name=foodq-admin
```

## 6. Monitoring & Rollback

### Monitor Deployments:
- **Mobile**: Check GitHub Actions tab for build status
- **Functions**: Cloudflare Dashboard → Workers & Pages
- **Crashes**: Firebase Crashlytics (if configured)

### Rollback if Needed:
```bash
# Functions - rollback to previous version
wrangler rollback

# Mobile - can't rollback, push fix as new version
git tag v1.0.21-hotfix
git push origin v1.0.21-hotfix
```

## 7. Testing Pipeline

Before deploying:
```bash
# Run all tests
flutter test
npm test

# Integration tests
flutter test integration_test/

# Build smoke test
flutter build apk --debug
flutter build ios --debug
```

## 8. Security Notes

- Never commit secrets to repository
- Rotate API keys regularly
- Use environment-specific keys
- Enable 2FA on all service accounts
- Review GitHub Actions logs for exposed secrets

## Support

For issues with:
- **iOS deployment**: Check Xcode logs and TestFlight status
- **Android deployment**: Check Play Console and build logs
- **Functions**: Check Cloudflare Workers logs
- **GitHub Actions**: Check workflow run logs

---

Last Updated: 2024-09-24