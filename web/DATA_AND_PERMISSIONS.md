# A Piece of Whole — Data Model & Permissions

**Stack:** Supabase Postgres + Storage | **Auth:** Supabase Auth (email magic link)

---

## Roles

| Role | Value | Description |
|------|-------|-------------|
| Participant | `participant` | Enrolled cohort member |
| Facilitator | `facilitator` | Cohort guide with circle visibility |
| Admin | `admin` | Full access to all data and CMS |

Roles are stored in a `user_profiles` table, not in Supabase auth metadata. All RLS policies join through `user_profiles`.

---

## Database Schema

### `user_profiles`
```sql
create table user_profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  full_name   text,
  role        text not null default 'participant' check (role in ('participant', 'facilitator', 'admin')),
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
```

### `cohorts`
```sql
create table cohorts (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  description     text,
  facilitator_id  uuid references user_profiles(id),
  capacity        int not null default 12,
  starts_at       date not null,
  ends_at         date not null,
  is_open         boolean not null default true,   -- accepting applications
  is_active       boolean not null default true,
  created_at      timestamptz not null default now()
);
```

### `applications`
```sql
create table applications (
  id              uuid primary key default gen_random_uuid(),
  email           text not null,
  full_name       text not null,
  motivation      text not null,        -- "why are you applying?"
  safety_screen   text not null,        -- "are you in active crisis?" — must answer no
  age_confirmed   boolean not null,     -- must be true (18+)
  cohort_id       uuid references cohorts(id),
  status          text not null default 'pending'
                    check (status in ('pending', 'approved', 'rejected', 'waitlisted')),
  admin_notes     text,
  reviewed_by     uuid references user_profiles(id),
  reviewed_at     timestamptz,
  created_at      timestamptz not null default now()
);
```

### `enrollments`
Joins a participant to a cohort after payment is confirmed.
```sql
create table enrollments (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references user_profiles(id) on delete cascade,
  cohort_id       uuid not null references cohorts(id) on delete cascade,
  application_id  uuid references applications(id),
  payment_id      uuid references payments(id),
  enrolled_at     timestamptz not null default now(),
  unique (user_id, cohort_id)
);
```

### `payments`
```sql
create table payments (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid references user_profiles(id),
  application_id      uuid references applications(id),
  cohort_id           uuid references cohorts(id),
  stripe_session_id   text unique not null,
  stripe_payment_id   text unique,
  amount_cents        int not null,
  currency            text not null default 'usd',
  status              text not null default 'pending'
                        check (status in ('pending', 'succeeded', 'failed', 'refunded')),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
```

### `practices`
Admin-managed library of audio and text practices.
```sql
create table practices (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  description   text,
  type          text not null check (type in ('audio', 'text', 'both')),
  duration_min  int,                   -- estimated minutes
  category      text,                  -- e.g. 'grounding', 'somatic', 'civic', 'reflection'
  audio_url     text,                  -- Supabase Storage URL (null if text-only)
  content       text,                  -- text content (null if audio-only)
  tags          text[],
  is_published  boolean not null default false,
  sort_order    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
```

### `cohort_curriculum`
Maps practices and prompts to specific weeks in a cohort.
```sql
create table cohort_curriculum (
  id              uuid primary key default gen_random_uuid(),
  cohort_id       uuid not null references cohorts(id) on delete cascade,
  week_number     int not null check (week_number between 1 and 12),
  title           text not null,
  theme           text,
  practice_id     uuid references practices(id),
  circle_prompt   text not null,
  facilitator_note text,
  created_at      timestamptz not null default now(),
  unique (cohort_id, week_number)
);
```

### `check_ins`
Weekly participant check-ins. Always private — never queryable by other users.
```sql
create table check_ins (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references user_profiles(id) on delete cascade,
  cohort_id       uuid not null references cohorts(id),
  week_number     int not null,
  mood_score      int check (mood_score between 1 and 5),
  body_sensation  text,                -- free text: "tight chest", "settled", etc.
  one_word        text,
  note            text,                -- optional private note
  created_at      timestamptz not null default now(),
  unique (user_id, cohort_id, week_number)
);
```

### `journal_entries`
Private journal. Never visible to anyone but the author.
```sql
create table journal_entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references user_profiles(id) on delete cascade,
  cohort_id   uuid references cohorts(id),
  week_number int,
  prompt      text,                    -- the prompt shown when writing, if any
  content     text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
```

### `circle_shares`
Intentional shares from a participant to their cohort circle.
```sql
create table circle_shares (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references user_profiles(id) on delete cascade,
  cohort_id       uuid not null references cohorts(id),
  week_number     int,
  content         text not null,
  is_anonymous    boolean not null default false,
  is_removed      boolean not null default false,  -- soft delete by moderator
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
```

### `circle_comments`
Supportive responses to circle shares. Visible to cohort members.
```sql
create table circle_comments (
  id          uuid primary key default gen_random_uuid(),
  share_id    uuid not null references circle_shares(id) on delete cascade,
  user_id     uuid not null references user_profiles(id) on delete cascade,
  cohort_id   uuid not null references cohorts(id),
  content     text not null,
  is_removed  boolean not null default false,
  created_at  timestamptz not null default now()
);
```

### `reports`
Safety/moderation reports on circle content.
```sql
create table reports (
  id              uuid primary key default gen_random_uuid(),
  reporter_id     uuid not null references user_profiles(id),
  share_id        uuid references circle_shares(id),
  comment_id      uuid references circle_comments(id),
  reason          text not null,
  status          text not null default 'open'
                    check (status in ('open', 'reviewed', 'actioned', 'dismissed')),
  reviewed_by     uuid references user_profiles(id),
  reviewed_at     timestamptz,
  action_taken    text,
  created_at      timestamptz not null default now()
);
```

### `civic_lessons`
Static, admin-managed civic education modules.
```sql
create table civic_lessons (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  description   text,
  content       text not null,          -- full lesson text (markdown)
  category      text,                   -- e.g. 'local government', 'participation', 'community'
  tags          text[],
  is_published  boolean not null default false,
  sort_order    int not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
```

### `notifications`
In-app notification records.
```sql
create table notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references user_profiles(id) on delete cascade,
  type        text not null,            -- 'application_approved', 'comment_received', etc.
  title       text not null,
  body        text,
  link        text,                     -- relative URL to navigate to
  is_read     boolean not null default false,
  created_at  timestamptz not null default now()
);
```

---

## Supabase Storage Buckets

| Bucket | Access | Purpose |
|--------|--------|---------|
| `practices-audio` | Private (signed URLs) | Audio practice files |
| `avatars` | Public | Optional user avatars |

---

## Row-Level Security (RLS) Policies

**All tables have RLS enabled.** Service-role key bypasses RLS for admin operations and webhook handlers.

### `user_profiles`
```sql
-- Users can read their own profile
create policy "users_read_own" on user_profiles
  for select using (auth.uid() = id);

-- Admins can read all profiles
create policy "admins_read_all" on user_profiles
  for select using (
    exists (select 1 from user_profiles where id = auth.uid() and role = 'admin')
  );

-- Users can update their own profile (not role)
create policy "users_update_own" on user_profiles
  for update using (auth.uid() = id)
  with check (role = (select role from user_profiles where id = auth.uid()));
```

### `check_ins`
```sql
-- Only the owner can read their own check-ins (no exceptions)
create policy "owner_only" on check_ins
  for all using (auth.uid() = user_id);
```

### `journal_entries`
```sql
-- Only the owner can read, insert, update, delete journal entries
create policy "owner_only" on journal_entries
  for all using (auth.uid() = user_id);
```

### `circle_shares`
```sql
-- Participants in the same cohort can see non-removed shares
create policy "cohort_members_read" on circle_shares
  for select using (
    is_removed = false and
    exists (
      select 1 from enrollments
      where user_id = auth.uid() and cohort_id = circle_shares.cohort_id
    )
  );

-- Owners can insert their own shares
create policy "owner_insert" on circle_shares
  for insert with check (auth.uid() = user_id);

-- Owners can update their own shares (edit/soft-delete)
create policy "owner_update" on circle_shares
  for update using (auth.uid() = user_id);

-- Facilitators can soft-delete shares in their cohort
create policy "facilitator_moderate" on circle_shares
  for update using (
    exists (
      select 1 from user_profiles u
      join cohorts c on c.facilitator_id = u.id
      where u.id = auth.uid() and u.role = 'facilitator' and c.id = circle_shares.cohort_id
    )
  );
```

### `circle_comments`
```sql
-- Cohort members can read non-removed comments on non-removed shares
create policy "cohort_members_read" on circle_comments
  for select using (
    is_removed = false and
    exists (
      select 1 from enrollments
      where user_id = auth.uid() and cohort_id = circle_comments.cohort_id
    )
  );

-- Cohort members can insert comments
create policy "cohort_members_insert" on circle_comments
  for insert with check (
    auth.uid() = user_id and
    exists (
      select 1 from enrollments
      where user_id = auth.uid() and cohort_id = circle_comments.cohort_id
    )
  );

-- Owners and facilitators can soft-delete
create policy "owner_or_facilitator_delete" on circle_comments
  for update using (
    auth.uid() = user_id or
    exists (
      select 1 from user_profiles u
      join cohorts c on c.facilitator_id = u.id
      where u.id = auth.uid() and u.role = 'facilitator' and c.id = circle_comments.cohort_id
    )
  );
```

### `enrollments`
```sql
-- Users can see their own enrollments
create policy "owner_read" on enrollments
  for select using (auth.uid() = user_id);

-- Facilitators can see enrollments in their cohort
create policy "facilitator_read" on enrollments
  for select using (
    exists (
      select 1 from cohorts c
      join user_profiles u on u.id = c.facilitator_id
      where c.id = enrollments.cohort_id and u.id = auth.uid()
    )
  );
```

### `practices`, `civic_lessons`, `cohort_curriculum`
```sql
-- Any authenticated user can read published content
create policy "authenticated_read_published" on practices
  for select using (auth.role() = 'authenticated' and is_published = true);

-- Admins can read and write all content
create policy "admin_all" on practices
  for all using (
    exists (select 1 from user_profiles where id = auth.uid() and role = 'admin')
  );
```

### `reports`
```sql
-- Any authenticated user can insert a report
create policy "authenticated_insert" on reports
  for insert with check (auth.uid() = reporter_id);

-- Facilitators and admins can read reports
create policy "facilitator_admin_read" on reports
  for select using (
    exists (
      select 1 from user_profiles
      where id = auth.uid() and role in ('facilitator', 'admin')
    )
  );
```

### `notifications`
```sql
-- Users can only read and update their own notifications
create policy "owner_all" on notifications
  for all using (auth.uid() = user_id);
```

---

## Stripe Webhook Flow

1. Stripe sends `checkout.session.completed` to `/api/webhooks/stripe`
2. Webhook handler (service-role) verifies signature
3. Looks up `payment` record by `stripe_session_id`
4. Updates `payment.status = 'succeeded'`
5. Creates `enrollment` record
6. Creates `user_profiles` entry if user doesn't exist yet (email from Stripe session)
7. Sends magic-link email via Supabase Auth so user can sign in
8. Sends confirmation email via Resend

---

## Environment Variables

```
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=

# Resend
RESEND_API_KEY=
RESEND_FROM_EMAIL=hello@apieceofwhole.com

# App
NEXT_PUBLIC_APP_URL=https://apieceofwhole.com
```
