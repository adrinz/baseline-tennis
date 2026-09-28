import type { FastifyInstance, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { ApiError } from '../errors.ts';
import { headerValue, optionalBoolean, optionalText, parseBody, parseNear, queryRecord, routeParam } from '../http.ts';
import { toPlaybackDescriptor } from '../media/publish.ts';
import { assertCoarsePlayerPayload } from '../player-card.ts';
import type { MemoryRepository } from '../repository.ts';
import type { SlidingWindowLimiter } from '../rate-limit.ts';

const emailSchema = z.string().trim().toLowerCase().email();
const daysSchema = z.number().int().min(2).max(5);

const profileShape = {
  displayName: z.string().trim().min(1).max(40).optional(),
  level: z.number().int().min(1).max(5).optional(),
  playedBefore: z.boolean().optional(),
  playFrequency: z.string().trim().min(1).max(80).optional(),
  primaryGoal: z.string().trim().min(1).max(120).optional(),
  format: z.enum(['singles', 'doubles', 'both']).optional(),
  daysPerWeek: daysSchema.optional(),
  focusSkills: z.array(z.string().trim().min(1).max(40)).max(8).optional(),
  setting: z.enum(['indoor', 'outdoor', 'either']).optional(),
  discoverable: z.boolean().optional(),
  availability: z.unknown().optional(),
  bio: z.string().trim().max(500).optional(),
  homeCity: z.string().trim().min(1).max(80).optional(),
  homeRegion: z.string().trim().min(1).max(80).optional(),
  countryCode: z.string().trim().regex(/^[A-Za-z]{2}$/).optional(),
  searchRadiusKm: z.number().min(1).max(100).optional(),
  showAgeBand: z.boolean().optional(),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
};

export type RouteDeps = {
  repo: MemoryRepository;
  allowDevPremium: boolean;
  authLimiter: SlidingWindowLimiter;
  messageLimiter: SlidingWindowLimiter;
  searchLimiter: SlidingWindowLimiter;
};

export async function registerRoutes(app: FastifyInstance, deps: RouteDeps): Promise<void> {
  app.get('/health', async () => ({ ok: true, service: 'baseline-api' }));

  await app.register(async (v1) => {
    registerAuth(v1, deps);
    registerMe(v1, deps);
    registerLearning(v1, deps);
    registerTraining(v1, deps);
    registerDiscovery(v1, deps);
    registerPartners(v1, deps);
  }, { prefix: '/v1' });
}

function requireUser(request: FastifyRequest, deps: RouteDeps) {
  const raw = headerValue(request.headers['x-dev-premium']);
  const devPremium = deps.allowDevPremium && raw?.toLowerCase() === 'true';
  const header = headerValue(request.headers.authorization);
  const user = deps.repo.authenticate(header, devPremium);
  if (!user) throw new ApiError(401, 'unauthorized', 'Sign in required.');
  return user;
}

function limit(limiter: SlidingWindowLimiter, key: string): void {
  if (!limiter.allow(key)) {
    throw new ApiError(429, 'rate_limited', 'Too many attempts. Wait a minute and try again.');
  }
}

function registerAuth(app: FastifyInstance, deps: RouteDeps): void {
  app.post('/auth/apple', async () => {
    throw new ApiError(501, 'not_configured', 'Sign in with Apple is unavailable until Apple credentials are configured.');
  });
  app.post('/auth/google', async () => {
    throw new ApiError(501, 'not_configured', 'Sign in with Google is unavailable until Google credentials are configured.');
  });

  app.post('/auth/email/start', async (request) => {
    limit(deps.authLimiter, request.ip);
    const body = parseBody(z.object({ email: emailSchema }), request.body);
    return deps.repo.startEmail(body.email);
  });

  app.post('/auth/email/finish', async (request) => {
    limit(deps.authLimiter, request.ip);
    const body = parseBody(
      z.object({
        email: emailSchema,
        code: z.string().trim().min(4).max(12),
        birthYear: z.number().int().min(1900).max(new Date().getFullYear()).optional(),
        displayName: z.string().trim().min(1).max(40).optional(),
      }),
      request.body,
    );
    return deps.repo.finishEmail(body);
  });

  app.post('/auth/refresh', async (request) => {
    limit(deps.authLimiter, request.ip);
    const body = parseBody(z.object({ refreshToken: z.string().min(20) }), request.body);
    return deps.repo.refresh(body.refreshToken);
  });

  app.post('/auth/logout', async (request, reply) => {
    limit(deps.authLimiter, request.ip);
    const body = parseBody(z.object({ refreshToken: z.string().min(20) }), request.body);
    deps.repo.logout(body.refreshToken);
    return reply.code(204).send();
  });
}

function registerMe(app: FastifyInstance, deps: RouteDeps): void {
  app.get('/me', async (request) => deps.repo.getMe(requireUser(request, deps).id));

  const update = async (request: FastifyRequest) => {
    const user = requireUser(request, deps);
    const body = parseBody(
      z.object(profileShape).superRefine((value, ctx) => {
        if ((value.latitude == null) !== (value.longitude == null)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'latitude and longitude must be sent together',
            path: ['latitude'],
          });
        }
      }),
      request.body,
    );
    return deps.repo.updateProfile(user.id, body);
  };
  app.put('/me', update);
  app.put('/me/profile', update);

  app.post('/me/onboarding', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(
      z
        .object({
          playedBefore: z.boolean(),
          level: z.number().int().min(1).max(5),
          playFrequency: z.string().trim().min(1).max(80),
          primaryGoal: z.string().trim().min(1).max(120),
          format: z.enum(['singles', 'doubles', 'both']),
          daysPerWeek: daysSchema.optional(),
          days_per_week: daysSchema.optional(),
          focusSkills: z.array(z.string().trim().min(1).max(40)).min(1).max(8),
          homeCity: z.string().trim().min(1).max(80).optional(),
          setting: z.enum(['indoor', 'outdoor', 'either']),
          availability: z.unknown().optional(),
          displayName: z.string().trim().min(1).max(40).optional(),
        })
        .superRefine((value, ctx) => {
          if (value.daysPerWeek == null && value.days_per_week == null) {
            ctx.addIssue({
              code: z.ZodIssueCode.custom,
              message: 'daysPerWeek must be 2, 3, 4, or 5',
              path: ['daysPerWeek'],
            });
          }
        }),
      request.body,
    );
    const daysPerWeek = body.daysPerWeek ?? body.days_per_week;
    if (daysPerWeek == null) throw new ApiError(400, 'validation', 'daysPerWeek must be 2, 3, 4, or 5.');
    return deps.repo.onboard(user.id, { ...body, daysPerWeek });
  });

  app.put('/me/notifications', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(
      z.object({
        practiceReminders: z.boolean().optional(),
        planReminders: z.boolean().optional(),
        lessonTips: z.boolean().optional(),
        weeklyProgress: z.boolean().optional(),
        partnerRequests: z.boolean().optional(),
        messages: z.boolean().optional(),
        milestones: z.boolean().optional(),
      }),
      request.body,
    );
    return deps.repo.updateNotifications(user.id, body);
  });

  app.get('/me/export', async (request) => deps.repo.exportData(requireUser(request, deps).id));

  app.delete('/me', async (request) => {
    const user = requireUser(request, deps);
    parseBody(z.object({ confirm: z.literal('DELETE') }), request.body);
    deps.repo.deleteAccount(user.id);
    return { deleted: true };
  });
}

function registerLearning(app: FastifyInstance, deps: RouteDeps): void {
  app.get('/levels', async (request) => deps.repo.levels(requireUser(request, deps).id));

  app.get('/lessons', async (request) => {
    const user = requireUser(request, deps);
    const query = queryRecord(request);
    const level = optionalLevel(query.level);
    return deps.repo.lessons(user.id, { level, category: optionalText(query.category) });
  });

  app.get('/lessons/:slug', async (request) => {
    const user = requireUser(request, deps);
    return deps.repo.lessonDetail(user.id, routeParam(request, 'slug'));
  });

  app.post('/lessons/:slug/progress', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(z.object({ status: z.enum(['started', 'completed']) }), request.body);
    return deps.repo.setLessonProgress(user.id, routeParam(request, 'slug'), body.status);
  });

  app.get('/techniques', async (request) => {
    requireUser(request, deps);
    return deps.repo.techniques(optionalText(queryRecord(request).family));
  });

  app.get('/techniques/:slug', async (request) => {
    requireUser(request, deps);
    return deps.repo.technique(routeParam(request, 'slug'));
  });

  app.get('/glossary', async (request) => {
    requireUser(request, deps);
    return deps.repo.glossary(optionalText(queryRecord(request).q));
  });

  app.get('/rules', async (request) => {
    requireUser(request, deps);
    return deps.repo.rules();
  });

  app.get('/rules/:slug', async (request) => {
    requireUser(request, deps);
    return deps.repo.rule(routeParam(request, 'slug'));
  });

  app.get('/videos/:id', async (request) => {
    requireUser(request, deps);
    const record = deps.repo.findVideo(routeParam(request, 'id'));
    if (!record) throw new ApiError(404, 'not_found', 'Video not found');
    const playback = toPlaybackDescriptor(record);
    if (!playback) throw new ApiError(404, 'not_found', 'Video is not available.');
    return playback;
  });
}

function registerTraining(app: FastifyInstance, deps: RouteDeps): void {
  app.get('/drills', async (request) => {
    const user = requireUser(request, deps);
    const query = queryRecord(request);
    return deps.repo.drills(user.id, {
      level: optionalLevel(query.level),
      technique: optionalText(query.technique),
    });
  });

  app.get('/drills/:slug', async (request) => {
    const user = requireUser(request, deps);
    return deps.repo.drillDetail(user.id, routeParam(request, 'slug'));
  });

  app.post('/drills/:slug/completions', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(z.object({ minutes: z.number().int().min(1).max(300).optional() }), request.body);
    return deps.repo.completeDrill(user.id, routeParam(request, 'slug'), body.minutes);
  });

  app.get('/plans/current', async (request) => deps.repo.currentPlan(requireUser(request, deps).id));
  app.post('/plans/rebuild', async (request) => deps.repo.rebuildPlan(requireUser(request, deps).id));

  app.post('/plans/items/:id/complete', async (request) => {
    const user = requireUser(request, deps);
    return deps.repo.completePlanItem(user.id, routeParam(request, 'id'));
  });

  app.get('/progress', async (request) => deps.repo.progress(requireUser(request, deps).id));

  app.post('/coach/ask', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(z.object({ question: z.string().trim().min(3).max(500) }), request.body);
    return deps.repo.askCoach(user.id, body.question);
  });
}

function registerDiscovery(app: FastifyInstance, deps: RouteDeps): void {
  app.get('/courts', async (request) => {
    requireUser(request, deps);
    const query = queryRecord(request);
    return deps.repo.listCourts({
      ...parseNear(query),
      indoor: optionalBoolean(query.indoor, 'indoor'),
      lights: optionalBoolean(query.lights, 'lights'),
      access: optionalText(query.access),
      surface: optionalText(query.surface),
    });
  });

  app.get('/courts/:id', async (request) => {
    requireUser(request, deps);
    return deps.repo.court(routeParam(request, 'id'));
  });

  app.get('/coaches', async (request) => {
    requireUser(request, deps);
    const query = queryRecord(request);
    return deps.repo.listCoaches({
      ...parseNear(query),
      audience: optionalText(query.audience),
      format: optionalText(query.format),
      priceBand: optionalText(query.priceBand),
    });
  });

  app.get('/coaches/:id', async (request) => {
    requireUser(request, deps);
    return deps.repo.coach(routeParam(request, 'id'));
  });

  app.get('/stores', async (request) => {
    requireUser(request, deps);
    const query = queryRecord(request);
    return deps.repo.listStores({ ...parseNear(query), service: optionalText(query.service) });
  });

  app.get('/players', async (request) => {
    const user = requireUser(request, deps);
    const query = queryRecord(request);
    const payload = deps.repo.listPlayers(user.id, {
      ...parseNear(query),
      level: optionalLevel(query.level),
      format: optionalText(query.format),
      setting: optionalText(query.setting),
    });
    assertCoarsePlayerPayload(payload);
    return payload;
  });

  app.get('/equipment', async (request) => {
    requireUser(request, deps);
    const query = queryRecord(request);
    return deps.repo.equipment({
      level: optionalLevel(query.level),
      budget: optionalText(query.budget),
      category: optionalText(query.category),
    });
  });

  app.get('/search', async (request) => {
    const user = requireUser(request, deps);
    limit(deps.searchLimiter, user.id);
    const query = queryRecord(request);
    const q = optionalText(query.q);
    if (!q) throw new ApiError(400, 'validation', 'q is required.');
    const payload = deps.repo.search(user.id, q, parseNear(query));
    for (const result of payload.results) {
      if (result.type === 'player') assertCoarsePlayerPayload(result);
    }
    return payload;
  });

  app.post('/favorites', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(
      z.object({
        placeType: z.enum(['court', 'coach', 'store']),
        placeId: z.string().min(1),
      }),
      request.body,
    );
    return deps.repo.addFavorite(user.id, body.placeType, body.placeId);
  });

  app.delete('/favorites/:id', async (request, reply) => {
    const user = requireUser(request, deps);
    deps.repo.removeFavorite(user.id, routeParam(request, 'id'));
    return reply.code(204).send();
  });
}

function registerPartners(app: FastifyInstance, deps: RouteDeps): void {
  app.post('/connections', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(z.object({ toUserId: z.string().min(1) }), request.body);
    return deps.repo.createConnection(user.id, body.toUserId);
  });

  app.post('/connections/:id/accept', async (request) => {
    const user = requireUser(request, deps);
    return deps.repo.acceptConnection(user.id, routeParam(request, 'id'));
  });

  app.post('/connections/:id/decline', async (request) => {
    const user = requireUser(request, deps);
    return deps.repo.declineConnection(user.id, routeParam(request, 'id'));
  });

  app.get('/conversations', async (request) => deps.repo.listConversations(requireUser(request, deps).id));

  app.get('/conversations/:id/messages', async (request) => {
    const user = requireUser(request, deps);
    return deps.repo.listMessages(user.id, routeParam(request, 'id'));
  });

  app.post('/conversations/:id/messages', async (request) => {
    const user = requireUser(request, deps);
    limit(deps.messageLimiter, user.id);
    const body = parseBody(z.object({ body: z.string().trim().min(1).max(2000) }), request.body);
    return deps.repo.sendMessage(user.id, routeParam(request, 'id'), body.body);
  });

  app.post('/blocks', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(z.object({ userId: z.string().min(1) }), request.body);
    return deps.repo.blockUser(user.id, body.userId);
  });

  app.post('/reports', async (request) => {
    const user = requireUser(request, deps);
    const body = parseBody(
      z.object({
        targetType: z.enum(['user', 'message']),
        targetId: z.string().min(1),
        reason: z.string().trim().min(3).max(200),
        note: z.string().trim().max(1000).optional(),
      }),
      request.body,
    );
    return deps.repo.report({ reporterId: user.id, ...body });
  });
}

function optionalLevel(value: unknown): number | undefined {
  const raw = Array.isArray(value) ? value[0] : value;
  if (raw == null || raw === '') return undefined;
  const number = Number(raw);
  if (!Number.isInteger(number) || number < 1 || number > 5) {
    throw new ApiError(400, 'validation', 'level must be an integer from 1 to 5.');
  }
  return number;
}
