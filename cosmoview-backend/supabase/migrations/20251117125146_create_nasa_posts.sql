-- Create nasa_posts table to store NASA APOD posts
create table if not exists nasa_posts (
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

create index idx_nasa_posts_date on nasa_posts(date);

