-- iOS MVP Schema — additive migration
-- Extends existing tables and creates new ones for the native iOS app

-- =====================================================================
-- EXTEND EXISTING TABLES
-- =====================================================================

-- user_profiles: add role, adult confirmation, onboarding state, My Piece fields
ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS role text NOT NULL DEFAULT 'participant'
    CHECK (role IN ('participant','facilitator','admin')),
  ADD COLUMN IF NOT EXISTS adult_confirmed_at timestamptz,
  ADD COLUMN IF NOT EXISTS agreements_accepted_at timestamptz,
  ADD COLUMN IF NOT EXISTS onboarding_step text DEFAULT 'age_confirm',
  ADD COLUMN IF NOT EXISTS onboarding_completed_at timestamptz,
  ADD COLUMN IF NOT EXISTS values text,
  ADD COLUMN IF NOT EXISTS gifts_skills text,
  ADD COLUMN IF NOT EXISTS current_capacity text,
  ADD COLUMN IF NOT EXISTS boundaries text,
  ADD COLUMN IF NOT EXISTS current_contribution text,
  ADD COLUMN IF NOT EXISTS small_action text;

-- applications: add missing intake fields
ALTER TABLE applications
  ADD COLUMN IF NOT EXISTS hoped_change text,
  ADD COLUMN IF NOT EXISTS weekly_capacity_hours int,
  ADD COLUMN IF NOT EXISTS group_comfort_level int CHECK (group_comfort_level BETWEEN 1 AND 5),
  ADD COLUMN IF NOT EXISTS agreements_accepted boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS safety_acknowledged boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS reviewed_by uuid REFERENCES user_profiles(id),
  ADD COLUMN IF NOT EXISTS reviewed_at timestamptz;

-- cohorts: add StoreKit product ID and end date
ALTER TABLE cohorts
  ADD COLUMN IF NOT EXISTS storekit_product_id text,
  ADD COLUMN IF NOT EXISTS end_date date,
  ADD COLUMN IF NOT EXISTS is_open boolean NOT NULL DEFAULT false;

-- check_ins: add detailed wellness fields
ALTER TABLE check_ins
  ADD COLUMN IF NOT EXISTS body_sensation text,
  ADD COLUMN IF NOT EXISTS mood int CHECK (mood BETWEEN 1 AND 5),
  ADD COLUMN IF NOT EXISTS stress_level int CHECK (stress_level BETWEEN 1 AND 5),
  ADD COLUMN IF NOT EXISTS capacity_level int CHECK (capacity_level BETWEEN 1 AND 5),
  ADD COLUMN IF NOT EXISTS private_note text;

-- journal_entries: add sharing and prompt fields
ALTER TABLE journal_entries
  ADD COLUMN IF NOT EXISTS week_number int,
  ADD COLUMN IF NOT EXISTS shared_post_id uuid;

-- =====================================================================
-- NEW TABLES
-- =====================================================================

-- circles
CREATE TABLE IF NOT EXISTS circles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cohort_id uuid NOT NULL REFERENCES cohorts(id) ON DELETE CASCADE,
  name text NOT NULL,
  facilitator_id uuid REFERENCES user_profiles(id),
  created_at timestamptz DEFAULT now()
);

-- circle_members (who belongs to each circle)
CREATE TABLE IF NOT EXISTS circle_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  circle_id uuid NOT NULL REFERENCES circles(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  joined_at timestamptz DEFAULT now(),
  UNIQUE(circle_id, user_id)
);

-- practices (audio-backed somatic exercises)
CREATE TABLE IF NOT EXISTS practices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body_text text,
  transcript text,
  audio_path text,
  has_audio boolean NOT NULL DEFAULT false,
  week_number int,
  duration_minutes int,
  category text CHECK (category IN ('self_regulation','co_regulation','community','agency','civic_engagement')),
  emotional_intensity int CHECK (emotional_intensity BETWEEN 1 AND 5),
  published boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- civic_lessons (static civic education modules)
CREATE TABLE IF NOT EXISTS civic_lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body_text text,
  category text,
  reflection_prompt text,
  suggested_action text,
  integration_question text,
  estimated_minutes int,
  order_index int,
  published boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- circle_shares (participant posts to their circle — includes shared journal entries)
CREATE TABLE IF NOT EXISTS circle_shares (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cohort_id uuid NOT NULL REFERENCES cohorts(id) ON DELETE CASCADE,
  circle_id uuid REFERENCES circles(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES user_profiles(id),
  week_number int,
  content text NOT NULL,
  is_anonymous boolean DEFAULT false,
  is_facilitator_prompt boolean DEFAULT false,
  hidden_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- add FK from journal_entries to circle_shares now that it exists
ALTER TABLE journal_entries
  ADD CONSTRAINT fk_journal_shared_post
    FOREIGN KEY (shared_post_id) REFERENCES circle_shares(id);

-- circle_comments
CREATE TABLE IF NOT EXISTS circle_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  share_id uuid NOT NULL REFERENCES circle_shares(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES user_profiles(id),
  content text NOT NULL,
  hidden_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- reports (content moderation)
CREATE TABLE IF NOT EXISTS reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid NOT NULL REFERENCES user_profiles(id),
  reported_user_id uuid REFERENCES user_profiles(id),
  reported_content_type text CHECK (reported_content_type IN ('post','comment','user')),
  reported_content_id uuid,
  reason text NOT NULL,
  details text,
  status text DEFAULT 'open' CHECK (status IN ('open','reviewing','resolved','dismissed')),
  resolved_by uuid REFERENCES user_profiles(id),
  resolved_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- purchases (StoreKit 2 transactions)
CREATE TABLE IF NOT EXISTS purchases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES user_profiles(id),
  cohort_id uuid REFERENCES cohorts(id),
  storekit_product_id text NOT NULL,
  original_transaction_id text NOT NULL UNIQUE,
  transaction_id text NOT NULL,
  app_account_token text,
  purchase_date timestamptz NOT NULL,
  expiration_date timestamptz,
  status text DEFAULT 'pending' CHECK (status IN ('pending','active','refunded','revoked','expired')),
  created_at timestamptz DEFAULT now()
);

-- enrollments (active cohort memberships — created after purchase verified)
CREATE TABLE IF NOT EXISTS enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  cohort_id uuid NOT NULL REFERENCES cohorts(id) ON DELETE CASCADE,
  payment_id text,
  status text DEFAULT 'active' CHECK (status IN ('pending_payment','active','removed','completed')),
  enrolled_at timestamptz DEFAULT now(),
  UNIQUE(user_id, cohort_id)
);

-- notifications (in-app notification feed)
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  type text NOT NULL,
  title text NOT NULL,
  body text,
  read_at timestamptz,
  action_target text,
  created_at timestamptz DEFAULT now()
);

-- cohort_curriculum (weekly content schedule)
CREATE TABLE IF NOT EXISTS cohort_curriculum (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cohort_id uuid NOT NULL REFERENCES cohorts(id) ON DELETE CASCADE,
  week_number int NOT NULL,
  title text NOT NULL DEFAULT '',
  theme text,
  layer text CHECK (layer IN ('self_regulation','co_regulation','community','agency','civic_engagement')),
  practice_id uuid REFERENCES practices(id),
  circle_prompt text,
  journal_prompt text,
  integration_prompt text,
  UNIQUE(cohort_id, week_number)
);

-- =====================================================================
-- ROW LEVEL SECURITY
-- =====================================================================

ALTER TABLE circles ENABLE ROW LEVEL SECURITY;
ALTER TABLE circle_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE practices ENABLE ROW LEVEL SECURITY;
ALTER TABLE civic_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE circle_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE circle_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohort_curriculum ENABLE ROW LEVEL SECURITY;

-- Helper functions

CREATE OR REPLACE FUNCTION is_admin() RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_facilitator_or_admin() RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('facilitator','admin')
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_circle_member(cid uuid) RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM circle_members WHERE circle_id = cid AND user_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_enrolled(cid uuid) RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM enrollments WHERE cohort_id = cid AND user_id = auth.uid() AND status = 'active'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- user_profiles policies
DROP POLICY IF EXISTS "profiles_own_read" ON user_profiles;
CREATE POLICY "profiles_own_read" ON user_profiles FOR SELECT USING (id = auth.uid() OR is_admin());

DROP POLICY IF EXISTS "profiles_own_update" ON user_profiles;
CREATE POLICY "profiles_own_update" ON user_profiles FOR UPDATE USING (id = auth.uid());

DROP POLICY IF EXISTS "profiles_admin_write" ON user_profiles;
CREATE POLICY "profiles_admin_write" ON user_profiles FOR UPDATE USING (is_admin());

-- applications policies
DROP POLICY IF EXISTS "apps_own" ON applications;
CREATE POLICY "apps_own" ON applications FOR ALL USING (user_id = auth.uid() OR is_facilitator_or_admin());

-- cohorts policies
DROP POLICY IF EXISTS "cohorts_read_open" ON cohorts;
CREATE POLICY "cohorts_read_open" ON cohorts FOR SELECT USING (
  is_open = true OR is_admin() OR is_enrolled(id)
);
DROP POLICY IF EXISTS "cohorts_admin_write" ON cohorts;
CREATE POLICY "cohorts_admin_write" ON cohorts FOR ALL USING (is_admin());

-- practices policies
DROP POLICY IF EXISTS "practices_read" ON practices;
CREATE POLICY "practices_read" ON practices FOR SELECT USING (published = true OR is_admin());
DROP POLICY IF EXISTS "practices_admin_write" ON practices;
CREATE POLICY "practices_admin_write" ON practices FOR ALL USING (is_admin());

-- civic_lessons policies
DROP POLICY IF EXISTS "civic_read" ON civic_lessons;
CREATE POLICY "civic_read" ON civic_lessons FOR SELECT USING (published = true OR is_admin());
DROP POLICY IF EXISTS "civic_admin_write" ON civic_lessons;
CREATE POLICY "civic_admin_write" ON civic_lessons FOR ALL USING (is_admin());

-- circle_shares policies
DROP POLICY IF EXISTS "shares_read" ON circle_shares;
CREATE POLICY "shares_read" ON circle_shares FOR SELECT USING (
  hidden_at IS NULL AND (
    is_circle_member(circle_id) OR is_facilitator_or_admin() OR is_enrolled(cohort_id)
  )
);
DROP POLICY IF EXISTS "shares_insert" ON circle_shares;
CREATE POLICY "shares_insert" ON circle_shares FOR INSERT WITH CHECK (user_id = auth.uid());
DROP POLICY IF EXISTS "shares_admin_hide" ON circle_shares;
CREATE POLICY "shares_admin_hide" ON circle_shares FOR UPDATE USING (is_facilitator_or_admin());

-- circle_comments policies
DROP POLICY IF EXISTS "comments_read" ON circle_comments;
CREATE POLICY "comments_read" ON circle_comments FOR SELECT USING (
  hidden_at IS NULL AND EXISTS (
    SELECT 1 FROM circle_shares s
    WHERE s.id = share_id AND (
      is_circle_member(s.circle_id) OR is_facilitator_or_admin() OR is_enrolled(s.cohort_id)
    )
  )
);
DROP POLICY IF EXISTS "comments_insert" ON circle_comments;
CREATE POLICY "comments_insert" ON circle_comments FOR INSERT WITH CHECK (user_id = auth.uid());
DROP POLICY IF EXISTS "comments_admin_hide" ON circle_comments;
CREATE POLICY "comments_admin_hide" ON circle_comments FOR UPDATE USING (is_facilitator_or_admin());

-- reports policies
DROP POLICY IF EXISTS "reports_insert" ON reports;
CREATE POLICY "reports_insert" ON reports FOR INSERT WITH CHECK (reporter_id = auth.uid());
DROP POLICY IF EXISTS "reports_admin" ON reports;
CREATE POLICY "reports_admin" ON reports FOR ALL USING (is_facilitator_or_admin());

-- purchases policies
DROP POLICY IF EXISTS "purchases_own" ON purchases;
CREATE POLICY "purchases_own" ON purchases FOR SELECT USING (user_id = auth.uid() OR is_admin());
DROP POLICY IF EXISTS "purchases_insert" ON purchases;
CREATE POLICY "purchases_insert" ON purchases FOR INSERT WITH CHECK (user_id = auth.uid());

-- enrollments policies
DROP POLICY IF EXISTS "enrollments_own" ON enrollments;
CREATE POLICY "enrollments_own" ON enrollments FOR SELECT USING (user_id = auth.uid() OR is_facilitator_or_admin());
DROP POLICY IF EXISTS "enrollments_insert" ON enrollments;
CREATE POLICY "enrollments_insert" ON enrollments FOR INSERT WITH CHECK (user_id = auth.uid());

-- notifications policies
DROP POLICY IF EXISTS "notifs_own" ON notifications;
CREATE POLICY "notifs_own" ON notifications FOR ALL USING (user_id = auth.uid());
DROP POLICY IF EXISTS "notifs_admin_insert" ON notifications;
CREATE POLICY "notifs_admin_insert" ON notifications FOR INSERT WITH CHECK (is_admin() OR user_id = auth.uid());

-- cohort_curriculum policies
DROP POLICY IF EXISTS "curriculum_read" ON cohort_curriculum;
CREATE POLICY "curriculum_read" ON cohort_curriculum FOR SELECT USING (
  is_enrolled(cohort_id) OR is_facilitator_or_admin()
);
DROP POLICY IF EXISTS "curriculum_admin_write" ON cohort_curriculum;
CREATE POLICY "curriculum_admin_write" ON cohort_curriculum FOR ALL USING (is_admin());

-- circles policies
DROP POLICY IF EXISTS "circles_read" ON circles;
CREATE POLICY "circles_read" ON circles FOR SELECT USING (
  is_circle_member(id) OR is_facilitator_or_admin()
);
DROP POLICY IF EXISTS "circles_admin_write" ON circles;
CREATE POLICY "circles_admin_write" ON circles FOR ALL USING (is_admin());

-- circle_members policies
DROP POLICY IF EXISTS "circle_members_read" ON circle_members;
CREATE POLICY "circle_members_read" ON circle_members FOR SELECT USING (
  user_id = auth.uid() OR is_facilitator_or_admin()
);
