import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const migrationsDir = join(root, 'db/migrations');
const init = readFileSync(join(migrationsDir, '001_init.sql'), 'utf8');
const seed = readFileSync(join(migrationsDir, '002_seed_reference.sql'), 'utf8');

const tables = [
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
  'audit_log',
];

const constraints = [
  'users_birth_year_chk',
  'users_status_chk',
  'users_deleted_chk',
  'auth_identities_provider_chk',
  'player_profiles_level_chk',
  'player_profiles_format_chk',
  'player_profiles_days_chk',
  'player_profiles_setting_chk',
  'player_profiles_radius_chk',
  'player_profiles_discoverable_deleted_chk',
  'player_profiles_deleted_cell_chk',
  'lessons_status_chk',
  'videos_playback_chk',
  'videos_license_chk',
  'videos_published_metadata_chk',
  'videos_owned_playback_license_chk',
  'drills_status_chk',
  'training_plans_days_chk',
  'courts_access_chk',
  'courts_source_chk',
  'favorites_place_type_chk',
  'connection_requests_distinct_chk',
  'blocks_distinct_chk',
  'reports_target_type_chk',
  'entitlements_plan_chk',
  'products_price_chk',
];

test('E2E-DB migrations declare 45 tables and the privacy constraints', () => {
  assert.deepEqual(readdirSync(migrationsDir).sort(), ['001_init.sql', '002_seed_reference.sql']);
  const declared = [...init.matchAll(/^CREATE TABLE (\w+)/gm)].map((match) => match[1]);
  assert.deepEqual(declared, tables);
  assert.match(init, /CREATE EXTENSION IF NOT EXISTS postgis/);
  assert.match(init, /location_cell geography\(Point, 4326\)/);
  assert.match(init, /search_radius_km numeric\(5, 1\)/);
  assert.match(init, /Responses expose a distance band, never this coordinate/);
  assert.match(init, /Player search is not in search_all/);
  assert.match(init, /CREATE INDEX player_profiles_location_cell_gist/);
  assert.match(init, /CREATE UNIQUE INDEX users_email_active_unique/);
  for (const name of constraints) {
    assert.match(init, new RegExp(`CONSTRAINT ${name}\\b`), name);
  }
  assert.equal(init.includes('player_profiles.latitude'), false);
  assert.equal(/\blatitude\b/.test(init.split('CREATE TABLE player_profiles')[1]?.split('CREATE TABLE')[0] ?? ''), false);
});

test('E2E-DB seed loads five levels, badges, and sample courts', () => {
  for (const name of [
    'Complete Beginner',
    'Beginner',
    'Advanced Beginner',
    'Intermediate',
    'Advanced',
  ]) {
    assert.match(seed, new RegExp(name));
  }
  for (const code of [
    'first_rally',
    'first_100_serves',
    'forehand_fundamentals',
    'backhand_beginner',
    'first_match',
    'ten_hour',
    'thirty_day_streak',
  ]) {
    assert.match(seed, new RegExp(`'${code}'`));
  }
  for (const court of [
    'South Austin Tennis Center',
    'Little Stacy Neighborhood Park',
    'Ramsey Park',
  ]) {
    assert.match(seed, new RegExp(court));
  }
  assert.match(seed, /not a live directory listing/);
  assert.equal((seed.match(/'admin'/g) ?? []).length, 3);
  assert.equal(seed.includes('private'), false);
});
