#!/bin/bash

# TestFlight Deployment Wrapper Script for FoodQ
# Sets up environment variables and runs the build script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🚀 FoodQ TestFlight Deployment Script"
echo "========================================"
echo ""

# Check if .env file exists for credentials
if [ -f ".env.deploy" ]; then
    echo -e "${GREEN}✓ Loading credentials from .env.deploy${NC}"
    source .env.deploy
else
    echo -e "${YELLOW}📝 Setting up Apple credentials...${NC}"
    echo ""
    echo "For automatic TestFlight upload, you need to provide:"
    echo "1. Your Apple ID email"
    echo "2. An app-specific password (not your regular Apple ID password)"
    echo ""
    echo "To create an app-specific password:"
    echo "1. Go to https://appleid.apple.com/account/manage"
    echo "2. Sign in and go to Security"
    echo "3. Under 'App-Specific Passwords', click 'Generate Password'"
    echo "4. Name it 'FoodQ TestFlight' and copy the password"
    echo ""
    
    read -p "Enter your Apple ID email (or press Enter to skip): " APPLE_ID
    
    if [ ! -z "$APPLE_ID" ]; then
        read -s -p "Enter your app-specific password: " APP_SPECIFIC_PASSWORD
        echo ""
        
        # Save credentials for future use (optional)
        read -p "Save credentials for future use? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cat > .env.deploy << EOF
# Apple Developer Credentials for TestFlight
export APPLE_ID="$APPLE_ID"
export APP_SPECIFIC_PASSWORD="$APP_SPECIFIC_PASSWORD"
EOF
            echo -e "${GREEN}✓ Credentials saved to .env.deploy${NC}"
            echo -e "${YELLOW}⚠️  Remember to add .env.deploy to .gitignore${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Manual upload will be required after build${NC}"
    fi
fi

# Export variables for the build script
export APPLE_ID
export APP_SPECIFIC_PASSWORD

echo ""
echo -e "${BLUE}📱 Starting build and deployment process...${NC}"
echo ""

# Run the main build and deploy script
./build_and_deploy.sh

# Cleanup sensitive variables
unset APPLE_ID
unset APP_SPECIFIC_PASSWORD

echo ""
echo -e "${GREEN}✅ Deployment process completed!${NC}"