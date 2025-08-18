#!/bin/bash
echo "🚀 Starting GraBeat Full Local Development Stack"
echo ""
echo "💡 For separate development, use:"
echo "   - ./scripts/dev-api.sh      (API + Supabase only)"
echo "   - ./scripts/dev-flutter.sh  (Flutter only)"
echo "   - ./scripts/dev-supabase.sh (Supabase only)"
echo ""

# Start Supabase
echo "📡 Starting Supabase..."
supabase start

# Check if services started successfully
if [ $? -eq 0 ]; then
    echo "✅ Supabase started successfully"
    echo "📊 Database: http://127.0.0.1:58323"
    echo "🔗 API: http://127.0.0.1:58321"
else
    echo "❌ Failed to start Supabase"
    exit 1
fi

echo ""
echo "🎯 Starting API Server (port 8788) and Flutter App (port 8081)..."
echo "🔗 API: http://localhost:8788"
echo "📱 Flutter: http://localhost:8081"
echo ""

# Start API and Flutter together
npm run dev