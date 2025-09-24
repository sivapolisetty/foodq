# GitHub Secrets Setup Guide

## 1. Android Firebase App Distribution Secrets

### Already Generated:
```bash
ANDROID_KEYSTORE_BASE64      → [See keystore-base64.txt in mobile-client root]
ANDROID_KEYSTORE_PASSWORD    → foodq2024
ANDROID_KEY_ALIAS           → upload
ANDROID_KEY_PASSWORD        → foodq2024
```

### Firebase Credentials (Already Set Up):
```bash
FIREBASE_PROJECT_ID         → grabeat-e0e1a
FIREBASE_APP_ID_ANDROID     → 1:940145436043:android:0e221a0cb1d17613453b8e
```

### ✅ Firebase Token (Ready):
```bash
FIREBASE_TOKEN              → 1//05HbC0gVO70A-CgYIARAAGAUSNgF-L9IrMoY16hsnzFwR_W4UuTfIQRJb5MStT2gC6P0-ZixRcnxPEOLfd8ye1ViUExitqqUvcw
```

## 2. iOS App Store Secrets

**Already have credentials:**
- Apple ID: sivapolisetty913@gmail.com
- App-specific password: wwoa-tmpk-dqex-azkn

**Need App Store Connect API Key:**
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Access → Keys → Generate API Key
3. Name: "FoodQ GitHub Actions"
4. Access: Developer
5. Download .p8 file immediately!

Set these secrets:
```
APP_STORE_CONNECT_API_KEY_ID     → [Key ID from App Store]
APP_STORE_CONNECT_ISSUER_ID      → [Issuer ID from App Store]
APP_STORE_CONNECT_API_KEY_CONTENT → [Contents of .p8 file]
```

## 3. Cloudflare Secrets

### Get Account ID:
```bash
npx wrangler whoami
# Copy the Account ID from output
```

### Create API Token:
1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Create Token → Custom token
3. Permissions:
   - Account → Cloudflare Pages:Edit
   - Account → Workers Scripts:Edit
   - Zone → Workers Routes:Edit
4. Create and copy token immediately!

Set these secrets:
```
CLOUDFLARE_API_TOKEN    → [Create from Cloudflare Dashboard - see instructions above]
CLOUDFLARE_ACCOUNT_ID   → a92f51792fd6067286a48c8d67ed6452
```

## 4. Firebase Secrets (Optional - for App Distribution)

```bash
# Get Firebase token
firebase login:ci

# Set these secrets:
FIREBASE_TOKEN          → [Token from above command]
FIREBASE_PROJECT_ID     → foodq-xxxxx
FIREBASE_APP_ID_ANDROID → [From Firebase Console]
FIREBASE_APP_ID_IOS     → [From Firebase Console]
```

## 5. How to Add Secrets to GitHub

### For Mobile Repository (foodq-mobile-app):
1. Go to https://github.com/sivapolisetty/foodq-mobile-app/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret one by one

### For Main Repository (foodq):
1. Go to https://github.com/sivapolisetty/foodq/settings/secrets/actions
2. Click "New repository secret"
3. Add Cloudflare secrets

## 6. Test Deployments

### Test iOS deployment:
```bash
cd mobile-client
git tag v1.0.21
git push origin v1.0.21
# Check GitHub Actions tab
```

### Test Android deployment:
```bash
# Uses same tag as iOS
# Both will deploy from same version tag
```

### Test Functions deployment:
```bash
cd ..
git push origin main
# Auto-deploys when functions/ changes
```

## Important Files:
- `mobile-client/keystore-base64.txt` - Android keystore (keep secure!)
- `mobile-client/upload-keystore.jks` - Original keystore file
- Downloaded `.p8` file from Apple - Keep secure!
- Google Play service account JSON - Keep secure!

## Security Notes:
- Never commit these files to git
- Add to .gitignore if not already
- Rotate credentials periodically
- Use different keys for production vs staging

---
Created: 2024-09-24