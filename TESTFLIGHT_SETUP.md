# TestFlight Setup Guide for iOS Distribution

## Prerequisites
- Apple Developer Account ($99/year)
- App ID configured in Apple Developer Portal
- App created in App Store Connect

## Step 1: Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Click on "Users and Access"
3. Select "Keys" tab under "Integrations"
4. Click the "+" button to create a new API Key
5. Set the following:
   - **Name**: `FoodQ CI/CD`
   - **Access**: `App Manager` (or Admin if you need full access)
6. Download the `.p8` key file (⚠️ You can only download this once!)
7. Note down:
   - **Issuer ID**: Shown at the top of the Keys page
   - **Key ID**: Shown in the key list

## Step 2: Prepare the API Key for GitHub

1. Open the downloaded `.p8` file in a text editor
2. Copy the entire contents (including BEGIN/END lines)
3. This will be your `APP_STORE_CONNECT_API_KEY_CONTENT`

## Step 3: Set GitHub Secrets for iOS

Add these secrets in your GitHub repository:

| Secret Name | Value | Where to Find |
|-------------|-------|---------------|
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from step 1 | App Store Connect → Keys |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from step 1 | App Store Connect → Keys (top of page) |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Contents of .p8 file | Downloaded file from step 1 |

## Step 4: Configure TestFlight

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Go to "TestFlight" tab
4. Set up your test groups:
   - **Internal Testing**: Up to 100 members, immediate availability
   - **External Testing**: Up to 10,000 testers, requires review

### Create Internal Test Group:
1. Click "Internal Group" → "+"
2. Name: `Internal Beta Testers`
3. Add team members (must be in your App Store Connect team)

### Create External Test Group:
1. Click "External Groups" → "+"
2. Name: `Beta Testers`
3. Add tester emails
4. Configure test information (required for first submission)

## Step 5: App Configuration

Ensure your iOS app is properly configured:

```bash
# In mobile-client/ios directory
cd mobile-client/ios

# Open Xcode
open Runner.xcworkspace

# Verify:
# 1. Bundle Identifier matches App Store Connect
# 2. Signing & Capabilities are configured
# 3. Version and Build numbers are set
```

## Step 6: Test the Pipeline

### Local Test:
```bash
cd mobile-client/ios
bundle install
bundle exec fastlane beta
```

### GitHub Actions:
The workflow is already configured. It will trigger on:
- Push to `main` branch with iOS changes
- Manual workflow dispatch

## Step 7: Monitor Deployment

After deployment:
1. Check [App Store Connect](https://appstoreconnect.apple.com/) → TestFlight
2. Build should appear in ~15-30 minutes
3. For external testers, submit for review (usually approved within 24h)

## Build Versioning

The pipeline automatically increments build numbers. Version format:
- **Version**: `1.0.0` (marketing version)
- **Build**: Auto-incremented number

## Troubleshooting

### Common Issues:

1. **"No certificate found"**:
   - Fastlane match will handle certificates automatically
   - Ensure API key has proper permissions

2. **"Invalid Bundle ID"**:
   - Check bundle ID in Xcode matches App Store Connect
   - Update in `ios/Runner/Info.plist` if needed

3. **"Build already exists"**:
   - Build number is already used
   - The pipeline auto-increments, but check for conflicts

4. **TestFlight not showing build**:
   - Processing can take 15-30 minutes
   - Check email for any Apple notifications
   - Verify build completed in App Store Connect

## Complete Distribution Setup

Your app now has dual distribution:

| Platform | Distribution Method | Testers | Build Expiry |
|----------|-------------------|---------|--------------|
| iOS | TestFlight | Up to 10,000 | 90 days |
| Android | Firebase App Distribution | Unlimited | 30 days |

## Security Notes

- Never commit API keys to repository
- Rotate API keys periodically
- Use least privilege access for API keys
- Monitor App Store Connect for unusual activity

## Next Steps

1. **Configure push notifications**: Set up APNS certificates
2. **Set up crash reporting**: Integrate Crashlytics
3. **Add analytics**: Configure app analytics
4. **Prepare for production**: Set up production signing

Your iOS TestFlight distribution is ready! 🚀