#!/bin/bash
echo "📡 Starting Supabase Local Database Only"
echo ""
echo "🔧 This will start:"
echo "   - Local PostgreSQL database"
echo "   - Supabase Studio (dashboard)"
echo "   - PostgREST API"
echo "   - Auth server"
echo ""

# Start Supabase
echo "🚀 Starting Supabase..."
supabase start

# Check if services started successfully
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Supabase started successfully!"
    echo ""
    echo "🔗 Available services:"
    supabase status
    echo ""
    echo "💡 Use './scripts/dev-api.sh' and './scripts/dev-flutter.sh' to start other services"
else
    echo "❌ Failed to start Supabase"
    exit 1
fi