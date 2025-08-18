# End-to-End API Tests

These tests perform **real operations** against a Supabase cloud database, creating, updating, and deleting actual data to verify the complete API functionality.

## 🚨 IMPORTANT WARNINGS

1. **Use a dedicated test Supabase project** - Never run these tests against production!
2. **Tests create and delete real data** - Ensure proper cleanup is enabled
3. **Network connectivity required** - Tests will fail without internet access
4. **Rate limits may apply** - Supabase has API rate limits for free tier

## 🏗️ Setup Instructions

### 1. Create Test Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project specifically for testing
3. Name it something like "kravekart-test"
4. Deploy the database schema:

```bash
# Run the main schema
psql -h db.xxx.supabase.co -U postgres -d postgres -f supabase/setup_deals_schema.sql

# Optionally load seed data for reference
psql -h db.xxx.supabase.co -U postgres -d postgres -f supabase/seed_data.sql
```

### 2. Configure Environment Variables

Option A: **Environment Variables** (Recommended for CI/CD)
```bash
export SUPABASE_TEST_URL="https://your-test-project.supabase.co"
export SUPABASE_TEST_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
export SUPABASE_TEST_SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

Option B: **Environment File** (For local development)
```bash
# Copy the example file
cp .env.test.example .env.test

# Edit .env.test with your actual Supabase credentials
# The test will automatically load this file
```

### 3. Get Supabase Credentials

From your test Supabase project dashboard:

1. **Project URL**: Settings → API → Project URL
2. **Anon Key**: Settings → API → Project API keys → anon public
3. **Service Key**: Settings → API → Project API keys → service_role (keep secret!)

## 🧪 Running the Tests

### Run All E2E Tests
```bash
flutter test test/e2e/
```

### Run Specific Test Groups
```bash
# Only business tests
flutter test test/e2e/supabase_e2e_test.dart --name "Business E2E API Tests"

# Only deal tests  
flutter test test/e2e/supabase_e2e_test.dart --name "Deal E2E API Tests"

# Performance tests
flutter test test/e2e/supabase_e2e_test.dart --name "Performance and Reliability Tests"
```

### Run with Verbose Output
```bash
flutter test test/e2e/supabase_e2e_test.dart -v
```

## 📊 What Gets Tested

### Business Operations
- ✅ **CREATE**: Insert new business into Supabase
- ✅ **READ**: Fetch business by ID from database  
- ✅ **UPDATE**: Modify business and verify persistence
- ✅ **DELETE**: Remove business and verify deletion
- ✅ **SEARCH**: Query businesses by name/description

### Deal Operations  
- ✅ **CREATE**: Insert new deal into Supabase
- ✅ **READ**: Fetch deals for business from database
- ✅ **UPDATE**: Modify deal and verify persistence  
- ✅ **DELETE**: Remove deal and verify deletion
- ✅ **TOGGLE STATUS**: Activate/deactivate deals
- ✅ **SEARCH**: Query deals by keywords

### Advanced Features
- ✅ **ACTIVE DEALS**: Filter only active, valid deals
- ✅ **BUSINESS STATS**: Calculate deal counts and statistics
- ✅ **CONCURRENT OPERATIONS**: Handle multiple simultaneous API calls
- ✅ **ERROR HANDLING**: Graceful handling of non-existent resources

### Data Verification
- ✅ **Database Consistency**: Verify data persists correctly
- ✅ **Foreign Key Relationships**: Ensure deals link to businesses
- ✅ **Data Integrity**: Validate required fields and constraints
- ✅ **Real-time Updates**: Confirm changes are immediately available

## 🧹 Test Data Management

### Automatic Cleanup
- Tests automatically clean up data they create
- Cleanup runs even if tests fail (configurable)
- Leftover data from previous runs is automatically detected and cleaned

### Test Data Identification
- All test data uses prefixes: `E2E_TEST_`, `E2E_TEST_BIZ_`, `E2E_TEST_DEAL_`
- Easy to identify and manually clean if needed
- Isolated from seed data and production data

### Manual Cleanup (if needed)
```sql
-- Clean up test businesses (cascades to deals)
DELETE FROM businesses WHERE name LIKE 'E2E_TEST_%';

-- Clean up test deals
DELETE FROM deals WHERE title LIKE 'E2E_TEST_%';
```

## 📈 Expected Results

When all tests pass, you should see:
```
✅ Business created with ID: abc-123-def
✅ Business fetched successfully: E2E_TEST_BIZ_Restaurant_1234567890
✅ Business updated successfully: E2E_TEST_BIZ_Updated_1234567890
✅ Business deleted successfully
✅ Search returned 5 businesses
✅ Deal created with ID: def-456-ghi
✅ Fetched 3 deals for business
✅ Deal updated successfully: E2E_TEST_DEAL_Updated_1234567890
✅ Deal deleted successfully
✅ Deal status toggled successfully
✅ Active deals filtered correctly: 2 active deals found
✅ Search returned 2 matching deals
✅ Business stats: 5 total, 3 active
✅ Created 5 deals concurrently
✅ Non-existent resources handled gracefully
```

## 🔧 Troubleshooting

### Common Issues

**"Test configuration incomplete"**
- Set SUPABASE_TEST_URL and SUPABASE_TEST_ANON_KEY environment variables
- Or create .env.test file with credentials

**"Connection refused" or timeout errors**
- Check internet connectivity
- Verify Supabase project URL is correct
- Ensure Supabase project is not paused (free tier limitation)

**"Row Level Security policy violation"**
- Check RLS policies in your test database
- Ensure anon key has necessary permissions
- Verify database schema was deployed correctly

**Tests fail with "Foreign key constraint violation"**
- Database schema may not be properly deployed
- Run the setup_deals_schema.sql script
- Check that all tables and relationships exist

### Debug Mode
```bash
# Run single test with debug output
flutter test test/e2e/supabase_e2e_test.dart --name "Should create business" -v
```

## 🚀 CI/CD Integration

For automated testing in GitHub Actions, GitLab CI, etc.:

```yaml
# Example GitHub Actions step
- name: Run E2E API Tests
  env:
    SUPABASE_TEST_URL: ${{ secrets.SUPABASE_TEST_URL }}
    SUPABASE_TEST_ANON_KEY: ${{ secrets.SUPABASE_TEST_ANON_KEY }}
    SUPABASE_TEST_SERVICE_KEY: ${{ secrets.SUPABASE_TEST_SERVICE_KEY }}
  run: flutter test test/e2e/
```

## 📝 Adding New Tests

To add new E2E tests:

1. Follow the existing pattern in `supabase_e2e_test.dart`
2. Register any created data with `testDataManager` for cleanup
3. Use `await testDataManager.waitForConsistency()` after operations
4. Verify both service responses AND database state
5. Include error scenarios and edge cases

Example:
```dart
test('NEW FEATURE: Should do something in Supabase', () async {
  // Create test data
  final data = testDataManager.createTestBusinessData();
  
  // Perform operation
  final result = await service.doSomething(data);
  
  // Register for cleanup
  testDataManager.registerBusiness(result.id);
  
  // Verify service response
  expect(result.success, true);
  
  // Wait for consistency
  await testDataManager.waitForConsistency();
  
  // Verify database state
  final dbData = await testDataManager.getBusinessFromDb(result.id);
  expect(dbData['status'], 'expected_value');
  
  print('✅ New feature working correctly');
});
```