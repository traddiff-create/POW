-- ============================================================
-- A Piece of Whole — Supabase Schema
-- Apply via: supabase db push  OR  Supabase SQL editor
-- ============================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";

-- ============================================================
-- ENUMS
-- ============================================================
create type user_role as enum ('participant', 'facilitator', 'admin');
create type application_status as enum ('pending', 'approved', 'rejected', 'waitlisted');
create type payment_status as enum ('pending', 'succeeded', 'failed');

-- ============================================================
-- TABLES
-- ============================================================

-- user_profiles (mirrors auth.users)
create table user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role user_role not null default 'participant',
  onboarding_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- cohorts
create table cohorts (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  slug text unique,
  description text,
  start_date date,
  max_participants int default 12,
  is_open boolean not null default false,
  created_at timestamptz not null default now()
);

-- cohort_curriculum (8-week arc per cohort)
create table cohort_curriculum (
  id uuid primary key default uuid_generate_v4(),
  cohort_id uuid references cohorts(id) on delete cascade,
  week_number int not null check (week_number between 1 and 8),
  title text not null,
  theme text,
  circle_prompt text,
  unique(cohort_id, week_number)
);

-- applications
create table applications (
  id uuid primary key default uuid_generate_v4(),
  cohort_id uuid references cohorts(id) on delete set null,
  applicant_name text not null,
  applicant_email text not null,
  motivation text,
  how_heard text,
  status application_status not null default 'pending',
  stripe_checkout_session_id text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references user_profiles(id) on delete set null
);

-- payments
create table payments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references user_profiles(id) on delete set null,
  cohort_id uuid references cohorts(id) on delete set null,
  stripe_session_id text unique,
  stripe_payment_intent_id text,
  amount_cents int,
  currency text default 'usd',
  status payment_status not null default 'pending',
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

-- enrollments (participant ↔ cohort)
create table enrollments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references user_profiles(id) on delete cascade,
  cohort_id uuid not null references cohorts(id) on delete cascade,
  payment_id uuid references payments(id) on delete set null,
  enrolled_at timestamptz not null default now(),
  unique(user_id, cohort_id)
);

-- practices (content library)
create table practices (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  category text,
  week_number int check (week_number between 1 and 8),
  duration_minutes int,
  has_audio boolean not null default false,
  audio_path text,
  body_text text,
  created_at timestamptz not null default now()
);

-- civic_lessons (static civic content)
create table civic_lessons (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  category text,
  estimated_minutes int,
  body_text text,
  reflection_prompt text,
  order_index int default 0,
  created_at timestamptz not null default now()
);

-- check_ins (weekly, private)
create table check_ins (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references user_profiles(id) on delete cascade,
  week_number int not null check (week_number between 1 and 8),
  mood_score int check (mood_score between 1 and 5),
  body_sensation text,
  one_word text,
  free_note text,
  created_at timestamptz not null default now(),
  unique(user_id, week_number)
);

-- journal_entries (private)
create table journal_entries (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references user_profiles(id) on delete cascade,
  week_number int check (week_number between 1 and 8),
  title text,
  body text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- circle_shares (intentional shares visible to cohort)
create table circle_shares (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references user_profiles(id) on delete cascade,
  cohort_id uuid not null references cohorts(id) on delete cascade,
  week_number int check (week_number between 1 and 8),
  content text not null,
  is_anonymous boolean not null default false,
  created_at timestamptz not null default now()
);

-- circle_comments (replies on circle shares)
create table circle_comments (
  id uuid primary key default uuid_generate_v4(),
  share_id uuid not null references circle_shares(id) on delete cascade,
  user_id uuid not null references user_profiles(id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);

-- reports (content moderation)
create table reports (
  id uuid primary key default uuid_generate_v4(),
  reporter_id uuid references user_profiles(id) on delete set null,
  reported_content_id uuid,
  reported_content_type text,
  reason text,
  status text not null default 'open',
  resolved_by uuid references user_profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

-- ============================================================
-- TRIGGERS: auto-create user_profile on signup
-- ============================================================
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into user_profiles (id, display_name)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ============================================================
-- TRIGGERS: updated_at
-- ============================================================
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

create trigger set_user_profiles_updated_at
  before update on user_profiles
  for each row execute function set_updated_at();

create trigger set_journal_entries_updated_at
  before update on journal_entries
  for each row execute function set_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table user_profiles enable row level security;
alter table cohorts enable row level security;
alter table cohort_curriculum enable row level security;
alter table applications enable row level security;
alter table payments enable row level security;
alter table enrollments enable row level security;
alter table practices enable row level security;
alter table civic_lessons enable row level security;
alter table check_ins enable row level security;
alter table journal_entries enable row level security;
alter table circle_shares enable row level security;
alter table circle_comments enable row level security;
alter table reports enable row level security;

-- helper: is_admin
create or replace function is_admin()
returns boolean language sql security definer as $$
  select exists (
    select 1 from user_profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- helper: is_facilitator_or_admin
create or replace function is_facilitator_or_admin()
returns boolean language sql security definer as $$
  select exists (
    select 1 from user_profiles
    where id = auth.uid() and role in ('facilitator', 'admin')
  );
$$;

-- helper: cohort_id for current user
create or replace function my_cohort_id()
returns uuid language sql security definer as $$
  select cohort_id from enrollments
  where user_id = auth.uid()
  order by enrolled_at desc
  limit 1;
$$;

-- user_profiles
create policy "users read own profile" on user_profiles for select using (id = auth.uid());
create policy "users update own profile" on user_profiles for update using (id = auth.uid());
create policy "admins read all profiles" on user_profiles for select using (is_admin());

-- cohorts (public read for open cohorts)
create policy "anyone reads open cohorts" on cohorts for select using (is_open = true);
create policy "authenticated reads all cohorts" on cohorts for select using (auth.uid() is not null);
create policy "admins manage cohorts" on cohorts for all using (is_admin());

-- cohort_curriculum (participants in cohort can read)
create policy "participants read curriculum" on cohort_curriculum for select
  using (auth.uid() is not null);
create policy "admins manage curriculum" on cohort_curriculum for all using (is_admin());

-- applications (applicant submits, admin reviews)
create policy "anyone inserts application" on applications for insert with check (true);
create policy "admins manage applications" on applications for all using (is_admin());

-- payments (user sees own, admin sees all)
create policy "users read own payments" on payments for select using (user_id = auth.uid());
create policy "admins manage payments" on payments for all using (is_admin());

-- enrollments (user sees own, facilitator/admin sees all)
create policy "users read own enrollment" on enrollments for select using (user_id = auth.uid());
create policy "facilitators read enrollments" on enrollments for select using (is_facilitator_or_admin());
create policy "admins manage enrollments" on enrollments for all using (is_admin());

-- practices (all authenticated users can read)
create policy "authenticated reads practices" on practices for select using (auth.uid() is not null);
create policy "admins manage practices" on practices for all using (is_admin());

-- civic_lessons (all authenticated users can read)
create policy "authenticated reads civic" on civic_lessons for select using (auth.uid() is not null);
create policy "admins manage civic" on civic_lessons for all using (is_admin());

-- check_ins (private — owner only)
create policy "users manage own check_ins" on check_ins for all using (user_id = auth.uid());

-- journal_entries (private — owner only)
create policy "users manage own journal" on journal_entries for all using (user_id = auth.uid());

-- circle_shares (cohort members + facilitators can read; user inserts own)
create policy "cohort members read shares" on circle_shares for select
  using (cohort_id = my_cohort_id() or is_facilitator_or_admin());
create policy "users insert own share" on circle_shares for insert
  with check (user_id = auth.uid());

-- circle_comments (cohort members can read and insert)
create policy "cohort members read comments" on circle_comments for select
  using (
    exists (
      select 1 from circle_shares s
      where s.id = share_id and (s.cohort_id = my_cohort_id() or is_facilitator_or_admin())
    )
  );
create policy "users insert own comment" on circle_comments for insert
  with check (user_id = auth.uid());

-- reports (users insert; admins manage)
create policy "users insert reports" on reports for insert with check (reporter_id = auth.uid());
create policy "admins manage reports" on reports for all using (is_admin());

-- ============================================================
-- STORAGE: audio bucket
-- ============================================================
insert into storage.buckets (id, name, public) values ('audio', 'audio', false)
on conflict (id) do nothing;

create policy "authenticated users read audio" on storage.objects for select
  using (bucket_id = 'audio' and auth.uid() is not null);
create policy "admins upload audio" on storage.objects for insert
  using (bucket_id = 'audio' and is_admin());
