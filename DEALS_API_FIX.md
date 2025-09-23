# 🔧 Deals API Fix: `future_expiration` Constraint

## ❌ Problem

The deals API was failing with a 500 error:
```json
{
  "error": "Database error: new row for relation \"deals\" violates check constraint \"future_expiration\""
}
```

**Root Cause**: Production database has a constraint requiring `expires_at` to be in the future, but the API wasn't properly handling this field.

## ✅ Solution Applied

### 1. **Fixed POST `/api/deals`**
Added validation and automatic handling of `expires_at`:

```typescript
// Validate and set expires_at - required for future_expiration constraint
let expiresAt = dealData.expires_at;
if (!expiresAt) {
  // Default to 24 hours from now if not provided
  const defaultExpiry = new Date();
  defaultExpiry.setHours(defaultExpiry.getHours() + 24);
  expiresAt = defaultExpiry.toISOString();
} else {
  // Validate that provided expiry is in the future
  const expiryDate = new Date(expiresAt);
  if (expiryDate <= new Date()) {
    return errorResponse('expires_at must be in the future', 400, request, env);
  }
}

// Include in deal record
const dealRecord = {
  ...dealData,
  expires_at: expiresAt,  // ← Fixed: Now properly sets expires_at
  // ... other fields
};
```

### 2. **Fixed PUT `/api/deals/{id}`**
Added validation for expires_at updates:

```typescript
// Validate expires_at if being updated
if (updates.expires_at) {
  const expiryDate = new Date(updates.expires_at);
  if (expiryDate <= new Date()) {
    return createErrorResponse('expires_at must be in the future', 400, corsHeaders);
  }
}
```

## 🎯 **Behavior Changes**

### **Before (Broken)**
- API didn't set `expires_at` field
- Database constraint violation → 500 error
- No validation of expiry dates

### **After (Fixed)**
- API automatically sets `expires_at` to 24 hours from now if not provided
- Validates that provided `expires_at` is in the future
- Returns proper 400 error for invalid dates
- Respects the database constraint

## 📊 **API Examples**

### **Creating Deal (No expires_at provided)**
```typescript
POST /api/deals
{
  "title": "Pizza Deal",
  "description": "50% off pizza",
  "original_price": 20.00,
  "discounted_price": 10.00,
  "business_id": "abc-123"
  // expires_at not provided
}

// API automatically sets: expires_at = now + 24 hours
```

### **Creating Deal (With expires_at)**
```typescript
POST /api/deals
{
  "title": "Pizza Deal",
  "expires_at": "2025-12-31T23:59:59Z",  // Valid future date
  // ... other fields
}

// API validates and uses provided expires_at
```

### **Error for Past Date**
```typescript
POST /api/deals
{
  "expires_at": "2020-01-01T00:00:00Z"  // Past date
}

// Returns 400: "expires_at must be in the future"
```

## 🗄️ **Database Constraint**

The production database has this constraint:
```sql
ALTER TABLE deals 
ADD CONSTRAINT future_expiration 
CHECK (expires_at > NOW());
```

This ensures all deals have a valid future expiration date.

## ✅ **Testing Results**

- **GET `/api/deals`**: ✅ Working correctly
- **POST `/api/deals`**: ✅ Now handles expires_at properly  
- **PUT `/api/deals/{id}`**: ✅ Validates expires_at updates
- **Database Constraint**: ✅ No longer violated

## 🚀 **Deployed**

**Live URL**: https://53ac1363.foodq.pages.dev/api/deals

The fix is now live and the 500 error should be resolved. The API will either:
1. Use the provided `expires_at` (if valid and in future)
2. Default to 24 hours from now (if not provided)
3. Return 400 error for invalid dates (if in past)

**Status**: ✅ **FIXED AND DEPLOYED**