-- Reference data for a local Baseline database.
-- Levels match the in-repo catalog names. Badge copy is original.
-- Courts are sample admin rows for the Austin launch city, not a live directory.
-- Coordinates are approximate. source is admin. osm_id is left null.

BEGIN;

INSERT INTO levels (id, name, summary, sort_order) VALUES
  (1, 'Complete Beginner', 'First time on a court: gear, rules, grips, and the first swings.', 1),
  (2, 'Beginner', 'Build a rally you can repeat: strokes, footwork, and simple patterns.', 2),
  (3, 'Advanced Beginner', 'Consistency, placement, spin, and building a point.', 3),
  (4, 'Intermediate', 'Patterns, serve plus one, and match decisions.', 4),
  (5, 'Advanced', 'Biomechanics, scouting, and tournament preparation.', 5);

INSERT INTO badges (id, code, name, description) VALUES
  (
    'b1000000-0000-4000-8000-000000000001',
    'first_rally',
    'First rally',
    'Keep a rally going, or finish a rally lesson.'
  ),
  (
    'b1000000-0000-4000-8000-000000000002',
    'first_100_serves',
    'First 100 serves',
    'Log 100 serve repetitions.'
  ),
  (
    'b1000000-0000-4000-8000-000000000003',
    'forehand_fundamentals',
    'Forehand fundamentals',
    'Finish the beginner forehand lesson.'
  ),
  (
    'b1000000-0000-4000-8000-000000000004',
    'backhand_beginner',
    'Backhand beginner',
    'Finish the beginner backhand lesson.'
  ),
  (
    'b1000000-0000-4000-8000-000000000005',
    'first_match',
    'First match',
    'Save your first match log.'
  ),
  (
    'b1000000-0000-4000-8000-000000000006',
    'ten_hour',
    'Ten hours',
    'Practice for ten hours in total.'
  ),
  (
    'b1000000-0000-4000-8000-000000000007',
    'thirty_day_streak',
    '30-day streak',
    'Practice on 30 different days.'
  );

-- Launch city: Austin, Texas. Three public courts. Fees and hours are omitted
-- so this file does not pretend to be a current city schedule.
INSERT INTO courts (
  id,
  name,
  court_count,
  indoor,
  access,
  lights,
  surface,
  address,
  location,
  status,
  source,
  notes
) VALUES
  (
    'c1000000-0000-4000-8000-000000000001',
    'South Austin Tennis Center',
    10,
    false,
    'public',
    true,
    'hard',
    '1000 Cumberland Rd, Austin, TX 78704',
    ST_SetSRID(ST_MakePoint(-97.7674, 30.2416), 4326)::geography,
    'active',
    'admin',
    'Sample data for the Austin launch city. Coordinates are approximate and this row is not a live directory listing.'
  ),
  (
    'c1000000-0000-4000-8000-000000000002',
    'Little Stacy Neighborhood Park',
    2,
    false,
    'public',
    true,
    'hard',
    '1500 Alameda Dr, Austin, TX 78704',
    ST_SetSRID(ST_MakePoint(-97.7439, 30.2468), 4326)::geography,
    'active',
    'admin',
    'Sample data for the Austin launch city. Coordinates are approximate and this row is not a live directory listing.'
  ),
  (
    'c1000000-0000-4000-8000-000000000003',
    'Ramsey Park',
    2,
    false,
    'public',
    true,
    'hard',
    '4301 Rosedale Ave, Austin, TX 78756',
    ST_SetSRID(ST_MakePoint(-97.7435, 30.3133), 4326)::geography,
    'active',
    'admin',
    'Sample data for the Austin launch city. Coordinates are approximate and this row is not a live directory listing.'
  );

COMMIT;
