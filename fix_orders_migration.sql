-- Fix Orders Migration
-- This migration creates orders and order_items tables with proper schema
-- WARNING: This will DROP existing orders tables if they exist!

-- Drop existing tables if they exist (be careful, this will delete all data!)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;

-- Create orders table
CREATE TABLE orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL,
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled')),
  total_amount DECIMAL(10, 2) NOT NULL,
  delivery_address TEXT,
  delivery_instructions TEXT,
  pickup_time TIMESTAMPTZ,
  payment_method VARCHAR(20) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'digital_wallet')),
  payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT positive_total CHECK (total_amount >= 0)
);

-- Create order_items table
CREATE TABLE order_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  deal_id UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  price DECIMAL(10, 2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT positive_quantity CHECK (quantity > 0),
  CONSTRAINT positive_price CHECK (price >= 0)
);

-- Create indexes for performance
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_business_id ON orders(business_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_pickup_time ON orders(pickup_time);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_deal_id ON order_items(deal_id);

-- Enable RLS on orders tables
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Grant permissions to roles
GRANT ALL ON orders TO postgres;
GRANT ALL ON orders TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON orders TO authenticated;

GRANT ALL ON order_items TO postgres;
GRANT ALL ON order_items TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON order_items TO authenticated;

-- Create RLS policies for orders
CREATE POLICY "Users can view their own orders" ON orders 
  FOR SELECT TO authenticated 
  USING (user_id::text = auth.uid()::text);

CREATE POLICY "Businesses can view their orders" ON orders 
  FOR SELECT TO authenticated 
  USING (business_id IN (
    SELECT business_id FROM app_users WHERE id::text = auth.uid()::text AND user_type = 'business'
  ));

CREATE POLICY "Service role can manage all orders" ON orders 
  FOR ALL TO service_role 
  USING (true) WITH CHECK (true);

-- Create RLS policies for order_items
CREATE POLICY "Users can view their order items" ON order_items 
  FOR SELECT TO authenticated 
  USING (order_id IN (
    SELECT id FROM orders WHERE user_id::text = auth.uid()::text
  ));

CREATE POLICY "Businesses can view their order items" ON order_items 
  FOR SELECT TO authenticated 
  USING (order_id IN (
    SELECT o.id FROM orders o
    JOIN app_users au ON au.business_id = o.business_id
    WHERE au.id::text = auth.uid()::text AND au.user_type = 'business'
  ));

CREATE POLICY "Service role can manage all order items" ON order_items 
  FOR ALL TO service_role 
  USING (true) WITH CHECK (true);

-- Create or replace function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update the updated_at column
CREATE TRIGGER update_orders_updated_at 
  BEFORE UPDATE ON orders 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();