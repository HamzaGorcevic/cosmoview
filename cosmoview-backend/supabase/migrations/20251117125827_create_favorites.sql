-- Create favorites table for user favorites
create table if not exists favorites (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    post_id uuid not null references nasa_posts(id) on delete cascade,
    created_at timestamptz default now(),
    unique(user_id, post_id)
);

create index idx_favorites_user_id on favorites(user_id);
create index idx_favorites_post_id on favorites(post_id);

