# GraBeat Development Guide

## Quick Start

```bash
# Start everything
./scripts/dev-local.sh

# API will be at: http://localhost:8788
# Flutter will be at: http://localhost:3000
# Database Studio: http://127.0.0.1:58323
```

## Architecture

- **API**: Cloudflare Pages Functions at `/functions/api/`
- **Frontend**: Flutter Web at port 3000
- **Database**: Local Supabase at port 58321
- **Environment**: Single local development setup

## API Endpoints

### Users
- `GET /api/users` - List all users
- `POST /api/users` - Create new user
- `GET /api/users/{id}` - Get user profile
- `PUT /api/users/{id}` - Update user profile

### Businesses
- `GET /api/businesses` - List all businesses
- `POST /api/businesses` - Create new business
- `GET /api/businesses/{id}` - Get business details
- `PUT /api/businesses/{id}` - Update business
- `DELETE /api/businesses/{id}` - Delete business

### Deals
- `GET /api/deals` - List deals (supports ?business_id, ?status, ?limit)
- `POST /api/deals` - Create new deal
- `GET /api/deals/{id}` - Get deal details
- `PUT /api/deals/{id}` - Update deal
- `DELETE /api/deals/{id}` - Delete deal

## Development Commands

```bash
# Development
npm run dev                 # Start everything (API + Flutter)
npm run dev:api-only       # Start only API
npm run dev:flutter-only   # Start only Flutter

# Utilities
npm run kill-ports         # Kill all development ports
npm run build              # Build functions
npm run test:api          # Test API endpoints

# Supabase
npm run supabase:start    # Start local Supabase
npm run supabase:stop     # Stop local Supabase
npm run supabase:status   # Check Supabase status
npm run supabase:reset    # Reset database
```

## Environment Configuration

- **Frontend**: `.env.local` (Flutter Web environment)
- **Backend**: `.dev.vars` (Cloudflare Functions environment)
- **Main Config**: `wrangler.toml` (Cloudflare Pages configuration)

## Authentication

The API supports two authentication methods:

1. **API Key** (Development): Add `X-API-Key: test-api-key-2024` header
2. **JWT Token** (Production): Add `Authorization: Bearer <token>` header

## Troubleshooting

### Supabase Issues
```bash
supabase db reset
supabase start
```

### API Connection Issues
- Ensure `.dev.vars` has correct local Supabase credentials
- Check that API is running at `http://localhost:8788`

### Flutter Connection Issues
- Verify Flutter is using correct baseUrl in `api_constants.dart`
- Check CORS settings in API functions

### Build Issues
```bash
rm -rf dist/
npm run build:functions
```