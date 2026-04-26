BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;

SELECT plan(32);

SELECT is_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'purchases'
       AND grantee = 'authenticated'
       AND privilege_type = 'INSERT' $$,
  'authenticated clients cannot insert purchases directly'
);

SELECT is_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'enrollments'
       AND grantee = 'authenticated'
       AND privilege_type = 'INSERT' $$,
  'authenticated clients cannot self-enroll directly'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'journal_entries'
       AND grantee = 'authenticated'
       AND privilege_type IN ('SELECT','INSERT','UPDATE') $$,
  'authenticated clients have intended journal grants'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'notifications'
       AND grantee = 'authenticated'
       AND privilege_type IN ('SELECT','UPDATE') $$,
  'authenticated clients have intended notification grants'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'cohort_curriculum'
       AND grantee = 'authenticated'
       AND privilege_type = 'SELECT' $$,
  'authenticated clients can read curriculum through RLS'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'learning_resources'
       AND grantee = 'authenticated'
       AND privilege_type = 'SELECT' $$,
  'authenticated clients can read published learning resources through RLS'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'learning_resource_metadata'
       AND grantee = 'anon'
       AND privilege_type = 'SELECT' $$,
  'anonymous web users can read the learning metadata view'
);

SELECT is_empty(
  $$ SELECT 1
     FROM information_schema.column_privileges
     WHERE table_schema = 'public'
       AND table_name = 'learning_resources'
       AND column_name = 'body_markdown'
       AND grantee = 'anon'
       AND privilege_type = 'SELECT' $$,
  'anonymous users cannot select learning full-text bodies'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'learning_resources'
       AND policyname = 'learning_resources_read_published' $$,
  'learning resources use a published-read policy'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'learning_resources'
       AND policyname = 'learning_resources_admin_insert'
       AND with_check LIKE '%is_admin%' $$,
  'learning resources writes are admin-gated by RLS'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.columns
     WHERE table_schema = 'public'
       AND table_name = 'journal_entries'
       AND column_name = 'source_resource_id' $$,
  'journal entries can link reflections to learning resources'
);

SELECT is_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'applications'
       AND policyname = 'apps_own' $$,
  'legacy broad applications policy is removed'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'applications'
       AND policyname = 'applications_insert_own_pending' $$,
  'applications require owner-bound pending insert policy'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'applications'
       AND policyname = 'applications_staff_update' $$,
  'application review updates are staff-only'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_trigger
     WHERE tgname = 'prevent_self_role_escalation_trigger' $$,
  'profile role changes are protected by trigger'
);

SELECT is_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'purchases'
       AND cmd = 'INSERT' $$,
  'purchases have no client insert policy'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'circle_shares'
       AND policyname = 'shares_insert_enrolled_member' $$,
  'circle shares require enrolled or circle-member insert policy'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'circle_shares'
       AND policyname = 'shares_insert_enrolled_member'
       AND with_check LIKE '%is_facilitator_prompt%' $$,
  'participant circle shares cannot self-mark as facilitator prompts'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'reports'
       AND policyname = 'reports_insert_own'
       AND with_check LIKE '%status = ''open''%' $$,
  'participant reports must be inserted as open reports'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'account_deletion_requests'
       AND policyname = 'account_deletion_insert_own' $$,
  'account deletion requests are available to authenticated owners'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'daily_practice_entries'
       AND grantee = 'authenticated'
       AND privilege_type IN ('SELECT','INSERT','UPDATE','DELETE')
     GROUP BY grantee
     HAVING count(DISTINCT privilege_type) = 4 $$,
  'authenticated clients can manage own daily practice entries through RLS'
);

SELECT is_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'daily_practice_entries'
       AND grantee = 'anon' $$,
  'anonymous users cannot access private daily practice entries'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'daily_practice_entries'
       AND policyname = 'daily_practice_select_own'
       AND qual LIKE '%user_id = auth.uid%' $$,
  'daily practice entries are owner-readable only'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'daily_practice_entries'
       AND policyname = 'daily_practice_insert_own'
       AND with_check LIKE '%user_id = auth.uid%' $$,
  'daily practice entries require owner-bound inserts'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'daily_practice_entries'
       AND policyname = 'daily_practice_update_own'
       AND qual LIKE '%user_id = auth.uid%'
       AND with_check LIKE '%user_id = auth.uid%' $$,
  'daily practice entries require owner-only edits'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'shared_reflection_excerpts'
       AND grantee = 'authenticated'
       AND privilege_type IN ('SELECT','INSERT','UPDATE','DELETE')
     GROUP BY grantee
     HAVING count(DISTINCT privilege_type) = 4 $$,
  'authenticated clients can manage own shared reflection excerpts through RLS'
);

SELECT is_empty(
  $$ SELECT 1
     FROM information_schema.role_table_grants
     WHERE table_schema = 'public'
       AND table_name = 'shared_reflection_excerpts'
       AND grantee = 'anon' $$,
  'anonymous users cannot access raw shared reflection rows'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'shared_reflection_excerpts'
       AND policyname = 'shared_reflection_update_own'
       AND qual LIKE '%user_id = auth.uid%'
       AND with_check LIKE '%user_id = auth.uid%' $$,
  'shared reflection excerpts require owner-only edits and unsharing'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.columns
     WHERE table_schema = 'public'
       AND table_name = 'shared_reflection_excerpts'
       AND column_name = 'is_active'
       AND column_default = 'true' $$,
  'shared reflection excerpts can be reversibly unshared'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM pg_proc p
     JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'public'
       AND p.proname = 'public_shared_reflection_excerpts'
       AND p.prosecdef = true $$,
  'public shared reflection excerpts are exposed through a security definer RPC'
);

SELECT isnt_empty(
  $$ SELECT 1
     FROM information_schema.routine_privileges
     WHERE routine_schema = 'public'
       AND routine_name = 'public_shared_reflection_excerpts'
       AND grantee IN ('anon','authenticated')
       AND privilege_type = 'EXECUTE'
     GROUP BY routine_name
     HAVING count(DISTINCT grantee) = 2 $$,
  'anonymous and authenticated users can read sanitized public excerpts'
);

SELECT is_empty(
  $$ SELECT 1
     FROM information_schema.parameters
     WHERE specific_schema = 'public'
       AND routine_name = 'public_shared_reflection_excerpts'
       AND parameter_name IN ('id','user_id','email','application_id') $$,
  'public shared reflection excerpts expose no identifying columns'
);

SELECT * FROM finish();

ROLLBACK;
