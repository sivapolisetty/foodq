-- KraveKart Complete Database Schema
-- Single migration file for clean setup

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create businesses table
CREATE TABLE IF NOT EXISTS businesses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  phone VARCHAR(20),
  email VARCHAR(255),
  website VARCHAR(255),
  image_url TEXT,
  cuisine_type VARCHAR(100),
  opening_hours JSONB,
  rating DECIMAL(2, 1) DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create app_users table for unified user system
CREATE TABLE IF NOT EXISTS app_users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('business', 'customer')),
  business_id UUID REFERENCES businesses(id) ON DELETE SET NULL,
  profile_image_url TEXT,
  phone VARCHAR(20),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create deals table
CREATE TABLE IF NOT EXISTS deals (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  original_price DECIMAL(10, 2) NOT NULL,
  discounted_price DECIMAL(10, 2) NOT NULL,
  discount_percentage INTEGER GENERATED ALWAYS AS (
    CASE 
      WHEN original_price > 0 THEN 
        ROUND(((original_price - discounted_price) / original_price * 100)::numeric, 0)::integer
      ELSE 0 
    END
  ) STORED,
  quantity_available INTEGER NOT NULL DEFAULT 0,
  quantity_sold INTEGER DEFAULT 0,
  image_url TEXT,
  category VARCHAR(100),
  allergen_info TEXT,
  nutritional_info JSONB,
  preparation_time INTEGER,
  pickup_instructions TEXT,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'expired', 'sold_out')),
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT positive_prices CHECK (original_price > 0 AND discounted_price > 0),
  CONSTRAINT discount_valid CHECK (discounted_price < original_price),
  CONSTRAINT quantity_valid CHECK (quantity_available >= 0 AND quantity_sold >= 0)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_businesses_cuisine_type ON businesses(cuisine_type);
CREATE INDEX IF NOT EXISTS idx_businesses_is_active ON businesses(is_active);
CREATE INDEX IF NOT EXISTS idx_businesses_rating ON businesses(rating);

CREATE INDEX IF NOT EXISTS idx_app_users_user_type ON app_users(user_type);
CREATE INDEX IF NOT EXISTS idx_app_users_email ON app_users(email);
CREATE INDEX IF NOT EXISTS idx_app_users_business_id ON app_users(business_id);

CREATE INDEX IF NOT EXISTS idx_deals_business_id ON deals(business_id);
CREATE INDEX IF NOT EXISTS idx_deals_status ON deals(status);
CREATE INDEX IF NOT EXISTS idx_deals_expires_at ON deals(expires_at);
CREATE INDEX IF NOT EXISTS idx_deals_category ON deals(category);
CREATE INDEX IF NOT EXISTS idx_deals_created_at ON deals(created_at);

-- Enable RLS on all tables
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;

-- Grant permissions to roles
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO anon;

-- Create RLS policies for businesses
CREATE POLICY "Anyone can read businesses" ON businesses FOR SELECT USING (true);
CREATE POLICY "Service role can manage businesses" ON businesses FOR ALL TO service_role USING (true);

-- Create RLS policies for app_users
CREATE POLICY "Service role can do everything on app_users" ON app_users
  FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Public can read app_users" ON app_users
  FOR SELECT TO public USING (true);
CREATE POLICY "Public can insert app_users" ON app_users
  FOR INSERT TO public WITH CHECK (true);
CREATE POLICY "Users can update their own records" ON app_users
  FOR UPDATE TO public USING (true) WITH CHECK (true);

-- Create RLS policies for deals
CREATE POLICY "Anyone can read active deals" ON deals FOR SELECT USING (status = 'active' AND expires_at > NOW());
CREATE POLICY "Service role can manage deals" ON deals FOR ALL TO service_role USING (true);

-- Insert test businesses
INSERT INTO businesses (id, name, description, address, latitude, longitude, phone, email, cuisine_type, rating, image_url) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Mario''s Authentic Pizza', 'Traditional Italian pizzas made with love and authentic ingredients imported directly from Italy.', '123 Little Italy St, New York, NY 10013', 40.7589, -73.9851, '+1-555-PIZZA-01', 'info@mariospizza.com', 'Italian', 4.8, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800'),
  ('aeaec618-7e20-4ef3-a7da-97510d119366', 'The Burger Barn', 'Farm-to-table gourmet burgers with locally sourced ingredients and artisanal buns baked daily.', '456 Main Street, Austin, TX 78701', 30.2672, -97.7431, '+1-555-BURGER-2', 'hello@burgerbarn.com', 'American', 4.6, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800'),
  ('78bffd03-bb34-4ddb-b144-99cecd71f9f4', 'Corner Coffee Co.', 'Specialty coffee roasted in-house with a cozy atmosphere perfect for work or catching up with friends.', '789 Coffee Lane, Seattle, WA 98101', 47.6062, -122.3321, '+1-555-COFFEE-3', 'brew@cornercoffee.com', 'Cafe', 4.7, 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800'),
  ('12a8c9e4-5f3d-4b2a-8c1e-7f9d6e5c4b3a', 'Spice Route Indian Kitchen', 'Authentic North Indian cuisine with traditional tandoor cooking and aromatic spices.', '101 Curry Street, San Francisco, CA 94108', 37.7749, -122.4194, '+1-555-SPICE-01', 'orders@spiceroute.com', 'Indian', 4.9, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800'),
  ('23b9d0f5-6e4e-5c3b-9d2f-8e0e7f6d5c4b', 'Mumbai Street Food', 'Experience the vibrant flavors of Mumbai street food in a modern setting.', '202 Bollywood Ave, Los Angeles, CA 90028', 34.0522, -118.2437, '+1-555-MUMBAI-2', 'hello@mumbaistreet.com', 'Indian', 4.7, 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800'),
  ('34c0e1f6-7f5f-6d4c-0e3e-9f1f8e7e6d5c', 'Himalayan Flavors', 'Traditional Nepalese and Tibetan dishes with a focus on healthy, organic ingredients.', '303 Mountain View Rd, Denver, CO 80202', 39.7392, -104.9903, '+1-555-NEPAL-03', 'info@himalayanflavors.com', 'Nepalese', 4.8, 'https://images.unsplash.com/photo-1547592180-85f173990554?w=800')
ON CONFLICT (id) DO NOTHING;

-- Insert test app_users
INSERT INTO app_users (name, email, user_type, business_id, phone) VALUES
  ('Mario Rossi', 'mario@demopizza.com', 'business', '550e8400-e29b-41d4-a716-446655440001', '+1-555-123-0001'),
  ('Sarah Johnson', 'sarah@burgerbarn.com', 'business', 'aeaec618-7e20-4ef3-a7da-97510d119366', '+1-555-123-0002'),
  ('Alex Chen', 'alex@coffeecorner.com', 'business', '78bffd03-bb34-4ddb-b144-99cecd71f9f4', '+1-555-123-0003'),
  ('Raj Patel', 'raj@spiceroute.com', 'business', '12a8c9e4-5f3d-4b2a-8c1e-7f9d6e5c4b3a', '+1-555-123-0009'),
  ('Priya Sharma', 'priya@mumbaistreet.com', 'business', '23b9d0f5-6e4e-5c3b-9d2f-8e0e7f6d5c4b', '+1-555-123-0010'),
  ('Tenzin Norbu', 'tenzin@himalayanflavors.com', 'business', '34c0e1f6-7f5f-6d4c-0e3e-9f1f8e7e6d5c', '+1-555-123-0011'),
  ('John Smith', 'john.smith@email.com', 'customer', NULL, '+1-555-123-0004'),
  ('Emma Wilson', 'emma.wilson@email.com', 'customer', NULL, '+1-555-123-0005'),
  ('Mike Chen', 'mike.chen@email.com', 'customer', NULL, '+1-555-123-0006'),
  ('Lisa Brown', 'lisa.brown@email.com', 'customer', NULL, '+1-555-123-0007'),
  ('David Jones', 'david.jones@email.com', 'customer', NULL, '+1-555-123-0008')
ON CONFLICT (email) DO NOTHING;

-- Insert test deals
INSERT INTO deals (business_id, title, description, original_price, discounted_price, quantity_available, image_url, category, allergen_info, expires_at) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Margherita Pizza Special', 'Classic Margherita pizza with fresh mozzarella, tomato sauce, and basil', 18.99, 12.99, 15, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500', 'Pizza', 'Contains gluten, dairy', NOW() + INTERVAL '6 hours'),
  ('550e8400-e29b-41d4-a716-446655440001', 'Pepperoni Deluxe', 'Loaded with premium pepperoni and extra cheese', 22.99, 16.99, 10, 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500', 'Pizza', 'Contains gluten, dairy, pork', NOW() + INTERVAL '4 hours'),
  ('aeaec618-7e20-4ef3-a7da-97510d119366', 'Gourmet Cheeseburger', 'Angus beef patty with aged cheddar, lettuce, tomato, and special sauce', 15.99, 10.99, 20, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500', 'Burgers', 'Contains gluten, dairy, beef', NOW() + INTERVAL '5 hours'),
  ('aeaec618-7e20-4ef3-a7da-97510d119366', 'Crispy Chicken Sandwich', 'Buttermilk fried chicken with pickles and mayo on brioche bun', 13.99, 9.99, 12, 'https://images.unsplash.com/photo-1606755962773-d324e9a13086?w=500', 'Sandwiches', 'Contains gluten, dairy, chicken', NOW() + INTERVAL '7 hours'),
  ('78bffd03-bb34-4ddb-b144-99cecd71f9f4', 'Artisan Coffee Bundle', 'Single-origin Ethiopian beans - 12oz bag with free brewing tips', 24.99, 17.99, 8, 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500', 'Coffee', 'None', NOW() + INTERVAL '8 hours'),
  ('12a8c9e4-5f3d-4b2a-8c1e-7f9d6e5c4b3a', 'Butter Chicken Combo', 'Creamy butter chicken with basmati rice and fresh naan bread', 19.99, 14.99, 18, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500', 'Indian', 'Contains dairy, gluten', NOW() + INTERVAL '3 hours'),
  ('12a8c9e4-5f3d-4b2a-8c1e-7f9d6e5c4b3a', 'Tandoori Mixed Grill', 'Assorted tandoori meats with mint chutney and onion salad', 26.99, 19.99, 12, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500', 'Indian', 'Contains dairy', NOW()  + INTERVAL '5 hours'),
  ('23b9d0f5-6e4e-5c3b-9d2f-8e0e7f6d5c4b', 'Pav Bhaji Special', 'Mumbai-style spiced vegetable curry with buttered bread rolls', 14.99, 10.99, 25, 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=500', 'Indian Street Food', 'Contains gluten, dairy', NOW() + INTERVAL '4 hours'),
  ('23b9d0f5-6e4e-5c3b-9d2f-8e0e7f6d5c4b', 'Vada Pav Triple Pack', 'Three crispy potato fritters in soft buns with chutneys', 11.99, 7.99, 30, 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=500', 'Indian Street Food', 'Contains gluten', NOW() + INTERVAL '6 hours'),
  ('34c0e1f6-7f5f-6d4c-0e3e-9f1f8e7e6d5c', 'Himalayan Thali', 'Traditional platter with dal, vegetables, rice, and homemade bread', 22.99, 16.99, 15, 'https://images.unsplash.com/photo-1547592180-85f173990554?w=500', 'Nepalese', 'Contains gluten', NOW() + INTERVAL '7 hours'),
  ('34c0e1f6-7f5f-6d4c-0e3e-9f1f8e7e6d5c', 'Momo Feast', '20 pieces of steamed dumplings with spicy tomato chutney', 16.99, 12.99, 20, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500', 'Nepalese', 'Contains gluten', NOW() + INTERVAL '5 hours')
ON CONFLICT DO NOTHING;