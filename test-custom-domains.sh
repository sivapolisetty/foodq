#!/bin/bash

# Test script for custom domains after DNS configuration

echo "🌐 Testing Custom Domains for foodqapp.com"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to test endpoint with detailed info
test_domain() {
    local name=$1
    local url=$2
    local expected_status=$3
    
    echo -e "${BLUE}Testing: $name${NC}"
    echo "URL: $url"
    
    # Get response with timing
    response=$(curl -s -o /tmp/response_body -w "%{http_code}|%{time_total}|%{time_namelookup}" "$url" 2>/dev/null)
    
    IFS='|' read -r status_code total_time dns_time <<< "$response"
    
    # Check status
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "Status: ${GREEN}✅ $status_code${NC}"
    else
        echo -e "Status: ${RED}❌ $status_code (expected $expected_status)${NC}"
    fi
    
    # Show timing
    echo "DNS Resolution: ${dns_time}s"
    echo "Total Time: ${total_time}s"
    
    # Show first few lines of response
    if [ -f /tmp/response_body ]; then
        echo "Response Preview:"
        head -3 /tmp/response_body | sed 's/^/  /'
        rm -f /tmp/response_body
    fi
    
    echo ""
}

# Test DNS resolution first
echo "🔍 DNS Resolution Check"
echo "----------------------"
for domain in foodqapp.com api.foodqapp.com admin.foodqapp.com; do
    ip=$(dig +short $domain)
    if [ -n "$ip" ]; then
        echo -e "$domain: ${GREEN}✅ $ip${NC}"
    else
        echo -e "$domain: ${RED}❌ Not resolved${NC}"
    fi
done
echo ""

# Test domains
echo "🚀 Domain Response Tests"
echo "------------------------"

test_domain "Landing Page" "https://foodqapp.com" "200"
test_domain "Admin Portal" "https://admin.foodqapp.com" "200"
test_domain "API Health" "https://api.foodqapp.com/health" "200"

# Test API endpoints
echo "🔧 API Endpoint Tests"
echo "--------------------"
test_domain "API Deals" "https://api.foodqapp.com/deals" "200"
test_domain "API Businesses" "https://api.foodqapp.com/businesses" "200"

# SSL Certificate check
echo "🔒 SSL Certificate Check"
echo "------------------------"
for domain in foodqapp.com api.foodqapp.com admin.foodqapp.com; do
    cert_info=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -issuer -subject 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "$domain: ${GREEN}✅ SSL Valid${NC}"
        echo "$cert_info" | sed 's/^/  /'
    else
        echo -e "$domain: ${RED}❌ SSL Issue${NC}"
    fi
    echo ""
done

# Final summary
echo "============================================"
echo "🎯 Migration Status Summary"
echo ""
echo "If all tests show ✅, your domain migration is complete!"
echo "Your mobile app can now use: https://api.foodqapp.com"
echo ""
echo "Next steps:"
echo "1. Update mobile app API configuration"
echo "2. Test mobile app with new endpoints"
echo "3. Monitor for any issues"
echo "4. Update documentation and team"
echo ""