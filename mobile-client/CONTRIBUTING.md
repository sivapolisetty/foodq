# Contributing to FoodQ Mobile App

Thank you for your interest in contributing to the FoodQ mobile app! This document provides guidelines and instructions for contributors.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Android Studio or VS Code
- Git
- A GitHub account

### Setup Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/foodq-mobile-app.git
   cd foodq-mobile-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

4. **Generate Code**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run Tests**
   ```bash
   flutter test
   ```

6. **Start Development**
   ```bash
   flutter run
   ```

## 🔄 Development Workflow

### Branch Strategy

- `main` - Production ready code
- `develop` - Integration branch (if used)
- `feature/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `hotfix/critical-fix` - Critical production fixes

### Creating a Feature

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Write clean, documented code
   - Follow existing code style
   - Add tests for new functionality

3. **Test Changes**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add user profile settings"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

## 📝 Code Style Guidelines

### Dart/Flutter Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Run `flutter analyze` to check for issues

### Code Organization

```
lib/
├── features/          # Feature modules
│   ├── auth/         # Authentication
│   ├── deals/        # Deal management  
│   └── orders/       # Order management
├── shared/           # Shared components
│   ├── models/       # Data models
│   ├── widgets/      # Reusable widgets
│   └── services/     # Shared services
└── core/             # Core functionality
    ├── config/       # Configuration
    └── services/     # Core services
```

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

### Documentation

- Add meaningful comments for complex logic
- Use `///` for public API documentation
- Update README if adding new features

## 🧪 Testing

### Writing Tests

- **Unit Tests**: `test/unit/`
- **Widget Tests**: `test/widget/`
- **Integration Tests**: `test/integration/`

### Test Requirements

- All new features must include tests
- Maintain or improve code coverage
- Tests should be fast and reliable

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit/auth/auth_service_test.dart

# With coverage
flutter test --coverage
```

## 🐛 Bug Reports

### Before Reporting

1. Check existing issues
2. Ensure you're using the latest version
3. Test on multiple devices if possible

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**Steps to reproduce**
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Device information:**
 - Device: [e.g. iPhone 12, Pixel 5]
 - OS: [e.g. iOS 15.0, Android 11]
 - App Version: [e.g. 1.2.0]
```

## ✨ Feature Requests

### Feature Request Template

```markdown
**Feature description**
A clear description of the feature you'd like to see.

**Use case**
Explain how this feature would be used.

**Proposed solution**
If you have ideas on implementation.

**Alternatives considered**
Any alternative solutions you've considered.
```

## 📋 Pull Request Process

### PR Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] CI checks pass

### PR Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes.
```

### Review Process

1. **Automated Checks**: CI must pass
2. **Code Review**: At least one review required
3. **Testing**: Reviewers test functionality
4. **Approval**: Maintainer approval needed
5. **Merge**: Squash and merge preferred

## 🚀 Release Process

### Version Management

- Follow semantic versioning (SemVer)
- Update version in `pubspec.yaml`
- Create git tags for releases

### Release Checklist

- [ ] All features tested
- [ ] Documentation updated
- [ ] Version bumped
- [ ] Changelog updated
- [ ] Release notes prepared

## 💡 Best Practices

### Performance

- Optimize widget rebuilds
- Use const constructors
- Profile app performance
- Optimize images and assets

### Security

- Never commit secrets
- Validate user inputs
- Follow security best practices
- Regular dependency updates

### Accessibility

- Add semantic labels
- Test with screen readers
- Ensure proper contrast ratios
- Support different font sizes

## 🤝 Community

### Communication

- Be respectful and inclusive
- Use clear, constructive language
- Help other contributors
- Share knowledge and best practices

### Recognition

Contributors are recognized in:
- README contributors section
- Release notes
- Special recognition for major contributions

## 📞 Getting Help

- **Issues**: Technical problems and bugs
- **Discussions**: General questions and ideas
- **Code Review**: Ask specific code questions in PRs

Thank you for contributing to FoodQ! 🎉