# 🚀 GraBeat Mobile Deployment Guide
## NoenCircles Pattern Implementation

This document outlines the mobile deployment strategy for GraBeat, following the proven NoenCircles pattern for iOS TestFlight and Android Firebase App Distribution.

## 📱 Platform Overview

### iOS - TestFlight Distribution
- **Target**: Beta testers and internal team
- **Tool**: Fastlane + App Store Connect API
- **Automation**: GitHub Actions + Xcode Cloud
- **Distribution**: Automatic TestFlight uploads

### Android - Firebase App Distribution
- **Target**: Beta testers and QA team  
- **Tool**: Fastlane + Firebase CLI
- **Automation**: GitHub Actions
- **Distribution**: Firebase App Distribution groups

## 🔧 Local Development Setup

### Prerequisites
```bash
# Install Flutter
flutter --version  # Should be 3.24.3+

# Install Ruby (for Fastlane)
ruby --version     # Should be 3.0+

# Install Firebase CLI
npm install -g firebase-tools

# Install Fastlane
gem install fastlane
```

### iOS Setup
```bash
cd mobile-client/ios

# Install Ruby dependencies
bundle install

# Install CocoaPods dependencies
pod install

# Build locally
bundle exec fastlane build_local

# Deploy to TestFlight (requires certificates)
bundle exec fastlane beta
```

### Android Setup
```bash
cd mobile-client/android

# Install Ruby dependencies
bundle install

# Setup Firebase (one-time)
bundle exec fastlane setup_firebase

# Build locally
bundle exec fastlane build_local

# Distribute via Firebase
bundle exec fastlane beta
```

## 🔐 Environment Variables

### Required Secrets (GitHub Actions)

#### iOS TestFlight
```bash
APP_STORE_CONNECT_API_KEY_ID=your_key_id
APP_STORE_CONNECT_ISSUER_ID=your_issuer_id
APP_STORE_CONNECT_API_KEY_CONTENT=your_key_content_base64
```

#### Android Firebase
```bash
FIREBASE_TOKEN=your_firebase_token
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_APP_ID_ANDROID=your_android_app_id
GOOGLE_PLAY_JSON_KEY_CONTENT=your_service_account_json
```

### Setup Commands
```bash
# Get Firebase token for CI
firebase login:ci

# Get Firebase project info
firebase projects:list

# Get Android app ID
firebase apps:list --platform=android
```

## 🚀 Deployment Workflows

### Automatic Deployment
- **Trigger**: Push to `main` branch with changes in `mobile-client/`
- **iOS**: Builds and uploads to TestFlight
- **Android**: Builds and distributes via Firebase

### Manual Deployment
```bash
# Via GitHub Actions (manual trigger)
# Go to Actions > Mobile App Deployment > Run workflow

# Via local Fastlane
cd mobile-client/ios && bundle exec fastlane beta      # iOS
cd mobile-client/android && bundle exec fastlane beta  # Android
```

### Branch Strategy
- **main**: Auto-deploy to TestFlight + Firebase
- **develop**: Run tests only
- **feature/***: Run tests only
- **Pull Requests**: Run tests + analysis

## 📋 Fastlane Lanes

### iOS Lanes (`mobile-client/ios/fastlane/Fastfile`)
```bash
fastlane beta        # Build + upload to TestFlight
fastlane setup_ci    # Setup CI/CD authentication  
fastlane build_local # Build locally for testing
fastlane test        # Run Flutter tests
```

### Android Lanes (`mobile-client/android/fastlane/Fastfile`)
```bash
fastlane beta           # Build APK + distribute via Firebase
fastlane internal       # Build AAB + upload to Play Console internal
fastlane setup_firebase # Setup Firebase CLI for CI
fastlane build_local    # Build debug APK locally
fastlane test          # Run Flutter tests
```

## 🔍 Version Management

### Automatic Version Increment
- **iOS**: Build number auto-incremented in Xcode project
- **Android**: Version code auto-incremented in pubspec.yaml
- **Version Name**: Manually updated in pubspec.yaml

### Version Format
```yaml
# pubspec.yaml
version: 1.2.3+45
#        │ │ │  │
#        │ │ │  └─ Build number (auto-incremented)
#        │ │ └─── Patch version
#        │ └───── Minor version  
#        └─────── Major version
```

## 🧪 Testing Strategy

### Pre-deployment Checks
1. **Flutter Analysis**: `flutter analyze`
2. **Unit Tests**: `flutter test`
3. **Integration Tests**: `flutter test integration_test/`
4. **Code Formatting**: `dart format --set-exit-if-changed .`

### Test Automation
- **GitHub Actions**: Runs all tests before deployment
- **Local Testing**: Use `fastlane test` lanes
- **Manual Testing**: Build debug versions with `build_local` lanes

## 📊 Monitoring & Notifications

### Build Status
- **GitHub Actions Summary**: Deployment status in Actions tab
- **Artifacts**: Build artifacts uploaded on failure
- **Logs**: Fastlane reports available for debugging

### Optional Integrations
```ruby
# Add to Fastfile for Slack notifications
slack(
  message: "GraBeat iOS Beta #{build_number} uploaded to TestFlight! 🚀",
  channel: "#deployments"
)
```

## 🛠 Troubleshooting

### Common Issues

#### iOS Code Signing
```bash
# Check certificates
security find-identity -v -p codesigning

# Reset Fastlane credentials  
bundle exec fastlane fastlane-credentials remove --username your@email.com
```

#### Android Firebase Authentication
```bash
# Re-authenticate Firebase
firebase logout
firebase login

# Check project access
firebase projects:list
```

#### Flutter Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build ios --release
flutter build apk --release
```

### Debug Commands
```bash
# Verbose Fastlane output
bundle exec fastlane beta --verbose

# Flutter build with verbose logging
flutter build ios --release --verbose

# Check Firebase project setup
firebase use --add
```

## 📚 NoenCircles Pattern Benefits

1. **🎯 Proven Architecture**: Battle-tested deployment pattern
2. **🔄 Consistent Workflow**: Same pattern for iOS and Android
3. **🤖 Full Automation**: GitHub Actions handles everything
4. **🔐 Secure**: Secrets managed in GitHub, no local credentials
5. **📱 Multi-platform**: Single workflow for both platforms
6. **🧪 Quality Gates**: Tests run before every deployment
7. **📊 Visibility**: Clear deployment status and artifacts

## 🔗 Useful Links

- [Fastlane iOS Documentation](https://docs.fastlane.tools/actions/build_app/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [GitHub Actions for Flutter](https://docs.flutter.dev/deployment/cd)

---

**Ready to deploy?** Follow the setup instructions above, configure your secrets, and push to the `main` branch! 🚀