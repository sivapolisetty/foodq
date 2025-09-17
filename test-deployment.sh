#!/bin/bash

# Test script for deployed services

echo "🧪 Testing FoodQ Deployment Status"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to test endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected=$3
    
    printf "Testing %-30s " "$name:"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" = "$expected" ]; then
        echo -e "${GREEN}✅ $response${NC}"
        return 0
    else
        echo -e "${RED}❌ $response (expected $expected)${NC}"
        return 1
    fi
}

# Test existing infrastructure
echo "1️⃣  Original Infrastructure"
echo "----------------------------"
test_endpoint "API Health" "https://foodq.pages.dev/api/health" "200"
test_endpoint "API Deals" "https://foodq.pages.dev/api/deals" "200"
test_endpoint "API Businesses" "https://foodq.pages.dev/api/businesses" "200"
echo ""

# Test deployed pages
echo "2️⃣  Deployed Pages Projects"
echo "----------------------------"
test_endpoint "Landing Page" "https://foodq-landing.pages.dev" "200"
test_endpoint "Admin Portal" "https://foodq-admin.pages.dev" "200"
echo ""

# Test workers
echo "3️⃣  Deployed Workers"
echo "----------------------------"
test_endpoint "API Router Worker" "https://foodq-api-router.sivapolisetty813.workers.dev/health" "200"
test_endpoint "API Proxy Worker" "https://foodq-api-proxy.sivapolisetty813.workers.dev/health" "200"
echo ""

# Test custom domains (will fail until DNS configured)
echo "4️⃣  Custom Domains (DNS Required)"
echo "----------------------------"
test_endpoint "foodqapp.com" "https://foodqapp.com" "200"
test_endpoint "api.foodqapp.com" "https://api.foodqapp.com/health" "200"
test_endpoint "admin.foodqapp.com" "https://admin.foodqapp.com" "200"
echo ""

# Summary
echo "=================================="
echo "📊 Deployment Summary"
echo ""
echo "✅ Ready for DNS Configuration:"
echo "  - Landing Page: foodq-landing.pages.dev"
echo "  - Admin Portal: foodq-admin.pages.dev"
echo "  - API Worker: Use original foodq.pages.dev/api"
echo ""
echo "⚠️  Next Steps:"
echo "  1. Configure DNS records in Cloudflare"
echo "  2. Add custom domains to Pages projects"
echo "  3. Wait for DNS propagation (5-30 minutes)"
echo "  4. Test custom domains"
echo ""