#!/bin/bash
echo "📱 Starting GraBeat Flutter App Only"
echo ""
echo "🔧 Configuration:"
echo "   - Flutter app: http://localhost:8081"
echo "   - API endpoint: http://localhost:8788 (make sure API is running separately)"
echo "   - Auth: Production Supabase Cloud (NoenCircles pattern)"
echo ""
echo "💡 Make sure to run './scripts/dev-api.sh' in another terminal for full functionality"
echo ""
echo "🚀 Starting Flutter..."

# Start only the Flutter app
npm run dev:flutter-only