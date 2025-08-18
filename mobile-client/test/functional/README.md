# KraveKart Functional Tests

## Overview

This directory contains comprehensive functional tests for KraveKart that **replace manual testing entirely**. These tests simulate real user interactions and validate complete user journeys across the application.

## Test Structure

### 📱 Core Test Suites

1. **`auth_flow_test.dart`** - Authentication & User Management
   - Customer login/signup
   - Business registration & enrollment
   - Staff access controls
   - Session management
   - Password reset
   - Social authentication

2. **`customer_home_flow_test.dart`** - Customer Experience
   - Home screen with map view
   - Browse nearby deals
   - Search and filtering
   - Real-time deal notifications
   - Location-based features

3. **`cart_checkout_flow_test.dart`** - Shopping & Payment
   - Add items to cart
   - Quantity management
   - Checkout process
   - Payment integration (Stripe mocks)
   - Order confirmation
   - Discount codes

4. **`business_management_flow_test.dart`** - Business Operations
   - Deal creation and management
   - Staff management
   - Order processing
   - Financial reporting
   - Pickup validation

5. **`notifications_flow_test.dart`** - Real-time Features
   - Push notifications
   - Geofenced alerts
   - Order status updates
   - Notification preferences

### 🧪 Test Infrastructure

- **`test_setup.dart`** - Mock services, test data, and common utilities
- **`run_functional_tests.dart`** - Test suite orchestrator
- **`../scripts/run_all_functional_tests.sh`** - Automated test runner

## Running Tests

### Quick Start
```bash
# Run all functional tests
./scripts/run_all_functional_tests.sh
```

### Individual Test Suites
```bash
# Authentication tests
flutter test test/functional/auth_flow_test.dart

# Customer experience tests
flutter test test/functional/customer_home_flow_test.dart

# Shopping cart tests
flutter test test/functional/cart_checkout_flow_test.dart

# Business management tests
flutter test test/functional/business_management_flow_test.dart

# Notifications tests
flutter test test/functional/notifications_flow_test.dart
```

### With Coverage
```bash
flutter test test/functional/ --coverage
```

## What These Tests Replace

### ❌ Manual Testing Not Needed For:
- **User Registration & Login** - All auth flows automated
- **Deal Browsing** - Map interactions, search, filters tested
- **Shopping Cart** - Add, remove, quantity changes automated
- **Checkout Process** - Payment flows, validations covered
- **Business Operations** - Deal posting, staff management tested
- **Order Fulfillment** - Pickup codes, status updates automated
- **Notifications** - Real-time alerts, preferences tested
- **Role-Based Access** - Customer/business/staff permissions verified

### ✅ Comprehensive Coverage:
- **Happy Path Flows** - Complete user journeys
- **Error Scenarios** - Network failures, validation errors
- **Edge Cases** - Empty states, minimum orders, expired deals
- **Security** - Role restrictions, data access controls
- **Performance** - Loading states, data refresh

## Test Data & Mocking

### Mock Services
- **Supabase Client** - Database operations, auth
- **Firebase** - Push notifications
- **Stripe** - Payment processing
- **Location Services** - GPS, geofencing
- **Image Uploads** - File handling

### Test Data Fixtures
- Sample users (customer, business, staff)
- Deal data with various categories
- Order workflows
- Notification scenarios

## Key Features Tested

### 🔐 Authentication
- [x] Customer login with email/password
- [x] Business login with role switching
- [x] Staff limited access
- [x] Social login (Google/Apple)
- [x] Password reset flow
- [x] Session persistence

### 🏠 Customer Experience
- [x] Map view with deal pins
- [x] Nearby deals based on location
- [x] Search and category filters
- [x] Deal details and descriptions
- [x] Real-time deal notifications
- [x] Distance-based sorting

### 🛒 Shopping & Payment
- [x] Add items to cart
- [x] Quantity management
- [x] Cart persistence
- [x] Checkout validation
- [x] Payment processing
- [x] Order confirmation
- [x] Pickup code generation

### 🏢 Business Operations
- [x] Business enrollment
- [x] Deal creation and editing
- [x] Staff invitation and management
- [x] Order processing
- [x] Financial reporting
- [x] Pickup validation

### 🔔 Notifications
- [x] Real-time deal alerts
- [x] Order status updates
- [x] Geofenced notifications
- [x] Preference management
- [x] Notification history

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Functional Tests
  run: ./scripts/run_all_functional_tests.sh
```

## Test-Driven Development

Following TDD principles:
1. **Write tests first** - Define expected behavior
2. **Implement features** - Make tests pass
3. **Refactor** - Improve code while maintaining tests
4. **100% automation** - No manual verification needed

## Maintenance

### Adding New Tests
1. Create test in appropriate suite
2. Add mock data to `test_setup.dart`
3. Update `run_functional_tests.dart`
4. Document new coverage

### Mock Updates
When APIs change:
1. Update mocks in `test_setup.dart`
2. Adjust test expectations
3. Verify all tests pass

## Success Criteria

✅ **All tests passing = App ready for release**
- No manual QA needed
- Complete user journey coverage
- All role-based permissions verified
- Payment flows validated
- Real-time features tested

## Coverage Goals

- **Line Coverage**: >80%
- **Feature Coverage**: 100% of user stories
- **Flow Coverage**: All critical user paths
- **Error Coverage**: All error scenarios

---

**Note**: These functional tests completely replace manual testing. When all tests pass, the app is ready for production deployment.