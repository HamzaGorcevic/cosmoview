CREATE TYPE user_role AS ENUM ('user', 'admin');

create table if not exists users (
    id uuid primary key default gen_random_uuid(),
    username text unique not null,
    email text unique not null,
    password_hash text not null,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    role user_role default 'user'
);