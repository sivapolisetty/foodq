# GitHub Repository Setup Instructions

Follow these steps to create the GitHub repository and push your FoodQ mobile app.

## 🚀 Quick Setup

### Step 1: Create GitHub Repository

1. **Go to GitHub**: Navigate to https://github.com/new
2. **Repository Details**:
   - **Repository name**: `foodq-mobile-app` (or your preferred name)
   - **Description**: `Flutter mobile app for FoodQ food deals platform with location-based discovery and FOMO psychology`
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)

3. **Click "Create repository"**

### Step 2: Connect Local Repository to GitHub

After creating the repository, GitHub will show you commands. Use these in your terminal:

```bash
# Add the remote repository (replace with your actual repository URL)
git remote add origin https://github.com/YOUR_USERNAME/foodq-mobile-app.git

# Verify the remote was added
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Set Up Repository Settings

1. **Enable Issues and Discussions** (optional but recommended)
   - Go to Settings > General
   - Check "Issues" and "Discussions"

2. **Set up Branch Protection** (recommended for collaboration)
   - Go to Settings > Branches
   - Add rule for `main` branch
   - Enable "Require pull request reviews before merging"
   - Enable "Require status checks to pass before merging"

3. **Add Topics** (for discoverability)
   - Go to repository home
   - Click the gear icon next to "About"
   - Add topics: `flutter`, `dart`, `mobile-app`, `food-delivery`, `location-based`, `supabase`, `stripe`

## 🔧 Repository Configuration

### Secrets Setup (for CI/CD)

If you plan to use GitHub Actions for CI/CD, add these secrets:

1. Go to Settings > Secrets and Variables > Actions
2. Add the following repository secrets:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY` 
   - `GOOGLE_MAPS_API_KEY`
   - `STRIPE_PUBLISHABLE_KEY`
   - `ANDROID_KEYSTORE_PASSWORD` (for Android releases)
   - `IOS_CERTIFICATE_PASSWORD` (for iOS releases)

### Environment Files

Make sure to create environment files for contributors:

1. **Create `.env.example`**:
   ```bash
   # Copy the example to create your own .env file
   cp .env.example .env
   ```

2. **Example content** for `.env.example`:
   ```env
   API_BASE_URL=https://foodq.pages.dev
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
   STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
   ```

## 📋 For Contributors

### Setting Up Development Environment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/foodq-mobile-app.git
   cd foodq-mobile-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code files**:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Set up environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your actual API keys
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

### Contribution Workflow

1. **Fork the repository** (for external contributors)
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Run tests**:
   ```bash
   flutter test
   ```
5. **Commit and push**:
   ```bash
   git add .
   git commit -m "Add your feature description"
   git push origin feature/your-feature-name
   ```
6. **Create Pull Request** on GitHub

## 🏷️ Release Management

### Version Tagging

When creating releases:

```bash
# Tag a version
git tag v1.0.0
git push origin v1.0.0

# Create release on GitHub UI or via CLI
gh release create v1.0.0 --notes "Release notes here"
```

### Semantic Versioning

Follow semantic versioning:
- `v1.0.0` - Major release
- `v1.1.0` - Minor release (new features)
- `v1.1.1` - Patch release (bug fixes)

## 📱 Mobile-Specific Setup

### Android Setup for Contributors

1. **Google Maps API Key**:
   - Add to `android/app/src/main/AndroidManifest.xml`
   - Add to environment configuration

2. **Signing Configuration**:
   - Contributors need their own keystore for debug builds
   - Production signing should be handled via CI/CD

### iOS Setup for Contributors

1. **Google Maps API Key**:
   - Add to `ios/Runner/Info.plist`
   - Configure in environment settings

2. **Bundle Identifier**:
   - Each contributor should use their own bundle ID for development
   - Production bundle ID managed by repository owner

## 🔐 Security Best Practices

1. **Never commit sensitive data**:
   - API keys
   - Passwords
   - Keystores
   - Certificates

2. **Use environment files**:
   - All configuration via `.env` files
   - Never commit `.env` files (only `.env.example`)

3. **Review dependencies**:
   - Regularly update and audit dependencies
   - Use `flutter pub audit` for security checks

## 🚀 Next Steps After Setup

1. **Set up CI/CD pipeline** (GitHub Actions)
2. **Configure automated testing**
3. **Set up deployment workflows**
4. **Create issue templates**
5. **Set up project boards** for task management
6. **Add contributors** and set permissions

## 📞 Support

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for general questions
- **Documentation**: Check the main README.md for detailed setup instructions

---

🎉 **Congratulations!** Your FoodQ mobile app is now ready for collaborative development on GitHub!