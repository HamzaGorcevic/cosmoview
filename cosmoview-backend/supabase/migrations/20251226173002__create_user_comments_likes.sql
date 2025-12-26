-- Run this SQL in your Supabase Dashboard -> SQL Editor to create the necessary tables

-- 1. Create User Post Likes Table
CREATE TABLE IF NOT EXISTS public.user_post_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.user_post(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  CONSTRAINT user_post_likes_unique_user_post UNIQUE(user_id, post_id)
);

-- 2. Create User Post Comments Table
CREATE TABLE IF NOT EXISTS public.user_post_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.user_post(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Enable RLS (Row Level Security)
ALTER TABLE public.user_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_post_comments ENABLE ROW LEVEL SECURITY;

-- 4. Create Policies (Adjust as needed for your security requirements)
-- Allow anyone to read likes
CREATE POLICY "Public read access likes" ON public.user_post_likes
  FOR SELECT USING (true);

-- Allow authenticated users to insert likes
CREATE POLICY "Authenticated insert likes" ON public.user_post_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own likes
CREATE POLICY "User delete own likes" ON public.user_post_likes
  FOR DELETE USING (auth.uid() = user_id);

-- Allow anyone to read comments
CREATE POLICY "Public read access comments" ON public.user_post_comments
  FOR SELECT USING (true);

-- Allow authenticated users to insert comments
CREATE POLICY "Authenticated insert comments" ON public.user_post_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own comments
CREATE POLICY "User delete own comments" ON public.user_post_comments
  FOR DELETE USING (auth.uid() = user_id);
-- Run this SQL in your Supabase Dashboard -> SQL Editor to create the necessary tables

-- 1. Create User Post Likes Table
CREATE TABLE IF NOT EXISTS public.user_post_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.user_post(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  CONSTRAINT user_post_likes_unique_user_post UNIQUE(user_id, post_id)
);

-- 2. Create User Post Comments Table
CREATE TABLE IF NOT EXISTS public.user_post_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.user_post(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Enable RLS (Row Level Security)
ALTER TABLE public.user_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_post_comments ENABLE ROW LEVEL SECURITY;

-- 4. Create Policies (Adjust as needed for your security requirements)
-- Allow anyone to read likes
CREATE POLICY "Public read access likes" ON public.user_post_likes
  FOR SELECT USING (true);

-- Allow authenticated users to insert likes
CREATE POLICY "Authenticated insert likes" ON public.user_post_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own likes
CREATE POLICY "User delete own likes" ON public.user_post_likes
  FOR DELETE USING (auth.uid() = user_id);

-- Allow anyone to read comments
CREATE POLICY "Public read access comments" ON public.user_post_comments
  FOR SELECT USING (true);

-- Allow authenticated users to insert comments
CREATE POLICY "Authenticated insert comments" ON public.user_post_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own comments
CREATE POLICY "User delete own comments" ON public.user_post_comments
  FOR DELETE USING (auth.uid() = user_id);
