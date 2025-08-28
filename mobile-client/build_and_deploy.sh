#!/bin/bash

# iOS Build and TestFlight Deployment Script for FoodQ Mobile App
# This script builds the iOS app and deploys it to TestFlight for testing

set -e

echo "🍎 Building and Deploying FoodQ Mobile to TestFlight..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCHEME="Runner"
WORKSPACE="Runner.xcworkspace"
ARCHIVE_PATH="build/Runner.xcarchive"
EXPORT_PATH="build/export"
IPA_PATH="build/export/Runner.ipa"
EXPORT_OPTIONS_PLIST="ExportOptions.plist"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: Run this script from the Flutter project root directory${NC}"
    exit 1
fi

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Error: Xcode is not installed or xcodebuild is not in PATH${NC}"
    exit 1
fi

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: This script must be run on macOS${NC}"
    exit 1
fi

echo -e "${YELLOW}📱 Step 1: Cleaning previous builds...${NC}"
flutter clean
rm -rf ios/build/
rm -rf build/

echo -e "${YELLOW}📦 Step 2: Auto-incrementing build number...${NC}"
# Get current build number and increment it
CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
VERSION_NAME=$(echo $CURRENT_VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f2)
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_VERSION="${VERSION_NAME}+${NEW_BUILD_NUMBER}"

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"

# Update pubspec.yaml with new build number
sed -i '' "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml

echo -e "${YELLOW}📦 Step 3: Getting Flutter dependencies...${NC}"
flutter pub get

echo -e "${YELLOW}🔧 Step 4: Running code generation...${NC}"
flutter packages pub run build_runner build --delete-conflicting-outputs || true

echo -e "${YELLOW}🍎 Step 5: Building iOS release...${NC}"
flutter build ios --release

echo -e "${YELLOW}📦 Step 6: Creating iOS archive...${NC}"
cd ios

# Create archive using xcodebuild
xcodebuild -workspace $WORKSPACE \
    -scheme $SCHEME \
    -configuration Release \
    -destination generic/platform=iOS \
    -archivePath $ARCHIVE_PATH \
    archive

echo -e "${YELLOW}📱 Step 7: Exporting IPA for TestFlight...${NC}"

# Create export directory
mkdir -p build/export

# Export IPA
xcodebuild -exportArchive \
    -archivePath $ARCHIVE_PATH \
    -exportPath $EXPORT_PATH \
    -exportOptionsPlist $EXPORT_OPTIONS_PLIST

cd ..

# Check if IPA was created successfully  
if [ -f "ios/$IPA_PATH" ]; then
    IPA_LOCATION="ios/$IPA_PATH"
elif [ -f "ios/Runner.ipa" ]; then
    IPA_LOCATION="ios/Runner.ipa"
    IPA_PATH="Runner.ipa"
else
    echo -e "${RED}❌ Error: IPA file was not created. Check your signing configuration.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ IPA created successfully at: $IPA_LOCATION${NC}"

echo -e "${YELLOW}🚀 Step 8: Uploading to TestFlight...${NC}"

# Upload to TestFlight using xcrun altool
# Note: This requires App Store Connect credentials to be configured
if command -v xcrun &> /dev/null; then
    echo -e "${BLUE}📤 Uploading to App Store Connect...${NC}"
    
    # Try to upload using xcrun altool (requires Apple ID authentication)
    xcrun altool --upload-app \
        --type ios \
        --file "$IPA_LOCATION" \
        --username "$APPLE_ID" \
        --password "$APP_SPECIFIC_PASSWORD" \
        --verbose || {
        echo -e "${YELLOW}⚠️  Automatic upload failed. Please upload manually:${NC}"
        echo -e "${BLUE}1. Open Xcode${NC}"
        echo -e "${BLUE}2. Go to Window → Organizer${NC}"
        echo -e "${BLUE}3. Select the archive and click 'Distribute App'${NC}"
        echo -e "${BLUE}4. Choose 'App Store Connect'${NC}"
        echo -e "${BLUE}5. Follow the prompts to upload${NC}"
        echo ""
        echo -e "${YELLOW}Or use Transporter app:${NC}"
        echo -e "${BLUE}1. Download Transporter from App Store${NC}"
        echo -e "${BLUE}2. Open the IPA file: $IPA_LOCATION${NC}"
        echo -e "${BLUE}3. Click 'Deliver' to upload${NC}"
    }
else
    echo -e "${YELLOW}⚠️  Please upload manually using one of these methods:${NC}"
    echo ""
    echo -e "${BLUE}Method 1 - Xcode Organizer:${NC}"
    echo -e "${BLUE}1. Open Xcode${NC}"
    echo -e "${BLUE}2. Go to Window → Organizer${NC}"
    echo -e "${BLUE}3. Select the archive and click 'Distribute App'${NC}"
    echo -e "${BLUE}4. Choose 'App Store Connect'${NC}"
    echo -e "${BLUE}5. Follow the prompts to upload${NC}"
    echo ""
    echo -e "${BLUE}Method 2 - Transporter App:${NC}"
    echo -e "${BLUE}1. Download Transporter from App Store${NC}"
    echo -e "${BLUE}2. Open the IPA file: $IPA_LOCATION${NC}"
    echo -e "${BLUE}3. Click 'Deliver' to upload${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Build completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps in App Store Connect:${NC}"
echo -e "${BLUE}1. Go to https://appstoreconnect.apple.com${NC}"
echo -e "${BLUE}2. Navigate to TestFlight tab${NC}"
echo -e "${BLUE}3. Wait for processing (5-10 minutes)${NC}"
echo -e "${BLUE}4. Add external testers to test groups${NC}"
echo -e "${BLUE}5. Send invitations to testers${NC}"
echo ""
echo -e "${GREEN}✨ Your testers will receive email invitations to download from TestFlight!${NC}"

# Optional: Open App Store Connect
read -p "Open App Store Connect in browser? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "https://appstoreconnect.apple.com"
fi

echo -e "${GREEN}🚀 Deployment script completed!${NC}"