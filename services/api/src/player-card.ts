import { ageBand } from './age.ts';
import { ApiError } from './errors.ts';
import { distanceBand } from './geo.ts';

export type PlayerCard = {
  id: string;
  displayName: string;
  level: number;
  levelLabel: string;
  format: 'singles' | 'doubles' | 'both' | null;
  city: string | null;
  distanceBand: string;
  goals: string[];
  availabilitySummary: string | null;
  ageBand?: string;
};

export type PlayerCardSource = {
  id: string;
  displayName: string;
  level: number;
  levelLabel: string;
  format: 'singles' | 'doubles' | 'both' | null;
  city: string | null;
  primaryGoal: string | null;
  focusSkills: string[];
  availability: unknown;
  showAgeBand: boolean;
  birthYear: number;
  /** Stored on the profile. The card must not copy this. */
  locationCell?: { lat: number; lng: number } | null;
  email?: string;
};

export function collectKeys(value: unknown, keys = new Set<string>()): Set<string> {
  if (Array.isArray(value)) {
    for (const item of value) collectKeys(item, keys);
    return keys;
  }
  if (value && typeof value === 'object') {
    for (const [key, child] of Object.entries(value as Record<string, unknown>)) {
      keys.add(key);
      collectKeys(child, keys);
    }
  }
  return keys;
}

const PRIVATE_PLAYER_KEYS = [
  'lat',
  'lng',
  'latitude',
  'longitude',
  'location',
  'locationCell',
  'email',
  'birthYear',
  'birth_year',
];

/**
 * Discovery card. The only location field is `distanceBand`.
 * Coordinates, email, and birth year are not copied onto the card.
 */
export function toPlayerCard(source: PlayerCardSource, distanceKm: number | null, now = new Date()): PlayerCard {
  const goals = [source.primaryGoal, ...source.focusSkills].filter((goal): goal is string => Boolean(goal));
  const card: PlayerCard = {
    id: source.id,
    displayName: source.displayName,
    level: source.level,
    levelLabel: source.levelLabel,
    format: source.format,
    city: source.city,
    distanceBand: distanceKm == null ? 'area not shared' : distanceBand(distanceKm),
    goals: [...new Set(goals)],
    availabilitySummary: availabilitySummary(source.availability),
  };
  if (source.showAgeBand) card.ageBand = ageBand(source.birthYear, now);
  return card;
}

export function assertCoarsePlayerPayload(value: unknown): void {
  const keys = collectKeys(value);
  for (const key of PRIVATE_PLAYER_KEYS) {
    if (keys.has(key)) {
      throw new ApiError(500, 'internal', 'Player results could not be shown.');
    }
  }
}

function availabilitySummary(availability: unknown): string | null {
  if (!availability || typeof availability !== 'object') return null;
  const summary = (availability as { summary?: unknown }).summary;
  return typeof summary === 'string' && summary.trim().length > 0 ? summary.trim() : null;
}
