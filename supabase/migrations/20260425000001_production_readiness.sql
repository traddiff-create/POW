-- Production readiness hardening for iOS-first launch.
-- Locks direct client writes around RLS and adds in-app account deletion requests.

-- ---------------------------------------------------------------------
-- Account deletion requests
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS account_deletion_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  reason text,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','processing','completed','cancelled')),
  requested_at timestamptz NOT NULL DEFAULT now(),
  processed_at timestamptz,
  processed_by uuid REFERENCES user_profiles(id),
  UNIQUE (user_id)
);

ALTER TABLE account_deletion_requests ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS account_deletion_requests_user_id_idx
  ON account_deletion_requests(user_id);

-- ---------------------------------------------------------------------
-- Role escalation guard
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_self_role_escalation()
RETURNS trigger AS $$
BEGIN
  IF OLD.role IS DISTINCT FROM NEW.role AND NOT is_admin() THEN
    RAISE EXCEPTION 'Only admins can change user roles';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS prevent_self_role_escalation_trigger ON user_profiles;
CREATE TRIGGER prevent_self_role_escalation_trigger
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION prevent_self_role_escalation();

-- ---------------------------------------------------------------------
-- Privilege reset: RLS handles rows, grants handle operations.
-- ---------------------------------------------------------------------

REVOKE ALL ON
  applications,
  check_ins,
  circle_comments,
  circle_members,
  circle_shares,
  circles,
  civic_lessons,
  cohort_curriculum,
  cohorts,
  enrollments,
  journal_entries,
  notifications,
  practices,
  purchases,
  reports,
  user_profiles,
  account_deletion_requests
FROM anon, authenticated;

GRANT SELECT ON cohorts, practices, civic_lessons TO anon;

GRANT SELECT, UPDATE ON user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE ON applications TO authenticated;
GRANT SELECT, INSERT, UPDATE ON cohorts TO authenticated;
GRANT SELECT ON practices, civic_lessons, cohort_curriculum TO authenticated;
GRANT SELECT ON enrollments, purchases, circles, circle_members TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON check_ins, journal_entries TO authenticated;
GRANT SELECT, INSERT, UPDATE ON circle_shares, circle_comments TO authenticated;
GRANT SELECT, INSERT, UPDATE ON reports, notifications, account_deletion_requests TO authenticated;

-- ---------------------------------------------------------------------
-- Policies
-- ---------------------------------------------------------------------

-- user_profiles
DROP POLICY IF EXISTS "profiles_own_read" ON user_profiles;
DROP POLICY IF EXISTS "profiles_own_update" ON user_profiles;
DROP POLICY IF EXISTS "profiles_admin_write" ON user_profiles;

CREATE POLICY "profiles_read_own_or_admin"
  ON user_profiles FOR SELECT
  USING (id = auth.uid() OR is_admin());

CREATE POLICY "profiles_update_own"
  ON user_profiles FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "profiles_update_admin"
  ON user_profiles FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- Server-stamped onboarding/legal acceptance updates. Clients should not
-- supply legal timestamps from device time.
CREATE OR REPLACE FUNCTION profile_confirm_adult()
RETURNS void AS $$
BEGIN
  UPDATE user_profiles
  SET
    adult_confirmed_at = COALESCE(adult_confirmed_at, now()),
    onboarding_step = 'agreements'
  WHERE id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER SET search_path = public;

CREATE OR REPLACE FUNCTION profile_accept_agreements()
RETURNS void AS $$
BEGIN
  UPDATE user_profiles
  SET
    agreements_accepted_at = COALESCE(agreements_accepted_at, now()),
    onboarding_step = 'profile_setup'
  WHERE id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER SET search_path = public;

CREATE OR REPLACE FUNCTION profile_complete_onboarding(display_name text)
RETURNS void AS $$
DECLARE
  normalized_display_name text := NULLIF(trim(display_name), '');
BEGIN
  IF normalized_display_name IS NULL THEN
    RAISE EXCEPTION 'Display name is required';
  END IF;

  UPDATE user_profiles
  SET
    display_name = normalized_display_name,
    onboarding_step = 'complete',
    onboarding_completed_at = COALESCE(onboarding_completed_at, now())
  WHERE id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER SET search_path = public;

GRANT EXECUTE ON FUNCTION profile_confirm_adult() TO authenticated;
GRANT EXECUTE ON FUNCTION profile_accept_agreements() TO authenticated;
GRANT EXECUTE ON FUNCTION profile_complete_onboarding(text) TO authenticated;

-- applications
DROP POLICY IF EXISTS "apps_own" ON applications;
DROP POLICY IF EXISTS "applications_read_own_or_staff" ON applications;
DROP POLICY IF EXISTS "applications_insert_own_pending" ON applications;
DROP POLICY IF EXISTS "applications_staff_update" ON applications;

CREATE POLICY "applications_read_own_or_staff"
  ON applications FOR SELECT
  USING (user_id = auth.uid() OR is_facilitator_or_admin());

CREATE POLICY "applications_insert_own_pending"
  ON applications FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    AND status = 'pending'
    AND reviewed_by IS NULL
    AND reviewed_at IS NULL
  );

CREATE POLICY "applications_staff_update"
  ON applications FOR UPDATE
  USING (is_facilitator_or_admin())
  WITH CHECK (is_facilitator_or_admin());

-- cohorts
DROP POLICY IF EXISTS "cohorts_read_open" ON cohorts;
DROP POLICY IF EXISTS "cohorts_admin_write" ON cohorts;

CREATE POLICY "cohorts_read_open_or_member"
  ON cohorts FOR SELECT
  USING (is_open = true OR is_admin() OR is_enrolled(id));

CREATE POLICY "cohorts_admin_insert"
  ON cohorts FOR INSERT
  WITH CHECK (is_admin());

CREATE POLICY "cohorts_admin_update"
  ON cohorts FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- practices
DROP POLICY IF EXISTS "practices_read" ON practices;
DROP POLICY IF EXISTS "practices_admin_write" ON practices;

CREATE POLICY "practices_read_published"
  ON practices FOR SELECT
  USING (published = true OR is_admin());

CREATE POLICY "practices_admin_insert"
  ON practices FOR INSERT
  WITH CHECK (is_admin());

CREATE POLICY "practices_admin_update"
  ON practices FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- civic lessons
DROP POLICY IF EXISTS "civic_read" ON civic_lessons;
DROP POLICY IF EXISTS "civic_admin_write" ON civic_lessons;

CREATE POLICY "civic_read_published"
  ON civic_lessons FOR SELECT
  USING (published = true OR is_admin());

CREATE POLICY "civic_admin_insert"
  ON civic_lessons FOR INSERT
  WITH CHECK (is_admin());

CREATE POLICY "civic_admin_update"
  ON civic_lessons FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- enrollments: service role creates/updates; clients read only through RLS.
DROP POLICY IF EXISTS "enrollments_own" ON enrollments;
DROP POLICY IF EXISTS "enrollments_insert" ON enrollments;

CREATE POLICY "enrollments_read_own_or_staff"
  ON enrollments FOR SELECT
  USING (user_id = auth.uid() OR is_facilitator_or_admin());

-- purchases: service role records transactions; clients read their own.
DROP POLICY IF EXISTS "purchases_own" ON purchases;
DROP POLICY IF EXISTS "purchases_insert" ON purchases;

CREATE POLICY "purchases_read_own_or_admin"
  ON purchases FOR SELECT
  USING (user_id = auth.uid() OR is_admin());

-- journal entries
DROP POLICY IF EXISTS "journal_own" ON journal_entries;

CREATE POLICY "journal_select_own"
  ON journal_entries FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "journal_insert_own"
  ON journal_entries FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "journal_update_own"
  ON journal_entries FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "journal_delete_own"
  ON journal_entries FOR DELETE
  USING (user_id = auth.uid());

-- cohort curriculum
DROP POLICY IF EXISTS "curriculum_read" ON cohort_curriculum;
DROP POLICY IF EXISTS "curriculum_admin_write" ON cohort_curriculum;

CREATE POLICY "curriculum_read_enrolled_or_staff"
  ON cohort_curriculum FOR SELECT
  USING (is_enrolled(cohort_id) OR is_facilitator_or_admin());

CREATE POLICY "curriculum_admin_insert"
  ON cohort_curriculum FOR INSERT
  WITH CHECK (is_admin());

CREATE POLICY "curriculum_admin_update"
  ON cohort_curriculum FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- circles and membership
DROP POLICY IF EXISTS "circles_read" ON circles;
DROP POLICY IF EXISTS "circles_admin_write" ON circles;
DROP POLICY IF EXISTS "circle_members_read" ON circle_members;

CREATE POLICY "circles_read_member_or_staff"
  ON circles FOR SELECT
  USING (is_circle_member(id) OR is_facilitator_or_admin());

CREATE POLICY "circle_members_read_self_or_staff"
  ON circle_members FOR SELECT
  USING (user_id = auth.uid() OR is_facilitator_or_admin());

-- circle shares
DROP POLICY IF EXISTS "shares_read" ON circle_shares;
DROP POLICY IF EXISTS "shares_insert" ON circle_shares;
DROP POLICY IF EXISTS "shares_admin_hide" ON circle_shares;

CREATE POLICY "shares_read_member_or_staff"
  ON circle_shares FOR SELECT
  USING (
    hidden_at IS NULL
    AND (
      is_enrolled(cohort_id)
      OR is_circle_member(circle_id)
      OR is_facilitator_or_admin()
    )
  );

CREATE POLICY "shares_insert_enrolled_member"
  ON circle_shares FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    AND hidden_at IS NULL
    AND COALESCE(is_facilitator_prompt, false) = false
    AND (
      circle_id IS NULL
      OR EXISTS (
        SELECT 1 FROM circles c
        WHERE c.id = circle_id
          AND c.cohort_id = cohort_id
      )
    )
    AND (
      is_enrolled(cohort_id)
      OR is_circle_member(circle_id)
    )
  );

CREATE POLICY "shares_staff_update"
  ON circle_shares FOR UPDATE
  USING (is_facilitator_or_admin())
  WITH CHECK (is_facilitator_or_admin());

-- circle comments
DROP POLICY IF EXISTS "comments_read" ON circle_comments;
DROP POLICY IF EXISTS "comments_insert" ON circle_comments;
DROP POLICY IF EXISTS "comments_admin_hide" ON circle_comments;

CREATE POLICY "comments_read_member_or_staff"
  ON circle_comments FOR SELECT
  USING (
    hidden_at IS NULL
    AND EXISTS (
      SELECT 1 FROM circle_shares s
      WHERE s.id = share_id
        AND s.hidden_at IS NULL
        AND (
          is_enrolled(s.cohort_id)
          OR is_circle_member(s.circle_id)
          OR is_facilitator_or_admin()
        )
    )
  );

CREATE POLICY "comments_insert_member"
  ON circle_comments FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    AND hidden_at IS NULL
    AND EXISTS (
      SELECT 1 FROM circle_shares s
      WHERE s.id = share_id
        AND s.hidden_at IS NULL
        AND (
          is_enrolled(s.cohort_id)
          OR is_circle_member(s.circle_id)
        )
    )
  );

CREATE POLICY "comments_staff_update"
  ON circle_comments FOR UPDATE
  USING (is_facilitator_or_admin())
  WITH CHECK (is_facilitator_or_admin());

-- reports
DROP POLICY IF EXISTS "reports_insert" ON reports;
DROP POLICY IF EXISTS "reports_admin" ON reports;

CREATE POLICY "reports_insert_own"
  ON reports FOR INSERT
  WITH CHECK (
    reporter_id = auth.uid()
    AND status = 'open'
    AND resolved_by IS NULL
    AND resolved_at IS NULL
  );

CREATE POLICY "reports_staff_read"
  ON reports FOR SELECT
  USING (is_facilitator_or_admin());

CREATE POLICY "reports_staff_update"
  ON reports FOR UPDATE
  USING (is_facilitator_or_admin())
  WITH CHECK (is_facilitator_or_admin());

-- notifications
DROP POLICY IF EXISTS "notifs_own" ON notifications;
DROP POLICY IF EXISTS "notifs_admin_insert" ON notifications;

CREATE POLICY "notifications_read_own_or_admin"
  ON notifications FOR SELECT
  USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "notifications_update_own_or_admin"
  ON notifications FOR UPDATE
  USING (user_id = auth.uid() OR is_admin())
  WITH CHECK (user_id = auth.uid() OR is_admin());

CREATE POLICY "notifications_admin_insert"
  ON notifications FOR INSERT
  WITH CHECK (is_admin());

-- account deletion requests
DROP POLICY IF EXISTS "account_deletion_read_own_or_admin" ON account_deletion_requests;
DROP POLICY IF EXISTS "account_deletion_insert_own" ON account_deletion_requests;
DROP POLICY IF EXISTS "account_deletion_update_admin" ON account_deletion_requests;

CREATE POLICY "account_deletion_read_own_or_admin"
  ON account_deletion_requests FOR SELECT
  USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "account_deletion_insert_own"
  ON account_deletion_requests FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    AND status = 'pending'
    AND processed_at IS NULL
    AND processed_by IS NULL
  );

CREATE POLICY "account_deletion_update_admin"
  ON account_deletion_requests FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());
