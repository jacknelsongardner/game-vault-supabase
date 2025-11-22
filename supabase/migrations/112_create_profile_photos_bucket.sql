-- Create the profile-photos storage bucket
INSERT INTO storage.buckets (id, name, public)
SELECT 'profile-photos', 'profile-photos', true
WHERE NOT EXISTS (
  SELECT 1 FROM storage.buckets WHERE id = 'profile-photos'
);

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public Access to view profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile photos" ON storage.objects;

-- Grant public access to view photos
CREATE POLICY "Public Access to view profile photos"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-photos');

-- Allow authenticated users to upload their own photos
CREATE POLICY "Users can upload their own profile photos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to update their own photos
CREATE POLICY "Users can update their own profile photos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own photos
CREATE POLICY "Users can delete their own profile photos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
