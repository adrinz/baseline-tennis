import { randomUUID } from 'node:crypto';
import { canCreateAccount, canUsePartnerFeatures } from './age.ts';
import { glossarySlug, type Catalog, type CatalogDrill, type CatalogLesson } from './catalog.ts';
import { answerCoachQuestion, type UnfinishedLesson } from './coach/engine.ts';
import { PRODUCTS, type ProductSuggestion } from './content/equipment.ts';
import {
  COACHES,
  COURTS,
  SEED_PLAYERS,
  STORES,
  type CoachRecord,
  type CourtRecord,
  type SeedPlayer,
  type StoreRecord,
} from './content/places.ts';
import { RULES_ARTICLES, type RulesArticle } from './content/rules.ts';
import { ApiError, notFound } from './errors.ts';
import { coarseCell, haversineKm } from './geo.ts';
import { addDays, buildWeekItems, weekStartMonday, type PlanItemDraft } from './plans.ts';
import type { VideoRecord } from './media/publish.ts';
import { toPlayerCard, type PlayerCard } from './player-card.ts';
import { hashToken, newToken, tokensMatch } from './tokens.ts';

const DEV_EMAIL_CODE = '000000';
const DEV_CODE_HASH = hashToken(DEV_EMAIL_CODE);
const ACCESS_TTL_MS = 15 * 60 * 1000;
const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000;
const CODE_TTL_MS = 10 * 60 * 1000;

const DRILL_TECHNIQUE: Record<string, string> = {
  'wall-rally': 'forehand',
  'forehand-consistency': 'forehand',
  'split-step': 'footwork',
  'serve-target': 'serve',
};

export type Entitlement = 'free' | 'premium';

export type User = {
  id: string;
  email: string;
  birthYear: number;
  status: 'active' | 'suspended' | 'deleted';
  entitlement: Entitlement;
  createdAt: string;
  deletedAt: string | null;
};

type Profile = {
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
  availability: unknown;
  bio: string | null;
  homeCity: string | null;
  homeRegion: string | null;
  countryCode: string | null;
  locationCell: { lat: number; lng: number } | null;
  searchRadiusKm: number;
  showAgeBand: boolean;
};

type Notifications = {
  practiceReminders: boolean;
  planReminders: boolean;
  lessonTips: boolean;
  weeklyProgress: boolean;
  partnerRequests: boolean;
  messages: boolean;
  milestones: boolean;
};

type Streak = {
  currentCount: number;
  longestCount: number;
  lastActiveOn: string | null;
};

type TokenSession = {
  userId: string;
  expiresAt: number;
  revoked: boolean;
};

type LessonProgress = {
  userId: string;
  slug: string;
  status: 'started' | 'completed';
  updatedAt: string;
  completedAt: string | null;
};

type PlanItem = PlanItemDraft & { completedAt: string | null };

type Plan = {
  id: string;
  userId: string;
  weekStart: string;
  daysPerWeek: number;
  goal: string;
  status: 'active';
  items: PlanItem[];
};

type PracticeSession = {
  id: string;
  userId: string;
  startedAt: string;
  minutes: number;
  planItemId: string | null;
};

type DrillCompletion = {
  id: string;
  userId: string;
  drillSlug: string;
  completedAt: string;
  minutes: number;
};

type Goal = {
  id: string;
  userId: string;
  kind: 'primary';
  title: string;
  target: number;
  progress: number;
  status: 'active';
};

type Connection = {
  id: string;
  fromUserId: string;
  toUserId: string;
  status: 'pending' | 'accepted' | 'declined' | 'cancelled';
  createdAt: string;
};

type Conversation = {
  id: string;
  requestId: string;
  memberIds: [string, string];
  createdAt: string;
};

type Message = {
  id: string;
  conversationId: string;
  senderId: string;
  body: string;
  createdAt: string;
};

type Block = {
  blockerId: string;
  blockedId: string;
  createdAt: string;
};

type Report = {
  id: string;
  reporterId: string;
  targetType: 'user' | 'message';
  targetId: string;
  reason: string;
  note: string | null;
  status: 'open';
  messageSnapshotId: string | null;
  createdAt: string;
};

type Favorite = {
  id: string;
  userId: string;
  placeType: 'court' | 'coach' | 'store';
  placeId: string;
  createdAt: string;
};

export type NearQuery = {
  lat?: number;
  lng?: number;
  radiusKm?: number;
  city?: string;
};

export type OnboardingInput = {
  playedBefore: boolean;
  level: number;
  playFrequency: string;
  primaryGoal: string;
  format: 'singles' | 'doubles' | 'both';
  daysPerWeek: number;
  focusSkills: string[];
  homeCity?: string;
  setting: 'indoor' | 'outdoor' | 'either';
  availability?: unknown;
  displayName?: string;
};

export type ProfilePatch = {
  displayName?: string;
  level?: number;
  playedBefore?: boolean;
  playFrequency?: string;
  primaryGoal?: string;
  format?: 'singles' | 'doubles' | 'both';
  daysPerWeek?: number;
  focusSkills?: string[];
  setting?: 'indoor' | 'outdoor' | 'either';
  discoverable?: boolean;
  availability?: unknown;
  bio?: string;
  homeCity?: string;
  homeRegion?: string;
  countryCode?: string;
  searchRadiusKm?: number;
  showAgeBand?: boolean;
  latitude?: number;
  longitude?: number;
};

type TechniqueRecord = {
  slug: string;
  name: string;
  family: string;
  levelMin: number;
  overview: string;
  whyItMatters: string;
  lessonSlugs: string[];
  status: 'published';
};

function defaultNotifications(): Notifications {
  return {
    practiceReminders: true,
    planReminders: false,
    lessonTips: false,
    weeklyProgress: false,
    partnerRequests: true,
    messages: true,
    milestones: false,
  };
}

function techniqueFamily(slug: string): string {
  const families: Record<string, string> = {
    'ready-position': 'ready',
    grip: 'grip',
    forehand: 'groundstroke',
    backhand: 'groundstroke',
    slice: 'groundstroke',
    topspin: 'groundstroke',
    'one-handed-backhand': 'groundstroke',
    'contact-point': 'groundstroke',
    rally: 'rally',
    serve: 'serve',
    'second-serve': 'serve',
    return: 'return',
    volley: 'net',
    smash: 'net',
    footwork: 'footwork',
    'split-step': 'footwork',
    recovery: 'footwork',
    drop: 'specialty',
    lob: 'specialty',
    approach: 'specialty',
    'passing-shot': 'specialty',
  };
  return families[slug] ?? 'specialty';
}

function techniqueName(slug: string): string {
  const names: Record<string, string> = {
    rally: 'Rallying fundamentals',
    'ready-position': 'Ready position',
    'contact-point': 'Contact point',
    'one-handed-backhand': 'One-handed backhand',
    return: 'Return of serve',
    smash: 'Overhead smash',
    recovery: 'Court recovery',
    drop: 'Drop shot',
    approach: 'Approach shot',
    'passing-shot': 'Passing shot',
    'second-serve': 'Second serve',
  };
  const named = names[slug];
  if (named) return named;
  return slug
    .split('-')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

function nameFromEmail(email: string): string {
  const local = email.split('@')[0] ?? 'player';
  const cleaned = local.replace(/[._]+/g, ' ').trim();
  return cleaned.slice(0, 40) || 'Player';
}

export class MemoryRepository {
  readonly catalog: Catalog;
  private readonly users = new Map<string, User>();
  private readonly usersByEmail = new Map<string, string>();
  private readonly profiles = new Map<string, Profile>();
  private readonly notifications = new Map<string, Notifications>();
  private readonly streaks = new Map<string, Streak>();
  private readonly accessTokens = new Map<string, TokenSession>();
  private readonly refreshTokens = new Map<string, TokenSession>();
  private readonly pendingCodes = new Map<string, { codeHash: string; expiresAt: number }>();
  private readonly lessonProgress = new Map<string, LessonProgress>();
  private readonly plans = new Map<string, Plan>();
  private readonly practiceSessions: PracticeSession[] = [];
  private readonly drillCompletions: DrillCompletion[] = [];
  private readonly goals: Goal[] = [];
  private readonly connections: Connection[] = [];
  private readonly conversations: Conversation[] = [];
  private readonly messages: Message[] = [];
  private readonly blocks: Block[] = [];
  private readonly reports: Report[] = [];
  private readonly favorites: Favorite[] = [];
  private readonly courts: CourtRecord[];
  private readonly coaches: CoachRecord[];
  private readonly stores: StoreRecord[];
  private readonly products: ProductSuggestion[];
  private readonly articles: RulesArticle[];

  constructor(catalog: Catalog) {
    this.catalog = catalog;
    this.courts = COURTS.map((court) => ({ ...court }));
    this.coaches = COACHES.map((coach) => ({ ...coach }));
    this.stores = STORES.map((store) => ({ ...store }));
    this.products = PRODUCTS.map((product) => ({ ...product }));
    this.articles = RULES_ARTICLES.map((article) => ({
      ...article,
      body: { sections: article.body.sections.map((section) => ({ ...section, paragraphs: [...section.paragraphs] })) },
    }));
    for (const seed of SEED_PLAYERS) this.insertSeedPlayer(seed);
  }

  startEmail(email: string): { ok: true; delivery: 'dev'; expiresIn: number } {
    this.pendingCodes.set(email, { codeHash: DEV_CODE_HASH, expiresAt: Date.now() + CODE_TTL_MS });
    return { ok: true, delivery: 'dev', expiresIn: CODE_TTL_MS / 1000 };
  }

  finishEmail(input: {
    email: string;
    code: string;
    birthYear?: number;
    displayName?: string;
  }): {
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
    user: { id: string; email: string; birthYear: number; status: User['status']; entitlement: Entitlement };
  } {
    const pending = this.pendingCodes.get(input.email);
    if (!pending || pending.expiresAt <= Date.now()) {
      throw new ApiError(401, 'unauthorized', 'Request a code first.');
    }
    if (!tokensMatch(hashToken(input.code), pending.codeHash)) {
      throw new ApiError(401, 'unauthorized', 'That code is not valid.');
    }

    const existingId = this.usersByEmail.get(input.email);
    if (existingId) {
      const existing = this.users.get(existingId)!;
      if (existing.status === 'deleted') {
        throw new ApiError(403, 'forbidden', 'This account was deleted and cannot be reactivated.');
      }
      if (existing.status === 'suspended') {
        throw new ApiError(403, 'forbidden', 'This account is suspended.');
      }
      this.pendingCodes.delete(input.email);
      return this.issueSession(existing);
    }

    if (input.birthYear == null) {
      throw new ApiError(400, 'validation', 'Birth year is required to create an account.');
    }
    if (!canCreateAccount(input.birthYear)) {
      throw new ApiError(403, 'forbidden', 'Baseline is for players 16 and older.');
    }

    const user = this.createUser({
      email: input.email,
      birthYear: input.birthYear,
      displayName: input.displayName?.trim() || nameFromEmail(input.email),
    });
    this.pendingCodes.delete(input.email);
    return this.issueSession(user);
  }

  refresh(refreshToken: string): ReturnType<MemoryRepository['issueSession']> {
    const session = this.refreshTokens.get(hashToken(refreshToken));
    const user = session ? this.users.get(session.userId) : undefined;
    if (!session || session.revoked || session.expiresAt <= Date.now() || !user || user.status !== 'active') {
      throw new ApiError(401, 'unauthorized', 'That refresh token is no longer valid.');
    }
    session.revoked = true;
    return this.issueSession(user);
  }

  logout(refreshToken: string): void {
    const session = this.refreshTokens.get(hashToken(refreshToken));
    if (!session || session.revoked) {
      throw new ApiError(401, 'unauthorized', 'That refresh token is no longer valid.');
    }
    session.revoked = true;
  }

  authenticate(authorization: string | undefined, devPremium: boolean): User | null {
    if (!authorization?.startsWith('Bearer ')) return null;
    const token = authorization.slice('Bearer '.length).trim();
    if (!token) return null;
    const session = this.accessTokens.get(hashToken(token));
    if (!session || session.revoked || session.expiresAt <= Date.now()) return null;
    const user = this.users.get(session.userId);
    if (!user || user.status !== 'active') return null;
    if (devPremium && user.entitlement !== 'premium') user.entitlement = 'premium';
    return user;
  }

  getMe(userId: string) {
    const user = this.requireActive(userId);
    return this.mePayload(user);
  }

  updateProfile(userId: string, patch: ProfilePatch) {
    const user = this.requireActive(userId);
    const profile = this.profiles.get(userId)!;
    if (patch.discoverable === true && !canUsePartnerFeatures(user.birthYear)) {
      throw new ApiError(403, 'forbidden', 'Players under 18 cannot turn on discovery.');
    }
    const nextCell =
      patch.latitude != null && patch.longitude != null
        ? coarseCell(patch.latitude, patch.longitude)
        : profile.locationCell;
    if (patch.discoverable === true) {
      const city = patch.homeCity ?? profile.homeCity;
      if (!city && !nextCell) {
        throw new ApiError(400, 'validation', 'Add a city or a coarse area before discovery.');
      }
    }
    if (patch.displayName != null) profile.displayName = patch.displayName;
    if (patch.level != null) profile.level = patch.level;
    if (patch.playedBefore != null) profile.playedBefore = patch.playedBefore;
    if (patch.playFrequency != null) profile.playFrequency = patch.playFrequency;
    if (patch.primaryGoal != null) profile.primaryGoal = patch.primaryGoal;
    if (patch.format != null) profile.format = patch.format;
    if (patch.daysPerWeek != null) profile.daysPerWeek = patch.daysPerWeek;
    if (patch.focusSkills != null) profile.focusSkills = patch.focusSkills;
    if (patch.setting != null) profile.setting = patch.setting;
    if (patch.discoverable != null) profile.discoverable = patch.discoverable;
    if (patch.availability !== undefined) profile.availability = patch.availability;
    if (patch.bio != null) profile.bio = patch.bio;
    if (patch.homeCity != null) profile.homeCity = patch.homeCity;
    if (patch.homeRegion != null) profile.homeRegion = patch.homeRegion;
    if (patch.countryCode != null) profile.countryCode = patch.countryCode.toUpperCase();
    if (patch.searchRadiusKm != null) profile.searchRadiusKm = patch.searchRadiusKm;
    if (patch.showAgeBand != null) profile.showAgeBand = patch.showAgeBand;
    if (patch.latitude != null && patch.longitude != null) profile.locationCell = nextCell;
    return this.mePayload(user);
  }

  onboard(userId: string, input: OnboardingInput) {
    const user = this.requireActive(userId);
    const profile = this.profiles.get(userId)!;
    profile.playedBefore = input.playedBefore;
    profile.level = input.level;
    profile.playFrequency = input.playFrequency;
    profile.primaryGoal = input.primaryGoal;
    profile.format = input.format;
    profile.daysPerWeek = input.daysPerWeek;
    profile.focusSkills = input.focusSkills;
    profile.setting = input.setting;
    if (input.homeCity) profile.homeCity = input.homeCity;
    if (input.availability !== undefined) profile.availability = input.availability;
    if (input.displayName) profile.displayName = input.displayName;

    const goal: Goal = {
      id: randomUUID(),
      userId,
      kind: 'primary',
      title: input.primaryGoal,
      target: input.daysPerWeek,
      progress: 0,
      status: 'active',
    };
    for (let index = this.goals.length - 1; index >= 0; index -= 1) {
      if (this.goals[index]?.userId === userId) this.goals.splice(index, 1);
    }
    this.goals.push(goal);
    const plan = this.makePlan(userId, profile);
    this.plans.set(userId, plan);
    return {
      profile: this.publicProfile(profile),
      plan: this.publicPlan(plan),
      goal,
    };
  }

  updateNotifications(userId: string, patch: Partial<Notifications>) {
    this.requireActive(userId);
    const current = this.notifications.get(userId)!;
    Object.assign(current, patch);
    return current;
  }

  exportData(userId: string) {
    const me = this.getMe(userId);
    return {
      profile: me.profile,
      progress: this.progress(userId),
      messagesSent: this.messages
        .filter((message) => message.senderId === userId)
        .map((message) => ({
          id: message.id,
          conversationId: message.conversationId,
          body: message.body,
          createdAt: message.createdAt,
        })),
      favorites: this.favorites
        .filter((favorite) => favorite.userId === userId)
        .map((favorite) => ({
          id: favorite.id,
          placeType: favorite.placeType,
          placeId: favorite.placeId,
          createdAt: favorite.createdAt,
        })),
    };
  }

  deleteAccount(userId: string): void {
    const user = this.requireActive(userId);
    user.status = 'deleted';
    user.deletedAt = new Date().toISOString();
    const profile = this.profiles.get(userId);
    if (profile) {
      profile.displayName = 'Deleted player';
      profile.discoverable = false;
      profile.locationCell = null;
      profile.bio = null;
      profile.homeCity = null;
      profile.homeRegion = null;
      profile.availability = null;
      profile.focusSkills = [];
    }
    for (let index = this.favorites.length - 1; index >= 0; index -= 1) {
      if (this.favorites[index]?.userId === userId) this.favorites.splice(index, 1);
    }
    for (let index = this.messages.length - 1; index >= 0; index -= 1) {
      if (this.messages[index]?.senderId === userId) this.messages.splice(index, 1);
    }
    for (const progress of this.lessonProgress.values()) {
      if (progress.userId === userId) progress.userId = '';
    }
    for (const session of this.accessTokens.values()) {
      if (session.userId === userId) session.revoked = true;
    }
    for (const session of this.refreshTokens.values()) {
      if (session.userId === userId) session.revoked = true;
    }
  }

  levels(userId: string) {
    this.requireActive(userId);
    const completed = this.completedLessonSlugs(userId);
    return {
      levels: this.catalog.levels.map((level) => {
        const lessons = this.catalog.lessons.filter((lesson) => lesson.level === level.id);
        return {
          id: level.id,
          name: level.name,
          summary: level.summary,
          lessonCount: lessons.length,
          completedCount: lessons.filter((lesson) => completed.has(lesson.slug)).length,
        };
      }),
    };
  }

  lessons(userId: string, filters: { level?: number; category?: string }) {
    const user = this.requireActive(userId);
    const lessons = this.catalog.lessons.filter((lesson) => {
      if (filters.level != null && lesson.level !== filters.level) return false;
      if (filters.category && lesson.category !== filters.category) return false;
      return true;
    });
    return {
      lessons: lessons.map((lesson) => ({
        slug: lesson.slug,
        title: lesson.title,
        summary: lesson.summary,
        level: lesson.level,
        category: lesson.category,
        technique: lesson.technique ?? null,
        estimatedMinutes: lesson.estimatedMinutes,
        freeTier: lesson.freeTier,
        locked: this.lessonLocked(user, lesson),
      })),
    };
  }

  lessonDetail(userId: string, slug: string) {
    const user = this.requireActive(userId);
    const lesson = this.catalog.lessons.find((item) => item.slug === slug);
    if (!lesson) throw notFound('Lesson not found');
    if (this.lessonLocked(user, lesson)) {
      throw new ApiError(403, 'premium_required', 'Premium is required to read this lesson.', {
        slug: lesson.slug,
        title: lesson.title,
        summary: lesson.summary,
        locked: true,
      });
    }
    const progress = this.lessonProgress.get(`${userId}:${slug}`);
    return {
      slug: lesson.slug,
      title: lesson.title,
      summary: lesson.summary,
      level: lesson.level,
      category: lesson.category,
      technique: lesson.technique ?? null,
      estimatedMinutes: lesson.estimatedMinutes,
      freeTier: lesson.freeTier,
      locked: false,
      blocks: lesson.blocks,
      checklist: lesson.blocks.filter((block) => block.kind === 'checklist').map((block) => block.body),
      drills: this.drillsForLesson(lesson),
      progress: progress ? { status: progress.status, completedAt: progress.completedAt } : null,
    };
  }

  setLessonProgress(userId: string, slug: string, status: 'started' | 'completed') {
    const user = this.requireActive(userId);
    const lesson = this.catalog.lessons.find((item) => item.slug === slug);
    if (!lesson) throw notFound('Lesson not found');
    if (this.lessonLocked(user, lesson)) {
      throw new ApiError(403, 'premium_required', 'Premium is required to read this lesson.', {
        slug: lesson.slug,
        title: lesson.title,
        summary: lesson.summary,
        locked: true,
      });
    }
    const key = `${userId}:${slug}`;
    const existing = this.lessonProgress.get(key);
    const now = new Date().toISOString();
    const alreadyCompleted = existing?.status === 'completed';
    const row: LessonProgress = {
      userId,
      slug,
      status: alreadyCompleted ? 'completed' : status,
      updatedAt: now,
      completedAt: status === 'completed' || alreadyCompleted ? (existing?.completedAt ?? now) : null,
    };
    this.lessonProgress.set(key, row);
    if (status === 'completed' && !alreadyCompleted) {
      this.practiceSessions.push({
        id: randomUUID(),
        userId,
        startedAt: now,
        minutes: lesson.estimatedMinutes,
        planItemId: null,
      });
      this.touchStreak(userId);
    }
    return { slug, status: row.status, completedAt: row.completedAt };
  }

  techniques(family?: string) {
    const records = this.techniqueRecords().filter((technique) => !family || technique.family === family);
    return { techniques: records };
  }

  technique(slug: string) {
    const record = this.techniqueRecords().find((technique) => technique.slug === slug);
    if (!record) throw notFound('Technique not found');
    const lessons = record.lessonSlugs
      .map((lessonSlug) => this.catalog.lessons.find((lesson) => lesson.slug === lessonSlug))
      .filter((lesson): lesson is CatalogLesson => Boolean(lesson));
    return {
      ...record,
      lessons: lessons.map((lesson) => ({
        slug: lesson.slug,
        title: lesson.title,
        summary: lesson.summary,
        level: lesson.level,
        freeTier: lesson.freeTier,
      })),
      blocks: lessons.flatMap((lesson) => lesson.blocks),
    };
  }

  glossary(query?: string) {
    const needle = query?.trim().toLowerCase() ?? '';
    const terms = this.catalog.glossary
      .filter((term) => {
        if (!needle) return true;
        return term.term.toLowerCase().includes(needle) || term.definition.toLowerCase().includes(needle);
      })
      .map((term) => ({
        slug: glossarySlug(term.term),
        term: term.term,
        definition: term.definition,
        levelMin: 1,
      }));
    return { terms };
  }

  rules() {
    return {
      articles: this.articles.map((article) => ({
        slug: article.slug,
        title: article.title,
        topic: article.topic,
        summary: article.summary,
      })),
    };
  }

  rule(slug: string) {
    const article = this.articles.find((item) => item.slug === slug);
    if (!article) throw notFound('Rules article not found');
    return article;
  }

  drills(userId: string, filters: { level?: number; technique?: string }) {
    const user = this.requireActive(userId);
    const drills = this.catalog.drills.filter((drill) => {
      if (filters.level != null && drill.levelMin > filters.level) return false;
      if (filters.technique && DRILL_TECHNIQUE[drill.slug] !== filters.technique) return false;
      return true;
    });
    return {
      drills: drills.map((drill) => ({
        slug: drill.slug,
        name: drill.name,
        levelMin: drill.levelMin,
        objective: drill.objective,
        equipment: drill.equipment,
        playersRequired: drill.playersRequired,
        durationMinutes: drill.durationMinutes,
        difficulty: drill.difficulty,
        freeTier: drill.freeTier,
        technique: DRILL_TECHNIQUE[drill.slug] ?? null,
        locked: this.drillLocked(user, drill),
      })),
    };
  }

  drillDetail(userId: string, slug: string) {
    const user = this.requireActive(userId);
    const drill = this.catalog.drills.find((item) => item.slug === slug);
    if (!drill) throw notFound('Drill not found');
    if (this.drillLocked(user, drill)) {
      throw new ApiError(403, 'premium_required', 'Premium is required to open this drill.', {
        slug: drill.slug,
        title: drill.name,
        summary: drill.objective,
        locked: true,
      });
    }
    return {
      ...this.drillCard(user, drill),
      locked: false,
      repetitions: drill.repetitions,
      instructions: drill.instructions,
      coachingTips: drill.coachingTips,
      commonMistakes: drill.commonMistakes,
    };
  }

  completeDrill(userId: string, slug: string, minutes?: number) {
    const user = this.requireActive(userId);
    const drill = this.catalog.drills.find((item) => item.slug === slug);
    if (!drill) throw notFound('Drill not found');
    if (this.drillLocked(user, drill)) {
      throw new ApiError(403, 'premium_required', 'Premium is required to open this drill.', {
        slug: drill.slug,
        title: drill.name,
        summary: drill.objective,
        locked: true,
      });
    }
    const completedAt = new Date().toISOString();
    const loggedMinutes = minutes ?? drill.durationMinutes;
    const completion: DrillCompletion = {
      id: randomUUID(),
      userId,
      drillSlug: slug,
      completedAt,
      minutes: loggedMinutes,
    };
    this.drillCompletions.push(completion);
    this.practiceSessions.push({
      id: randomUUID(),
      userId,
      startedAt: completedAt,
      minutes: loggedMinutes,
      planItemId: null,
    });
    this.touchStreak(userId);
    return completion;
  }

  currentPlan(userId: string) {
    this.requireActive(userId);
    const plan = this.plans.get(userId);
    if (!plan) throw notFound('Finish onboarding to build a week plan.');
    return this.publicPlan(plan);
  }

  rebuildPlan(userId: string) {
    const user = this.requireActive(userId);
    const profile = this.profiles.get(user.id)!;
    if (profile.daysPerWeek == null) {
      throw new ApiError(400, 'validation', 'Finish onboarding before rebuilding a plan.');
    }
    const plan = this.makePlan(userId, profile);
    this.plans.set(userId, plan);
    return this.publicPlan(plan);
  }

  completePlanItem(userId: string, itemId: string) {
    this.requireActive(userId);
    const plan = this.plans.get(userId);
    if (!plan) throw notFound('Finish onboarding to build a week plan.');
    const item = plan.items.find((candidate) => candidate.id === itemId);
    if (!item) throw notFound('Plan item not found');
    if (item.completedAt) throw new ApiError(409, 'conflict', 'That block is already complete.');
    item.completedAt = new Date().toISOString();
    this.practiceSessions.push({
      id: randomUUID(),
      userId,
      startedAt: item.completedAt,
      minutes: item.minutes,
      planItemId: item.id,
    });
    return { item: this.publicItem(item), streak: this.touchStreak(userId) };
  }

  progress(userId: string) {
    const user = this.requireActive(userId);
    const lessonRows = [...this.lessonProgress.values()].filter((row) => row.userId === userId);
    const drills = this.drillCompletions.filter((row) => row.userId === userId);
    const sessions = this.practiceSessions.filter((row) => row.userId === userId);
    return {
      entitlement: user.entitlement,
      lessonsCompleted: lessonRows.filter((row) => row.status === 'completed').length,
      lessonsStarted: lessonRows.filter((row) => row.status === 'started').length,
      drillsCompleted: drills.length,
      practiceMinutes: sessions.reduce((sum, session) => sum + session.minutes, 0),
      streak: this.streaks.get(userId)!,
      xp: this.xpFor(userId),
      weeks: this.weekMinutes(userId),
    };
  }

  askCoach(userId: string, question: string) {
    const user = this.requireActive(userId);
    if (user.entitlement !== 'premium') {
      throw new ApiError(403, 'premium_required', 'The rules coach is part of Baseline Premium.');
    }
    return answerCoachQuestion({
      question,
      rules: this.catalog.coachRules,
      knownDrillSlugs: new Set(this.catalog.drills.map((drill) => drill.slug)),
      unfinishedLesson: this.unfinishedLesson(userId),
    });
  }

  listCourts(filters: NearQuery & { indoor?: boolean; lights?: boolean; access?: string; surface?: string }) {
    let rows = this.courts.filter((court) => this.withinPlace(court, filters));
    if (filters.indoor != null) rows = rows.filter((court) => court.indoor === filters.indoor);
    if (filters.lights != null) rows = rows.filter((court) => court.lights === filters.lights);
    if (filters.access) rows = rows.filter((court) => court.access === filters.access);
    const surface = filters.surface;
    if (surface) rows = rows.filter((court) => court.surface.toLowerCase() === surface.toLowerCase());
    const courts = this.sortByDistance(rows, filters).map((court) => this.publicCourt(court, filters));
    return courts.length === 0 ? { courts, message: 'No courts in this radius yet' } : { courts };
  }

  court(id: string) {
    const court = this.courts.find((item) => item.id === id);
    if (!court) throw notFound('Court not found');
    return this.publicCourt(court, {});
  }

  listCoaches(filters: NearQuery & { audience?: string; format?: string; priceBand?: string }) {
    let rows = this.coaches.filter((coach) => this.withinPlace(coach, filters));
    if (filters.audience) {
      rows = rows.filter((coach) => coach.audience === filters.audience || coach.audience === 'both');
    }
    if (filters.format) {
      rows = rows.filter((coach) => coach.format === filters.format || coach.format === 'both');
    }
    if (filters.priceBand) rows = rows.filter((coach) => coach.priceBand === filters.priceBand);
    const coaches = this.sortByDistance(rows, filters).map((coach) => this.publicCoach(coach, filters));
    return coaches.length === 0 ? { coaches, message: 'No coaches in this radius yet' } : { coaches };
  }

  coach(id: string) {
    const coach = this.coaches.find((item) => item.id === id);
    if (!coach) throw notFound('Coach not found');
    return this.publicCoach(coach, {});
  }

  listStores(filters: NearQuery & { service?: string }) {
    let rows = this.stores.filter((store) => this.withinPlace(store, filters));
    if (filters.service) {
      const service = filters.service.toLowerCase();
      rows = rows.filter((store) => store.services.some((item) => item.toLowerCase() === service));
    }
    const stores = this.sortByDistance(rows, filters).map((store) => this.publicStore(store, filters));
    return stores.length === 0 ? { stores, message: 'No stores in this radius yet' } : { stores };
  }

  listPlayers(
    viewerId: string,
    filters: NearQuery & { level?: number; format?: string; setting?: string },
  ): { players: PlayerCard[] } {
    const viewer = this.requireActive(viewerId);
    if (!canUsePartnerFeatures(viewer.birthYear)) {
      throw new ApiError(
        403,
        'forbidden',
        'Player discovery is available from age 18. Lessons, courts, coaches, and stores are still open.',
      );
    }
    const ranked: Array<{ card: PlayerCard; distanceKm: number }> = [];
    for (const user of this.users.values()) {
      if (user.id === viewerId || user.status !== 'active') continue;
      if (!canUsePartnerFeatures(user.birthYear)) continue;
      const profile = this.profiles.get(user.id);
      if (!profile?.discoverable) continue;
      if (this.isBlocked(viewerId, user.id)) continue;
      if (filters.level != null && profile.level !== filters.level) continue;
      if (filters.format && profile.format !== filters.format && profile.format !== 'both') continue;
      if (filters.setting && profile.setting && profile.setting !== 'either' && profile.setting !== filters.setting) {
        continue;
      }
      if (filters.city && !(profile.homeCity ?? '').toLowerCase().includes(filters.city.toLowerCase())) continue;

      let distanceKm: number | null = null;
      if (filters.lat != null && filters.lng != null) {
        if (!profile.locationCell) continue;
        distanceKm = haversineKm(filters.lat, filters.lng, profile.locationCell.lat, profile.locationCell.lng);
        if (filters.radiusKm != null && distanceKm > filters.radiusKm) continue;
      } else if (filters.radiusKm != null) {
        continue;
      }

      ranked.push({
        distanceKm: distanceKm ?? Number.POSITIVE_INFINITY,
        card: toPlayerCard(
          {
            id: user.id,
            displayName: profile.displayName,
            level: profile.level,
            levelLabel: this.levelLabel(profile.level),
            format: profile.format,
            city: profile.homeCity,
            primaryGoal: profile.primaryGoal,
            focusSkills: profile.focusSkills,
            availability: profile.availability,
            showAgeBand: profile.showAgeBand,
            birthYear: user.birthYear,
            locationCell: profile.locationCell,
            email: user.email,
          },
          distanceKm,
        ),
      });
    }
    ranked.sort((left, right) => left.distanceKm - right.distanceKm);
    return { players: ranked.map((row) => row.card) };
  }

  addFavorite(userId: string, placeType: Favorite['placeType'], placeId: string) {
    this.requireActive(userId);
    if (!this.placeExists(placeType, placeId)) throw notFound('Place not found');
    const existing = this.favorites.find(
      (favorite) => favorite.userId === userId && favorite.placeType === placeType && favorite.placeId === placeId,
    );
    if (existing) throw new ApiError(409, 'conflict', 'That place is already saved.');
    const favorite: Favorite = {
      id: randomUUID(),
      userId,
      placeType,
      placeId,
      createdAt: new Date().toISOString(),
    };
    this.favorites.push(favorite);
    return favorite;
  }

  removeFavorite(userId: string, favoriteId: string): void {
    this.requireActive(userId);
    const index = this.favorites.findIndex((favorite) => favorite.id === favoriteId && favorite.userId === userId);
    if (index < 0) throw notFound('Favorite not found');
    this.favorites.splice(index, 1);
  }

  equipment(filters: { level?: number; budget?: string; category?: string }) {
    const products = this.products.filter((product) => {
      if (filters.level != null && (product.levelMin > filters.level || product.levelMax < filters.level)) return false;
      if (filters.budget && product.budgetBand !== filters.budget) return false;
      if (filters.category && product.category !== filters.category) return false;
      return true;
    });
    return {
      products,
      note: 'A shop or coach should check grip size and shoes if you have pain. This guide is not medical advice.',
    };
  }

  search(userId: string, query: string, near: NearQuery) {
    const user = this.requireActive(userId);
    const needle = query.trim().toLowerCase();
    const results: Array<Record<string, unknown>> = [];
    const matches = (...parts: Array<string | null | undefined>) =>
      parts.some((part) => part?.toLowerCase().includes(needle));

    for (const lesson of this.catalog.lessons) {
      if (matches(lesson.title, lesson.summary, lesson.technique)) {
        results.push({
          type: 'lesson',
          id: lesson.slug,
          title: lesson.title,
          summary: lesson.summary,
          locked: this.lessonLocked(user, lesson),
        });
      }
    }
    for (const technique of this.techniqueRecords()) {
      if (matches(technique.name, technique.overview, technique.slug)) {
        results.push({ type: 'technique', id: technique.slug, title: technique.name, summary: technique.overview });
      }
    }
    for (const drill of this.catalog.drills) {
      if (matches(drill.name, drill.objective, drill.slug)) {
        results.push({
          type: 'drill',
          id: drill.slug,
          title: drill.name,
          summary: drill.objective,
          locked: this.drillLocked(user, drill),
        });
      }
    }
    for (const term of this.catalog.glossary) {
      if (matches(term.term, term.definition)) {
        results.push({ type: 'glossary', id: glossarySlug(term.term), title: term.term, summary: term.definition });
      }
    }
    for (const article of this.articles) {
      if (matches(article.title, article.summary, article.topic)) {
        results.push({ type: 'rule', id: article.slug, title: article.title, summary: article.summary });
      }
    }
    for (const court of this.courts) {
      if (!this.withinPlace(court, near)) continue;
      if (matches(court.name, court.city, court.surface, court.address)) {
        results.push({ type: 'court', id: court.id, title: court.name, summary: court.address });
      }
    }
    for (const coach of this.coaches) {
      if (!this.withinPlace(coach, near)) continue;
      if (matches(coach.name, coach.summary, coach.city, ...coach.specialties)) {
        results.push({ type: 'coach', id: coach.id, title: coach.name, summary: coach.summary });
      }
    }
    for (const store of this.stores) {
      if (!this.withinPlace(store, near)) continue;
      if (matches(store.name, store.summary, store.city, ...store.services)) {
        results.push({ type: 'store', id: store.id, title: store.name, summary: store.summary });
      }
    }
    for (const product of this.products) {
      if (matches(product.name, product.summary, product.category)) {
        results.push({
          type: 'equipment',
          id: product.id,
          title: product.name,
          summary: product.summary,
          sponsored: product.sponsored,
        });
      }
    }
    if (canUsePartnerFeatures(user.birthYear)) {
      const { players } = this.listPlayers(userId, near);
      for (const player of players) {
        if (matches(player.displayName, player.city, ...player.goals)) {
          results.push({ type: 'player', id: player.id, title: player.displayName, summary: player.distanceBand, player });
        }
      }
    }
    return { q: query.trim(), results: results.slice(0, 30) };
  }

  createConnection(userId: string, toUserId: string) {
    const user = this.requireActive(userId);
    this.requireAdult(user);
    if (toUserId === userId) throw new ApiError(400, 'validation', 'You cannot send a request to yourself.');
    const target = this.users.get(toUserId);
    const targetProfile = target ? this.profiles.get(target.id) : undefined;
    if (!target || target.status !== 'active' || !targetProfile?.discoverable || !canUsePartnerFeatures(target.birthYear)) {
      throw notFound('Player not found');
    }
    if (this.isBlocked(userId, toUserId)) {
      throw new ApiError(403, 'forbidden', 'You cannot contact this player.');
    }
    const open = this.connections.find(
      (connection) =>
        (connection.status === 'pending' || connection.status === 'accepted') &&
        ((connection.fromUserId === userId && connection.toUserId === toUserId) ||
          (connection.fromUserId === toUserId && connection.toUserId === userId)),
    );
    if (open) throw new ApiError(409, 'conflict', 'A request already exists between these players.');
    const connection: Connection = {
      id: randomUUID(),
      fromUserId: userId,
      toUserId,
      status: 'pending',
      createdAt: new Date().toISOString(),
    };
    this.connections.push(connection);
    return connection;
  }

  acceptConnection(userId: string, connectionId: string) {
    const user = this.requireActive(userId);
    this.requireAdult(user);
    const connection = this.connections.find((item) => item.id === connectionId);
    if (!connection) throw notFound('Request not found');
    if (connection.toUserId !== userId) throw new ApiError(403, 'forbidden', 'Only the recipient can accept this request.');
    if (this.isBlocked(connection.fromUserId, connection.toUserId)) {
      throw new ApiError(403, 'forbidden', 'You cannot contact this player.');
    }
    if (connection.status !== 'pending') throw new ApiError(409, 'conflict', 'This request is no longer pending.');
    connection.status = 'accepted';
    const conversation: Conversation = {
      id: randomUUID(),
      requestId: connection.id,
      memberIds: [connection.fromUserId, connection.toUserId],
      createdAt: new Date().toISOString(),
    };
    this.conversations.push(conversation);
    return { connection, conversationId: conversation.id };
  }

  declineConnection(userId: string, connectionId: string) {
    const user = this.requireActive(userId);
    this.requireAdult(user);
    const connection = this.connections.find((item) => item.id === connectionId);
    if (!connection) throw notFound('Request not found');
    if (connection.toUserId !== userId) throw new ApiError(403, 'forbidden', 'Only the recipient can decline this request.');
    if (connection.status !== 'pending') throw new ApiError(409, 'conflict', 'This request is no longer pending.');
    connection.status = 'declined';
    return { connection };
  }

  listConversations(userId: string) {
    const user = this.requireActive(userId);
    this.requireAdult(user);
    const conversations = this.conversations
      .filter((conversation) => conversation.memberIds.includes(userId))
      .filter((conversation) => !this.isBlocked(conversation.memberIds[0], conversation.memberIds[1]))
      .map((conversation) => {
        const otherId = conversation.memberIds[0] === userId ? conversation.memberIds[1] : conversation.memberIds[0];
        const other = this.profiles.get(otherId);
        const last = [...this.messages].reverse().find((message) => message.conversationId === conversation.id);
        return {
          id: conversation.id,
          createdAt: conversation.createdAt,
          withUser: { id: otherId, displayName: other?.displayName ?? 'Player' },
          lastMessage: last ? { id: last.id, body: last.body, createdAt: last.createdAt, senderId: last.senderId } : null,
        };
      });
    return { conversations };
  }

  listMessages(userId: string, conversationId: string) {
    const conversation = this.requireConversation(userId, conversationId);
    const messages = this.messages
      .filter((message) => message.conversationId === conversation.id)
      .map((message) => ({
        id: message.id,
        senderId: message.senderId,
        body: message.body,
        createdAt: message.createdAt,
      }));
    return { messages };
  }

  sendMessage(userId: string, conversationId: string, body: string) {
    const conversation = this.requireConversation(userId, conversationId);
    const message: Message = {
      id: randomUUID(),
      conversationId: conversation.id,
      senderId: userId,
      body,
      createdAt: new Date().toISOString(),
    };
    this.messages.push(message);
    return {
      id: message.id,
      senderId: message.senderId,
      body: message.body,
      createdAt: message.createdAt,
    };
  }

  blockUser(userId: string, blockedId: string) {
    const user = this.requireActive(userId);
    this.requireAdult(user);
    if (blockedId === userId) throw new ApiError(400, 'validation', 'You cannot block yourself.');
    if (!this.users.has(blockedId)) throw notFound('Player not found');
    if (!this.blocks.some((block) => block.blockerId === userId && block.blockedId === blockedId)) {
      this.blocks.push({ blockerId: userId, blockedId, createdAt: new Date().toISOString() });
    }
    return { blocked: true };
  }

  findVideo(_id: string): VideoRecord | null {
    return null;
  }

  report(input: {
    reporterId: string;
    targetType: 'user' | 'message';
    targetId: string;
    reason: string;
    note?: string;
  }) {
    const user = this.requireActive(input.reporterId);
    this.requireAdult(user);
    if (input.targetType === 'user') {
      if (!this.users.has(input.targetId)) throw notFound('Player not found');
    } else {
      const message = this.messages.find((item) => item.id === input.targetId);
      if (!message) throw notFound('Message not found');
      const conversation = this.conversations.find((item) => item.id === message.conversationId);
      if (!conversation?.memberIds.includes(input.reporterId)) throw new ApiError(403, 'forbidden', 'You cannot report that message.');
    }
    const report: Report = {
      id: randomUUID(),
      reporterId: input.reporterId,
      targetType: input.targetType,
      targetId: input.targetId,
      reason: input.reason,
      note: input.note ?? null,
      status: 'open',
      messageSnapshotId: input.targetType === 'message' ? input.targetId : null,
      createdAt: new Date().toISOString(),
    };
    this.reports.push(report);
    return { message: 'Thanks, we received this.' };
  }

  private insertSeedPlayer(seed: SeedPlayer): void {
    const user: User = {
      id: seed.id,
      email: seed.email,
      birthYear: seed.birthYear,
      status: 'active',
      entitlement: 'free',
      createdAt: new Date().toISOString(),
      deletedAt: null,
    };
    this.users.set(user.id, user);
    this.usersByEmail.set(user.email, user.id);
    this.profiles.set(user.id, {
      userId: user.id,
      displayName: seed.displayName,
      level: seed.level,
      playedBefore: true,
      playFrequency: seed.playFrequency,
      primaryGoal: seed.primaryGoal,
      format: seed.format,
      daysPerWeek: seed.daysPerWeek,
      focusSkills: [...seed.focusSkills],
      setting: seed.setting,
      discoverable: true,
      availability: seed.availability,
      bio: null,
      homeCity: seed.homeCity,
      homeRegion: null,
      countryCode: null,
      locationCell: { ...seed.locationCell },
      searchRadiusKm: 25,
      showAgeBand: false,
    });
    this.notifications.set(user.id, defaultNotifications());
    this.streaks.set(user.id, { currentCount: 0, longestCount: 0, lastActiveOn: null });
  }

  private createUser(input: { email: string; birthYear: number; displayName: string }): User {
    const user: User = {
      id: randomUUID(),
      email: input.email,
      birthYear: input.birthYear,
      status: 'active',
      entitlement: 'free',
      createdAt: new Date().toISOString(),
      deletedAt: null,
    };
    this.users.set(user.id, user);
    this.usersByEmail.set(user.email, user.id);
    this.profiles.set(user.id, {
      userId: user.id,
      displayName: input.displayName,
      level: 1,
      playedBefore: null,
      playFrequency: null,
      primaryGoal: null,
      format: null,
      daysPerWeek: null,
      focusSkills: [],
      setting: null,
      discoverable: false,
      availability: null,
      bio: null,
      homeCity: null,
      homeRegion: null,
      countryCode: null,
      locationCell: null,
      searchRadiusKm: 10,
      showAgeBand: false,
    });
    this.notifications.set(user.id, defaultNotifications());
    this.streaks.set(user.id, { currentCount: 0, longestCount: 0, lastActiveOn: null });
    return user;
  }

  private issueSession(user: User) {
    const accessToken = newToken();
    const refreshToken = newToken();
    const now = Date.now();
    this.accessTokens.set(hashToken(accessToken), { userId: user.id, expiresAt: now + ACCESS_TTL_MS, revoked: false });
    this.refreshTokens.set(hashToken(refreshToken), {
      userId: user.id,
      expiresAt: now + REFRESH_TTL_MS,
      revoked: false,
    });
    return {
      accessToken,
      refreshToken,
      expiresIn: ACCESS_TTL_MS / 1000,
      user: {
        id: user.id,
        email: user.email,
        birthYear: user.birthYear,
        status: user.status,
        entitlement: user.entitlement,
      },
    };
  }

  private requireActive(userId: string): User {
    const user = this.users.get(userId);
    if (!user || user.status !== 'active') throw new ApiError(401, 'unauthorized', 'Sign in required.');
    return user;
  }

  private requireAdult(user: User): void {
    if (!canUsePartnerFeatures(user.birthYear)) {
      throw new ApiError(
        403,
        'forbidden',
        'Player discovery, requests, and messages are available from age 18.',
      );
    }
  }

  private mePayload(user: User) {
    return {
      id: user.id,
      email: user.email,
      birthYear: user.birthYear,
      status: user.status,
      entitlement: user.entitlement,
      profile: this.publicProfile(this.profiles.get(user.id)!),
      streak: this.streaks.get(user.id)!,
      notifications: this.notifications.get(user.id)!,
      goals: this.goals.filter((goal) => goal.userId === user.id),
    };
  }

  private publicProfile(profile: Profile) {
    return {
      displayName: profile.displayName,
      level: profile.level,
      levelLabel: this.levelLabel(profile.level),
      playedBefore: profile.playedBefore,
      playFrequency: profile.playFrequency,
      primaryGoal: profile.primaryGoal,
      format: profile.format,
      daysPerWeek: profile.daysPerWeek,
      focusSkills: profile.focusSkills,
      setting: profile.setting,
      discoverable: profile.discoverable,
      availability: profile.availability,
      bio: profile.bio,
      homeCity: profile.homeCity,
      homeRegion: profile.homeRegion,
      countryCode: profile.countryCode,
      searchRadiusKm: profile.searchRadiusKm,
      showAgeBand: profile.showAgeBand,
      hasLocationCell: profile.locationCell != null,
    };
  }

  private levelLabel(level: number): string {
    return this.catalog.levels.find((item) => item.id === level)?.name ?? `Level ${level}`;
  }

  private lessonLocked(user: User, lesson: CatalogLesson): boolean {
    return !lesson.freeTier && user.entitlement !== 'premium';
  }

  private drillLocked(user: User, drill: CatalogDrill): boolean {
    return !drill.freeTier && user.entitlement !== 'premium';
  }

  private drillCard(user: User, drill: CatalogDrill) {
    return {
      slug: drill.slug,
      name: drill.name,
      levelMin: drill.levelMin,
      objective: drill.objective,
      equipment: drill.equipment,
      playersRequired: drill.playersRequired,
      durationMinutes: drill.durationMinutes,
      difficulty: drill.difficulty,
      freeTier: drill.freeTier,
      technique: DRILL_TECHNIQUE[drill.slug] ?? null,
      locked: this.drillLocked(user, drill),
    };
  }

  private drillsForLesson(lesson: CatalogLesson) {
    return this.catalog.drills
      .filter((drill) => {
        const technique = DRILL_TECHNIQUE[drill.slug];
        if (!lesson.technique || !technique) return false;
        if (lesson.technique === 'rally') return drill.slug === 'wall-rally' || drill.slug === 'forehand-consistency';
        return technique === lesson.technique;
      })
      .map((drill) => ({ slug: drill.slug, name: drill.name }));
  }

  private techniqueRecords(): TechniqueRecord[] {
    const bySlug = new Map<string, TechniqueRecord>();
    for (const lesson of this.catalog.lessons) {
      if (!lesson.technique) continue;
      const existing = bySlug.get(lesson.technique);
      const why = lesson.blocks.find((block) => block.kind === 'why')?.body ?? lesson.summary;
      if (!existing) {
        bySlug.set(lesson.technique, {
          slug: lesson.technique,
          name: techniqueName(lesson.technique),
          family: techniqueFamily(lesson.technique),
          levelMin: lesson.level,
          overview: lesson.summary,
          whyItMatters: why,
          lessonSlugs: [lesson.slug],
          status: 'published',
        });
      } else {
        existing.lessonSlugs.push(lesson.slug);
        existing.levelMin = Math.min(existing.levelMin, lesson.level);
      }
    }
    return [...bySlug.values()];
  }

  private makePlan(userId: string, profile: Profile): Plan {
    const days = profile.daysPerWeek ?? 3;
    const items = buildWeekItems({
      daysPerWeek: days,
      focusSkills: profile.focusSkills,
      level: profile.level,
      lessons: this.catalog.lessons,
      drillSlugs: new Set(this.catalog.drills.map((drill) => drill.slug)),
    }).map((item) => ({ ...item, completedAt: null }));
    return {
      id: randomUUID(),
      userId,
      weekStart: weekStartMonday(),
      daysPerWeek: days,
      goal: profile.primaryGoal ?? 'practice',
      status: 'active',
      items,
    };
  }

  private publicItem(item: PlanItem) {
    return {
      id: item.id,
      dayIndex: item.dayIndex,
      sortOrder: item.sortOrder,
      kind: item.kind,
      title: item.title,
      minutes: item.minutes,
      lessonSlug: item.lessonSlug,
      drillSlug: item.drillSlug,
      completed: item.completedAt != null,
      completedAt: item.completedAt,
    };
  }

  private publicPlan(plan: Plan) {
    return {
      id: plan.id,
      weekStart: plan.weekStart,
      daysPerWeek: plan.daysPerWeek,
      goal: plan.goal,
      status: plan.status,
      items: plan.items.map((item) => this.publicItem(item)),
    };
  }

  private completedLessonSlugs(userId: string): Set<string> {
    return new Set(
      [...this.lessonProgress.values()]
        .filter((row) => row.userId === userId && row.status === 'completed')
        .map((row) => row.slug),
    );
  }

  private unfinishedLesson(userId: string): UnfinishedLesson | null {
    const profile = this.profiles.get(userId);
    const rows = [...this.lessonProgress.values()]
      .filter((row) => row.userId === userId)
      .sort((left, right) => right.updatedAt.localeCompare(left.updatedAt));
    const started = rows.find((row) => row.status === 'started');
    const startedLesson = started ? this.catalog.lessons.find((lesson) => lesson.slug === started.slug) : undefined;
    if (startedLesson) {
      return {
        slug: startedLesson.slug,
        title: startedLesson.title,
        techniqueSlug: startedLesson.technique ?? null,
      };
    }
    const completed = this.completedLessonSlugs(userId);
    const next =
      this.catalog.lessons.find((lesson) => lesson.level === profile?.level && !completed.has(lesson.slug)) ??
      this.catalog.lessons.find((lesson) => !completed.has(lesson.slug));
    if (!next) return null;
    return { slug: next.slug, title: next.title, techniqueSlug: next.technique ?? null };
  }

  private touchStreak(userId: string): Streak {
    const streak = this.streaks.get(userId)!;
    const today = new Date().toISOString().slice(0, 10);
    if (streak.lastActiveOn !== today) {
      const yesterday = addDays(today, -1);
      streak.currentCount = streak.lastActiveOn === yesterday ? streak.currentCount + 1 : 1;
      streak.longestCount = Math.max(streak.longestCount, streak.currentCount);
      streak.lastActiveOn = today;
    }
    return { ...streak };
  }

  private xpFor(userId: string): number {
    const lessons = [...this.lessonProgress.values()].filter(
      (row) => row.userId === userId && row.status === 'completed',
    ).length;
    const drills = this.drillCompletions.filter((row) => row.userId === userId).length;
    const minutesByDay = new Map<string, number>();
    for (const session of this.practiceSessions) {
      if (session.userId !== userId) continue;
      const day = session.startedAt.slice(0, 10);
      minutesByDay.set(day, (minutesByDay.get(day) ?? 0) + session.minutes);
    }
    let minuteXp = 0;
    for (const minutes of minutesByDay.values()) minuteXp += Math.min(minutes, 60);
    return lessons * 20 + drills * 10 + minuteXp;
  }

  private weekMinutes(userId: string) {
    const current = weekStartMonday();
    const weeks = [];
    for (let index = 7; index >= 0; index -= 1) {
      const weekStart = addDays(current, -7 * index);
      const weekEnd = addDays(weekStart, 7);
      const minutes = this.practiceSessions
        .filter((session) => {
          if (session.userId !== userId) return false;
          const day = session.startedAt.slice(0, 10);
          return day >= weekStart && day < weekEnd;
        })
        .reduce((sum, session) => sum + session.minutes, 0);
      weeks.push({ weekStart, minutes });
    }
    return weeks;
  }

  private withinPlace(place: { city: string; lat: number; lng: number }, near: NearQuery): boolean {
    if (near.city && !place.city.toLowerCase().includes(near.city.toLowerCase())) return false;
    if (near.radiusKm != null && near.lat != null && near.lng != null) {
      return haversineKm(near.lat, near.lng, place.lat, place.lng) <= near.radiusKm;
    }
    return true;
  }

  private sortByDistance<T extends { lat: number; lng: number; name: string }>(rows: T[], near: NearQuery): T[] {
    return [...rows].sort((left, right) => {
      if (near.lat == null || near.lng == null) return left.name.localeCompare(right.name);
      const leftKm = haversineKm(near.lat, near.lng, left.lat, left.lng);
      const rightKm = haversineKm(near.lat, near.lng, right.lat, right.lng);
      return leftKm - rightKm;
    });
  }

  private distanceKm(place: { lat: number; lng: number }, near: NearQuery): number | null {
    if (near.lat == null || near.lng == null) return null;
    return Math.round(haversineKm(near.lat, near.lng, place.lat, place.lng) * 10) / 10;
  }

  /** Public places may include a map pin. Do not reuse this for players. */
  private publicCourt(court: CourtRecord, near: NearQuery) {
    return { ...court, distanceKm: this.distanceKm(court, near) };
  }

  private publicCoach(coach: CoachRecord, near: NearQuery) {
    return { ...coach, distanceKm: this.distanceKm(coach, near) };
  }

  private publicStore(store: StoreRecord, near: NearQuery) {
    return { ...store, distanceKm: this.distanceKm(store, near) };
  }

  private placeExists(placeType: Favorite['placeType'], placeId: string): boolean {
    if (placeType === 'court') return this.courts.some((court) => court.id === placeId);
    if (placeType === 'coach') return this.coaches.some((coach) => coach.id === placeId);
    return this.stores.some((store) => store.id === placeId);
  }

  private isBlocked(leftId: string, rightId: string): boolean {
    return this.blocks.some(
      (block) =>
        (block.blockerId === leftId && block.blockedId === rightId) ||
        (block.blockerId === rightId && block.blockedId === leftId),
    );
  }

  private requireConversation(userId: string, conversationId: string): Conversation {
    const user = this.requireActive(userId);
    this.requireAdult(user);
    const conversation = this.conversations.find((item) => item.id === conversationId);
    if (!conversation || !conversation.memberIds.includes(userId)) throw notFound('Conversation not found');
    if (this.isBlocked(conversation.memberIds[0], conversation.memberIds[1])) {
      throw new ApiError(403, 'forbidden', 'You cannot view this conversation.');
    }
    return conversation;
  }

  exportState(): Record<string, unknown> {
    return {
      users: [...this.users.values()],
      profiles: [...this.profiles.values()],
      notifications: [...this.notifications.entries()],
      streaks: [...this.streaks.entries()],
      accessTokens: [...this.accessTokens.entries()],
      refreshTokens: [...this.refreshTokens.entries()],
      pendingCodes: [...this.pendingCodes.entries()],
      lessonProgress: [...this.lessonProgress.values()],
      plans: [...this.plans.values()],
      practiceSessions: this.practiceSessions,
      drillCompletions: this.drillCompletions,
      goals: this.goals,
      connections: this.connections,
      conversations: this.conversations,
      messages: this.messages,
      blocks: this.blocks,
      reports: this.reports,
      favorites: this.favorites,
    };
  }

  importState(raw: Record<string, unknown>): void {
    const users = arrayOf<User>(raw.users);
    this.users.clear();
    this.usersByEmail.clear();
    for (const user of users) {
      this.users.set(user.id, user);
      if (user.email) this.usersByEmail.set(user.email.toLowerCase(), user.id);
    }
    replaceMap(this.profiles, arrayOf<Profile>(raw.profiles).map((profile) => [profile.userId, profile]));
    replaceEntries(this.notifications, raw.notifications);
    replaceEntries(this.streaks, raw.streaks);
    replaceEntries(this.accessTokens, raw.accessTokens);
    replaceEntries(this.refreshTokens, raw.refreshTokens);
    replaceEntries(this.pendingCodes, raw.pendingCodes);
    this.lessonProgress.clear();
    for (const row of arrayOf<LessonProgress>(raw.lessonProgress)) {
      this.lessonProgress.set(`${row.userId}:${row.slug}`, row);
    }
    this.plans.clear();
    for (const plan of arrayOf<Plan>(raw.plans)) this.plans.set(plan.userId, plan);
    replaceArray(this.practiceSessions, raw.practiceSessions);
    replaceArray(this.drillCompletions, raw.drillCompletions);
    replaceArray(this.goals, raw.goals);
    replaceArray(this.connections, raw.connections);
    replaceArray(this.conversations, raw.conversations);
    replaceArray(this.messages, raw.messages);
    replaceArray(this.blocks, raw.blocks);
    replaceArray(this.reports, raw.reports);
    replaceArray(this.favorites, raw.favorites);
  }
}

function arrayOf<T>(value: unknown): T[] {
  return Array.isArray(value) ? (value as T[]) : [];
}

function replaceMap<K, V>(target: Map<K, V>, entries: Array<[K, V]>): void {
  target.clear();
  for (const [key, value] of entries) target.set(key, value);
}

function replaceEntries<V>(target: Map<string, V>, value: unknown): void {
  target.clear();
  if (!Array.isArray(value)) return;
  for (const entry of value) {
    if (!Array.isArray(entry) || entry.length < 2) continue;
    target.set(String(entry[0]), entry[1] as V);
  }
}

function replaceArray<T>(target: T[], value: unknown): void {
  target.length = 0;
  if (Array.isArray(value)) target.push(...(value as T[]));
}
