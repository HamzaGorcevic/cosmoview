-- Create likes table for user likes on NASA posts
create table if not exists likes (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    post_id uuid not null references nasa_posts(id) on delete cascade,
    created_at timestamptz default now(),
    unique(user_id, post_id)
);

create index idx_likes_user_id on likes(user_id);
create index idx_likes_post_id on likes(post_id);
