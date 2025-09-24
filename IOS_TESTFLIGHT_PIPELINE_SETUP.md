# iOS TestFlight Pipeline Setup Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Apple Developer Portal Setup](#apple-developer-portal-setup)
3. [App Store Connect Setup](#app-store-connect-setup)
4. [Generate API Keys](#generate-api-keys)
5. [Configure GitHub Secrets](#configure-github-secrets)
6. [Test the Pipeline](#test-the-pipeline)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### ✅ Already Completed
- ✓ Apple Developer Account ($99/year)
- ✓ Xcode installed
- ✓ Flutter iOS configuration
- ✓ Fastlane configured for iOS
- ✓ GitHub Actions workflow configured

### 📋 Still Needed
- App ID registration in Apple Developer Portal
- App creation in App Store Connect
- API keys for automation
- TestFlight configuration

---

## Apple Developer Portal Setup

### Step 1: Register App Identifier

1. **Open Apple Developer Portal**
   - URL: `https://developer.apple.com/account`
   - Sign in with Apple ID

2. **Navigate to Identifiers**
   - Click "Certificates, Identifiers & Profiles"
   - Select "Identifiers" from left sidebar
   - Click "+" button (blue plus icon)

3. **Create App ID**
   ```
   Register a new identifier:
   ✓ App IDs
   → Continue
   
   Select a type:
   ✓ App
   → Continue
   ```

4. **Configure App ID**
   ```
   Description: FoodQ App
   Bundle ID: Explicit
   Value: com.foodqapp.foodqapp
   ```

5. **Enable Capabilities**
   - ✅ Push Notifications (if needed)
   - ✅ Sign in with Apple (if using)
   - ✅ Associated Domains (if using deep links)
   - Click "Continue" → "Register"

### Step 2: Create Provisioning Profiles (Optional - Fastlane will handle)

Fastlane match will automatically manage certificates and profiles, but if manual setup needed:

1. **Development Profile**
   - Profiles → "+" → iOS App Development
   - Select App ID: `com.foodqapp.foodqapp`
   - Select certificates and devices
   - Name: `FoodQ Development`

2. **Distribution Profile**
   - Profiles → "+" → App Store
   - Select App ID: `com.foodqapp.foodqapp`
   - Select distribution certificate
   - Name: `FoodQ Distribution`

---

## App Store Connect Setup

### Step 1: Create New App

1. **Open App Store Connect**
   - URL: `https://appstoreconnect.apple.com`
   - Sign in with Apple ID

2. **Navigate to My Apps**
   - Click "My Apps" icon
   - Click "+" button → "New App"

3. **Configure App Information**
   ```
   Platform: ✓ iOS
   Name: FoodQ
   Primary Language: English (US)
   Bundle ID: com.foodqapp.foodqapp (select from dropdown)
   SKU: FOODQ001 (unique identifier)
   User Access: Full Access
   ```

4. **Click "Create"**

### Step 2: Configure App Information

1. **General Information**
   ```
   Category: Food & Drink
   Secondary Category: Shopping
   Content Rights: ✓ No third-party content
   Age Rating: 4+
   ```

2. **App Privacy**
   - Click "Get Started" on Privacy Policy
   - Answer privacy questions
   - Add Privacy Policy URL

### Step 3: Setup TestFlight

1. **Navigate to TestFlight Tab**
   - In your app, click "TestFlight"

2. **Configure Test Information**
   ```
   Beta App Description: 
   FoodQ is a food delivery app that connects users 
   with local restaurants offering deals and discounts.
   
   Feedback Email: beta@foodqapp.com
   Marketing URL: https://foodqapp.com (optional)
   ```

3. **Create Internal Testing Group**
   - Click "Internal Testing" → "+"
   - Name: `Internal Team`
   - Add team members (must be in App Store Connect)

4. **Create External Testing Group**
   - Click "External Testing" → "+"
   - Name: `Beta Testers`
   - Add up to 10,000 email addresses

---

## Generate API Keys

### Step 1: Create App Store Connect API Key

1. **Navigate to API Keys**
   - App Store Connect → "Users and Access"
   - Click "Integrations" tab
   - Select "App Store Connect API"

2. **Generate New Key**
   - Click "Generate API Key" or "+"
   - Name: `FoodQ CI/CD Pipeline`
   - Access: `App Manager`
   - Click "Generate"

3. **Download and Save Key**
   ```
   ⚠️ IMPORTANT: Download .p8 file immediately
   You can only download this file ONCE!
   
   Save these values:
   - Issuer ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   - Key ID: XXXXXXXXXX
   - Download: AuthKey_XXXXXXXXXX.p8
   ```

### Step 2: Prepare Key for GitHub

1. **Open .p8 File**
   ```bash
   cat ~/Downloads/AuthKey_XXXXXXXXXX.p8
   ```

2. **Copy Contents**
   ```
   -----BEGIN PRIVATE KEY-----
   [Multiple lines of base64 encoded key]
   -----END PRIVATE KEY-----
   ```

---

## Configure GitHub Secrets

### Step 1: Navigate to Repository Settings

1. **Open GitHub Repository**
   - URL: `https://github.com/[your-username]/foodqapp`
   - Click "Settings" tab

2. **Access Secrets Section**
   - Left sidebar → "Secrets and variables"
   - Click "Actions"

### Step 2: Add Required Secrets

Click "New repository secret" for each:

#### Secret 1: APP_STORE_CONNECT_API_KEY_ID
```
Name: APP_STORE_CONNECT_API_KEY_ID
Value: XXXXXXXXXX
(10-character Key ID from App Store Connect)
```

#### Secret 2: APP_STORE_CONNECT_ISSUER_ID
```
Name: APP_STORE_CONNECT_ISSUER_ID
Value: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
(UUID format Issuer ID from App Store Connect)
```

#### Secret 3: APP_STORE_CONNECT_API_KEY_CONTENT
```
Name: APP_STORE_CONNECT_API_KEY_CONTENT
Value: 
-----BEGIN PRIVATE KEY-----
[Paste entire contents of .p8 file including BEGIN/END lines]
-----END PRIVATE KEY-----
```

---

## Test the Pipeline

### Method 1: Manual Trigger via GitHub Actions

1. **Navigate to Actions Tab**
   - Go to your repository
   - Click "Actions" tab

2. **Select Workflow**
   - Find "Mobile App Deployment"
   - Click on the workflow

3. **Run Workflow**
   - Click "Run workflow" button
   - Select branch: `main`
   - Check: ✅ Deploy to iOS TestFlight
   - Click green "Run workflow" button

4. **Monitor Progress**
   - Click on the running workflow
   - Watch "build-ios" job
   - Check for any errors

### Method 2: Local Testing

1. **Prepare Environment**
   ```bash
   cd mobile-client/ios
   bundle install
   pod install
   ```

2. **Test Build**
   ```bash
   # Test build without upload
   bundle exec fastlane build_local
   ```

3. **Test Full Pipeline** (requires API keys)
   ```bash
   export APP_STORE_CONNECT_API_KEY_ID="XXXXXXXXXX"
   export APP_STORE_CONNECT_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   export APP_STORE_CONNECT_API_KEY_CONTENT="$(cat ~/Downloads/AuthKey_XXXXXXXXXX.p8)"
   
   bundle exec fastlane beta
   ```

---

## Verify Deployment

### Step 1: Check App Store Connect

1. **Monitor Processing**
   - App Store Connect → Your App → TestFlight
   - New build appears with status "Processing"
   - Takes 15-30 minutes typically

2. **Build States**
   ```
   Processing → Ready to Submit → Ready for Testing
   ```

3. **Email Notifications**
   - You'll receive email when processing completes
   - Another when ready for testing

### Step 2: Configure Build for Testing

1. **For Internal Testing**
   - Automatically available to internal group
   - No review required

2. **For External Testing**
   - Click on build number
   - Add to external group
   - Submit for review (first time only)
   - Add test notes:
   ```
   Test Account: test@example.com
   Password: TestPassword123
   
   Features to test:
   - User registration and login
   - Browse restaurants and deals
   - Place orders
   ```

### Step 3: Install via TestFlight

1. **On iOS Device**
   - Download TestFlight app from App Store
   - Sign in with Apple ID (tester email)
   - Accept invitation
   - Install app

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Certificate/Profile Issues
```
Error: No signing certificate "iOS Distribution" found
```
**Solution:**
```bash
# Use Fastlane match to sync certificates
bundle exec fastlane match appstore
```

#### 2. Invalid API Key
```
Error: Authentication credentials are missing or invalid
```
**Solution:**
- Verify Key ID and Issuer ID correct
- Check .p8 content includes BEGIN/END lines
- Regenerate key if needed

#### 3. Build Number Already Exists
```
Error: Build number (16) has already been used
```
**Solution:**
- Increment build number in pubspec.yaml
- Or let Fastlane auto-increment

#### 4. App Not Found
```
Error: Could not find app with bundle identifier
```
**Solution:**
- Verify bundle ID matches exactly
- Check app exists in App Store Connect
- Ensure app status is not "Removed"

#### 5. Processing Takes Too Long
**Normal Processing Times:**
- Small app: 15-30 minutes
- Large app: 30-60 minutes
- First submission: Can take longer

**If stuck > 2 hours:**
- Check Apple System Status
- Contact Apple Developer Support

### Debug Commands

```bash
# Verify Xcode setup
xcodebuild -showBuildSettings -workspace ios/Runner.xcworkspace -scheme Runner

# Check bundle identifier
grep PRODUCT_BUNDLE_IDENTIFIER ios/Runner.xcodeproj/project.pbxproj

# Verify certificates
security find-identity -p codesigning -v

# Test API connection
xcrun altool --list-apps --apiKey XXXXXXXXXX --apiIssuer xxxxxxxx

# Check Fastlane configuration
bundle exec fastlane lanes
```

---

## Build Configuration

### Version Management

**In pubspec.yaml:**
```yaml
version: 1.0.0+16
         ↑     ↑
    version  build
```

**Auto-increment in Fastlane:**
```ruby
increment_build_number(
  build_number: latest_testflight_build_number + 1
)
```

### Build Settings

**Release Configuration:**
- Optimization: Smallest, Fastest
- Bitcode: Enabled
- Strip Swift Symbols: Yes
- Dead Code Stripping: Yes

---

## Security Best Practices

1. **API Key Management**
   - Store .p8 file securely
   - Never commit to repository
   - Rotate keys annually
   - Use least privilege access

2. **Code Signing**
   - Use Fastlane match for team sharing
   - Store certificates in encrypted git repo
   - Regular certificate renewal

3. **TestFlight Security**
   - Review external testers carefully
   - Use test accounts for demos
   - Don't include production data

---

## Advanced Configuration

### Fastlane Match Setup (Optional)

For team certificate sharing:

```bash
# Initialize match
bundle exec fastlane match init

# Sync certificates
bundle exec fastlane match development
bundle exec fastlane match appstore
```

### Multiple Environments

```ruby
# In Fastfile
lane :beta do
  build_app(
    scheme: "Runner",
    configuration: "Release-Beta",
    export_options: {
      method: "app-store",
      provisioningProfiles: {
        "com.foodqapp.foodqapp" => "FoodQ Beta"
      }
    }
  )
end

lane :production do
  build_app(
    scheme: "Runner",
    configuration: "Release",
    export_options: {
      method: "app-store"
    }
  )
end
```

---

## Next Steps

1. ✅ **Complete Basic Setup**
2. 🔄 **Test Full Pipeline**
3. 📱 **Distribute to Beta Testers**
4. 🚀 **Future Enhancements**:
   - Implement Crashlytics
   - Add performance monitoring
   - Configure push notifications
   - Set up App Store screenshots automation
   - Implement phased rollout

---

## Quick Reference

### Required GitHub Secrets
```yaml
APP_STORE_CONNECT_API_KEY_ID: "XXXXXXXXXX"
APP_STORE_CONNECT_ISSUER_ID: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
APP_STORE_CONNECT_API_KEY_CONTENT: |
  -----BEGIN PRIVATE KEY-----
  [key content]
  -----END PRIVATE KEY-----
```

### Key URLs
- Apple Developer: https://developer.apple.com
- App Store Connect: https://appstoreconnect.apple.com
- TestFlight: https://testflight.apple.com
- System Status: https://developer.apple.com/system-status/

### Support Commands
```bash
# Full deployment
cd mobile-client/ios
bundle exec fastlane beta

# Check setup
flutter doctor -v
xcodebuild -version

# View certificates
security find-identity -v -p codesigning
```

---

## Completion Checklist

### Apple Developer Portal
- [ ] App ID registered
- [ ] Push notifications enabled (if needed)
- [ ] Provisioning profiles created (or using match)

### App Store Connect
- [ ] App created
- [ ] App information filled
- [ ] TestFlight configured
- [ ] Test groups created

### GitHub Configuration
- [ ] API Key generated
- [ ] Secrets configured
- [ ] Workflow tested

### Testing
- [ ] Build uploaded successfully
- [ ] Processing completed
- [ ] TestFlight invitation received
- [ ] App installed on test device

Once all items are checked, your iOS pipeline is fully operational! 🎉