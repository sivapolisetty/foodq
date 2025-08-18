-- KraveKart Local Development Seed Data
-- This script seeds the local Supabase with test data using the app_users table
-- Note: The migration already includes comprehensive test data, so this seed file is optional

-- Skip seeding for now since migration includes test data
-- Uncomment below if you want to add additional test data

-- Migration already includes test users, skipping additional seeding
/*
-- Create test users (business owners and customers)  
INSERT INTO app_users (id, name, email, user_type, business_id, phone, created_at) VALUES
-- Business users
('8db04ccf-3dc3-43a5-81aa-141ed4c74a37', 'Rajesh Patel', 'rajesh@pondicheridallas.com', 'business', '550e8400-e29b-41d4-a716-446655440001', '+1-555-123-0001', NOW()),
('cf73f9b3-38e3-464e-a814-fefee2926d3d', 'Priya Sharma', 'priya@kalachandjipalace.com', 'business', '550e8400-e29b-41d4-a716-446655440002', '+1-555-123-0002', NOW()),
('67f14748-2101-414a-b8b1-b6c328642f26', 'Arjun Singh', 'arjun@mughlaidallas.com', 'business', '550e8400-e29b-41d4-a716-446655440003', '+1-555-123-0003', NOW()),

-- Customer users
('5746b001-0333-4436-98d3-d44ee2dd323f', 'John Smith', 'john.smith@email.com', 'customer', NULL, '+1-555-123-0004', NOW()),
('84c5f752-0895-45cd-807b-ce85b3abe0a1', 'Emma Wilson', 'emma.wilson@email.com', 'customer', NULL, '+1-555-123-0005', NOW()),
('01f61879-f63f-4463-aa8c-974b231870ad', 'Mike Chen', 'mike.chen@email.com', 'customer', NULL, '+1-555-123-0006', NOW()),
('483e3a8f-2856-4ec1-badb-5f25fcf33b88', 'Lisa Brown', 'lisa.brown@email.com', 'customer', NULL, '+1-555-123-0007', NOW()),
('39140d53-afc7-429a-acff-b453fe1a0898', 'David Jones', 'david.jones@email.com', 'customer', NULL, '+1-555-123-0008', NOW())
ON CONFLICT (id) DO NOTHING;
*/

-- Migration already includes test businesses, using those instead
/*
-- Create businesses (Indian restaurants in Dallas)
INSERT INTO businesses (id, name, description, image_url, latitude, longitude, address, phone, email, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Pondicheri', 'Contemporary Indian cuisine with a creative twist', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800', 32.8205, -96.7838, '2800 Routh St, Dallas, TX 75201', '+1-214-522-1234', 'info@pondicheridallas.com', true),
('550e8400-e29b-41d4-a716-446655440002', 'Clay Pit Contemporary Indian Cuisine', 'Upscale Indian dining experience', 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800', 32.7767, -96.8077, '1601 Main St, Dallas, TX 75201', '+1-214-744-5678', 'info@claypit.com', true),
('550e8400-e29b-41d4-a716-446655440003', 'Cosmic Cafe', 'Vegetarian Indian fusion restaurant', 'https://images.unsplash.com/photo-1567337710282-00832b415979?w=800', 32.8098, -96.8295, '2912 Oak Lawn Ave, Dallas, TX 75219', '+1-214-521-6157', 'info@cosmiccafedallas.com', true)
ON CONFLICT (id) DO NOTHING;
*/

-- Migration already includes test deals, skipping additional deals
/*
-- Create Indian food deals  
INSERT INTO deals (id, business_id, title, description, original_price, discounted_price, quantity_available, quantity_sold, image_url, allergen_info, expires_at, status) VALUES
-- Pondicheri deals
('650e8400-e29b-41d4-a716-446655440017', '550e8400-e29b-41d4-a716-446655440001', 'Bhel Puri Platter', 'Mumbai street food mix of puffed rice, sev, chutneys, and vegetables', 12.00, 6.99, 15, 0, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=500', 'Contains: Gluten, Peanuts', NOW() + INTERVAL '4 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440018', '550e8400-e29b-41d4-a716-446655440001', 'Masala Dosa with Sambar', 'Crispy South Indian crepe with spiced potato filling', 16.00, 9.99, 10, 0, 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=500', 'Vegan, Gluten-Free', NOW() + INTERVAL '5 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440019', '550e8400-e29b-41d4-a716-446655440001', 'Chole Bhature Combo', 'Spiced chickpea curry with fluffy fried bread', 14.00, 8.49, 12, 0, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=500', 'Contains: Gluten', NOW() + INTERVAL '6 hours', 'active'),

-- Clay Pit deals
('650e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440002', 'Chicken Biryani Special', 'Aromatic basmati rice with marinated chicken and spices', 18.00, 12.99, 20, 0, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500', 'Contains: Dairy', NOW() + INTERVAL '3 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Paneer Tikka Platter', 'Grilled cottage cheese with bell peppers and onions', 15.00, 9.99, 15, 0, 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500', 'Contains: Dairy', NOW() + INTERVAL '4 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'Tandoori Mixed Grill', 'Assorted kebabs including chicken, lamb, and seekh', 25.00, 17.99, 8, 0, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500', 'Contains: Dairy', NOW() + INTERVAL '5 hours', 'active'),

-- Cosmic Cafe deals
('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'Buddha Bowl Special', 'Quinoa, roasted vegetables, chickpeas with tahini dressing', 14.00, 8.99, 20, 0, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500', 'Vegan, Gluten-Free', NOW() + INTERVAL '6 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', 'Palak Paneer Thali', 'Spinach curry with cottage cheese, rice, naan, and sides', 16.00, 10.99, 15, 0, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500', 'Contains: Dairy, Gluten', NOW() + INTERVAL '4 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', 'Samosa Chaat Bowl', 'Crushed samosas topped with yogurt, chutneys, and sev', 12.00, 7.99, 18, 0, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500', 'Contains: Gluten, Dairy', NOW() + INTERVAL '5 hours', 'active')
ON CONFLICT (id) DO NOTHING;

-- Add more variety of deals
INSERT INTO deals (id, business_id, title, description, original_price, discounted_price, quantity_available, quantity_sold, image_url, allergen_info, expires_at, status) VALUES
('650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440001', 'Idli Vada Combo', 'Steamed rice cakes with lentil donuts and chutneys', 10.00, 5.99, 25, 0, 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=500', 'Vegan, Gluten-Free', NOW() + INTERVAL '8 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'Butter Chicken Bowl', 'Creamy tomato curry with tender chicken and rice', 16.00, 11.99, 18, 0, 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500', 'Contains: Dairy', NOW() + INTERVAL '7 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', 'Aloo Gobi Wrap', 'Spiced cauliflower and potato in whole wheat wrap', 11.00, 6.99, 22, 0, 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500', 'Vegan', NOW() + INTERVAL '9 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440001', 'Pani Puri Kit', 'DIY kit with puris, spiced water, and fillings', 15.00, 8.99, 12, 0, 'https://images.unsplash.com/photo-1625398407796-82650a8c135f?w=500', 'Vegan', NOW() + INTERVAL '10 hours', 'active'),
('650e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440002', 'Lamb Korma Special', 'Mild curry with tender lamb in cashew sauce', 22.00, 15.99, 10, 0, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500', 'Contains: Dairy, Nuts', NOW() + INTERVAL '6 hours', 'active')
ON CONFLICT (id) DO NOTHING;

*/

-- Orders table will be added in a separate migration  
-- Sample orders would go here once the orders table is created

-- Output confirmation
SELECT 
    (SELECT COUNT(*) FROM app_users) as total_users,
    (SELECT COUNT(*) FROM businesses) as total_businesses,
    (SELECT COUNT(*) FROM deals) as total_deals;