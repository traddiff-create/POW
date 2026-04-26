-- Alexandria-backed Learn library.
-- Alexandria remains an offline editorial/source library. Runtime clients read
-- only reviewed rows from Supabase.

CREATE TABLE IF NOT EXISTS learning_resources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_kind text NOT NULL
    CHECK (source_kind IN ('alexandria')),
  source_id text NOT NULL UNIQUE,
  source_uuid uuid NOT NULL UNIQUE,
  title text NOT NULL,
  subtitle text,
  summary text,
  body_markdown text,
  content_status text NOT NULL DEFAULT 'metadata_only'
    CHECK (content_status IN ('metadata_only', 'excerpt', 'full_text')),
  file_type text NOT NULL,
  layers text[] NOT NULL DEFAULT ARRAY[]::text[],
  subjects text[] NOT NULL DEFAULT ARRAY[]::text[],
  tags text[] NOT NULL DEFAULT ARRAY[]::text[],
  reading_minutes int CHECK (reading_minutes IS NULL OR reading_minutes > 0),
  reflection_prompt text,
  published boolean NOT NULL DEFAULT false,
  sort_order int,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (array_length(layers, 1) IS NOT NULL),
  CHECK (content_status <> 'full_text' OR body_markdown IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS learning_resources_layers_gin_idx
  ON learning_resources USING gin(layers);
CREATE INDEX IF NOT EXISTS learning_resources_subjects_gin_idx
  ON learning_resources USING gin(subjects);
CREATE INDEX IF NOT EXISTS learning_resources_tags_gin_idx
  ON learning_resources USING gin(tags);
CREATE INDEX IF NOT EXISTS learning_resources_sort_order_idx
  ON learning_resources(sort_order);
CREATE INDEX IF NOT EXISTS learning_resources_published_idx
  ON learning_resources(published);

DROP TRIGGER IF EXISTS learning_resources_updated_at ON learning_resources;
CREATE TRIGGER learning_resources_updated_at
  BEFORE UPDATE ON learning_resources
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

ALTER TABLE learning_resources ENABLE ROW LEVEL SECURITY;

ALTER TABLE journal_entries
  ADD COLUMN IF NOT EXISTS source_resource_id uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'journal_entries_source_resource_id_fkey'
  ) THEN
    ALTER TABLE journal_entries
      ADD CONSTRAINT journal_entries_source_resource_id_fkey
      FOREIGN KEY (source_resource_id)
      REFERENCES learning_resources(id)
      ON DELETE SET NULL;
  END IF;
END;
$$;

CREATE INDEX IF NOT EXISTS journal_entries_source_resource_id_idx
  ON journal_entries(source_resource_id);

CREATE OR REPLACE VIEW learning_resource_metadata
WITH (security_invoker = true) AS
SELECT
  id,
  source_kind,
  source_id,
  source_uuid,
  title,
  subtitle,
  summary,
  content_status,
  file_type,
  layers,
  subjects,
  tags,
  reading_minutes,
  published,
  sort_order,
  created_at,
  updated_at
FROM learning_resources
WHERE published = true;

REVOKE ALL ON learning_resources FROM anon, authenticated;
REVOKE ALL ON learning_resource_metadata FROM anon, authenticated;

GRANT SELECT (
  id,
  source_kind,
  source_id,
  source_uuid,
  title,
  subtitle,
  summary,
  content_status,
  file_type,
  layers,
  subjects,
  tags,
  reading_minutes,
  published,
  sort_order,
  created_at,
  updated_at
) ON learning_resources TO anon;

GRANT SELECT ON learning_resource_metadata TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON learning_resources TO authenticated;

DROP POLICY IF EXISTS "learning_resources_read_published" ON learning_resources;
DROP POLICY IF EXISTS "learning_resources_admin_insert" ON learning_resources;
DROP POLICY IF EXISTS "learning_resources_admin_update" ON learning_resources;
DROP POLICY IF EXISTS "learning_resources_admin_delete" ON learning_resources;

CREATE POLICY "learning_resources_read_published"
  ON learning_resources FOR SELECT
  USING (published = true OR is_admin());

CREATE POLICY "learning_resources_admin_insert"
  ON learning_resources FOR INSERT
  WITH CHECK (is_admin());

CREATE POLICY "learning_resources_admin_update"
  ON learning_resources FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "learning_resources_admin_delete"
  ON learning_resources FOR DELETE
  USING (is_admin());
