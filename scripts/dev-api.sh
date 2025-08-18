#!/bin/bash
echo "🚀 Starting GraBeat API Server Only"

# Start Supabase (needed for local database)
echo "📡 Starting Supabase..."
supabase start

# Check if Supabase started successfully
if [ $? -eq 0 ]; then
    echo "✅ Supabase started successfully"
    echo "📊 Database: http://127.0.0.1:58323"
    echo "🔗 API: http://127.0.0.1:58321"
else
    echo "❌ Failed to start Supabase"
    exit 1
fi

echo ""
echo "🎯 Starting API Server on port 8788..."
echo "🔗 API will be available at: http://localhost:8788"
echo ""

# Start only the API server
npm run dev:api-only