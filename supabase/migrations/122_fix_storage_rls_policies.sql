-- Fix storage RLS policies for profile-photos bucket
-- The path structure is: profiles/{userId}/{imageType}/{timestamp}_filename
-- So foldername should use [2] to get the userId, not [1] which gets 'profiles'

-- Drop existing policies
DROP POLICY "Users can upload their own profile photos" ON storage.objects;
DROP POLICY "Users can update their own profile photos" ON storage.objects;
DROP POLICY "Users can delete their own profile photos" ON storage.objects;

-- Create corrected policies using [2] to get the userId from the path
CREATE POLICY "Users can upload their own profile photos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[2]
);

CREATE POLICY "Users can update their own profile photos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[2]
)
WITH CHECK (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[2]
);

CREATE POLICY "Users can delete their own profile photos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[2]
);
