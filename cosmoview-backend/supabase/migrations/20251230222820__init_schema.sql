-- Types
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('user', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 1. Users
CREATE TABLE IF NOT EXISTS public.users (
    id uuid primary key default gen_random_uuid(),
    username text unique not null,
    email text unique not null,
    password_hash text not null,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    role user_role default 'user',
    total_points int default 0
);
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 2. NASA Posts
CREATE TABLE IF NOT EXISTS public.nasa_posts (
    id uuid primary key default gen_random_uuid(),
    date date unique not null,
    title text not null,
    explanation text,
    url text,
    hdurl text,
    media_type text,
    service_version text,
    copyright text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);
CREATE INDEX IF NOT EXISTS idx_nasa_posts_date ON public.nasa_posts(date);
ALTER TABLE public.nasa_posts DISABLE ROW LEVEL SECURITY;

-- 3. NASA Likes
CREATE TABLE IF NOT EXISTS public.likes (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    post_id uuid not null references public.nasa_posts(id) on delete cascade,
    created_at timestamptz default now(),
    unique(user_id, post_id)
);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON public.likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_post_id ON public.likes(post_id);
ALTER TABLE public.likes DISABLE ROW LEVEL SECURITY;

-- 4. NASA Comments
CREATE TABLE IF NOT EXISTS public.comments (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    post_id uuid not null references public.nasa_posts(id) on delete cascade,
    parent_id uuid references public.comments(id) on delete cascade,
    content text not null,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON public.comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON public.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON public.comments(parent_id);
ALTER TABLE public.comments DISABLE ROW LEVEL SECURITY;

-- 5. Favorites
CREATE TABLE IF NOT EXISTS public.favorites (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    post_id uuid not null references public.nasa_posts(id) on delete cascade,
    created_at timestamptz default now(),
    unique(user_id, post_id)
);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_post_id ON public.favorites(post_id);
ALTER TABLE public.favorites DISABLE ROW LEVEL SECURITY;

-- 6. User Posts
CREATE TABLE IF NOT EXISTS public.user_post (
  id uuid primary key default gen_random_uuid(),
  title varchar(250),
  description varchar(250),
  image_url varchar(250),
  user_id uuid references public.users(id),
  created_at timestamptz default now()
);
ALTER TABLE public.user_post DISABLE ROW LEVEL SECURITY;

-- 7. User Post Likes
CREATE TABLE IF NOT EXISTS public.user_post_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.user_post(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  CONSTRAINT user_post_likes_unique_user_post UNIQUE(user_id, post_id)
);
ALTER TABLE public.user_post_likes DISABLE ROW LEVEL SECURITY;

-- 8. User Post Comments
CREATE TABLE IF NOT EXISTS public.user_post_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.user_post(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
ALTER TABLE public.user_post_comments DISABLE ROW LEVEL SECURITY;

-- 9. AI Quiz
CREATE TABLE IF NOT EXISTS public.ai_quiz (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  options jsonb not null,
  correct_answer text not null,
  created_at timestamptz default now(),
  quiz_date date default current_date unique
);
ALTER TABLE public.ai_quiz DISABLE ROW LEVEL SECURITY;

-- 10. User Quiz Attempts
CREATE TABLE IF NOT EXISTS public.user_quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  quiz_id uuid references public.ai_quiz(id) on delete cascade,
  is_correct boolean default false,
  awarded_points int default 0,
  created_at timestamptz default now(),
  unique(user_id, quiz_id)
);
ALTER TABLE public.user_quiz_attempts DISABLE ROW LEVEL SECURITY;
