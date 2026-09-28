-- Live database checks for Baseline.
-- Apply migrations 001 and 002 first, then run:
--   psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f services/api/db/verify_e2e.sql
--
-- The phone Discover list is Apple Maps plus OpenStreetMap. These rows are
-- the reference database, including sample Austin courts. They are not the
-- live courts around the phone.

DO $$
DECLARE
  expected text[] := ARRAY[
    'users',
    'auth_identities',
    'sessions',
    'levels',
    'player_profiles',
    'notification_preferences',
    'techniques',
    'technique_relations',
    'lessons',
    'lesson_blocks',
    'glossary_terms',
    'rules_articles',
    'videos',
    'lesson_videos',
    'drills',
    'drill_videos',
    'lesson_drills',
    'training_plans',
    'training_plan_items',
    'practice_sessions',
    'match_logs',
    'lesson_progress',
    'drill_completions',
    'skill_ratings',
    'goals',
    'badges',
    'user_badges',
    'streaks',
    'xp_events',
    'courts',
    'academies',
    'coaches',
    'stores',
    'favorites',
    'place_reviews',
    'products',
    'connection_requests',
    'conversations',
    'conversation_members',
    'messages',
    'blocks',
    'reports',
    'entitlements',
    'admin_users',
    'audit_log'
  ];
  missing text;
  constraints_missing text;
  level_count integer;
  badge_count integer;
  court_count integer;
  cell_type text;
  radius_type text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis') THEN
    RAISE EXCEPTION 'postgis extension is not installed';
  END IF;

  SELECT string_agg(name, ', ')
    INTO missing
  FROM unnest(expected) AS name
  WHERE NOT EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = name
  );
  IF missing IS NOT NULL THEN
    RAISE EXCEPTION 'Missing tables: %', missing;
  END IF;

  IF (
    SELECT count(*)
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_type = 'BASE TABLE'
      AND table_name = ANY (expected)
  ) <> 45 THEN
    RAISE EXCEPTION 'Expected 45 Baseline tables';
  END IF;

  SELECT string_agg(name, ', ')
    INTO constraints_missing
  FROM unnest(ARRAY[
    'users_birth_year_chk',
    'users_deleted_chk',
    'player_profiles_radius_chk',
    'player_profiles_discoverable_deleted_chk',
    'player_profiles_deleted_cell_chk',
    'videos_published_metadata_chk',
    'videos_owned_playback_license_chk',
    'courts_access_chk',
    'blocks_distinct_chk',
    'entitlements_plan_chk'
  ]) AS name
  WHERE NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = name
  );
  IF constraints_missing IS NOT NULL THEN
    RAISE EXCEPTION 'Missing constraints: %', constraints_missing;
  END IF;

  SELECT udt_name INTO cell_type
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'player_profiles'
    AND column_name = 'location_cell';
  IF cell_type IS DISTINCT FROM 'geography' THEN
    RAISE EXCEPTION 'player_profiles.location_cell must be geography, found %', cell_type;
  END IF;

  SELECT udt_name INTO radius_type
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'player_profiles'
    AND column_name = 'search_radius_km';
  IF radius_type IS NULL THEN
    RAISE EXCEPTION 'player_profiles.search_radius_km is missing';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'player_profiles'
      AND column_name IN ('latitude', 'longitude', 'lat', 'lng', 'email')
  ) THEN
    RAISE EXCEPTION 'player_profiles exposes a raw coordinate or email column';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_indexes
    WHERE schemaname = 'public'
      AND indexname = 'player_profiles_location_cell_gist'
  ) THEN
    RAISE EXCEPTION 'location_cell gist index is missing';
  END IF;

  SELECT count(*) INTO level_count FROM levels;
  IF level_count <> 5 THEN
    RAISE EXCEPTION 'Expected 5 levels, found %', level_count;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM levels
    WHERE id = 1 AND name = 'Complete Beginner'
  ) OR NOT EXISTS (
    SELECT 1 FROM levels WHERE id = 5 AND name = 'Advanced'
  ) THEN
    RAISE EXCEPTION 'Level names do not match the catalog';
  END IF;

  SELECT count(*) INTO badge_count FROM badges;
  IF badge_count < 7 THEN
    RAISE EXCEPTION 'Expected at least 7 badges, found %', badge_count;
  END IF;

  SELECT count(*) INTO court_count
  FROM courts
  WHERE source = 'admin'
    AND status = 'active'
    AND access = 'public'
    AND name IN (
      'South Austin Tennis Center',
      'Little Stacy Neighborhood Park',
      'Ramsey Park'
    );
  IF court_count <> 3 THEN
    RAISE EXCEPTION 'Expected 3 sample public courts, found %', court_count;
  END IF;

  IF EXISTS (
    SELECT 1 FROM courts
    WHERE name IN ('Tennis Court', 'Tennis Courts')
       OR name ILIKE '%private%'
  ) THEN
    RAISE EXCEPTION 'Sample courts include a generic or private listing';
  END IF;
END $$;
