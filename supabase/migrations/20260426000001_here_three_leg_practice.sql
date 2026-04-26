-- Here three-leg practice model: private daily practice and opt-in anonymous excerpts.

CREATE TABLE IF NOT EXISTS daily_practice_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  leg text NOT NULL CHECK (leg IN ('self', 'together', 'community')),
  prompt_id text NOT NULL,
  prompt_title text NOT NULL,
  private_reflection text,
  practice_date date NOT NULL DEFAULT current_date,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (user_id, leg, practice_date)
);

CREATE INDEX IF NOT EXISTS daily_practice_entries_user_date_idx
  ON daily_practice_entries(user_id, practice_date DESC);

DROP TRIGGER IF EXISTS daily_practice_entries_updated_at ON daily_practice_entries;
CREATE TRIGGER daily_practice_entries_updated_at
  BEFORE UPDATE ON daily_practice_entries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

ALTER TABLE daily_practice_entries ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE, DELETE ON daily_practice_entries TO authenticated;

DROP POLICY IF EXISTS "daily_practice_select_own" ON daily_practice_entries;
CREATE POLICY "daily_practice_select_own"
  ON daily_practice_entries FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "daily_practice_insert_own" ON daily_practice_entries;
CREATE POLICY "daily_practice_insert_own"
  ON daily_practice_entries FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "daily_practice_update_own" ON daily_practice_entries;
CREATE POLICY "daily_practice_update_own"
  ON daily_practice_entries FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "daily_practice_delete_own" ON daily_practice_entries;
CREATE POLICY "daily_practice_delete_own"
  ON daily_practice_entries FOR DELETE
  USING (user_id = auth.uid());

CREATE TABLE IF NOT EXISTS shared_reflection_excerpts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  source_type text NOT NULL CHECK (source_type IN ('application', 'daily_practice', 'community_intention')),
  leg text NOT NULL CHECK (leg IN ('self', 'together', 'community')),
  excerpt text NOT NULL CHECK (char_length(excerpt) BETWEEN 1 AND 500),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (user_id, source_type)
);

CREATE INDEX IF NOT EXISTS shared_reflection_excerpts_active_idx
  ON shared_reflection_excerpts(is_active, created_at DESC);

DROP TRIGGER IF EXISTS shared_reflection_excerpts_updated_at ON shared_reflection_excerpts;
CREATE TRIGGER shared_reflection_excerpts_updated_at
  BEFORE UPDATE ON shared_reflection_excerpts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

ALTER TABLE shared_reflection_excerpts ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE, DELETE ON shared_reflection_excerpts TO authenticated;

DROP POLICY IF EXISTS "shared_reflection_select_own" ON shared_reflection_excerpts;
CREATE POLICY "shared_reflection_select_own"
  ON shared_reflection_excerpts FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "shared_reflection_insert_own" ON shared_reflection_excerpts;
CREATE POLICY "shared_reflection_insert_own"
  ON shared_reflection_excerpts FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "shared_reflection_update_own" ON shared_reflection_excerpts;
CREATE POLICY "shared_reflection_update_own"
  ON shared_reflection_excerpts FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "shared_reflection_delete_own" ON shared_reflection_excerpts;
CREATE POLICY "shared_reflection_delete_own"
  ON shared_reflection_excerpts FOR DELETE
  USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.public_shared_reflection_excerpts()
RETURNS TABLE (
  excerpt text,
  source_type text,
  leg text,
  created_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    shared_reflection_excerpts.excerpt,
    shared_reflection_excerpts.source_type,
    shared_reflection_excerpts.leg,
    shared_reflection_excerpts.created_at
  FROM public.shared_reflection_excerpts
  WHERE shared_reflection_excerpts.is_active = true
  ORDER BY shared_reflection_excerpts.created_at DESC
  LIMIT 50;
$$;

REVOKE ALL ON FUNCTION public.public_shared_reflection_excerpts() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.public_shared_reflection_excerpts() TO anon, authenticated;
