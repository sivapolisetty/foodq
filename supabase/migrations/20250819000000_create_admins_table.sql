-- Create admins table for admin user management
CREATE TABLE public.admins (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create indexes for performance
CREATE INDEX idx_admins_email ON public.admins(email);
CREATE INDEX idx_admins_active ON public.admins(is_active);

-- Enable Row Level Security (RLS)
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

-- RLS Policies for admins - only allow service role to access
CREATE POLICY "Service role can manage admins" ON public.admins
    FOR ALL USING (auth.role() = 'service_role');

-- Insert the initial admin user
INSERT INTO public.admins (email, full_name, role) 
VALUES ('sivapolisetty813@gmail.com', 'Siva Polisetty', 'admin');

-- Trigger to update timestamps for admins table
CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON public.admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();