# Mobile Deployment Quick Setup Guide

## 🚀 Quick Action Items

This guide provides step-by-step actions you need to take in your browser to set up both iOS and Android deployment pipelines.

---

## Part 1: Android Setup (Firebase) - 30 minutes

### 📱 Browser Actions Required:

1. **Firebase Console Setup**
   - [ ] Open: https://console.firebase.google.com/
   - [ ] Select: `foodqapp-c6b03` project
   - [ ] Click: "App Distribution" in left sidebar
   - [ ] Click: "Get Started" if prompted
   - [ ] Click: "Testers & Groups" tab
   - [ ] Click: "Add group"
   - [ ] Enter: Group name = `beta-testers`
   - [ ] Click: "Add testers"
   - [ ] Enter: Your email and test emails
   - [ ] Click: "Save"

2. **Generate Firebase Token** (Terminal)
   ```bash
   npm install -g firebase-tools
   firebase login:ci
   ```
   - [ ] Copy the token that appears after login

3. **GitHub Secrets Setup**
   - [ ] Open: https://github.com/[your-username]/foodqapp/settings/secrets/actions
   - [ ] Click: "New repository secret"
   
   **Add these 3 secrets:**
   
   | Click "New repository secret" | Name | Value |
   |------|------|--------|
   | 1st Secret | `FIREBASE_TOKEN` | [Token from step 2] |
   | 2nd Secret | `FIREBASE_PROJECT_ID` | `foodqapp-c6b03` |
   | 3rd Secret | `FIREBASE_APP_ID_ANDROID` | `1:502878691558:android:b0fab1f84f3ad17af61b27` |

4. **Test Android Deployment**
   - [ ] Open: https://github.com/[your-username]/foodqapp/actions
   - [ ] Click: "Mobile App Deployment" workflow
   - [ ] Click: "Run workflow"
   - [ ] Check: ✅ Deploy to Android Firebase
   - [ ] Click: Green "Run workflow" button
   - [ ] Wait for completion (5-10 minutes)

---

## Part 2: iOS Setup (TestFlight) - 45 minutes

### 🍎 Browser Actions Required:

1. **Apple Developer Portal**
   - [ ] Open: https://developer.apple.com/account
   - [ ] Click: "Certificates, Identifiers & Profiles"
   - [ ] Click: "Identifiers" → "+"
   - [ ] Select: "App IDs" → Continue
   - [ ] Select: "App" → Continue
   - [ ] Enter: Description = `FoodQ App`
   - [ ] Enter: Bundle ID = `com.foodqapp.foodqapp`
   - [ ] Enable: Push Notifications (if needed)
   - [ ] Click: "Continue" → "Register"

2. **App Store Connect - Create App**
   - [ ] Open: https://appstoreconnect.apple.com
   - [ ] Click: "My Apps"
   - [ ] Click: "+" → "New App"
   - [ ] Select: Platform = iOS
   - [ ] Enter: Name = `FoodQ`
   - [ ] Select: Primary Language = English (US)
   - [ ] Select: Bundle ID = `com.foodqapp.foodqapp`
   - [ ] Enter: SKU = `FOODQ001`
   - [ ] Click: "Create"

3. **TestFlight Setup**
   - [ ] In your app, click: "TestFlight" tab
   - [ ] Fill: Beta App Description
   - [ ] Enter: Feedback Email
   - [ ] Click: "Internal Testing" → "+"
   - [ ] Enter: Group Name = `Internal Team`
   - [ ] Add: Your Apple ID email
   - [ ] Click: "External Testing" → "+"
   - [ ] Enter: Group Name = `Beta Testers`

4. **Generate API Key**
   - [ ] Click: "Users and Access"
   - [ ] Click: "Integrations" tab
   - [ ] Click: "App Store Connect API" → "+"
   - [ ] Enter: Name = `FoodQ CI/CD Pipeline`
   - [ ] Select: Access = App Manager
   - [ ] Click: "Generate"
   - [ ] **IMPORTANT**: Download .p8 file NOW (only chance!)
   - [ ] Copy: Issuer ID (top of page)
   - [ ] Copy: Key ID (in the list)

5. **GitHub Secrets Setup**
   - [ ] Open: https://github.com/[your-username]/foodqapp/settings/secrets/actions
   
   **Add these 3 secrets:**
   
   | Click "New repository secret" | Name | Value |
   |------|------|--------|
   | 1st Secret | `APP_STORE_CONNECT_API_KEY_ID` | [Key ID from step 4] |
   | 2nd Secret | `APP_STORE_CONNECT_ISSUER_ID` | [Issuer ID from step 4] |
   | 3rd Secret | `APP_STORE_CONNECT_API_KEY_CONTENT` | [Entire contents of .p8 file] |

6. **Test iOS Deployment**
   - [ ] Open: https://github.com/[your-username]/foodqapp/actions
   - [ ] Click: "Mobile App Deployment" workflow
   - [ ] Click: "Run workflow"
   - [ ] Check: ✅ Deploy to iOS TestFlight
   - [ ] Click: Green "Run workflow" button
   - [ ] Wait for completion (20-30 minutes)
   - [ ] Check email for TestFlight notification

---

## 📋 Verification Checklist

### Android (Firebase)
- [ ] Check Firebase Console: New release visible
- [ ] Email received: Beta test invitation
- [ ] APK installs: On Android test device

### iOS (TestFlight)
- [ ] Check App Store Connect: Build processing/ready
- [ ] Email received: TestFlight available
- [ ] App installs: Via TestFlight app

---

## 🔧 Quick Troubleshooting

### If Android fails:
```bash
# Regenerate Firebase token
firebase login:ci
# Update FIREBASE_TOKEN secret in GitHub
```

### If iOS fails:
```bash
# Check bundle ID matches exactly
grep PRODUCT_BUNDLE_IDENTIFIER mobile-client/ios/Runner.xcodeproj/project.pbxproj
# Should show: com.foodqapp.foodqapp
```

---

## 📞 Need Help?

1. **Check detailed guides:**
   - Android: `ANDROID_FIREBASE_PIPELINE_SETUP.md`
   - iOS: `IOS_TESTFLIGHT_PIPELINE_SETUP.md`

2. **Common URLs:**
   - Firebase Console: https://console.firebase.google.com/project/foodqapp-c6b03
   - App Store Connect: https://appstoreconnect.apple.com
   - GitHub Actions: https://github.com/[your-username]/foodqapp/actions

3. **Test locally first:**
   ```bash
   # Android
   cd mobile-client
   ./test_firebase_deployment.sh
   
   # iOS (on Mac)
   cd mobile-client/ios
   bundle exec fastlane build_local
   ```

---

## ✅ Success Indicators

You know setup is complete when:
1. ✅ GitHub Actions workflow runs without errors
2. ✅ Android: APK appears in Firebase Console
3. ✅ iOS: Build appears in TestFlight
4. ✅ Test devices can install both apps
5. ✅ Automatic triggers work on push to main

---

## 🎯 Total Time Estimate

- Android Setup: 30 minutes
- iOS Setup: 45 minutes
- Testing Both: 15 minutes
- **Total: ~90 minutes**

Good luck with your deployment! 🚀