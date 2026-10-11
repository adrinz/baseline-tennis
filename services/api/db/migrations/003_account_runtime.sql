-- Live account snapshot for the API process on this Mac.
-- The normalized user tables are filled from this snapshot when ids are UUIDs.
-- NTRP is the player's own estimate, stored beside the profile.

CREATE TABLE account_runtime (
  id integer PRIMARY KEY DEFAULT 1,
  state jsonb NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT account_runtime_singleton_chk CHECK (id = 1)
);

ALTER TABLE player_profiles
  ADD COLUMN ntrp_code text;

COMMENT ON COLUMN player_profiles.ntrp_code IS
  'Player estimate. An NTRP value such as 3.5, or rough:<id> when only a band was chosen.';
