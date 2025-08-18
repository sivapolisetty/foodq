# 🚀 GraBeat Development Scripts

This directory contains development scripts for running GraBeat components separately or together.

## 📋 Available Scripts

### 🔄 Combined Development
```bash
./scripts/dev-local.sh
```
Starts the complete development stack:
- ✅ Supabase local database
- ✅ API server (port 8788)
- ✅ Flutter app (port 8081)

### 📡 API Only
```bash
./scripts/dev-api.sh
```
Starts API development environment:
- ✅ Supabase local database
- ✅ API server (port 8788)
- ❌ Flutter app (run separately)

### 📱 Flutter Only
```bash
./scripts/dev-flutter.sh
```
Starts Flutter app only:
- ❌ Supabase (run separately)
- ❌ API server (run separately)
- ✅ Flutter app (port 8081)

**Note**: Make sure API is running for full functionality.

### 🗄️ Database Only
```bash
./scripts/dev-supabase.sh
```
Starts Supabase local database only:
- ✅ PostgreSQL database
- ✅ Supabase Studio dashboard
- ✅ PostgREST API
- ✅ Auth server
- ❌ Custom API server
- ❌ Flutter app

## 🎯 Common Development Workflows

### Scenario 1: Full Stack Development
```bash
# Terminal 1: Start everything together
./scripts/dev-local.sh
```

### Scenario 2: API Development Focus
```bash
# Terminal 1: Start API + Database
./scripts/dev-api.sh

# Terminal 2: Start Flutter (optional)
./scripts/dev-flutter.sh
```

### Scenario 3: Flutter UI Development Focus
```bash
# Terminal 1: Start API + Database
./scripts/dev-api.sh

# Terminal 2: Start Flutter with hot reload
./scripts/dev-flutter.sh
```

### Scenario 4: Database-only Development
```bash
# Terminal 1: Start database only
./scripts/dev-supabase.sh

# Use Supabase Studio at: http://127.0.0.1:58323
```

## 🔗 Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Flutter App** | http://localhost:8081 | Main application UI |
| **API Server** | http://localhost:8788 | Cloudflare Pages Functions |
| **Supabase Studio** | http://127.0.0.1:58323 | Database dashboard |
| **Local Supabase API** | http://127.0.0.1:58321 | Local Supabase REST API |

## 🛠️ NPM Scripts Reference

The scripts use these npm commands internally:

```json
{
  "dev": "Combined API + Flutter",
  "dev:api-only": "API server only",
  "dev:flutter-only": "Flutter app only",
  "kill-ports": "Kill both 8788 and 8081",
  "kill-port:8788": "Kill API port",
  "kill-port:8081": "Kill Flutter port"
}
```

## 🔧 Troubleshooting

### Port Already in Use
```bash
# Kill specific ports
npm run kill-port:8788  # API
npm run kill-port:8081  # Flutter

# Kill both ports
npm run kill-ports
```

### Supabase Issues
```bash
# Stop Supabase
supabase stop

# Reset database
supabase db reset

# Check status
supabase status
```

### Build Issues
```bash
# Clean build
npm run build

# Rebuild functions
npm run build:functions
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │────│   API Server    │────│   Supabase DB   │
│   Port: 8081    │    │   Port: 8788    │    │   Port: 58321   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
    ┌─────────┐            ┌─────────┐            ┌─────────┐
    │ Chrome  │            │ Wrangler│            │ PostgREST│
    │ Browser │            │ Pages   │            │ Studio  │
    └─────────┘            └─────────┘            └─────────┘
```

## 🎯 NoenCircles Pattern

Following NoenCircles architecture:
- **Authentication**: Production Supabase Cloud (OAuth)
- **API Development**: Local Cloudflare Pages Functions
- **Database**: Local PostgreSQL for development
- **UI**: Local Flutter with hot reload