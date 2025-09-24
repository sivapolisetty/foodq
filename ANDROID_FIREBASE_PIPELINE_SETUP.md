# Android Firebase App Distribution Pipeline Setup Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Console Setup](#firebase-console-setup)
3. [Generate Firebase CLI Token](#generate-firebase-cli-token)
4. [Configure GitHub Secrets](#configure-github-secrets)
5. [Test the Pipeline](#test-the-pipeline)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### ✅ Already Completed
- ✓ Firebase project created (`foodqapp-c6b03`)
- ✓ Android app registered in Firebase
- ✓ `google-services.json` added to project
- ✓ Fastlane configured with Firebase plugin
- ✓ GitHub Actions workflow configured

### 📋 Still Needed
- Firebase CLI token for authentication
- Firebase App Distribution enabled
- Tester groups configured

---

## Firebase Console Setup

### Step 1: Enable Firebase App Distribution

1. **Open Firebase Console**
   - URL: `https://console.firebase.google.com/`
   - Select project: `foodqapp-c6b03`

2. **Navigate to App Distribution**
   - In left sidebar, find "Release & Monitor" section
   - Click on "App Distribution"
   - If prompted, click "Get Started"

3. **Verify Android App**
   - You should see: `com.foodqapp.foodqapp`
   - If not visible, click "Add app" and select your Android app

### Step 2: Create Tester Groups

1. **Go to Testers & Groups Tab**
   - Click "Testers & Groups" in App Distribution
   - Click "Add group" button

2. **Create Beta Testers Group**
   ```
   Group name: beta-testers
   Description: Beta testing group for FoodQ Android app
   ```

3. **Add Testers**
   - Click "Add testers"
   - Enter email addresses (comma-separated):
   ```
   tester1@example.com,
   tester2@example.com,
   your-email@example.com
   ```
   - Click "Add"

4. **Create Additional Groups (Optional)**
   ```
   Group name: internal-testers
   Description: Internal team members
   
   Group name: qa-testers
   Description: QA team
   ```

---

## Generate Firebase CLI Token

### Option A: Using Terminal (Recommended)

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Generate CI Token**
   ```bash
   firebase login:ci
   ```

3. **Follow the Browser Flow**
   - Browser will open automatically
   - Select your Google account
   - Grant permissions
   - Copy the token displayed in terminal

4. **Save the Token**
   ```
   Your Firebase CI Token:
   1//0e-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   
   ⚠️ Save this token securely - you'll need it for GitHub Secrets
   ```

### Option B: Using Docker (If npm not available)

```bash
docker run -it node:18 bash
npm install -g firebase-tools
firebase login:ci --no-localhost
# Follow the URL and enter code
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

#### Secret 1: FIREBASE_TOKEN
```
Name: FIREBASE_TOKEN
Value: [Token from previous step]
Example: 1//0e-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### Secret 2: FIREBASE_PROJECT_ID
```
Name: FIREBASE_PROJECT_ID
Value: foodqapp-c6b03
```

#### Secret 3: FIREBASE_APP_ID_ANDROID
```
Name: FIREBASE_APP_ID_ANDROID
Value: 1:502878691558:android:b0fab1f84f3ad17af61b27
```

### Step 3: Add Optional Secrets

#### For Google Play Store (Future)
```
Name: GOOGLE_PLAY_JSON_KEY_CONTENT
Value: [Contents of service account JSON]
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
   - Check: ✅ Deploy to Android Firebase
   - Click green "Run workflow" button

4. **Monitor Progress**
   - Click on the running workflow
   - Watch the logs in real-time
   - Check for any errors

### Method 2: Trigger via Code Push

1. **Make a Change in mobile-client**
   ```bash
   cd mobile-client
   echo "// Deployment test" >> lib/main.dart
   ```

2. **Commit and Push**
   ```bash
   git add .
   git commit -m "test: Android Firebase deployment"
   git push origin main
   ```

3. **Check GitHub Actions**
   - Workflow should trigger automatically
   - Monitor in Actions tab

### Method 3: Local Testing

1. **Set Environment Variables**
   ```bash
   export FIREBASE_TOKEN="your-token-here"
   export FIREBASE_PROJECT_ID="foodqapp-c6b03"
   export FIREBASE_APP_ID_ANDROID="1:502878691558:android:b0fab1f84f3ad17af61b27"
   ```

2. **Run Fastlane**
   ```bash
   cd mobile-client/android
   bundle install
   bundle exec fastlane beta
   ```

---

## Verify Deployment

### Step 1: Check Firebase Console

1. **Open App Distribution**
   - Firebase Console → App Distribution
   - Select "Releases" tab

2. **Verify New Release**
   - You should see new release
   - Version: `1.0.0 (16)`
   - Status: "Distributed"
   - Groups: "beta-testers"

### Step 2: Check Tester Emails

Testers receive email with:
- Subject: "You're invited to test FoodQ"
- Download link
- Installation instructions

### Step 3: Install on Test Device

1. **Open Email on Android Device**
2. **Click "Download" Link**
3. **Install Firebase App Tester** (if prompted)
4. **Download and Install APK**

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Firebase Token Invalid
```
Error: Failed to authenticate, have you run firebase login?
```
**Solution:**
- Regenerate token: `firebase login:ci`
- Update GitHub Secret

#### 2. App ID Not Found
```
Error: App with ID 1:xxx:android:xxx not found
```
**Solution:**
- Verify App ID in Firebase Console
- Check `google-services.json` matches

#### 3. Tester Group Not Found
```
Error: Group 'beta-testers' not found
```
**Solution:**
- Create group in Firebase Console
- Ensure exact name match (case-sensitive)

#### 4. APK Build Failed
```
Error: Gradle build failed
```
**Solution:**
```bash
cd mobile-client
flutter clean
flutter pub get
flutter build apk --release
```

#### 5. Permission Denied
```
Error: Permission denied for project
```
**Solution:**
- Check Firebase project permissions
- Regenerate token with correct account

### Debug Commands

```bash
# Test Firebase CLI
firebase projects:list

# Test specific project
firebase use foodqapp-c6b03

# Test App Distribution
firebase appdistribution:distribute \
  --app 1:502878691558:android:b0fab1f84f3ad17af61b27 \
  --groups "beta-testers" \
  mobile-client/build/app/outputs/flutter-apk/app-release.apk

# Check GitHub Secrets (in workflow)
echo "Token exists: ${{ secrets.FIREBASE_TOKEN != '' }}"
```

---

## Pipeline Configuration Summary

### GitHub Workflow Triggers
- **Automatic**: Push to `main` with changes in `mobile-client/`
- **Manual**: Workflow dispatch with Android option

### Build Process
1. Checkout code
2. Setup Flutter (3.24.3)
3. Setup Java (17)
4. Install dependencies
5. Build release APK
6. Upload to Firebase App Distribution

### Distribution Settings
- **Target Group**: `beta-testers`
- **Build Format**: APK (not AAB)
- **Release Notes**: Auto-generated with timestamp

---

## Security Best Practices

1. **Token Management**
   - Rotate Firebase tokens every 90 days
   - Never commit tokens to repository
   - Use GitHub Secrets for all credentials

2. **Access Control**
   - Limit Firebase project access
   - Use service accounts with minimal permissions
   - Review tester list regularly

3. **Build Security**
   - Sign APKs properly
   - Enable ProGuard/R8 for release builds
   - Implement certificate pinning

---

## Next Steps

1. ✅ **Complete This Setup First**
2. 🔄 **Test Pipeline End-to-End**
3. 📱 **Install on Test Devices**
4. 🚀 **Future Enhancements**:
   - Add Crashlytics integration
   - Implement automatic version bumping
   - Add Slack/Discord notifications
   - Configure different tracks (alpha, beta, production)

---

## Quick Reference

### Required GitHub Secrets
```yaml
FIREBASE_TOKEN: "1//0e-xxxxx..."
FIREBASE_PROJECT_ID: "foodqapp-c6b03"
FIREBASE_APP_ID_ANDROID: "1:502878691558:android:b0fab1f84f3ad17af61b27"
```

### Key URLs
- Firebase Console: https://console.firebase.google.com/
- App Distribution: https://console.firebase.google.com/project/foodqapp-c6b03/appdistribution
- GitHub Actions: https://github.com/[your-username]/foodqapp/actions

### Support Commands
```bash
# Check setup
cd mobile-client
./test_firebase_deployment.sh

# Manual deploy
cd android
bundle exec fastlane beta

# View logs
firebase functions:log
```

---

## Completion Checklist

- [ ] Firebase App Distribution enabled
- [ ] Beta testers group created
- [ ] Firebase CLI token generated
- [ ] GitHub Secrets configured
- [ ] Test build deployed successfully
- [ ] Testers received invitation emails
- [ ] APK installed on test device

Once all items are checked, your Android pipeline is fully operational! 🎉