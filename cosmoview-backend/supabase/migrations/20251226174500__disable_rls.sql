-- Disable RLS on these tables to bypass auth.uid() checks.
-- This allows the backend to read/write data purely based on the public.users relation
-- without requiring a matching JWT auth session.

ALTER TABLE IF EXISTS public.user_post_likes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_post_comments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_post DISABLE ROW LEVEL SECURITY;
