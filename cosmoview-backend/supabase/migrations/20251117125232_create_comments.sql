-- Create comments table for comments and replies on NASA posts
create table if not exists comments (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    post_id uuid not null references nasa_posts(id) on delete cascade,
    parent_id uuid references comments(id) on delete cascade,
    content text not null,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

create index idx_comments_user_id on comments(user_id);
create index idx_comments_post_id on comments(post_id);
create index idx_comments_parent_id on comments(parent_id);

