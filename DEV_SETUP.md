# Grabeat Development Setup

## Quick Start

```bash
npm run dev
```

This command starts:
1. **Flutter App** - http://localhost:8081 (web-server mode)
2. **API Server** - http://localhost:8788 (Cloudflare Workers locally)
3. **Local Supabase** - http://127.0.0.1:58323 (Studio dashboard)

## Architecture

### Database & Authentication
- **Database**: Local Supabase (port 58321)
- **Authentication**: Supabase Cloud (production auth)
- **API**: Local Cloudflare Workers connecting to local Supabase with service role

### Available Scripts

#### Main Development
- `npm run dev` - Start Flutter + API (NO admin client)
- `npm run dev:full` - Start Flutter + API + Admin client (all services)

#### Individual Services
- `npm run dev:api-only` - Just the API server
- `npm run dev:flutter` - Just the Flutter app
- `npm run dev:admin` - Just the admin client

#### Supabase Management
- `npm run supabase:start` - Start local Supabase
- `npm run supabase:stop` - Stop local Supabase
- `npm run supabase:status` - Check Supabase status
- `npm run supabase:reset` - Reset database

## Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| Flutter App | http://localhost:8081 | Main mobile app (web version) |
| API Server | http://localhost:8788 | Cloudflare Workers API |
| Supabase Studio | http://127.0.0.1:58323 | Database management UI |
| Admin Client | http://localhost:5174 | Admin dashboard (run separately) |

## Authentication Flow

1. **User Login**: Flutter app → Supabase Cloud Auth
2. **API Calls**: Flutter app → Local API (port 8788)
3. **Database**: Local API → Local Supabase (service role)

## Environment Configuration

### API Server (.dev.vars)
- Uses local Supabase for database operations
- Service role key for bypassing RLS
- API_KEY for testing: `test-api-key-2024`

### Flutter App
- Configured to use Supabase Cloud for auth
- API calls to local server (http://localhost:8788)

### Admin Client (.env.local)
- Supabase Cloud for authentication
- Cloud API for admin verification
- Optional local API access

## Testing User

**Business Owner Account**:
- User ID: `f0337be4-1399-4363-8652-3534df397078`
- Email: `sivapolisetty813@gmail.com`
- Business: Mario's Authentic Pizza
- Business ID: `550e8400-e29b-41d4-a716-446655440001`

## Common Commands

```bash
# Start development (Flutter + API only)
npm run dev

# Start everything including admin
npm run dev:full

# Check if everything is running
npm run supabase:status

# Reset database if needed
npm run supabase:reset

# Kill all ports if stuck
npm run kill-ports
```

## Notes

- Admin client is NOT started by default with `npm run dev`
- Use `npm run dev:full` if you need admin client
- Supabase must be running for the system to work
- Authentication uses Supabase Cloud (production)
- Database uses local Supabase instance