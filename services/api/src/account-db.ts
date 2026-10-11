import pg from 'pg';

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

type StoredUser = {
  id: string;
  email: string;
  birthYear: number;
  status: 'active' | 'suspended' | 'deleted';
  entitlement: 'free' | 'premium';
  createdAt: string;
  deletedAt: string | null;
};

type StoredProfile = {
  userId: string;
  displayName: string;
  level: number;
  playedBefore: boolean | null;
  playFrequency: string | null;
  primaryGoal: string | null;
  format: 'singles' | 'doubles' | 'both' | null;
  daysPerWeek: number | null;
  focusSkills: string[];
  setting: 'indoor' | 'outdoor' | 'either' | null;
  discoverable: boolean;
  bio: string | null;
  homeCity: string | null;
  homeRegion: string | null;
  countryCode: string | null;
  searchRadiusKm: number;
  showAgeBand: boolean;
  ntrpCode?: string | null;
};

type StoredNotifications = [
  string,
  {
    practiceReminders: boolean;
    planReminders: boolean;
    lessonTips: boolean;
    weeklyProgress: boolean;
    partnerRequests: boolean;
    messages: boolean;
    milestones: boolean;
  },
];

type StoredStreak = [string, { currentCount: number; longestCount: number; lastActiveOn: string | null }];

type StoredRefresh = [string, { userId: string; expiresAt: number; revoked: boolean }];

export async function loadAccountState(pool: pg.Pool): Promise<Record<string, unknown> | null> {
  const result = await pool.query<{ state: Record<string, unknown> }>(
    'SELECT state FROM account_runtime WHERE id = 1',
  );
  return result.rows[0]?.state ?? null;
}

export async function saveAccountState(pool: pg.Pool, state: Record<string, unknown>): Promise<void> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(
      `INSERT INTO account_runtime (id, state, updated_at)
       VALUES (1, $1::jsonb, now())
       ON CONFLICT (id) DO UPDATE SET state = EXCLUDED.state, updated_at = now()`,
      [JSON.stringify(state)],
    );
    await projectUsers(client, state);
    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function projectUsers(client: pg.PoolClient, state: Record<string, unknown>): Promise<void> {
  const users = arrayOf<StoredUser>(state.users).filter((user) => UUID.test(user.id));
  const ids = users.map((user) => user.id);
  if (ids.length === 0) return;
  await client.query('DELETE FROM users WHERE NOT (id = ANY($1::uuid[]))', [ids]);
  const profiles = new Map(arrayOf<StoredProfile>(state.profiles).map((profile) => [profile.userId, profile]));
  const notifications = new Map(arrayOf<StoredNotifications>(state.notifications));
  const streaks = new Map(arrayOf<StoredStreak>(state.streaks));
  for (const user of users) {
    await client.query(
      `INSERT INTO users (id, email, birth_year, status, created_at, deleted_at)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (id) DO UPDATE
         SET email = EXCLUDED.email,
             birth_year = EXCLUDED.birth_year,
             status = EXCLUDED.status,
             deleted_at = EXCLUDED.deleted_at`,
      [
        user.id,
        user.email || null,
        user.birthYear,
        user.status,
        user.createdAt,
        user.deletedAt,
      ],
    );
    await client.query(
      `INSERT INTO entitlements (user_id, plan, source, updated_at)
       VALUES ($1, $2, 'local', now())
       ON CONFLICT (user_id) DO UPDATE SET plan = EXCLUDED.plan, updated_at = now()`,
      [user.id, user.entitlement],
    );
    const profile = profiles.get(user.id);
    if (profile && profile.level >= 1 && profile.level <= 5) {
      const days = profile.daysPerWeek === 2 || profile.daysPerWeek === 3 || profile.daysPerWeek === 4 || profile.daysPerWeek === 5
        ? profile.daysPerWeek
        : null;
      await client.query(
        `INSERT INTO player_profiles (
           user_id, display_name, level, played_before, play_frequency, primary_goal, format,
           days_per_week, focus_skills, setting, discoverable, bio, home_city, home_region,
           country_code, search_radius_km, show_age_band, ntrp_code
         )
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
         ON CONFLICT (user_id) DO UPDATE SET
           display_name = EXCLUDED.display_name,
           level = EXCLUDED.level,
           played_before = EXCLUDED.played_before,
           play_frequency = EXCLUDED.play_frequency,
           primary_goal = EXCLUDED.primary_goal,
           format = EXCLUDED.format,
           days_per_week = EXCLUDED.days_per_week,
           focus_skills = EXCLUDED.focus_skills,
           setting = EXCLUDED.setting,
           discoverable = EXCLUDED.discoverable,
           bio = EXCLUDED.bio,
           home_city = EXCLUDED.home_city,
           home_region = EXCLUDED.home_region,
           country_code = EXCLUDED.country_code,
           search_radius_km = EXCLUDED.search_radius_km,
           show_age_band = EXCLUDED.show_age_band,
           ntrp_code = EXCLUDED.ntrp_code`,
        [
          user.id,
          profile.displayName,
          profile.level,
          profile.playedBefore,
          profile.playFrequency,
          profile.primaryGoal,
          profile.format,
          days,
          profile.focusSkills,
          profile.setting,
          profile.discoverable && user.status !== 'deleted',
          profile.bio,
          profile.homeCity,
          profile.homeRegion,
          profile.countryCode,
          profile.searchRadiusKm,
          profile.showAgeBand,
          profile.ntrpCode ?? null,
        ],
      );
    }
    const notes = notifications.get(user.id);
    if (notes) {
      await client.query(
        `INSERT INTO notification_preferences (
           user_id, practice_reminders, plan_reminders, lesson_tips, weekly_progress,
           partner_requests, messages, milestones
         )
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
         ON CONFLICT (user_id) DO UPDATE SET
           practice_reminders = EXCLUDED.practice_reminders,
           plan_reminders = EXCLUDED.plan_reminders,
           lesson_tips = EXCLUDED.lesson_tips,
           weekly_progress = EXCLUDED.weekly_progress,
           partner_requests = EXCLUDED.partner_requests,
           messages = EXCLUDED.messages,
           milestones = EXCLUDED.milestones`,
        [
          user.id,
          notes.practiceReminders,
          notes.planReminders,
          notes.lessonTips,
          notes.weeklyProgress,
          notes.partnerRequests,
          notes.messages,
          notes.milestones,
        ],
      );
    }
    const streak = streaks.get(user.id);
    if (streak) {
      await client.query(
        `INSERT INTO streaks (user_id, current_count, longest_count, last_active_on)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (user_id) DO UPDATE SET
           current_count = EXCLUDED.current_count,
           longest_count = EXCLUDED.longest_count,
           last_active_on = EXCLUDED.last_active_on`,
        [user.id, streak.currentCount, streak.longestCount, streak.lastActiveOn],
      );
    }
  }
  const refreshes = arrayOf<StoredRefresh>(state.refreshTokens).filter((entry) => UUID.test(entry[1].userId));
  await client.query('DELETE FROM sessions WHERE user_id = ANY($1::uuid[])', [ids]);
  for (const [tokenHash, session] of refreshes) {
    if (!ids.includes(session.userId)) continue;
    await client.query(
      `INSERT INTO sessions (user_id, refresh_token_hash, expires_at, revoked_at)
       VALUES ($1, $2, to_timestamp($3 / 1000.0), $4)`,
      [session.userId, tokenHash, session.expiresAt, session.revoked ? new Date().toISOString() : null],
    );
  }
}

function arrayOf<T>(value: unknown): T[] {
  return Array.isArray(value) ? (value as T[]) : [];
}
