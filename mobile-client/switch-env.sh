#!/bin/bash

# Script to switch between local and cloud API environments

if [ "$1" = "local" ]; then
    echo "🔧 Switching to LOCAL environment (API: http://localhost:8788)"
    cp .env .env.backup 2>/dev/null || true
    cat > .env << 'ENV_EOF'
# Flutter Environment Configuration for GraBeat - LOCAL DEVELOPMENT
# API: Local Cloudflare Pages Functions
API_BASE_URL=http://localhost:8788

# Authentication: Production Supabase Cloud (for OAuth to work)
SUPABASE_URL=https://zobhorsszzthyljriiim.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5ODIzNzYsImV4cCI6MjA2OTU1ODM3Nn0.91GlHZxmJGg5E-T2iR5rzgLrQJzNPNW-SzS2VhqlymA

ENVIRONMENT=development
DEBUG_MODE=true
ENABLE_LOGGING=true
ENV_EOF
    echo "✅ Switched to LOCAL environment"
    
elif [ "$1" = "cloud" ] || [ "$1" = "production" ]; then
    echo "☁️ Switching to CLOUD/PRODUCTION environment (API: https://grabeat.pages.dev)"
    cp .env .env.backup 2>/dev/null || true
    cp .env.production .env
    echo "✅ Switched to CLOUD environment"
    
else
    echo "Usage: ./switch-env.sh [local|cloud|production]"
    echo ""
    echo "Commands:"
    echo "  local      - Use local API (http://localhost:8788)"
    echo "  cloud      - Use production API (https://grabeat.pages.dev)"
    echo "  production - Same as cloud"
    echo ""
    echo "Current environment:"
    grep "API_BASE_URL" .env 2>/dev/null || echo "No .env file found"
fi
