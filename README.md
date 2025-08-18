# 🍽️ GraBeat - Food Delivery Platform

GraBeat is a modern food delivery platform built with Flutter, Supabase, and Cloudflare Pages Functions, following the proven NoenCircles architecture pattern.

## 🚀 Quick Start

### Option 1: All Services Together
```bash
./scripts/dev-local.sh
```

### Option 2: Separate Development
```bash
# Terminal 1: Start API + Database
./scripts/dev-api.sh

# Terminal 2: Start Flutter App
./scripts/dev-flutter.sh
```

## 📋 Development Scripts

| Script | Purpose | Services |
|--------|---------|----------|
| `./scripts/dev-local.sh` | Full development stack | API + Flutter + Database |
| `./scripts/dev-api.sh` | API development | API + Database |
| `./scripts/dev-flutter.sh` | Flutter development | Flutter only |
| `./scripts/dev-supabase.sh` | Database only | Supabase + Studio |

📖 **Detailed documentation**: See [scripts/README.md](scripts/README.md)

## 🔗 Service URLs

- **Flutter App**: http://localhost:8081
- **API Server**: http://localhost:8788
- **Database Studio**: http://127.0.0.1:58323

## 🏗️ Architecture

**Following NoenCircles Pattern:**
- ✅ **Authentication**: Production Supabase Cloud (OAuth)
- ✅ **API**: Local Cloudflare Pages Functions
- ✅ **Database**: Local PostgreSQL
- ✅ **UI**: Local Flutter with hot reload

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Cloudflare Pages Functions (TypeScript)
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth (OAuth)
- **Deployment**: Cloudflare Pages

## 📱 Features

- 🔐 Google OAuth authentication
- 🏪 Restaurant discovery and ordering
- 📦 Real-time order tracking
- 💳 Stripe payment integration
- 📍 Location-based services
- 👥 User role management (Customer/Restaurant)

## 🔧 Development Requirements

- Node.js 18+
- Flutter 3.x
- Supabase CLI
- Wrangler CLI (Cloudflare)

## 📝 Project Structure

```
grabeat_new/
├── functions/           # Cloudflare Pages Functions
├── mobile-client/       # Flutter application
├── scripts/            # Development scripts
├── supabase/           # Database migrations & config
└── admin-dashboard/    # Admin interface (future)
```

## 🎯 Getting Started

1. **Clone and setup**:
   ```bash
   cd grabeat_new
   npm install
   ```

2. **Start development**:
   ```bash
   ./scripts/dev-local.sh
   ```

3. **Open in browser**:
   - Flutter app: http://localhost:8081
   - Database studio: http://127.0.0.1:58323

## 📚 Documentation

- [Development Scripts](scripts/README.md)
- [API Documentation](functions/README.md)
- [Flutter Setup](mobile-client/README.md)
- [Migration Guide](MIGRATION_TO_NOENCIRCLES_PATTERN.md)

## 🤝 Contributing

This project follows the NoenCircles architecture pattern for clean, maintainable code structure.

## 📄 License

MIT License - see LICENSE file for details.