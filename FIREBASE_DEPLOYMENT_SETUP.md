# Firebase App Distribution Setup Guide

This guide will help you set up Firebase App Distribution for your Android app deployment pipeline.

## Prerequisites

1. **Firebase Project**: You already have a Firebase project (`foodqapp-c6b03`) configured
2. **GitHub Repository**: Your repository is set up with GitHub Actions
3. **Android App**: Your app is already configured with Firebase (google-services.json is present)

## Step 1: Enable Firebase App Distribution

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `foodqapp-c6b03`
3. In the left sidebar, click on "App Distribution"
4. If prompted, enable App Distribution for your project
5. Make sure your Android app is listed and connected

## Step 2: Create a Tester Group

1. In Firebase App Distribution, go to "Testers & Groups"
2. Click "Add group"
3. Name the group: `beta-testers`
4. Add email addresses of people who should receive the beta builds
5. Save the group

## Step 3: Get Firebase CLI Token

You need a Firebase CLI token for GitHub Actions to authenticate with Firebase.

### Option A: Local Setup (if you have Firebase CLI installed)
```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login and get token
firebase login:ci
```

### Option B: GitHub Codespaces/Online
If you're using GitHub Codespaces or don't have local access:

1. Go to [Firebase CI Token Generator](https://firebase.tools/ci)
2. Follow the steps to authenticate and generate a token
3. Copy the generated token

## Step 4: Get Firebase App ID for Android

1. In Firebase Console, go to "Project Settings" (gear icon)
2. Scroll down to "Your apps" section
3. Find your Android app
4. Copy the "App ID" (starts with `1:502878691558:android:`)

From your google-services.json, it appears to be: `1:502878691558:android:b0fab1f84f3ad17af61b27`

## Step 5: Set Up GitHub Secrets

Go to your GitHub repository and add these secrets:

1. Go to `Settings` → `Secrets and variables` → `Actions`
2. Click "New repository secret" for each of the following:

### Required Secrets for Firebase App Distribution:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `FIREBASE_TOKEN` | Token from Step 3 | Firebase CLI authentication token |
| `FIREBASE_PROJECT_ID` | `foodqapp-c6b03` | Your Firebase project ID |
| `FIREBASE_APP_ID_ANDROID` | `1:502878691558:android:b0fab1f84f3ad17af61b27` | Your Android app ID from Firebase |

### Optional Secrets (for Play Store deployment):

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `GOOGLE_PLAY_JSON_KEY_CONTENT` | JSON content | Service account key for Play Store (optional) |

## Step 6: Test the Pipeline

### Manual Trigger
1. Go to your GitHub repository
2. Click "Actions" tab
3. Select "Mobile App Deployment" workflow
4. Click "Run workflow"
5. Check "Deploy to Android Firebase" option
6. Click "Run workflow"

### Automatic Trigger
Push changes to the `mobile-client/` directory in the `main` branch to trigger automatic deployment.

## Step 7: Verify Deployment

1. Check the GitHub Actions logs for any errors
2. Go to Firebase Console → App Distribution
3. You should see your app build listed
4. Beta testers in the `beta-testers` group will receive an email notification

## Troubleshooting

### Common Issues:

1. **"Permission denied" errors**: 
   - Verify your Firebase token is correct
   - Make sure App Distribution is enabled in Firebase Console

2. **"App not found" errors**: 
   - Verify the Firebase App ID is correct
   - Make sure the app is properly configured in Firebase

3. **"Group not found" errors**: 
   - Verify the `beta-testers` group exists in Firebase App Distribution
   - Check group name spelling

4. **APK build fails**: 
   - Check Flutter/Android build logs
   - Verify all dependencies are correctly configured

### Debug Commands

To test locally:

```bash
# Navigate to mobile-client directory
cd mobile-client

# Install dependencies
flutter pub get

# Test Android build
flutter build apk --release

# Test Fastlane (if you have Firebase CLI configured locally)
cd android
bundle install
bundle exec fastlane beta
```

## Security Notes

- Never commit Firebase tokens or sensitive keys to your repository
- Use GitHub Secrets for all sensitive information
- Regularly rotate your Firebase CLI tokens
- Review who has access to your Firebase project and GitHub repository

## Next Steps

Once the pipeline is working:

1. **Set up signing**: Configure proper Android app signing for production builds
2. **Customize release notes**: Modify the Fastfile to include more detailed release notes
3. **Add notifications**: Configure Slack or other notifications for successful deployments
4. **Branch strategy**: Consider setting up different deployment tracks for different branches

## Current Configuration Summary

- **Firebase Project**: `foodqapp-c6b03`
- **Android Package**: `com.foodqapp.foodqapp`
- **App Version**: Current version from pubspec.yaml (1.0.0+16)
- **Deployment Target**: Firebase App Distribution → `beta-testers` group
- **Trigger**: Push to main branch with changes in `mobile-client/` directory

Your deployment pipeline is now ready! 🚀