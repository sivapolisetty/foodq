#!/bin/bash

# Test Google Places API directly
API_KEY="AIzaSyCZ4ulfUP-2FaLe90Ar1zoQBimcVJu8ZFM"

echo "Testing Google Places API directly..."
echo "======================================="

# Test the API key directly with Google's API
RESPONSE=$(curl -s "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=123%20main%20street&key=${API_KEY}&types=address&components=country:us")

# Check the status
STATUS=$(echo "$RESPONSE" | jq -r '.status' 2>/dev/null)
ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error_message' 2>/dev/null)

echo "Status: $STATUS"

if [ "$STATUS" = "REQUEST_DENIED" ]; then
    echo "❌ API Key Error: $ERROR_MSG"
    echo ""
    echo "To fix this issue:"
    echo "1. Go to https://console.cloud.google.com/"
    echo "2. Select your project"
    echo "3. Navigate to APIs & Services > Library"
    echo "4. Search for 'Places API'"
    echo "5. Click on 'Places API' and then 'Enable'"
    echo "6. Wait a few minutes for the changes to propagate"
elif [ "$STATUS" = "OK" ] || [ "$STATUS" = "ZERO_RESULTS" ]; then
    echo "✅ API Key is working correctly!"
    echo ""
    echo "Now testing through local endpoint..."
    LOCAL_RESPONSE=$(curl -s 'http://localhost:8788/api/places/autocomplete?input=123%20main%20street&language=en&components=country:us')
    LOCAL_SUCCESS=$(echo "$LOCAL_RESPONSE" | jq -r '.success' 2>/dev/null)
    
    if [ "$LOCAL_SUCCESS" = "true" ]; then
        echo "✅ Local endpoint is working!"
    else
        LOCAL_ERROR=$(echo "$LOCAL_RESPONSE" | jq -r '.error' 2>/dev/null)
        echo "❌ Local endpoint error: $LOCAL_ERROR"
        echo ""
        echo "Try restarting the development server:"
        echo "npm run kill-ports && npm run dev"
    fi
else
    echo "Unexpected response:"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
fi