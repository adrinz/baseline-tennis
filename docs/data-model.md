# Data model

PostgreSQL 16 with PostGIS. Identifiers are UUIDs. Timestamps are `timestamptz`. Soft delete (`deleted_at`) is used for accounts and public places. Lessons use a status instead of a hard delete.

## Identity and profile

**users**

- id, created_at, deleted_at
- email (nullable, unique when present)
- birth_year (required; social features check age)
- status: active, suspended, deleted

**auth_identities**

- id, user_id, provider: apple | google | email
- provider_subject, password_hash (email only)
- unique (provider, provider_subject)

**sessions**

- id, user_id, refresh_token_hash, expires_at, revoked_at, user_agent

**player_profiles**

- user_id (pk)
- display_name
- level: 1–5
- played_before, play_frequency, primary_goal
- format: singles | doubles | both
- days_per_week: 2 | 3 | 4 | 5
- focus_skills: text[]
- setting: indoor | outdoor | either
- discoverable: boolean (default false)
- availability: jsonb (days and time blocks)
- bio, home_city, home_region, country_code
- location_cell: geography point (coarse), search_radius_km
- show_age_band: boolean

**notification_preferences**

- user_id
- practice_reminders, plan_reminders, lesson_tips, weekly_progress
- partner_requests, messages, milestones
- Each is a boolean. Default practice and partner requests on. Marketing off.

## Learning content

**levels** — id 1–5, name, summary, sort_order

**lessons**

- id, level_id, slug, title, summary
- category: rules | technique | strategy | fitness | etiquette | mental
- technique_id nullable
- estimated_minutes, difficulty: 1–5
- prerequisite_lesson_id nullable
- next_lesson_id nullable
- status: draft | published
- free_tier: boolean
- published_at

**lesson_blocks** — ordered body. A lesson is readable with zero videos.

- id, lesson_id, sort_order
- kind: overview | why | steps | tips | mistakes | beginner_mistakes | checklist | text
- body: jsonb (headings and paragraphs, not raw HTML from editors)

**techniques**

- id, slug, name
- family: ready | grip | footwork | groundstroke | net | serve | return | rally | specialty
- difficulty, reps_suggested, overview, why_it_matters
- status, level_min

**technique_relations** — technique_id, related_technique_id, relation: next | similar

**glossary_terms** — slug, term, definition, level_min

**rules_articles** — slug, title, body jsonb, topic: scoring | singles | doubles | serve | let | tiebreak | lines | conduct

## Video

**videos**

- id, title, duration_seconds
- category, level_min, technique_id nullable
- playback: embed | owned_file
- embed_url nullable, owned_object_key nullable
- source_name, creator_name, license
- license: original | licensed | public_domain | creative_commons | provider_embed
- license_url, attribution, source_page_url
- status: draft | published
- created_by, reviewed_at

A check constraint requires license fields before `published`. `owned_file` is allowed only when license is `original` or `licensed`.

**lesson_videos** — lesson_id, video_id, sort_order

**drill_videos** — drill_id, video_id, sort_order

## Training

**drills**

- id, slug, name, level_min, objective
- equipment: text[], court_setup, players_required
- instructions jsonb, duration_minutes, repetitions
- difficulty, coaching_tips, common_mistakes
- free_tier, status

**lesson_drills** — lesson_id, drill_id

**training_plans**

- id, user_id, week_start, days_per_week, goal, status

**training_plan_items**

- id, plan_id, day_index, sort_order
- kind: warmup | footwork | technique | drill | serve | rally | recover
- title, minutes, lesson_id nullable, drill_id nullable

**practice_sessions**

- id, user_id, started_at, minutes, plan_item_id nullable
- note

**match_logs**

- id, user_id, played_on, format, result: win | loss | unfinished
- score_text, went_well, to_improve
- serve_note, return_note, mental_note

## Progress

**lesson_progress** — user_id, lesson_id, status: started | completed, completed_at

**drill_completions** — user_id, drill_id, completed_at, minutes

**skill_ratings** — user_id, skill (forehand, backhand, serve, volley, footwork, rally, mental), rating 1–5, updated_at

**goals** — id, user_id, kind, title, target, progress, status

**badges** — id, code, name, description

**user_badges** — user_id, badge_id, earned_at

**streaks** — user_id, current_count, longest_count, last_active_on

XP is derived from completions (lesson 20, drill 10, session minute 1, capped per day) so it can be recomputed. A `xp_events` table records the grant for an audit trail.

## Places

All place tables include `location geography(Point, 4326)`, address, phone, website, hours jsonb, status, and source: admin | osm.

**courts** — name, court_count, indoor, access: public | private | club | unknown, lights, surface, price_text, booking_url, osm_id nullable

**academies** — name, kind: academy | club | school | center, summary

**coaches** — academy_id nullable, name, credentials, years_experience, specialties text[], audience: adult | junior | both, format: private | group | both, price_text, intro_video_id nullable, photo_url, contact_url

**stores** — name, services text[] (stringing, grips, shoes, repair, used)

**favorites** — user_id, place_type, place_id

**place_reviews** — deferred. Column reserved only if a review provider’s terms allow storing a snippet. MVP does not scrape Google reviews.

## Equipment

**products** — name, category, level_min, level_max, playing_style, budget_band, age_band, specs jsonb, pros, considerations, price_cents nullable, currency, retailer_name, retailer_url, updated_on, sponsored boolean

Editorial copy never gives injury or medical advice. The guide says a shop or coach should check grip size and shoes if the player has pain.

## Partners and safety

**connection_requests** — from_user_id, to_user_id, status: pending | accepted | declined | cancelled, created_at

**conversations** — id, request_id, created_at

**conversation_members** — conversation_id, user_id

**messages** — id, conversation_id, sender_id, body, created_at

**blocks** — blocker_id, blocked_id

**reports** — id, reporter_id, target_type, target_id, reason, note, status: open | closed, created_at

Blocked pairs are excluded from search and cannot message.

## Billing and admin

**entitlements** — user_id, plan: free | premium, source, expires_at, updated_at

**admin_users** — user_id, role: editor | admin

**audit_log** — actor_id, action, entity, entity_id, at, diff jsonb

## Search

MVP uses Postgres full text on lessons, techniques, drills, glossary, courts, coaches, and stores. One SQL function `search_all(query, near_point)` returns typed hits. Player hits go through the partner service so coarse-location rules apply.

## Indexes

- GiST on every geography column
- Unique slugs on lessons, techniques, drills
- (user_id, completed_at) on progress tables
- Partial index on discoverable profiles where deleted_at is null
