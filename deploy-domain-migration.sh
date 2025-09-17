#!/bin/bash

# FoodQ Domain Migration Deployment Script
# This script deploys all components for the foodqapp.com domain migration

set -e  # Exit on any error

echo "🚀 Starting FoodQ domain migration deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    print_error "Wrangler CLI is not installed. Please install it first:"
    echo "npm install -g wrangler"
    exit 1
fi

print_status "Wrangler CLI found ✓"

# Check if user is logged in to Cloudflare
if ! wrangler whoami &> /dev/null; then
    print_warning "Not logged in to Cloudflare. Please login first:"
    echo "wrangler login"
    exit 1
fi

print_success "Logged in to Cloudflare ✓"

# 1. Deploy API Router Worker
print_status "Deploying API Router Worker to handle api.foodqapp.com..."
if wrangler deploy --config api-wrangler.toml; then
    print_success "API Router Worker deployed successfully"
else
    print_error "Failed to deploy API Router Worker"
    exit 1
fi

# 2. Deploy Landing Page
print_status "Building and deploying landing page for foodqapp.com..."
cd landing-page
if wrangler pages deploy . --project-name foodq-landing; then
    print_success "Landing page deployed successfully"
else
    print_error "Failed to deploy landing page"
    exit 1
fi
cd ..

# 3. Deploy Admin Portal
print_status "Building and deploying admin portal for admin.foodqapp.com..."
cd admin-client
npm install
npm run build
if wrangler pages deploy dist --project-name foodq-admin; then
    print_success "Admin portal deployed successfully"
else
    print_error "Failed to deploy admin portal"
    exit 1
fi
cd ..

# 4. Display DNS configuration instructions
print_status "🌐 DNS Configuration Required"
echo ""
echo "Please configure the following DNS records in your Cloudflare dashboard:"
echo ""
echo "1. Root domain (foodqapp.com):"
echo "   - Type: CNAME"
echo "   - Name: @"
echo "   - Target: foodq-landing.pages.dev"
echo ""
echo "2. API subdomain (api.foodqapp.com):"
echo "   - Type: CNAME" 
echo "   - Name: api"
echo "   - Target: foodq-api-router.foodqapp.workers.dev"
echo ""
echo "3. Admin subdomain (admin.foodqapp.com):"
echo "   - Type: CNAME"
echo "   - Name: admin"
echo "   - Target: foodq-admin.pages.dev"
echo ""

print_success "🎉 Domain migration deployment completed!"
echo ""
echo "Next steps:"
echo "1. Configure DNS records as shown above"
echo "2. Test all endpoints: api.foodqapp.com/health"
echo "3. Verify landing page: https://foodqapp.com"
echo "4. Verify admin portal: https://admin.foodqapp.com"
echo "5. Update mobile app to use new API endpoints"
echo ""
print_warning "Allow 24-48 hours for DNS propagation worldwide"