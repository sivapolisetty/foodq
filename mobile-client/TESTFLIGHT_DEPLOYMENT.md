# 🚀 FoodQ iOS TestFlight Deployment Guide

This guide explains how to build and deploy the FoodQ iOS app to TestFlight using the automated deployment scripts.

## 📋 Prerequisites

1. **macOS with Xcode**: Xcode 14.0 or later installed
2. **Apple Developer Account**: Active membership ($99/year)
3. **App on App Store Connect**: App must be created in App Store Connect
4. **Certificates & Provisioning**: Automatic signing configured in Xcode
5. **Flutter Environment**: Flutter SDK installed and configured

## 🔑 Initial Setup

### 1. Verify Xcode Configuration
```bash
# Open Xcode project to verify settings
open ios/Runner.xcworkspace
```

Ensure:
- Team ID is set to `456ZSP6395`
- Bundle ID is `com.foodq.foodq`
- Automatic signing is enabled

### 2. Create App-Specific Password

For automated uploads, you need an app-specific password:

1. Go to [Apple ID Account](https://appleid.apple.com/account/manage)
2. Sign in and navigate to **Security**
3. Under **App-Specific Passwords**, click **Generate Password**
4. Name it "FoodQ TestFlight"
5. Copy the generated password

## 🚀 Deployment Methods

### Method 1: Automated Deployment Script (Recommended)

The easiest way to deploy to TestFlight:

```bash
cd mobile-client
./deploy_testflight.sh
```

This script will:
- Prompt for Apple ID credentials (first time only)
- Auto-increment build number
- Build the iOS release
- Create archive and IPA
- Upload to TestFlight automatically

### Method 2: Direct Build Script

If you prefer manual upload:

```bash
cd mobile-client
./build_and_deploy.sh
```

This will build the app and provide instructions for manual upload.

### Method 3: Using Fastlane

For more control over the process:

```bash
cd mobile-client/ios
bundle exec fastlane beta
```

## 📱 Build Process Steps

The deployment scripts perform these steps:

1. **Clean Previous Builds**: Removes old build artifacts
2. **Increment Build Number**: Automatically updates version in `pubspec.yaml`
3. **Get Dependencies**: Installs Flutter packages
4. **Code Generation**: Runs build_runner for generated files
5. **Build iOS Release**: Creates optimized release build
6. **Create Archive**: Generates `.xcarchive` file
7. **Export IPA**: Creates IPA for TestFlight
8. **Upload to TestFlight**: Submits to App Store Connect

## 🔧 Manual Upload Options

If automatic upload fails, use one of these methods:

### Option 1: Xcode Organizer
1. Open Xcode
2. Go to **Window → Organizer**
3. Select the archive
4. Click **Distribute App**
5. Choose **App Store Connect**
6. Follow the prompts

### Option 2: Transporter App
1. Download [Transporter](https://apps.apple.com/app/transporter/id1450874784) from App Store
2. Open the IPA file: `ios/build/export/Runner.ipa`
3. Click **Deliver**

## 📊 Post-Upload Steps

After successful upload:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **TestFlight** tab
3. Wait for processing (5-10 minutes)
4. Configure test information:
   - Add testing notes
   - Set up test groups
   - Add external testers
5. Send invitations to testers

## 🔍 Troubleshooting

### Build Failures

```bash
# Clean everything and retry
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
cd ios && pod install && cd ..
```

### Signing Issues

```bash
# Open Xcode to fix signing
open ios/Runner.xcworkspace
# Go to Signing & Capabilities tab
# Ensure automatic signing is enabled
```

### Upload Authentication Errors

```bash
# Create new app-specific password
# Update credentials in .env.deploy
rm .env.deploy
./deploy_testflight.sh
```

## 📝 Version Management

Current version format in `pubspec.yaml`:
```yaml
version: 1.0.0+2
#        │ │ │  │
#        │ │ │  └─ Build number (auto-incremented)
#        │ │ └─── Patch version
#        │ └───── Minor version
#        └─────── Major version
```

Build number is automatically incremented with each deployment.

## 🔐 Security Notes

- Never commit `.env.deploy` file
- App-specific passwords are different from Apple ID password
- Store credentials securely
- Use environment variables for CI/CD

## 📦 File Locations

- **Archive**: `ios/build/Runner.xcarchive`
- **IPA**: `ios/build/export/Runner.ipa`
- **Export Options**: `ios/ExportOptions.plist`
- **Credentials**: `.env.deploy` (git-ignored)

## 🎯 Quick Commands

```bash
# Full automated deployment
./deploy_testflight.sh

# Build only (no upload)
./build_and_deploy.sh

# Using Fastlane
cd ios && bundle exec fastlane beta

# Clean build
flutter clean && flutter build ios --release

# Check current version
grep "version:" pubspec.yaml
```

## 📞 Support

For issues with:
- **Build Process**: Check Flutter and Xcode logs
- **Signing**: Verify certificates in Apple Developer Portal
- **Upload**: Check App Store Connect for processing errors
- **TestFlight**: Review test information and compliance

---

**Note**: This deployment process follows the NoenCircles pattern for consistent iOS TestFlight distribution.