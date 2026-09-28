-- Baseline schema. PostgreSQL 16 + PostGIS.
-- Identifiers are uuid. Timestamps are timestamptz.
-- Accounts and public places use deleted_at. Lessons, drills, techniques,
-- and videos use status instead of a hard delete.
-- updated_at is a column where the model names it. The API sets it. No triggers.
-- Player search is not in search_all. The partner service applies coarse-location rules.

BEGIN;

CREATE EXTENSION IF NOT EXISTS postgis;

-- array_to_string is STABLE, so it cannot appear in a generated column.
-- Joining text[] with a space does not depend on session settings.
CREATE FUNCTION baseline_join_text(items text[])
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
RETURN coalesce(array_to_string(items, ' '), '');

-- ---------------------------------------------------------------------------
-- Identity and profile
-- ---------------------------------------------------------------------------

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text,
  birth_year integer NOT NULL,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT users_birth_year_chk CHECK (birth_year BETWEEN 1900 AND 2100),
  CONSTRAINT users_status_chk CHECK (status IN ('active', 'suspended', 'deleted')),
  CONSTRAINT users_deleted_chk CHECK (
    (status = 'deleted' AND deleted_at IS NOT NULL)
    OR (status <> 'deleted' AND deleted_at IS NULL)
  )
);

-- Under 16 is rejected by the API. A check constraint cannot read the current
-- year. Under 18 cannot turn on discoverable; the partner service enforces that.

CREATE UNIQUE INDEX users_email_active_unique
  ON users (lower(email))
  WHERE email IS NOT NULL AND deleted_at IS NULL;

CREATE TABLE auth_identities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  provider text NOT NULL,
  provider_subject text NOT NULL,
  password_hash text,
  code_hash text,
  code_expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT auth_identities_provider_chk CHECK (provider IN ('apple', 'google', 'email')),
  CONSTRAINT auth_identities_provider_subject_unique UNIQUE (provider, provider_subject),
  CONSTRAINT auth_identities_secrets_chk CHECK (
    provider = 'email'
    OR (password_hash IS NULL AND code_hash IS NULL AND code_expires_at IS NULL)
  )
);

COMMENT ON COLUMN auth_identities.password_hash IS
  'Reserved for a later password login. MVP email login stores a one-time code hash in code_hash.';

COMMENT ON COLUMN auth_identities.code_hash IS
  'Hash of the email one-time code. Null for Apple and Google.';

CREATE TABLE sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  refresh_token_hash text NOT NULL,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT sessions_refresh_token_hash_unique UNIQUE (refresh_token_hash)
);

CREATE TABLE levels (
  id smallint PRIMARY KEY,
  name text NOT NULL,
  summary text NOT NULL,
  sort_order smallint NOT NULL,
  CONSTRAINT levels_id_chk CHECK (id BETWEEN 1 AND 5),
  CONSTRAINT levels_sort_order_unique UNIQUE (sort_order)
);

CREATE TABLE player_profiles (
  user_id uuid PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  display_name text,
  level smallint NOT NULL REFERENCES levels (id),
  played_before boolean,
  play_frequency text,
  primary_goal text,
  format text,
  days_per_week smallint,
  focus_skills text[] NOT NULL DEFAULT '{}',
  setting text,
  discoverable boolean NOT NULL DEFAULT false,
  availability jsonb NOT NULL DEFAULT '{}'::jsonb,
  bio text,
  home_city text,
  home_region text,
  country_code text,
  location_cell geography(Point, 4326),
  search_radius_km numeric(5, 1),
  show_age_band boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT player_profiles_level_chk CHECK (level BETWEEN 1 AND 5),
  CONSTRAINT player_profiles_format_chk CHECK (
    format IS NULL OR format IN ('singles', 'doubles', 'both')
  ),
  CONSTRAINT player_profiles_days_chk CHECK (
    days_per_week IS NULL OR days_per_week IN (2, 3, 4, 5)
  ),
  CONSTRAINT player_profiles_setting_chk CHECK (
    setting IS NULL OR setting IN ('indoor', 'outdoor', 'either')
  ),
  CONSTRAINT player_profiles_country_chk CHECK (
    country_code IS NULL OR country_code ~ '^[A-Z]{2}$'
  ),
  CONSTRAINT player_profiles_radius_chk CHECK (
    search_radius_km IS NULL
    OR (search_radius_km > 0 AND search_radius_km <= 200)
  ),
  CONSTRAINT player_profiles_discoverable_deleted_chk CHECK (
    deleted_at IS NULL OR discoverable = false
  ),
  CONSTRAINT player_profiles_deleted_cell_chk CHECK (
    deleted_at IS NULL OR location_cell IS NULL
  )
);

COMMENT ON COLUMN player_profiles.location_cell IS
  'Coarse cell only. The API rounds the point before save (about a geohash-5 cell). Responses expose a distance band, never this coordinate.';

COMMENT ON COLUMN player_profiles.deleted_at IS
  'Set with the account soft delete so the discoverable partial index can exclude the row. The API also clears location_cell.';

CREATE TABLE notification_preferences (
  user_id uuid PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  practice_reminders boolean NOT NULL DEFAULT true,
  plan_reminders boolean NOT NULL DEFAULT false,
  lesson_tips boolean NOT NULL DEFAULT false,
  weekly_progress boolean NOT NULL DEFAULT false,
  partner_requests boolean NOT NULL DEFAULT true,
  messages boolean NOT NULL DEFAULT true,
  milestones boolean NOT NULL DEFAULT false,
  marketing boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE notification_preferences IS
  'Practice reminders and partner requests default on. Message alerts default on because they are transactional. Marketing defaults off.';

-- ---------------------------------------------------------------------------
-- Learning content
-- ---------------------------------------------------------------------------

CREATE TABLE techniques (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL,
  name text NOT NULL,
  family text NOT NULL,
  difficulty smallint,
  reps_suggested text,
  overview text,
  why_it_matters text,
  status text NOT NULL DEFAULT 'draft',
  level_min smallint,
  created_at timestamptz NOT NULL DEFAULT now(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector(
      'english',
      coalesce(name, '') || ' ' || coalesce(overview, '') || ' ' || coalesce(why_it_matters, '')
    )
  ) STORED,
  CONSTRAINT techniques_slug_unique UNIQUE (slug),
  CONSTRAINT techniques_slug_chk CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  CONSTRAINT techniques_family_chk CHECK (
    family IN (
      'ready', 'grip', 'footwork', 'groundstroke', 'net',
      'serve', 'return', 'rally', 'specialty'
    )
  ),
  CONSTRAINT techniques_difficulty_chk CHECK (
    difficulty IS NULL OR difficulty BETWEEN 1 AND 5
  ),
  CONSTRAINT techniques_status_chk CHECK (status IN ('draft', 'published')),
  CONSTRAINT techniques_level_min_chk CHECK (
    level_min IS NULL OR level_min BETWEEN 1 AND 5
  )
);

CREATE TABLE technique_relations (
  technique_id uuid NOT NULL REFERENCES techniques (id) ON DELETE CASCADE,
  related_technique_id uuid NOT NULL REFERENCES techniques (id) ON DELETE CASCADE,
  relation text NOT NULL,
  PRIMARY KEY (technique_id, related_technique_id, relation),
  CONSTRAINT technique_relations_distinct_chk CHECK (technique_id <> related_technique_id),
  CONSTRAINT technique_relations_relation_chk CHECK (relation IN ('next', 'similar'))
);

CREATE TABLE lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  level_id smallint NOT NULL REFERENCES levels (id),
  slug text NOT NULL,
  title text NOT NULL,
  summary text,
  category text NOT NULL,
  technique_id uuid REFERENCES techniques (id) ON DELETE RESTRICT,
  estimated_minutes integer,
  difficulty smallint,
  prerequisite_lesson_id uuid REFERENCES lessons (id) ON DELETE SET NULL,
  next_lesson_id uuid REFERENCES lessons (id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'draft',
  free_tier boolean NOT NULL DEFAULT false,
  published_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(summary, ''))
  ) STORED,
  CONSTRAINT lessons_slug_unique UNIQUE (slug),
  CONSTRAINT lessons_slug_chk CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  CONSTRAINT lessons_category_chk CHECK (
    category IN ('rules', 'technique', 'strategy', 'fitness', 'etiquette', 'mental')
  ),
  CONSTRAINT lessons_minutes_chk CHECK (
    estimated_minutes IS NULL OR estimated_minutes > 0
  ),
  CONSTRAINT lessons_difficulty_chk CHECK (
    difficulty IS NULL OR difficulty BETWEEN 1 AND 5
  ),
  CONSTRAINT lessons_status_chk CHECK (status IN ('draft', 'published')),
  CONSTRAINT lessons_published_at_chk CHECK (
    status <> 'published' OR published_at IS NOT NULL
  ),
  CONSTRAINT lessons_not_self_prerequisite_chk CHECK (
    prerequisite_lesson_id IS DISTINCT FROM id
  ),
  CONSTRAINT lessons_not_self_next_chk CHECK (next_lesson_id IS DISTINCT FROM id)
);

CREATE TABLE lesson_blocks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL REFERENCES lessons (id) ON DELETE CASCADE,
  sort_order integer NOT NULL,
  kind text NOT NULL,
  body jsonb NOT NULL,
  CONSTRAINT lesson_blocks_sort_unique UNIQUE (lesson_id, sort_order),
  CONSTRAINT lesson_blocks_kind_chk CHECK (
    kind IN (
      'overview', 'why', 'steps', 'tips', 'mistakes',
      'beginner_mistakes', 'checklist', 'text'
    )
  )
);

COMMENT ON COLUMN lesson_blocks.body IS
  'Headings and paragraphs as JSON. Not raw HTML.';

CREATE TABLE glossary_terms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL,
  term text NOT NULL,
  definition text NOT NULL,
  level_min smallint,
  created_at timestamptz NOT NULL DEFAULT now(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector('english', coalesce(term, '') || ' ' || coalesce(definition, ''))
  ) STORED,
  CONSTRAINT glossary_terms_slug_unique UNIQUE (slug),
  CONSTRAINT glossary_terms_slug_chk CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  CONSTRAINT glossary_terms_level_min_chk CHECK (
    level_min IS NULL OR level_min BETWEEN 1 AND 5
  )
);

CREATE TABLE rules_articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL,
  title text NOT NULL,
  body jsonb NOT NULL,
  topic text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT rules_articles_slug_unique UNIQUE (slug),
  CONSTRAINT rules_articles_slug_chk CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  CONSTRAINT rules_articles_topic_chk CHECK (
    topic IN (
      'scoring', 'singles', 'doubles', 'serve', 'let', 'tiebreak', 'lines', 'conduct'
    )
  )
);

-- ---------------------------------------------------------------------------
-- Video
-- ---------------------------------------------------------------------------

CREATE TABLE videos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  duration_seconds integer,
  category text,
  level_min smallint,
  technique_id uuid REFERENCES techniques (id) ON DELETE SET NULL,
  playback text NOT NULL DEFAULT 'embed',
  embed_url text,
  owned_object_key text,
  source_name text,
  creator_name text,
  license text,
  license_url text,
  attribution text,
  source_page_url text,
  status text NOT NULL DEFAULT 'draft',
  created_by uuid REFERENCES users (id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT videos_duration_chk CHECK (
    duration_seconds IS NULL OR duration_seconds > 0
  ),
  CONSTRAINT videos_level_min_chk CHECK (
    level_min IS NULL OR level_min BETWEEN 1 AND 5
  ),
  CONSTRAINT videos_playback_chk CHECK (playback IN ('embed', 'owned_file')),
  CONSTRAINT videos_license_chk CHECK (
    license IS NULL
    OR license IN (
      'original', 'licensed', 'public_domain', 'creative_commons', 'provider_embed'
    )
  ),
  CONSTRAINT videos_status_chk CHECK (status IN ('draft', 'published')),
  CONSTRAINT videos_playback_fields_chk CHECK (
    (playback = 'embed' AND owned_object_key IS NULL)
    OR (playback = 'owned_file' AND embed_url IS NULL)
  ),
  CONSTRAINT videos_provider_embed_playback_chk CHECK (
    license IS DISTINCT FROM 'provider_embed' OR playback = 'embed'
  ),
  -- Owned files are Baseline originals or contracted streams. Embeds cover
  -- public domain, Creative Commons, and provider pages.
  -- coalesce(..., false) matters: a CHECK passes on NULL, so a missing
  -- license must be an explicit false, not an unknown result.
  CONSTRAINT videos_owned_playback_license_chk CHECK (
    playback IS DISTINCT FROM 'owned_file'
    OR coalesce(license IN ('original', 'licensed'), false)
  ),
  CONSTRAINT videos_published_metadata_chk CHECK (
    status IS DISTINCT FROM 'published'
    OR (
      coalesce(char_length(btrim(title)), 0) > 0
      AND coalesce(char_length(btrim(source_name)), 0) > 0
      AND coalesce(char_length(btrim(creator_name)), 0) > 0
      AND license IS NOT NULL
      AND coalesce(char_length(btrim(attribution)), 0) > 0
      AND coalesce(char_length(btrim(category)), 0) > 0
      AND level_min IS NOT NULL
      AND duration_seconds IS NOT NULL
      AND duration_seconds > 0
      AND (
        coalesce(char_length(btrim(embed_url)), 0) > 0
        OR coalesce(char_length(btrim(license_url)), 0) > 0
        OR coalesce(char_length(btrim(source_page_url)), 0) > 0
      )
      AND (
        (
          playback = 'embed'
          AND coalesce(char_length(btrim(embed_url)), 0) > 0
        )
        OR (
          playback = 'owned_file'
          AND coalesce(char_length(btrim(owned_object_key)), 0) > 0
        )
      )
    )
  )
);

COMMENT ON CONSTRAINT videos_published_metadata_chk ON videos IS
  'A published video must have source_name, creator_name, license, attribution, and a URL.';

COMMENT ON CONSTRAINT videos_owned_playback_license_chk ON videos IS
  'owned_file playback is allowed only when license is original or licensed.';

CREATE TABLE lesson_videos (
  lesson_id uuid NOT NULL REFERENCES lessons (id) ON DELETE CASCADE,
  video_id uuid NOT NULL REFERENCES videos (id) ON DELETE RESTRICT,
  sort_order integer NOT NULL,
  PRIMARY KEY (lesson_id, video_id),
  CONSTRAINT lesson_videos_sort_unique UNIQUE (lesson_id, sort_order)
);

-- drill_videos is created after drills.

-- ---------------------------------------------------------------------------
-- Training
-- ---------------------------------------------------------------------------

CREATE TABLE drills (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL,
  name text NOT NULL,
  level_min smallint,
  objective text,
  equipment text[] NOT NULL DEFAULT '{}',
  court_setup text,
  players_required integer,
  instructions jsonb NOT NULL DEFAULT '{}'::jsonb,
  duration_minutes integer,
  repetitions text,
  difficulty smallint,
  coaching_tips text,
  common_mistakes text,
  free_tier boolean NOT NULL DEFAULT false,
  status text NOT NULL DEFAULT 'draft',
  created_at timestamptz NOT NULL DEFAULT now(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector(
      'english',
      coalesce(name, '') || ' ' ||
      coalesce(objective, '') || ' ' ||
      coalesce(instructions::text, '') || ' ' ||
      coalesce(coaching_tips, '') || ' ' ||
      coalesce(common_mistakes, '')
    )
  ) STORED,
  CONSTRAINT drills_slug_unique UNIQUE (slug),
  CONSTRAINT drills_slug_chk CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  CONSTRAINT drills_level_min_chk CHECK (level_min IS NULL OR level_min BETWEEN 1 AND 5),
  CONSTRAINT drills_players_chk CHECK (players_required IS NULL OR players_required >= 1),
  CONSTRAINT drills_duration_chk CHECK (duration_minutes IS NULL OR duration_minutes > 0),
  CONSTRAINT drills_difficulty_chk CHECK (difficulty IS NULL OR difficulty BETWEEN 1 AND 5),
  CONSTRAINT drills_status_chk CHECK (status IN ('draft', 'published'))
);

CREATE TABLE drill_videos (
  drill_id uuid NOT NULL REFERENCES drills (id) ON DELETE CASCADE,
  video_id uuid NOT NULL REFERENCES videos (id) ON DELETE RESTRICT,
  sort_order integer NOT NULL,
  PRIMARY KEY (drill_id, video_id),
  CONSTRAINT drill_videos_sort_unique UNIQUE (drill_id, sort_order)
);

CREATE TABLE lesson_drills (
  lesson_id uuid NOT NULL REFERENCES lessons (id) ON DELETE CASCADE,
  drill_id uuid NOT NULL REFERENCES drills (id) ON DELETE RESTRICT,
  PRIMARY KEY (lesson_id, drill_id)
);

CREATE TABLE training_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  week_start date NOT NULL,
  days_per_week smallint NOT NULL,
  goal text,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT training_plans_days_chk CHECK (days_per_week IN (2, 3, 4, 5)),
  CONSTRAINT training_plans_status_chk CHECK (
    status IN ('active', 'completed', 'archived')
  )
);

CREATE TABLE training_plan_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id uuid NOT NULL REFERENCES training_plans (id) ON DELETE CASCADE,
  day_index smallint NOT NULL,
  sort_order integer NOT NULL,
  kind text NOT NULL,
  title text NOT NULL,
  minutes integer NOT NULL,
  lesson_id uuid REFERENCES lessons (id) ON DELETE SET NULL,
  drill_id uuid REFERENCES drills (id) ON DELETE SET NULL,
  CONSTRAINT training_plan_items_day_sort_unique UNIQUE (plan_id, day_index, sort_order),
  CONSTRAINT training_plan_items_day_chk CHECK (day_index BETWEEN 0 AND 6),
  CONSTRAINT training_plan_items_kind_chk CHECK (
    kind IN ('warmup', 'footwork', 'technique', 'drill', 'serve', 'rally', 'recover')
  ),
  CONSTRAINT training_plan_items_minutes_chk CHECK (minutes > 0)
);

CREATE TABLE practice_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  started_at timestamptz NOT NULL DEFAULT now(),
  minutes integer NOT NULL,
  plan_item_id uuid REFERENCES training_plan_items (id) ON DELETE SET NULL,
  note text,
  CONSTRAINT practice_sessions_minutes_chk CHECK (minutes >= 0)
);

CREATE TABLE match_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  played_on date NOT NULL,
  format text NOT NULL,
  result text NOT NULL,
  score_text text,
  went_well text,
  to_improve text,
  serve_note text,
  return_note text,
  mental_note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT match_logs_format_chk CHECK (format IN ('singles', 'doubles')),
  CONSTRAINT match_logs_result_chk CHECK (result IN ('win', 'loss', 'unfinished'))
);

-- ---------------------------------------------------------------------------
-- Progress
-- XP totals are derived from xp_events (lesson 20, drill 10, one point per
-- session minute). The API caps grants per day before insert so the total
-- can be recomputed from this table.
-- ---------------------------------------------------------------------------

CREATE TABLE lesson_progress (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  lesson_id uuid NOT NULL REFERENCES lessons (id) ON DELETE CASCADE,
  status text NOT NULL,
  completed_at timestamptz,
  PRIMARY KEY (user_id, lesson_id),
  CONSTRAINT lesson_progress_status_chk CHECK (status IN ('started', 'completed')),
  CONSTRAINT lesson_progress_completed_chk CHECK (
    (status = 'completed' AND completed_at IS NOT NULL)
    OR (status = 'started' AND completed_at IS NULL)
  )
);

CREATE TABLE drill_completions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  drill_id uuid NOT NULL REFERENCES drills (id) ON DELETE CASCADE,
  completed_at timestamptz NOT NULL DEFAULT now(),
  minutes integer,
  CONSTRAINT drill_completions_minutes_chk CHECK (minutes IS NULL OR minutes >= 0)
);

CREATE TABLE skill_ratings (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  skill text NOT NULL,
  rating smallint NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, skill),
  CONSTRAINT skill_ratings_skill_chk CHECK (
    skill IN ('forehand', 'backhand', 'serve', 'volley', 'footwork', 'rally', 'mental')
  ),
  CONSTRAINT skill_ratings_rating_chk CHECK (rating BETWEEN 1 AND 5)
);

COMMENT ON COLUMN skill_ratings.updated_at IS
  'Set by the API on each change. There is no updated_at trigger.';

CREATE TABLE goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  kind text NOT NULL,
  title text NOT NULL,
  target numeric,
  progress numeric NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT goals_status_chk CHECK (status IN ('active', 'completed', 'abandoned')),
  CONSTRAINT goals_progress_chk CHECK (progress >= 0)
);

CREATE TABLE badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL,
  name text NOT NULL,
  description text NOT NULL,
  CONSTRAINT badges_code_unique UNIQUE (code)
);

CREATE TABLE user_badges (
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  badge_id uuid NOT NULL REFERENCES badges (id) ON DELETE RESTRICT,
  earned_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, badge_id)
);

CREATE TABLE streaks (
  user_id uuid PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  current_count integer NOT NULL DEFAULT 0,
  longest_count integer NOT NULL DEFAULT 0,
  last_active_on date,
  CONSTRAINT streaks_counts_chk CHECK (
    current_count >= 0
    AND longest_count >= 0
    AND longest_count >= current_count
  )
);

CREATE TABLE xp_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  kind text NOT NULL,
  points integer NOT NULL,
  source_id uuid,
  granted_on date NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT xp_events_kind_chk CHECK (kind IN ('lesson', 'drill', 'session_minute')),
  CONSTRAINT xp_events_points_chk CHECK (
    (kind = 'lesson' AND points = 20)
    OR (kind = 'drill' AND points = 10)
    OR (kind = 'session_minute' AND points >= 1)
  )
);

COMMENT ON TABLE xp_events IS
  'Audit trail for XP. Lesson grants are 20, drill grants are 10, and each practice minute is 1. The API applies the daily cap before insert.';

-- ---------------------------------------------------------------------------
-- Places. Coordinates are public. Player cells live on player_profiles.
-- place_reviews is reserved and stays empty until a provider agreement
-- allows a snippet. Do not scrape Google reviews into it.
-- ---------------------------------------------------------------------------

CREATE TABLE courts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  court_count integer,
  indoor boolean NOT NULL DEFAULT false,
  access text NOT NULL DEFAULT 'unknown',
  lights boolean NOT NULL DEFAULT false,
  surface text,
  price_text text,
  booking_url text,
  osm_id text,
  location geography(Point, 4326) NOT NULL,
  address text,
  phone text,
  website text,
  hours jsonb,
  status text NOT NULL DEFAULT 'active',
  source text NOT NULL,
  notes text,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector(
      'english',
      coalesce(name, '') || ' ' || coalesce(address, '') || ' ' || coalesce(surface, '')
    )
  ) STORED,
  CONSTRAINT courts_count_chk CHECK (court_count IS NULL OR court_count > 0),
  CONSTRAINT courts_access_chk CHECK (access IN ('public', 'private', 'club', 'unknown')),
  CONSTRAINT courts_status_chk CHECK (status IN ('active', 'inactive')),
  CONSTRAINT courts_source_chk CHECK (source IN ('admin', 'osm'))
);

CREATE UNIQUE INDEX courts_osm_id_unique
  ON courts (osm_id)
  WHERE osm_id IS NOT NULL;

CREATE TABLE academies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  kind text NOT NULL,
  summary text,
  location geography(Point, 4326) NOT NULL,
  address text,
  phone text,
  website text,
  hours jsonb,
  status text NOT NULL DEFAULT 'active',
  source text NOT NULL,
  notes text,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT academies_kind_chk CHECK (kind IN ('academy', 'club', 'school', 'center')),
  CONSTRAINT academies_status_chk CHECK (status IN ('active', 'inactive')),
  CONSTRAINT academies_source_chk CHECK (source IN ('admin', 'osm'))
);

CREATE TABLE coaches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  academy_id uuid REFERENCES academies (id) ON DELETE SET NULL,
  name text NOT NULL,
  credentials text,
  years_experience integer,
  specialties text[] NOT NULL DEFAULT '{}',
  audience text,
  format text,
  price_text text,
  intro_video_id uuid REFERENCES videos (id) ON DELETE SET NULL,
  photo_url text,
  contact_url text,
  location geography(Point, 4326) NOT NULL,
  address text,
  phone text,
  website text,
  hours jsonb,
  status text NOT NULL DEFAULT 'active',
  source text NOT NULL,
  notes text,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector(
      'english',
      coalesce(name, '') || ' ' ||
      coalesce(credentials, '') || ' ' ||
      baseline_join_text(specialties)
    )
  ) STORED,
  CONSTRAINT coaches_years_chk CHECK (years_experience IS NULL OR years_experience >= 0),
  CONSTRAINT coaches_audience_chk CHECK (
    audience IS NULL OR audience IN ('adult', 'junior', 'both')
  ),
  CONSTRAINT coaches_format_chk CHECK (
    format IS NULL OR format IN ('private', 'group', 'both')
  ),
  CONSTRAINT coaches_status_chk CHECK (status IN ('active', 'inactive')),
  CONSTRAINT coaches_source_chk CHECK (source IN ('admin', 'osm'))
);

CREATE TABLE stores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  services text[] NOT NULL DEFAULT '{}',
  location geography(Point, 4326) NOT NULL,
  address text,
  phone text,
  website text,
  hours jsonb,
  status text NOT NULL DEFAULT 'active',
  source text NOT NULL,
  notes text,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector(
      'english',
      coalesce(name, '') || ' ' || baseline_join_text(services)
    )
  ) STORED,
  CONSTRAINT stores_services_chk CHECK (
    services <@ ARRAY['stringing', 'grips', 'shoes', 'repair', 'used']::text[]
  ),
  CONSTRAINT stores_status_chk CHECK (status IN ('active', 'inactive')),
  CONSTRAINT stores_source_chk CHECK (source IN ('admin', 'osm'))
);

CREATE TABLE favorites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  place_type text NOT NULL,
  place_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT favorites_place_type_chk CHECK (
    place_type IN ('court', 'academy', 'coach', 'store')
  ),
  CONSTRAINT favorites_user_place_unique UNIQUE (user_id, place_type, place_id)
);

COMMENT ON TABLE favorites IS
  'place_id is checked by the API against the table named by place_type.';

CREATE TABLE place_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  place_type text NOT NULL,
  place_id uuid NOT NULL,
  provider text,
  snippet text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT place_reviews_place_type_chk CHECK (
    place_type IN ('court', 'academy', 'coach', 'store')
  ),
  CONSTRAINT place_reviews_snippet_requires_provider CHECK (
    snippet IS NULL OR (provider IS NOT NULL AND char_length(btrim(provider)) > 0)
  )
);

COMMENT ON TABLE place_reviews IS
  'Deferred. Leave empty in the MVP. A snippet is allowed only when that provider''s terms permit storing it. Do not scrape Google reviews.';

-- ---------------------------------------------------------------------------
-- Equipment. Editorial copy must not give injury or medical advice.
-- ---------------------------------------------------------------------------

CREATE TABLE products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  level_min smallint,
  level_max smallint,
  playing_style text,
  budget_band text,
  age_band text,
  specs jsonb NOT NULL DEFAULT '{}'::jsonb,
  pros text,
  considerations text,
  price_cents integer,
  currency text NOT NULL DEFAULT 'USD',
  retailer_name text,
  retailer_url text,
  updated_on date,
  sponsored boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT products_level_min_chk CHECK (level_min IS NULL OR level_min BETWEEN 1 AND 5),
  CONSTRAINT products_level_max_chk CHECK (level_max IS NULL OR level_max BETWEEN 1 AND 5),
  CONSTRAINT products_level_order_chk CHECK (
    level_min IS NULL OR level_max IS NULL OR level_min <= level_max
  ),
  CONSTRAINT products_price_chk CHECK (price_cents IS NULL OR price_cents >= 0),
  CONSTRAINT products_currency_chk CHECK (currency ~ '^[A-Z]{3}$')
);

COMMENT ON TABLE products IS
  'Guides only. Do not store injury or medical advice. Grip size and shoes belong with a shop or coach when the player has pain.';

-- ---------------------------------------------------------------------------
-- Partners and safety
-- A conversation row is inserted only after the request is accepted.
-- Blocked pairs are excluded from search and messaging by the partner service.
-- ---------------------------------------------------------------------------

CREATE TABLE connection_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  to_user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT connection_requests_distinct_chk CHECK (from_user_id <> to_user_id),
  CONSTRAINT connection_requests_status_chk CHECK (
    status IN ('pending', 'accepted', 'declined', 'cancelled')
  )
);

CREATE UNIQUE INDEX connection_requests_pending_pair_unique
  ON connection_requests (from_user_id, to_user_id)
  WHERE status = 'pending';

CREATE TABLE conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL UNIQUE REFERENCES connection_requests (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE conversation_members (
  conversation_id uuid NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES conversations (id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT messages_body_chk CHECK (
    char_length(btrim(body)) > 0 AND char_length(body) <= 4000
  )
);

COMMENT ON COLUMN messages.body IS
  'Plain text. No link previews and no images in the MVP.';

CREATE TABLE blocks (
  blocker_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  blocked_id uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id),
  CONSTRAINT blocks_distinct_chk CHECK (blocker_id <> blocked_id)
);

CREATE TABLE reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id uuid NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
  target_type text NOT NULL,
  target_id uuid NOT NULL,
  message_id uuid REFERENCES messages (id) ON DELETE SET NULL,
  snapshot_body text,
  reason text NOT NULL,
  note text,
  status text NOT NULL DEFAULT 'open',
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT reports_target_type_chk CHECK (target_type IN ('user', 'message')),
  CONSTRAINT reports_status_chk CHECK (status IN ('open', 'closed')),
  CONSTRAINT reports_reason_chk CHECK (char_length(btrim(reason)) > 0)
);

COMMENT ON COLUMN reports.message_id IS
  'Snapshot id of a reported message. snapshot_body keeps the plain text if that message is later deleted.';

-- ---------------------------------------------------------------------------
-- Billing and admin
-- ---------------------------------------------------------------------------

CREATE TABLE entitlements (
  user_id uuid PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  plan text NOT NULL DEFAULT 'free',
  source text NOT NULL,
  expires_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT entitlements_plan_chk CHECK (plan IN ('free', 'premium'))
);

COMMENT ON COLUMN entitlements.updated_at IS
  'Set by the billing webhook upsert. There is no updated_at trigger.';

CREATE TABLE admin_users (
  user_id uuid PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  role text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT admin_users_role_chk CHECK (role IN ('editor', 'admin'))
);

CREATE TABLE audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid REFERENCES users (id) ON DELETE SET NULL,
  action text NOT NULL,
  entity text NOT NULL,
  entity_id text,
  at timestamptz NOT NULL DEFAULT now(),
  diff jsonb
);

COMMENT ON TABLE audit_log IS
  'Publish, unpublish, suspend, and report decisions. entity_id is text so non-uuid keys such as level ids can be stored.';

-- ---------------------------------------------------------------------------
-- Indexes required by the data model
-- ---------------------------------------------------------------------------

-- GiST on every geography column.
CREATE INDEX player_profiles_location_cell_gist
  ON player_profiles USING gist (location_cell);

CREATE INDEX courts_location_gist
  ON courts USING gist (location);

CREATE INDEX academies_location_gist
  ON academies USING gist (location);

CREATE INDEX coaches_location_gist
  ON coaches USING gist (location);

CREATE INDEX stores_location_gist
  ON stores USING gist (location);

-- Partial index of discoverable profiles that are not deleted.
CREATE INDEX player_profiles_discoverable_idx
  ON player_profiles (level, format, setting)
  WHERE discoverable = true AND deleted_at IS NULL;

-- (user_id, completed_at) on progress tables.
CREATE INDEX lesson_progress_user_completed_idx
  ON lesson_progress (user_id, completed_at);

CREATE INDEX drill_completions_user_completed_idx
  ON drill_completions (user_id, completed_at);

-- ---------------------------------------------------------------------------
-- Supporting indexes
-- ---------------------------------------------------------------------------

CREATE INDEX auth_identities_user_id_idx ON auth_identities (user_id);
CREATE INDEX sessions_user_id_idx ON sessions (user_id);

CREATE INDEX lessons_level_id_idx ON lessons (level_id);
CREATE INDEX lessons_technique_id_idx ON lessons (technique_id);
CREATE INDEX lessons_status_level_idx ON lessons (status, level_id);

CREATE INDEX lesson_blocks_lesson_id_idx ON lesson_blocks (lesson_id);

CREATE INDEX technique_relations_related_idx
  ON technique_relations (related_technique_id);

CREATE INDEX videos_technique_id_idx ON videos (technique_id);
CREATE INDEX videos_created_by_idx ON videos (created_by);
CREATE INDEX videos_status_idx ON videos (status);

CREATE INDEX lesson_videos_video_id_idx ON lesson_videos (video_id);
CREATE INDEX drill_videos_video_id_idx ON drill_videos (video_id);
CREATE INDEX lesson_drills_drill_id_idx ON lesson_drills (drill_id);

CREATE INDEX drills_status_level_idx ON drills (status, level_min);

CREATE INDEX training_plans_user_id_idx ON training_plans (user_id, week_start);
CREATE INDEX training_plan_items_plan_id_idx ON training_plan_items (plan_id);
CREATE INDEX training_plan_items_lesson_id_idx ON training_plan_items (lesson_id);
CREATE INDEX training_plan_items_drill_id_idx ON training_plan_items (drill_id);

CREATE INDEX practice_sessions_user_started_idx
  ON practice_sessions (user_id, started_at);

CREATE INDEX practice_sessions_plan_item_id_idx
  ON practice_sessions (plan_item_id);

CREATE INDEX match_logs_user_played_idx ON match_logs (user_id, played_on);

CREATE INDEX lesson_progress_lesson_id_idx ON lesson_progress (lesson_id);
CREATE INDEX drill_completions_drill_id_idx ON drill_completions (drill_id);
CREATE INDEX goals_user_id_idx ON goals (user_id);
CREATE INDEX user_badges_badge_id_idx ON user_badges (badge_id);

CREATE INDEX xp_events_user_granted_idx ON xp_events (user_id, granted_on);

CREATE UNIQUE INDEX xp_events_source_once
  ON xp_events (user_id, kind, source_id)
  WHERE source_id IS NOT NULL;

CREATE INDEX coaches_academy_id_idx ON coaches (academy_id);
CREATE INDEX coaches_intro_video_id_idx ON coaches (intro_video_id);
CREATE INDEX favorites_user_id_idx ON favorites (user_id);

CREATE INDEX connection_requests_to_user_idx
  ON connection_requests (to_user_id, status);

CREATE INDEX connection_requests_from_user_idx
  ON connection_requests (from_user_id, status);

CREATE INDEX conversation_members_user_id_idx ON conversation_members (user_id);
CREATE INDEX messages_conversation_created_idx
  ON messages (conversation_id, created_at);

CREATE INDEX messages_sender_id_idx ON messages (sender_id);
CREATE INDEX blocks_blocked_id_idx ON blocks (blocked_id);
CREATE INDEX reports_status_created_idx ON reports (status, created_at);
CREATE INDEX reports_reporter_id_idx ON reports (reporter_id);
CREATE INDEX audit_log_at_idx ON audit_log (at);
CREATE INDEX audit_log_entity_idx ON audit_log (entity, entity_id);

CREATE INDEX lessons_search_gin
  ON lessons USING gin (search_vector)
  WHERE status = 'published';

CREATE INDEX lesson_blocks_body_search_gin
  ON lesson_blocks USING gin (to_tsvector('english', body::text));

CREATE INDEX techniques_search_gin
  ON techniques USING gin (search_vector)
  WHERE status = 'published';

CREATE INDEX drills_search_gin
  ON drills USING gin (search_vector)
  WHERE status = 'published';

CREATE INDEX glossary_terms_search_gin
  ON glossary_terms USING gin (search_vector);

CREATE INDEX courts_search_gin
  ON courts USING gin (search_vector)
  WHERE deleted_at IS NULL AND status = 'active';

CREATE INDEX coaches_search_gin
  ON coaches USING gin (search_vector)
  WHERE deleted_at IS NULL AND status = 'active';

CREATE INDEX stores_search_gin
  ON stores USING gin (search_vector)
  WHERE deleted_at IS NULL AND status = 'active';

-- ---------------------------------------------------------------------------
-- Search. Players are omitted on purpose.
-- ---------------------------------------------------------------------------

CREATE FUNCTION search_all(
  query text,
  near_point geography(Point, 4326) DEFAULT NULL
)
RETURNS TABLE (
  kind text,
  id uuid,
  slug text,
  title text,
  score real,
  distance_meters double precision
)
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  WITH q AS (
    SELECT plainto_tsquery('english', btrim(query)) AS tsq
    WHERE query IS NOT NULL AND btrim(query) <> ''
  )
  SELECT
    hits.kind,
    hits.id,
    hits.slug,
    hits.title,
    hits.score,
    hits.distance_meters
  FROM (
    SELECT
      'lesson'::text AS kind,
      l.id,
      l.slug,
      l.title,
      GREATEST(
        ts_rank(l.search_vector, q.tsq),
        coalesce((
          SELECT max(ts_rank(to_tsvector('english', b.body::text), q.tsq))
          FROM lesson_blocks b
          WHERE b.lesson_id = l.id
        ), 0)
      )::real AS score,
      NULL::double precision AS distance_meters
    FROM lessons l
    CROSS JOIN q
    WHERE l.status = 'published'
      AND (
        l.search_vector @@ q.tsq
        OR EXISTS (
          SELECT 1
          FROM lesson_blocks b
          WHERE b.lesson_id = l.id
            AND to_tsvector('english', b.body::text) @@ q.tsq
        )
      )

    UNION ALL

    SELECT
      'technique'::text,
      t.id,
      t.slug,
      t.name,
      ts_rank(t.search_vector, q.tsq)::real,
      NULL::double precision
    FROM techniques t
    CROSS JOIN q
    WHERE t.status = 'published'
      AND t.search_vector @@ q.tsq

    UNION ALL

    SELECT
      'drill'::text,
      d.id,
      d.slug,
      d.name,
      ts_rank(d.search_vector, q.tsq)::real,
      NULL::double precision
    FROM drills d
    CROSS JOIN q
    WHERE d.status = 'published'
      AND d.search_vector @@ q.tsq

    UNION ALL

    SELECT
      'glossary'::text,
      g.id,
      g.slug,
      g.term,
      ts_rank(g.search_vector, q.tsq)::real,
      NULL::double precision
    FROM glossary_terms g
    CROSS JOIN q
    WHERE g.search_vector @@ q.tsq

    UNION ALL

    SELECT
      'court'::text,
      c.id,
      NULL::text,
      c.name,
      ts_rank(c.search_vector, q.tsq)::real,
      CASE
        WHEN near_point IS NULL THEN NULL::double precision
        ELSE ST_Distance(c.location, near_point)
      END
    FROM courts c
    CROSS JOIN q
    WHERE c.deleted_at IS NULL
      AND c.status = 'active'
      AND c.search_vector @@ q.tsq

    UNION ALL

    SELECT
      'coach'::text,
      c.id,
      NULL::text,
      c.name,
      ts_rank(c.search_vector, q.tsq)::real,
      CASE
        WHEN near_point IS NULL THEN NULL::double precision
        ELSE ST_Distance(c.location, near_point)
      END
    FROM coaches c
    CROSS JOIN q
    WHERE c.deleted_at IS NULL
      AND c.status = 'active'
      AND c.search_vector @@ q.tsq

    UNION ALL

    SELECT
      'store'::text,
      s.id,
      NULL::text,
      s.name,
      ts_rank(s.search_vector, q.tsq)::real,
      CASE
        WHEN near_point IS NULL THEN NULL::double precision
        ELSE ST_Distance(s.location, near_point)
      END
    FROM stores s
    CROSS JOIN q
    WHERE s.deleted_at IS NULL
      AND s.status = 'active'
      AND s.search_vector @@ q.tsq
  ) AS hits
  ORDER BY hits.score DESC, hits.distance_meters ASC NULLS LAST;
$$;

COMMENT ON FUNCTION search_all(text, geography) IS
  'Full-text hits for lessons, techniques, drills, glossary, courts, coaches, and stores. near_point adds distance in meters for places. Player hits are not included.';

COMMIT;
