create table public.user_post (
  id uuid primary key default gen_random_uuid(),
  title varchar(250),
  description varchar(250),
  image_url varchar(250),
  user_id uuid references public.users(id),
  created_at timestamptz default now()
);

-- Enable Row Level Security
alter table public.user_post enable row level security;

-- Create policies
create policy "Allow public read access"
  on public.user_post for select
  using (true);

create policy "Allow authenticated insert"
  on public.user_post for insert
  with check (auth.uid() = user_id);

create policy "Allow users to update their own posts"
  on public.user_post for update
  using (auth.uid() = user_id);

create policy "Allow users to delete their own posts"
  on public.user_post for delete
  using (auth.uid() = user_id);
