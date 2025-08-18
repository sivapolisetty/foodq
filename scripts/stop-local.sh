#!/bin/bash
echo "🛑 Stopping GraBeat Development"

# Kill processes
npm run kill-ports
supabase stop

echo "✅ All services stopped"