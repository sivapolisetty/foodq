-- Add JSONB saved_addresses column to app_users table for pickup location preferences
-- This replaces the separate customer_addresses table with a simpler JSONB approach

-- Add saved_addresses JSONB column to app_users
ALTER TABLE app_users ADD COLUMN saved_addresses JSONB DEFAULT '[]'::jsonb;

-- Create GIN index for efficient JSONB queries
CREATE INDEX idx_app_users_saved_addresses ON app_users USING GIN (saved_addresses);

-- Create index for querying primary address
CREATE INDEX idx_app_users_primary_address ON app_users USING GIN ((saved_addresses -> 'primary_address'));

-- Add comment explaining the column
COMMENT ON COLUMN app_users.saved_addresses IS 'JSONB array storing user''s saved pickup location preferences with structure: {"addresses": [...], "primary_address": {...}}';

-- Example JSONB structure:
/*
{
  "addresses": [
    {
      "id": "addr_001",
      "label": "Home", 
      "formatted_address": "123 Main St, City, State 12345",
      "street": "123 Main St",
      "city": "City",
      "state": "State", 
      "zip_code": "12345",
      "country": "US",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "place_id": "ChIJGVtI4by3t4kRr51d_Qm_x58",
      "is_primary": true,
      "address_type": "pickup_location",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "primary_address": {
    "id": "addr_001",
    "formatted_address": "123 Main St, City, State 12345",
    "latitude": 40.7128,
    "longitude": -74.0060
  }
}
*/