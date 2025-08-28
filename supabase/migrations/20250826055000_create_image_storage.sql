-- Create storage bucket for deal images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'deal-images',
  'deal-images',
  true,
  5242880, -- 5MB in bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload deal images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'deal-images');

-- Allow authenticated users to update their own images  
CREATE POLICY "Users can update their own deal images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'deal-images');

-- Allow authenticated users to delete their own images
CREATE POLICY "Users can delete their own deal images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'deal-images');

-- Allow public read access to all deal images
CREATE POLICY "Public can view deal images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'deal-images');