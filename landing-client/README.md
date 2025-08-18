# Grabeat

Unified Cloudflare Pages deployment for Grabeat - connecting restaurants and customers through amazing food deals.

## Architecture

- **Landing Page**: `/` - Public-facing website
- **Restaurant Page**: `/restaurants` - Information for restaurant partners  
- **Customer Page**: `/customers` - How it works for customers
- **API Endpoints**: `/api/*` - Cloudflare Functions for backend

## API Endpoints

### User Endpoints
- `GET /api/users/profile/:id` - Get user profile
- `GET /api/users/:id/onboarding-status` - Get onboarding status

### Restaurant Onboarding
- `POST /api/restaurant-onboarding` - Submit onboarding request


## Development

```bash
npm install
npm run dev
```

## Deployment to Cloudflare Pages

1. **Connect to GitHub**:
   - Go to Cloudflare Dashboard → Pages
   - Connect your GitHub repository
   - Select `grabeat-platform` directory as source

2. **Build Settings**:
   - Build command: `npm run build`
   - Build output directory: `dist`
   - Root directory: `/grabeat-platform`

3. **Environment Variables**:
   ```
   SUPABASE_URL=https://zobhorsszzthyljriiim.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvYmhvcnNzenp0aHlsanJpaWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5ODIzNzYsImV4cCI6MjA2OTU1ODM3Nn0.91GlHZxmJGg5E-T2iR5rzgLrQJzNPNW-SzS2VhqlymA
   ```

4. **Custom Domain**:
   - Set up `grabeat.pages.dev` as custom domain
   - Configure DNS as needed

## Features

### Landing Page (`/`)
- Hero section with app download buttons
- Feature highlights (exclusive deals, real-time updates, local community)
- Restaurant partnership CTA
- Modern, responsive design with Grabeat branding

### Restaurant Page (`/restaurants`)
- Partnership benefits and success stories
- How it works for restaurants
- CTA for restaurant onboarding
- Feature highlights (reach customers, increase revenue, reduce waste)

### Customer Page (`/customers`)
- How the app works (discover, order, pickup)
- App features and benefits
- Statistics and social proof
- App download CTAs


### API Functions
- JWT authentication with Supabase
- Row Level Security (RLS) compliant queries
- Error handling and proper HTTP status codes
- TypeScript for type safety

## Tech Stack

- **Frontend**: React + TypeScript + Vite
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Routing**: React Router
- **Backend**: Cloudflare Functions
- **Database**: Supabase PostgreSQL
- **Authentication**: Supabase Auth
- **Deployment**: Cloudflare Pages

## Migration from Workers

This replaces the previous `grabeat-deals-api` Cloudflare Worker with a unified Pages deployment:

- All API endpoints migrated to Functions format
- Public landing pages added for marketing
- Consistent branding and user experience across all touchpoints