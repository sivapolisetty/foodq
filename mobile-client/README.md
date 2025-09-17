# FoodQ Mobile App

A Flutter-based mobile application for discovering and purchasing food deals from local restaurants. The app provides location-based deal discovery, FOMO-driven psychology features, and comprehensive deal management.

## 🚀 Features

- **Location-Based Deal Discovery**: Find deals near your current location
- **Deal Categories**: Browse nearby, missed, and expired deals with psychological motivators
- **User Management**: Customer and business user roles with different interfaces
- **Order Management**: Place orders, track status, and view order history
- **Cart System**: Add deals to cart with validation and checkout
- **Authentication**: Secure user authentication with Supabase
- **Payment Integration**: Stripe payment processing
- **Maps Integration**: Google Maps for location services
- **Real-time Updates**: Live deal updates and notifications

## 🛠 Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Backend**: Supabase (Authentication, Database)
- **API**: Cloudflare Workers (https://foodq.pages.dev)
- **Navigation**: go_router
- **Code Generation**: freezed, json_annotation
- **Maps**: Google Maps Flutter
- **Payments**: Stripe
- **Location**: Geolocator
- **HTTP**: http package
- **Testing**: flutter_test, mockito

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or higher)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio) as IDE
- [Git](https://git-scm.com/)

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mobile-client
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code files**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Set up environment configuration**
   
   Create a `.env` file in the root directory:
   ```env
   API_BASE_URL=https://foodq.pages.dev
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
   ```

5. **Configure platform-specific settings**

   ### Android Setup
   - Add Google Maps API key to `android/app/src/main/AndroidManifest.xml`
   - Configure Stripe in `android/app/build.gradle`
   - Set up location permissions in AndroidManifest.xml

   ### iOS Setup
   - Add Google Maps API key to `ios/Runner/Info.plist`
   - Configure location permissions in Info.plist
   - Set up Stripe iOS configuration

## 🚀 Running the App

### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run with specific flavor
flutter run --flavor development
flutter run --flavor production

# Run with debug logging
flutter run --debug
```

### Building for Release

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# Build for iOS
flutter build ios --release

# Build for TestFlight/App Store
flutter build ipa --release
```

## 🏗 Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── config/            # Configuration files
│   ├── services/          # Core services (API, Auth, etc.)
│   └── utils/             # Utility functions
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── deals/             # Deal management
│   ├── orders/            # Order management
│   ├── profile/           # User profile
│   └── cart/              # Shopping cart
├── shared/                # Shared components
│   ├── models/            # Data models
│   ├── widgets/           # Reusable widgets
│   ├── services/          # Shared services
│   └── theme/             # App theming
└── main.dart              # App entry point
```

## 🔧 Configuration

### Environment Variables
The app uses environment-specific configuration. Check `ENV_SETUP.md` for detailed setup instructions.

### API Configuration
API endpoints are configured in `lib/core/config/api_config.dart`. The app connects to a Cloudflare Workers backend.

### Supabase Setup
Authentication and real-time features use Supabase. Configure your Supabase project URL and keys in the environment file.

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/unit/auth/auth_service_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Test Structure
- `test/unit/` - Unit tests for individual components
- `test/widget/` - Widget tests for UI components
- `test/integration/` - Integration tests
- `integration_test/` - End-to-end tests

## 📱 Features in Detail

### Deal Discovery System
- **Nearby Deals**: Location-based deal discovery with distance calculations
- **Missed Deals**: FOMO-driven interface showing deals user viewed but didn't purchase
- **Expired Deals**: Regret psychology showing deals that have expired

### User Roles
- **Customers**: Browse deals, place orders, manage profile
- **Business Owners**: Create and manage deals, view orders, business analytics

### Real-time Features
- Live deal updates
- Order status tracking
- Location-based notifications

## 🔐 Security

- Secure API authentication with JWT tokens
- Environment-based configuration for sensitive keys
- Input validation and sanitization
- Secure payment processing with Stripe

## 🚀 Deployment

### TestFlight (iOS)
```bash
# Build and deploy to TestFlight
./deploy_testflight.sh
```

### Play Store (Android)
```bash
# Build and prepare for Play Store
./build_and_deploy.sh
```

## 🛠 Development Guidelines

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation for public APIs
- Keep functions small and focused

### State Management
- Use Riverpod for state management
- Create providers for shared state
- Use StateNotifier for complex state logic

### Code Generation
The project uses code generation for:
- JSON serialization (`*.g.dart`)
- Freezed classes (`*.freezed.dart`)
- Route generation (`*.gr.dart`)

Run code generation after making changes:
```bash
flutter packages pub run build_runner build
```

## 📚 Key Dependencies

- `flutter`: 3.x - UI framework
- `riverpod`: State management
- `go_router`: Navigation
- `freezed`: Code generation for data classes
- `supabase_flutter`: Backend integration
- `google_maps_flutter`: Maps integration
- `geolocator`: Location services
- `stripe_android` / `stripe_ios`: Payment processing

## 🐛 Troubleshooting

### Common Issues

1. **Build errors after pulling changes**
   ```bash
   flutter clean
   flutter pub get
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **Location services not working**
   - Check permissions in AndroidManifest.xml and Info.plist
   - Ensure location services are enabled on device

3. **API connection issues**
   - Verify API_BASE_URL in .env file
   - Check network connectivity
   - Validate authentication tokens

### Debug Commands
```bash
# Check Flutter setup
flutter doctor

# Analyze code for issues
flutter analyze

# Check dependency conflicts
flutter pub deps
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Add tests for new functionality**
5. **Ensure all tests pass**
   ```bash
   flutter test
   ```
6. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
7. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
8. **Open a Pull Request**

### Development Workflow
- Create feature branches from `main`
- Write tests for new features
- Follow the existing code style
- Update documentation as needed
- Ensure CI/CD checks pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the `docs/` folder for detailed guides
- **Issues**: Report bugs and request features via GitHub Issues
- **API Documentation**: Available at the backend repository

## 📞 Contact

For questions about the mobile app development:
- Create an issue in this repository
- Check the project documentation
- Review the codebase for examples

---

Built with ❤️ using Flutter