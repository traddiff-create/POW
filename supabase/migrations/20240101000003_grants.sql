-- Grant table permissions to authenticated role
-- RLS policies alone aren't enough — the role also needs SELECT/INSERT/etc privileges.

-- Read-only content: practices and civic lessons
GRANT SELECT ON practices TO authenticated, anon;
GRANT SELECT ON civic_lessons TO authenticated, anon;

-- User-owned data: full CRUD scoped by RLS
GRANT SELECT, INSERT, UPDATE, DELETE ON user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON check_ins TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON circles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON circle_members TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON circle_shares TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON circle_comments TO authenticated;
GRANT SELECT, INSERT ON purchases TO authenticated;
GRANT SELECT, INSERT ON reports TO authenticated;
GRANT SELECT, INSERT, UPDATE ON applications TO authenticated;
