-- Enable Row Level Security on all tables
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE friend ENABLE ROW LEVEL SECURITY;
ALTER TABLE badge ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges_earned ENABLE ROW LEVEL SECURITY;

-- Profile policies
-- Users can read all profiles (for discovery/search)
CREATE POLICY "Profiles are viewable by everyone"
ON profile FOR SELECT
USING (true);

-- Users can only insert their own profile
CREATE POLICY "Users can insert their own profile"
ON profile FOR INSERT
WITH CHECK (auth.uid() = auth_id);

-- Users can only update their own profile
CREATE POLICY "Users can update their own profile"
ON profile FOR UPDATE
USING (auth.uid() = auth_id)
WITH CHECK (auth.uid() = auth_id);

-- Users can only delete their own profile
CREATE POLICY "Users can delete their own profile"
ON profile FOR DELETE
USING (auth.uid() = auth_id);

-- Friend policies
-- Users can view friendships they're part of
CREATE POLICY "Users can view their own friendships"
ON friend FOR SELECT
USING (auth.uid() = friendOne OR auth.uid() = friendTwo);

-- Users can create friendships involving themselves
CREATE POLICY "Users can create friendships for themselves"
ON friend FOR INSERT
WITH CHECK (auth.uid() = friendOne OR auth.uid() = friendTwo);

-- Users can delete friendships they're part of
CREATE POLICY "Users can delete their own friendships"
ON friend FOR DELETE
USING (auth.uid() = friendOne OR auth.uid() = friendTwo);

-- Badge policies
-- Everyone can read badges (they're public achievements)
CREATE POLICY "Badges are viewable by everyone"
ON badge FOR SELECT
USING (true);

-- Only service role can manage badges (admins only)
CREATE POLICY "Only service role can insert badges"
ON badge FOR INSERT
WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- BadgesEarned policies
-- Users can view all earned badges (for profiles)
CREATE POLICY "Earned badges are viewable by everyone"
ON badges_earned FOR SELECT
USING (true);

-- Users can only manage their own earned badges
CREATE POLICY "Users can view their own earned badges"
ON badges_earned FOR INSERT
WITH CHECK (auth.uid() = profile_id);

-- Storage policies for profile-photos bucket
CREATE POLICY "Users can upload their own profile photos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Profile photos are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-photos');

CREATE POLICY "Users can update their own profile photos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own profile photos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profile-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
