-- Create the deal-images storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'deal-images',
  'deal-images',
  true,
  5242880, -- 5MB in bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
);

-- Allow authenticated users to upload images to the deal-images bucket
CREATE POLICY "Authenticated users can upload deal images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'deal-images' 
  AND auth.role() = 'authenticated'
);

-- Allow public read access to deal images
CREATE POLICY "Public read access for deal images" ON storage.objects
FOR SELECT USING (bucket_id = 'deal-images');

-- Allow users to update their own uploaded images
CREATE POLICY "Users can update their own deal images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'deal-images' 
  AND auth.uid()::text = (storage.foldername(name))[2]
);

-- Allow users to delete their own uploaded images
CREATE POLICY "Users can delete their own deal images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'deal-images' 
  AND auth.uid()::text = (storage.foldername(name))[2]
);