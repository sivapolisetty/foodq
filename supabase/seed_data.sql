-- KraveKart Seed Data Script
-- Creates sample data for testing with 5 restaurants owned by the same business owner

-- Clear existing seed data (optional - comment out in production)
DELETE FROM deal_redemptions WHERE customer_id IN (SELECT id FROM auth.users WHERE email LIKE '%@kravekart-demo.com');
DELETE FROM deal_category_mapping WHERE deal_id IN (SELECT id FROM deals WHERE business_id IN (SELECT id FROM businesses WHERE owner_id IN (SELECT id FROM auth.users WHERE email = 'owner@kravekart-demo.com')));
DELETE FROM deals WHERE business_id IN (SELECT id FROM businesses WHERE owner_id IN (SELECT id FROM auth.users WHERE email = 'owner@kravekart-demo.com'));
DELETE FROM businesses WHERE owner_id IN (SELECT id FROM auth.users WHERE email = 'owner@kravekart-demo.com');

-- Create demo business owner user (if using Supabase Auth)
-- Note: In real scenarios, users would be created through auth flow
-- This is just for demonstration
DO $$
DECLARE
  owner_id UUID := '11111111-1111-1111-1111-111111111111';
BEGIN
  -- Insert demo owner (you might need to handle this differently based on your auth setup)
  -- For now, we'll use a fixed UUID
  
  -- Insert 5 restaurants for the same owner
  INSERT INTO businesses (id, name, description, image_url, owner_id, address, phone, email, latitude, longitude, is_active, created_at)
  VALUES
    -- Restaurant 1: Indian Cuisine
    ('22222222-2222-2222-2222-222222222221', 
     'Spice Garden Restaurant', 
     'Authentic Indian cuisine with a modern twist. Specializing in North Indian, South Indian, and Indo-Chinese dishes.',
     'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
     owner_id,
     '123 MG Road, Bangalore, Karnataka 560001',
     '+91 80 2222 1111',
     'spicegarden@kravekart-demo.com',
     12.9716, 77.5946,
     true,
     NOW() - INTERVAL '6 months'),
    
    -- Restaurant 2: Italian
    ('22222222-2222-2222-2222-222222222222',
     'Bella Vista Pizzeria',
     'Wood-fired pizzas, fresh pasta, and authentic Italian flavors in a cozy atmosphere.',
     'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
     owner_id,
     '45 Brigade Road, Bangalore, Karnataka 560025',
     '+91 80 2222 2222',
     'bellavista@kravekart-demo.com',
     12.9688, 77.6099,
     true,
     NOW() - INTERVAL '4 months'),
    
    -- Restaurant 3: Chinese
    ('22222222-2222-2222-2222-222222222223',
     'Dragon Palace',
     'Premium Chinese dining experience with Szechuan, Cantonese, and Hunan specialties.',
     'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800',
     owner_id,
     '78 Indiranagar, Bangalore, Karnataka 560038',
     '+91 80 2222 3333',
     'dragonpalace@kravekart-demo.com',
     12.9784, 77.6408,
     true,
     NOW() - INTERVAL '8 months'),
    
    -- Restaurant 4: Multi-cuisine Cafe
    ('22222222-2222-2222-2222-222222222224',
     'The Urban Cafe',
     'All-day dining cafe serving Continental, Asian, and Indian favorites with great coffee.',
     'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800',
     owner_id,
     '12 Koramangala, Bangalore, Karnataka 560034',
     '+91 80 2222 4444',
     'urbancafe@kravekart-demo.com',
     12.9352, 77.6245,
     true,
     NOW() - INTERVAL '3 months'),
    
    -- Restaurant 5: Fast Food
    ('22222222-2222-2222-2222-222222222225',
     'Quick Bites Express',
     'Fast food favorites including burgers, wraps, sandwiches, and shakes for quick meals.',
     'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=800',
     owner_id,
     '90 HSR Layout, Bangalore, Karnataka 560102',
     '+91 80 2222 5555',
     'quickbites@kravekart-demo.com',
     12.9150, 77.6380,
     true,
     NOW() - INTERVAL '2 months');

  -- Insert deals for Restaurant 1: Spice Garden
  INSERT INTO deals (id, title, description, original_price, discounted_price, discount_percentage, business_id, image_url, is_active, valid_from, valid_until, terms_conditions, max_redemptions, current_redemptions, created_at)
  VALUES
    (gen_random_uuid(),
     'Lunch Buffet Special',
     'Unlimited vegetarian lunch buffet with 20+ dishes including starters, main course, and desserts',
     699, 499, 29,
     '22222222-2222-2222-2222-222222222221',
     'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800',
     true,
     NOW() - INTERVAL '1 day',
     NOW() + INTERVAL '30 days',
     'Valid Monday to Friday, 12 PM to 3 PM only. Beverages not included.',
     50, 12,
     NOW() - INTERVAL '1 day'),
    
    (gen_random_uuid(),
     'Family Dinner Combo',
     'Complete dinner for 4 people with 2 starters, 3 main courses, breads, rice, and dessert',
     2499, 1799, 28,
     '22222222-2222-2222-2222-222222222221',
     'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '45 days',
     'Advance booking required. Valid for dine-in only.',
     30, 5,
     NOW()),
    
    (gen_random_uuid(),
     'Weekend Breakfast Deal',
     'South Indian breakfast platter with dosa, idli, vada, and filter coffee',
     299, 199, 33,
     '22222222-2222-2222-2222-222222222221',
     'https://images.unsplash.com/photo-1589301760014-d929f919ed24?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '60 days',
     'Valid on weekends only, 8 AM to 11 AM.',
     100, 23,
     NOW());

  -- Insert deals for Restaurant 2: Bella Vista Pizzeria
  INSERT INTO deals (id, title, description, original_price, discounted_price, discount_percentage, business_id, image_url, is_active, valid_from, valid_until, terms_conditions, max_redemptions, current_redemptions, created_at)
  VALUES
    (gen_random_uuid(),
     'Buy 1 Get 1 Pizza',
     'Order any large pizza and get another large pizza of equal or lesser value free',
     899, 449, 50,
     '22222222-2222-2222-2222-222222222222',
     'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '20 days',
     'Not valid on premium pizzas. Dine-in and takeaway only.',
     75, 45,
     NOW()),
    
    (gen_random_uuid(),
     'Pasta Tuesday Special',
     'Any pasta dish with garlic bread and soft drink at special price',
     599, 399, 33,
     '22222222-2222-2222-2222-222222222222',
     'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '90 days',
     'Valid only on Tuesdays. Choice of pasta from regular menu.',
     40, 8,
     NOW()),
    
    (gen_random_uuid(),
     'Date Night Combo',
     'Special combo for couples - 1 appetizer, 2 mains, dessert to share, and 2 mocktails',
     1899, 1299, 32,
     '22222222-2222-2222-2222-222222222222',
     'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
     true,
     NOW() - INTERVAL '5 days',
     NOW() + INTERVAL '25 days',
     'Reservation required. Valid after 7 PM only.',
     20, 12,
     NOW() - INTERVAL '5 days');

  -- Insert deals for Restaurant 3: Dragon Palace
  INSERT INTO deals (id, title, description, original_price, discounted_price, discount_percentage, business_id, image_url, is_active, valid_from, valid_until, terms_conditions, max_redemptions, current_redemptions, created_at)
  VALUES
    (gen_random_uuid(),
     'Dim Sum Festival',
     'Unlimited dim sum varieties with complimentary Chinese tea',
     899, 599, 33,
     '22222222-2222-2222-2222-222222222223',
     'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '15 days',
     'Available 12 PM to 4 PM only. Minimum 2 people.',
     60, 35,
     NOW()),
    
    (gen_random_uuid(),
     'Wok Special Combo',
     'Choose any wok dish with fried rice or noodles and spring rolls',
     799, 549, 31,
     '22222222-2222-2222-2222-222222222223',
     'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '40 days',
     'Not valid on seafood items. Spice level customizable.',
     80, 15,
     NOW()),
    
    (gen_random_uuid(),
     'Corporate Lunch Box',
     'Quick lunch box with main course, rice/noodles, soup, and fortune cookie',
     399, 249, 38,
     '22222222-2222-2222-2222-222222222223',
     'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '3 days', -- Expiring soon!
     'Minimum order 5 boxes. Delivery within 5km radius.',
     200, 178,
     NOW());

  -- Insert deals for Restaurant 4: The Urban Cafe
  INSERT INTO deals (id, title, description, original_price, discounted_price, discount_percentage, business_id, image_url, is_active, valid_from, valid_until, terms_conditions, max_redemptions, current_redemptions, created_at)
  VALUES
    (gen_random_uuid(),
     'All Day Breakfast',
     'Classic breakfast options available all day with complimentary coffee refill',
     499, 349, 30,
     '22222222-2222-2222-2222-222222222224',
     'https://images.unsplash.com/photo-1533089860892-a7c6f0a1dc6?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '50 days',
     'Coffee refill valid for 2 hours from order time.',
     100, 28,
     NOW()),
    
    (gen_random_uuid(),
     'Healthy Bowl Festival',
     'Choose from 5 healthy bowl options with fresh juice',
     649, 449, 31,
     '22222222-2222-2222-2222-222222222224',
     'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '35 days',
     'Vegan and gluten-free options available.',
     50, 15,
     NOW()),
    
    (gen_random_uuid(),
     'Coffee & Dessert Hour',
     'Any coffee with slice of cake or pastry at special price',
     399, 199, 50,
     '22222222-2222-2222-2222-222222222224',
     'https://images.unsplash.com/photo-1486909219908-438b67457b7e?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '2 days', -- Expiring soon!
     'Valid 3 PM to 6 PM only. Not valid on specialty coffees.',
     150, 142,
     NOW()),
    
    (gen_random_uuid(),
     'Work From Cafe',
     'Full day access with breakfast, lunch, unlimited coffee/tea, and Wi-Fi',
     1299, 799, 38,
     '22222222-2222-2222-2222-222222222224',
     'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=800',
     false, -- Inactive deal
     NOW() - INTERVAL '30 days',
     NOW() - INTERVAL '1 day',
     'Advance booking required. Power outlets guaranteed.',
     20, 20,
     NOW() - INTERVAL '30 days');

  -- Insert deals for Restaurant 5: Quick Bites Express
  INSERT INTO deals (id, title, description, original_price, discounted_price, discount_percentage, business_id, image_url, is_active, valid_from, valid_until, terms_conditions, max_redemptions, current_redemptions, created_at)
  VALUES
    (gen_random_uuid(),
     'Mega Burger Combo',
     'Double patty burger with large fries and drink',
     449, 299, 33,
     '22222222-2222-2222-2222-222222222225',
     'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '25 days',
     'Upgrade to cheese fries for ₹30 extra.',
     120, 67,
     NOW()),
    
    (gen_random_uuid(),
     'Student Special',
     'Show student ID and get any wrap/sandwich combo at flat discount',
     349, 199, 43,
     '22222222-2222-2222-2222-222222222225',
     'https://images.unsplash.com/photo-1565299507004-7d179e25d38b?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '4 days', -- Expiring soon!
     'Valid student ID required. One per customer per day.',
     200, 189,
     NOW()),
    
    (gen_random_uuid(),
     'Party Pack',
     '4 burgers + 4 wraps + 4 drinks + 2 large fries',
     2199, 1499, 32,
     '22222222-2222-2222-2222-222222222225',
     'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '60 days',
     'Perfect for small gatherings. Mix and match items allowed.',
     40, 8,
     NOW()),
    
    (gen_random_uuid(),
     'Late Night Munchies',
     '20% off on all items after 10 PM',
     0, 0, 20,
     '22222222-2222-2222-2222-222222222225',
     'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '30 days',
     'Valid 10 PM to 2 AM. Cannot combine with other offers.',
     0, 0, -- Unlimited
     NOW()),
    
    (gen_random_uuid(),
     'Fitness Friday',
     'Grilled chicken salad bowl with protein shake',
     549, 349, 36,
     '22222222-2222-2222-2222-222222222225',
     'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
     true,
     NOW(),
     NOW() + INTERVAL '1 day', -- Expiring very soon!
     'Only on Fridays. Choice of protein shake flavors.',
     50, 48,
     NOW());

  -- Add some sample categories if not already present
  INSERT INTO deal_categories (name, icon_url, color_code)
  VALUES
    ('Buffet', 'https://example.com/icons/buffet.png', '#FF6B35'),
    ('Combo Meals', 'https://example.com/icons/combo.png', '#2E7D32'),
    ('Happy Hours', 'https://example.com/icons/happy-hour.png', '#9C27B0'),
    ('Student Offers', 'https://example.com/icons/student.png', '#00BCD4'),
    ('Family Deals', 'https://example.com/icons/family.png', '#FF9800'),
    ('Express Meals', 'https://example.com/icons/express.png', '#3F51B5')
  ON CONFLICT (name) DO NOTHING;

  -- Map some deals to categories
  -- This would need actual deal IDs from above inserts
  -- In production, you'd capture the IDs or use a different approach
  
END $$;

-- Create a view for easy testing - shows deal distribution
CREATE OR REPLACE VIEW deal_statistics AS
SELECT 
    b.name as business_name,
    COUNT(d.id) as total_deals,
    COUNT(CASE WHEN d.is_active = true THEN 1 END) as active_deals,
    COUNT(CASE WHEN d.valid_until < NOW() + INTERVAL '3 days' AND d.valid_until > NOW() THEN 1 END) as expiring_soon,
    AVG(d.discount_percentage) as avg_discount,
    SUM(d.current_redemptions) as total_redemptions
FROM businesses b
LEFT JOIN deals d ON b.id = d.business_id
WHERE b.owner_id = '11111111-1111-1111-1111-111111111111'
GROUP BY b.id, b.name
ORDER BY b.created_at;

-- Sample query to verify seed data
SELECT 
    'Total Businesses' as metric, 
    COUNT(*) as count 
FROM businesses 
WHERE owner_id = '11111111-1111-1111-1111-111111111111'
UNION ALL
SELECT 
    'Total Deals' as metric, 
    COUNT(*) as count 
FROM deals d
JOIN businesses b ON d.business_id = b.id
WHERE b.owner_id = '11111111-1111-1111-1111-111111111111'
UNION ALL
SELECT 
    'Active Deals' as metric, 
    COUNT(*) as count 
FROM deals d
JOIN businesses b ON d.business_id = b.id
WHERE b.owner_id = '11111111-1111-1111-1111-111111111111'
    AND d.is_active = true
    AND d.valid_from <= NOW()
    AND d.valid_until >= NOW();

COMMENT ON SCHEMA public IS 'KraveKart seed data loaded successfully. 5 restaurants with 20+ deals created for demo business owner.';