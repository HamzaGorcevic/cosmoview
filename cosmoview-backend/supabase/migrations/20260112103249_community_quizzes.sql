create table public.community_quizzes (
  id uuid not null default gen_random_uuid (),
  created_at timestamp with time zone not null default now(),
  creator_id uuid not null references public.users (id) on delete cascade,
  question text not null,
  options text[] not null,
  correct_answer text not null,
  constraint community_quizzes_pkey primary key (id)
);

create table public.community_quiz_attempts (
  id uuid not null default gen_random_uuid (),
  created_at timestamp with time zone not null default now(),
  user_id uuid not null references public.users (id) on delete cascade,
  quiz_id uuid not null references public.community_quizzes (id) on delete cascade,
  is_correct boolean not null,
  constraint community_quiz_attempts_pkey primary key (id)
);

-- RLS Policies (Optional but recommended)
