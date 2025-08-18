-- KraveKart Database Schema
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create custom types
CREATE TYPE user_role AS ENUM ('customer', 'business_owner', 'staff');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'ready', 'completed', 'cancelled');
CREATE TYPE deal_status AS ENUM ('active', 'expired', 'sold_out');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role user_role NOT NULL DEFAULT 'customer',
    avatar_url TEXT,
    location GEOGRAPHY(POINT, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Businesses table
CREATE TABLE public.businesses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES public.profiles(id) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    logo_url TEXT,
    cover_image_url TEXT,
    is_approved BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Staff table (for business staff members)
CREATE TABLE public.staff (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) NOT NULL,
    business_id UUID REFERENCES public.businesses(id) NOT NULL,
    role VARCHAR(50) DEFAULT 'staff',
    permissions JSONB DEFAULT '{"can_manage_items": true, "can_view_orders": true, "can_view_finances": false}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(user_id, business_id)
);

-- Food items/deals table
CREATE TABLE public.deals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    business_id UUID REFERENCES public.businesses(id) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    original_price DECIMAL(10, 2) NOT NULL,
    discounted_price DECIMAL(10, 2) NOT NULL,
    quantity_available INTEGER NOT NULL DEFAULT 1,
    quantity_sold INTEGER DEFAULT 0,
    image_url TEXT,
    allergen_info TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status deal_status DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Orders table
CREATE TABLE public.orders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    customer_id UUID REFERENCES public.profiles(id) NOT NULL,
    business_id UUID REFERENCES public.businesses(id) NOT NULL,
    deal_id UUID REFERENCES public.deals(id) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    total_amount DECIMAL(10, 2) NOT NULL,
    status order_status DEFAULT 'pending',
    pickup_code VARCHAR(10) NOT NULL UNIQUE,
    stripe_payment_intent_id TEXT,
    notes TEXT,
    pickup_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create indexes for performance
CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_profiles_location ON public.profiles USING GIST(location);
CREATE INDEX idx_businesses_location ON public.businesses USING GIST(location);
CREATE INDEX idx_businesses_owner ON public.businesses(owner_id);
CREATE INDEX idx_businesses_active ON public.businesses(is_active, is_approved);
CREATE INDEX idx_staff_business ON public.staff(business_id);
CREATE INDEX idx_staff_user ON public.staff(user_id);
CREATE INDEX idx_deals_business ON public.deals(business_id);
CREATE INDEX idx_deals_status ON public.deals(status);
CREATE INDEX idx_deals_expires ON public.deals(expires_at);
CREATE INDEX idx_orders_customer ON public.orders(customer_id);
CREATE INDEX idx_orders_business ON public.orders(business_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_pickup_code ON public.orders(pickup_code);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Enable insert for authenticated users only" ON public.profiles
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- RLS Policies for businesses
CREATE POLICY "Anyone can view approved businesses" ON public.businesses
    FOR SELECT USING (is_approved = true AND is_active = true);

CREATE POLICY "Owners can manage their businesses" ON public.businesses
    FOR ALL USING (auth.uid() = owner_id);

-- RLS Policies for staff
CREATE POLICY "Business owners can manage staff" ON public.staff
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.businesses 
            WHERE id = business_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Staff can view own record" ON public.staff
    FOR SELECT USING (user_id = auth.uid());

-- RLS Policies for deals
CREATE POLICY "Anyone can view active deals" ON public.deals
    FOR SELECT USING (status = 'active' AND expires_at > NOW());

CREATE POLICY "Business owners and staff can manage deals" ON public.deals
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.businesses 
            WHERE id = business_id AND owner_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.staff 
            WHERE business_id = deals.business_id AND user_id = auth.uid() AND is_active = true
        )
    );

-- RLS Policies for orders
CREATE POLICY "Customers can view own orders" ON public.orders
    FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "Customers can create orders" ON public.orders
    FOR INSERT WITH CHECK (customer_id = auth.uid());

CREATE POLICY "Business owners and staff can view business orders" ON public.orders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.businesses 
            WHERE id = business_id AND owner_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.staff 
            WHERE business_id = orders.business_id AND user_id = auth.uid() AND is_active = true
        )
    );

CREATE POLICY "Business owners and staff can update orders" ON public.orders
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.businesses 
            WHERE id = business_id AND owner_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.staff 
            WHERE business_id = orders.business_id AND user_id = auth.uid() AND is_active = true
        )
    );

-- Functions for nearby deals
CREATE OR REPLACE FUNCTION get_nearby_deals(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    radius_km INTEGER DEFAULT 10
)
RETURNS TABLE (
    deal_id UUID,
    business_name VARCHAR(255),
    deal_title VARCHAR(255),
    deal_description TEXT,
    original_price DECIMAL(10, 2),
    discounted_price DECIMAL(10, 2),
    quantity_available INTEGER,
    image_url TEXT,
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id as deal_id,
        b.name as business_name,
        d.title as deal_title,
        d.description as deal_description,
        d.original_price,
        d.discounted_price,
        d.quantity_available,
        d.image_url,
        ST_Distance(b.location, ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)) / 1000 as distance_km
    FROM public.deals d
    JOIN public.businesses b ON d.business_id = b.id
    WHERE 
        d.status = 'active' 
        AND d.expires_at > NOW()
        AND d.quantity_available > 0
        AND b.is_approved = true
        AND b.is_active = true
        AND ST_DWithin(
            b.location, 
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326),
            radius_km * 1000
        )
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate pickup codes
CREATE OR REPLACE FUNCTION generate_pickup_code()
RETURNS TEXT AS $$
DECLARE
    code TEXT;
    exists BOOLEAN;
BEGIN
    LOOP
        code := UPPER(substring(md5(random()::text), 1, 6));
        SELECT EXISTS(SELECT 1 FROM public.orders WHERE pickup_code = code) INTO exists;
        IF NOT exists THEN
            RETURN code;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate pickup codes
CREATE OR REPLACE FUNCTION set_pickup_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pickup_code IS NULL OR NEW.pickup_code = '' THEN
        NEW.pickup_code := generate_pickup_code();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_pickup_code
    BEFORE INSERT ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION set_pickup_code();

-- Trigger to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON public.businesses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deals_updated_at BEFORE UPDATE ON public.deals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();