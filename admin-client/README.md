# FoodQ Admin Portal

Admin portal for FoodQ app management, hosted at `admin.foodqapp.com`.

## Overview

This is a React + TypeScript + Vite application that provides administrative functionality for the FoodQ platform, including:

- Restaurant business onboarding management
- Food library content management
- Dashboard analytics and insights
- User management and oversight

## Technology Stack

- **Framework**: React 19 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **Authentication**: Supabase Auth
- **Backend**: Supabase + Cloudflare Workers
- **Deployment**: Cloudflare Pages

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Environment Configuration

The app uses Supabase for authentication and data management. Environment variables are configured in `wrangler.toml`:

- `VITE_SUPABASE_URL`: Supabase project URL
- `VITE_SUPABASE_ANON_KEY`: Supabase anonymous key

## Features

### Authentication
- Google OAuth integration
- Protected routes with role-based access
- Automatic session management

### Business Management
- Restaurant onboarding workflow
- Business verification and approval
- Business profile management

### Food Library
- Menu item management
- Image upload and optimization
- Content categorization

### Dashboard
- Analytics and metrics
- User activity monitoring
- Performance insights

## Deployment

The admin portal is deployed to Cloudflare Pages and accessible at `admin.foodqapp.com`.

```bash
# Deploy to Cloudflare Pages
npm run build
wrangler pages deploy dist
```

## Development

### Project Structure

```
src/
├── components/     # Reusable UI components
├── pages/         # Route components
├── hooks/         # Custom React hooks
├── services/      # API service layer
├── config/        # Configuration files
└── lib/           # Utility libraries
```

### Code Style

- ESLint configuration for React + TypeScript
- Consistent code formatting
- Component-based architecture
- Custom hooks for state management

## Contributing

1. Follow the existing code style and patterns
2. Add appropriate tests for new features
3. Update documentation as needed
4. Ensure all builds pass before submitting PRs
