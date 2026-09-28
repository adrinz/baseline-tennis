import assert from 'node:assert/strict';
import test from 'node:test';
import { canCreateAccount, canUsePartnerFeatures } from '../src/age.ts';
import { buildApp } from '../src/app.ts';
import { loadCatalog } from '../src/catalog.ts';
import { answerCoachQuestion } from '../src/coach/engine.ts';
import { coarseCell } from '../src/geo.ts';
import { isVideoPublishable, toPlaybackDescriptor, type VideoRecord } from '../src/media/publish.ts';
import { collectKeys, toPlayerCard } from '../src/player-card.ts';
import type { FastifyInstance } from 'fastify';

const catalog = loadCatalog();
const rileyCell = coarseCell(40.731, -73.991);
const caseyCell = coarseCell(40.786, -73.962);

async function withApp(
  run: (app: FastifyInstance) => Promise<void>,
  options?: { allowDevPremium?: boolean },
): Promise<void> {
  const app = await buildApp(options);
  try {
    await run(app);
  } finally {
    await app.close();
  }
}

async function signIn(
  app: FastifyInstance,
  email: string,
  extra?: { birthYear?: number; displayName?: string },
): Promise<{ accessToken: string; refreshToken: string; user: { id: string; entitlement: string } }> {
  const start = await app.inject({
    method: 'POST',
    url: '/v1/auth/email/start',
    payload: { email },
  });
  assert.equal(start.statusCode, 200, start.body);
  const finish = await app.inject({
    method: 'POST',
    url: '/v1/auth/email/finish',
    payload: { email, code: '000000', ...extra },
  });
  assert.equal(finish.statusCode, 200, finish.body);
  return finish.json();
}

function authHeader(accessToken: string, extra?: Record<string, string>): Record<string, string> {
  return { authorization: `Bearer ${accessToken}`, ...extra };
}

test('age gate rejects players under 16', async () => {
  const fixed = new Date('2026-09-27T12:00:00Z');
  assert.equal(canCreateAccount(2011, fixed), false);
  assert.equal(canCreateAccount(2010, fixed), true);
  assert.equal(canUsePartnerFeatures(2009, fixed), false);
  assert.equal(canUsePartnerFeatures(2008, fixed), true);

  const year = new Date().getFullYear();
  await withApp(async (app) => {
    const start = await app.inject({
      method: 'POST',
      url: '/v1/auth/email/start',
      payload: { email: 'young@example.com' },
    });
    assert.equal(start.statusCode, 200, start.body);
    const rejected = await app.inject({
      method: 'POST',
      url: '/v1/auth/email/finish',
      payload: { email: 'young@example.com', code: '000000', birthYear: year - 15 },
    });
    assert.equal(rejected.statusCode, 403);
    assert.equal(rejected.json().error.code, 'forbidden');
    assert.equal(rejected.json().accessToken, undefined);

    const created = await signIn(app, 'sixteen@example.com', {
      birthYear: year - 16,
      displayName: 'Sixteen',
    });
    assert.equal(created.user.entitlement, 'free');

    const teen = await signIn(app, 'teen@example.com', { birthYear: year - 17, displayName: 'Teen' });
    const denied = await app.inject({
      method: 'PUT',
      url: '/v1/me',
      headers: authHeader(teen.accessToken),
      payload: { discoverable: true, homeCity: 'Riverton', latitude: 40.73, longitude: -73.99 },
    });
    assert.equal(denied.statusCode, 403);
    assert.equal(denied.json().error.code, 'forbidden');
    const players = await app.inject({
      method: 'GET',
      url: '/v1/players',
      headers: authHeader(teen.accessToken),
    });
    assert.equal(players.statusCode, 403);
    assert.equal(players.json().error.code, 'forbidden');
    const lesson = await app.inject({
      method: 'GET',
      url: '/v1/lessons/welcome-to-tennis',
      headers: authHeader(teen.accessToken),
    });
    assert.equal(lesson.statusCode, 200, lesson.body);
    assert.ok(lesson.json().blocks.length > 0);
  });
});

test('player cards expose a distance band and no coordinates', async () => {
  const card = toPlayerCard(
    {
      id: 'player-riley',
      displayName: 'Riley M.',
      level: 2,
      levelLabel: 'Beginner',
      format: 'singles',
      city: 'Riverton',
      primaryGoal: 'consistency',
      focusSkills: ['forehand'],
      availability: { summary: 'Weeknights after 6' },
      showAgeBand: false,
      birthYear: 1994,
      locationCell: { lat: rileyCell.lat, lng: rileyCell.lng },
      email: 'riley.m@baseline.example',
    },
    0.2,
  );
  assert.equal(card.distanceBand, 'within 1 km');
  const cardKeys = collectKeys(card);
  for (const key of ['lat', 'lng', 'latitude', 'longitude', 'locationCell', 'email', 'birthYear']) {
    assert.equal(cardKeys.has(key), false, key);
  }
  const cardJson = JSON.stringify(card);
  assert.equal(cardJson.includes('40.75'), false);
  assert.equal(cardJson.includes('riley.m@'), false);
  assert.equal(cardJson.includes('1994'), false);

  await withApp(async (app) => {
    const alex = await signIn(app, 'alex@example.com', { birthYear: new Date().getFullYear() - 25, displayName: 'Alex P.' });
    const headers = authHeader(alex.accessToken);
    const onboard = await app.inject({
      method: 'POST',
      url: '/v1/me/onboarding',
      headers,
      payload: {
        playedBefore: false,
        level: 1,
        playFrequency: 'new',
        primaryGoal: 'learn from scratch',
        format: 'singles',
        daysPerWeek: 3,
        focusSkills: ['forehand'],
        homeCity: 'Riverton',
        setting: 'outdoor',
        availability: { summary: 'Weeknights' },
      },
    });
    assert.equal(onboard.statusCode, 200, onboard.body);
    const plan = onboard.json().plan;
    assert.equal(plan.daysPerWeek, 3);
    assert.equal(plan.items.length, 12);
    assert.deepEqual(
      plan.items.filter((item: { dayIndex: number }) => item.dayIndex === 0).map((item: { kind: string }) => item.kind),
      ['warmup', 'footwork', 'focus', 'rally'],
    );

    const located = await app.inject({
      method: 'PUT',
      url: '/v1/me',
      headers,
      payload: { discoverable: true, latitude: 40.731, longitude: -73.991, homeCity: 'Riverton' },
    });
    assert.equal(located.statusCode, 200, located.body);
    const profileJson = JSON.stringify(located.json().profile);
    assert.equal(profileJson.includes('40.731'), false);
    assert.equal(profileJson.includes('-73.991'), false);
    assert.equal(profileJson.includes('locationCell'), false);
    assert.equal(located.json().profile.hasLocationCell, true);

    const nearRiley = `/v1/players?lat=${rileyCell.lat}&lng=${rileyCell.lng}&radiusKm=3`;
    const close = await app.inject({ method: 'GET', url: nearRiley, headers });
    assert.equal(close.statusCode, 200, close.body);
    assertNoPrivateLocation(close.json(), ['40.75', '40.8', '-73.95', 'riley.m@', 'casey.d@']);
    assert.deepEqual(
      close.json().players.map((player: { displayName: string }) => player.displayName),
      ['Riley M.'],
    );
    assert.equal(close.json().players[0].distanceBand, 'within 1 km');

    const wide = await app.inject({
      method: 'GET',
      url: `/v1/players?lat=${rileyCell.lat}&lng=${rileyCell.lng}&radiusKm=15`,
      headers,
    });
    assert.equal(wide.statusCode, 200, wide.body);
    const names = wide.json().players.map((player: { displayName: string }) => player.displayName);
    assert.ok(names.includes('Riley M.'));
    assert.ok(names.includes('Casey D.'));
    assertNoPrivateLocation(wide.json(), ['40.75', '40.8', '-73.95', String(caseyCell.lat), String(caseyCell.lng)]);

    const courts = await app.inject({
      method: 'GET',
      url: '/v1/courts?lat=40.73&lng=-73.99&radiusKm=1',
      headers,
    });
    assert.equal(courts.statusCode, 200, courts.body);
    const courtNames = courts.json().courts.map((court: { name: string }) => court.name);
    assert.deepEqual(courtNames.sort(), ['North Loop Indoor Tennis', 'Riverton Municipal Courts']);

    const riley = wide.json().players.find((player: { displayName: string }) => player.displayName === 'Riley M.');
    const casey = wide.json().players.find((player: { displayName: string }) => player.displayName === 'Casey D.');
    const blocked = await app.inject({
      method: 'POST',
      url: '/v1/blocks',
      headers,
      payload: { userId: riley.id },
    });
    assert.equal(blocked.statusCode, 200, blocked.body);
    const afterBlock = await app.inject({
      method: 'GET',
      url: `/v1/players?lat=${rileyCell.lat}&lng=${rileyCell.lng}&radiusKm=15`,
      headers,
    });
    const afterNames = afterBlock.json().players.map((player: { displayName: string }) => player.displayName);
    assert.equal(afterNames.includes('Riley M.'), false);
    assert.equal(afterNames.includes('Casey D.'), true);

    const request = await app.inject({
      method: 'POST',
      url: '/v1/connections',
      headers,
      payload: { toUserId: casey.id },
    });
    assert.equal(request.statusCode, 200, request.body);
    const caseySession = await signIn(app, 'casey.d@baseline.example');
    const accepted = await app.inject({
      method: 'POST',
      url: `/v1/connections/${request.json().id}/accept`,
      headers: authHeader(caseySession.accessToken),
    });
    assert.equal(accepted.statusCode, 200, accepted.body);
    const conversationId = accepted.json().conversationId as string;
    const sent = await app.inject({
      method: 'POST',
      url: `/v1/conversations/${conversationId}/messages`,
      headers,
      payload: { body: 'Want to rally this week?' },
    });
    assert.equal(sent.statusCode, 200, sent.body);
    const report = await app.inject({
      method: 'POST',
      url: '/v1/reports',
      headers,
      payload: { targetType: 'user', targetId: casey.id, reason: 'Unwanted messages' },
    });
    assert.equal(report.json().message, 'Thanks, we received this.');

    await app.inject({
      method: 'POST',
      url: '/v1/blocks',
      headers,
      payload: { userId: casey.id },
    });
    const hidden = await app.inject({
      method: 'GET',
      url: `/v1/players?lat=${rileyCell.lat}&lng=${rileyCell.lng}&radiusKm=15`,
      headers,
    });
    assert.equal(
      hidden.json().players.some((player: { displayName: string }) => player.displayName === 'Casey D.'),
      false,
    );
    const alexThread = await app.inject({
      method: 'GET',
      url: `/v1/conversations/${conversationId}/messages`,
      headers,
    });
    const caseyThread = await app.inject({
      method: 'GET',
      url: `/v1/conversations/${conversationId}/messages`,
      headers: authHeader(caseySession.accessToken),
    });
    assert.equal(alexThread.statusCode, 403);
    assert.equal(caseyThread.statusCode, 403);

    const caseyView = await app.inject({
      method: 'GET',
      url: `/v1/players?lat=${rileyCell.lat}&lng=${rileyCell.lng}&radiusKm=5`,
      headers: authHeader(caseySession.accessToken),
    });
    assertNoPrivateLocation(caseyView.json(), ['40.731', '40.75', '-73.991']);
    assert.equal(
      caseyView.json().players.some((player: { displayName: string }) => player.displayName === 'Alex P.'),
      false,
    );
  });
});

test('coach answers forehand into the net with catalog drills only', () => {
  const known = new Set(catalog.drills.map((drill) => drill.slug));
  const answer = answerCoachQuestion({
    question: 'I keep hitting my forehand into the net.',
    rules: catalog.coachRules,
    knownDrillSlugs: known,
    unfinishedLesson: null,
  });
  assert.equal(answer.label, 'coaching_assistance');
  assert.deepEqual(answer.drillSlugs, ['wall-rally', 'forehand-consistency']);
  assert.equal(answer.nextTechniqueSlug, 'contact-point');
  assert.ok(answer.causes.includes('Contact point too low'));
  for (const slug of answer.drillSlugs) assert.equal(known.has(slug), true);

  const filtered = answerCoachQuestion({
    question: 'forehand into the net',
    rules: catalog.coachRules.map((rule) => ({ ...rule, drillSlugs: ['wall-rally', 'not-a-real-drill'] })),
    knownDrillSlugs: known,
    unfinishedLesson: null,
  });
  assert.deepEqual(filtered.drillSlugs, ['wall-rally']);

  const pain = answerCoachQuestion({
    question: 'My forehand causes pain in my wrist.',
    rules: catalog.coachRules,
    knownDrillSlugs: known,
    unfinishedLesson: { slug: 'basic-forehand', title: 'Basic forehand', techniqueSlug: 'forehand' },
  });
  assert.equal(pain.label, 'coaching_assistance');
  assert.deepEqual(pain.drillSlugs, []);
  assert.equal(pain.nextTechniqueSlug, null);
  assert.match(pain.summary, /clinician/i);
  assert.equal(JSON.stringify(pain).includes('wall-rally'), false);

  const fallback = answerCoachQuestion({
    question: 'What shoes should I buy?',
    rules: catalog.coachRules,
    knownDrillSlugs: known,
    unfinishedLesson: { slug: 'basic-forehand', title: 'Basic forehand', techniqueSlug: 'forehand' },
  });
  assert.equal(fallback.label, 'coaching_assistance');
  assert.deepEqual(fallback.drillSlugs, ['forehand-consistency']);
  assert.match(fallback.summary, /Basic forehand/);
});

test('video publish requires attribution and rejects third-party media files', () => {
  const owned: VideoRecord = {
    title: 'Ready position',
    sourceName: 'Baseline',
    creatorName: 'Baseline Studio',
    license: 'original',
    attribution: 'Filmed by Baseline',
    url: 'https://cdn.baseline.example/ready.mp4',
    category: 'technique',
    level: 1,
    technique: 'ready-position',
    durationSeconds: 40,
    playback: 'owned_file',
  };
  assert.equal(isVideoPublishable(owned), true);
  assert.equal(toPlaybackDescriptor(owned)?.mode, 'owned');
  assert.equal(isVideoPublishable({ ...owned, attribution: '   ' }), false);
  assert.equal(isVideoPublishable({ ...owned, attribution: '' }), false);
  assert.equal(isVideoPublishable({ ...owned, technique: 'general' }), true);
  assert.equal(isVideoPublishable({ ...owned, playback: 'owned_file', license: 'public_domain' }), false);

  const thirdParty: VideoRecord = {
    ...owned,
    playback: 'embed',
    license: 'provider_embed',
    attribution: 'Found online',
    url: 'https://videos.example/secret.mp4',
  };
  assert.equal(isVideoPublishable(thirdParty), false);
  assert.equal(toPlaybackDescriptor(thirdParty), null);

  const embed: VideoRecord = {
    ...owned,
    playback: 'embed',
    license: 'provider_embed',
    url: 'https://www.youtube.com/watch?v=baseline-ready',
    attribution: 'Baseline Studio',
  };
  assert.equal(isVideoPublishable(embed), true);
  assert.deepEqual(toPlaybackDescriptor(embed), {
    mode: 'embed',
    url: embed.url,
    attribution: 'Baseline Studio',
  });
});

test('premium lessons stay locked until the development premium header', async () => {
  const summary = 'Cross-court until you have a shorter ball, then change direction.';
  await withApp(async (app) => {
    const session = await signIn(app, 'free@example.com', { birthYear: 1998, displayName: 'Free Player' });
    const headers = authHeader(session.accessToken);
    const locked = await app.inject({ method: 'GET', url: '/v1/lessons/rally-construction', headers });
    assert.equal(locked.statusCode, 403);
    assert.equal(locked.json().error.code, 'premium_required');
    assert.equal(locked.json().title, 'Rally construction');
    assert.equal(locked.json().summary, summary);
    assert.equal(locked.json().blocks, undefined);

    const coachLocked = await app.inject({
      method: 'POST',
      url: '/v1/coach/ask',
      headers,
      payload: { question: 'I keep hitting my forehand into the net.' },
    });
    assert.equal(coachLocked.statusCode, 403);
    assert.equal(coachLocked.json().error.code, 'premium_required');

    const opened = await app.inject({
      method: 'GET',
      url: '/v1/lessons/rally-construction',
      headers: authHeader(session.accessToken, { 'x-dev-premium': 'true' }),
    });
    assert.equal(opened.statusCode, 200, opened.body);
    assert.ok(opened.json().blocks.length > 0);
    assert.equal(opened.json().summary, summary);
    const me = await app.inject({ method: 'GET', url: '/v1/me', headers });
    assert.equal(me.json().entitlement, 'premium');

    const coach = await app.inject({
      method: 'POST',
      url: '/v1/coach/ask',
      headers,
      payload: { question: 'I keep hitting my forehand into the net.' },
    });
    assert.equal(coach.statusCode, 200, coach.body);
    assert.equal(coach.json().label, 'coaching_assistance');
    assert.deepEqual(coach.json().drillSlugs, ['wall-rally', 'forehand-consistency']);

    const rules = await app.inject({ method: 'GET', url: '/v1/rules', headers });
    assert.deepEqual(
      rules.json().articles.map((article: { slug: string }) => article.slug).sort(),
      ['let', 'scoring', 'serve'],
    );
    const equipment = await app.inject({ method: 'GET', url: '/v1/equipment', headers });
    assert.ok(equipment.json().products.length >= 4);
    assert.equal(equipment.json().products.filter((product: { sponsored: boolean }) => product.sponsored).length, 1);

    const deleted = await app.inject({
      method: 'DELETE',
      url: '/v1/me',
      headers,
      payload: { confirm: 'DELETE' },
    });
    assert.equal(deleted.statusCode, 200, deleted.body);
    const refresh = await app.inject({
      method: 'POST',
      url: '/v1/auth/refresh',
      payload: { refreshToken: session.refreshToken },
    });
    assert.equal(refresh.statusCode, 401);
    assert.equal(refresh.json().error.code, 'unauthorized');
  }, { allowDevPremium: true });

  await withApp(async (app) => {
    const session = await signIn(app, 'prod@example.com', { birthYear: 1998, displayName: 'Prod' });
    const locked = await app.inject({
      method: 'GET',
      url: '/v1/lessons/rally-construction',
      headers: authHeader(session.accessToken, { 'x-dev-premium': 'true' }),
    });
    assert.equal(locked.statusCode, 403);
    assert.equal(locked.json().error.code, 'premium_required');
    assert.equal(locked.json().summary, summary);
  }, { allowDevPremium: false });
});

test('health, provider stubs, and search respond', async () => {
  await withApp(async (app) => {
    const health = await app.inject({ method: 'GET', url: '/health' });
    assert.equal(health.statusCode, 200);
    assert.equal(health.json().ok, true);

    const apple = await app.inject({ method: 'POST', url: '/v1/auth/apple', payload: {} });
    assert.equal(apple.statusCode, 501);
    assert.equal(apple.json().error.code, 'not_configured');
    const google = await app.inject({ method: 'POST', url: '/v1/auth/google', payload: {} });
    assert.equal(google.statusCode, 501);
    assert.equal(google.json().error.code, 'not_configured');

    const session = await signIn(app, 'search@example.com', { birthYear: 1990, displayName: 'Searcher' });
    const search = await app.inject({
      method: 'GET',
      url: '/v1/search?q=forehand',
      headers: authHeader(session.accessToken),
    });
    assert.equal(search.statusCode, 200, search.body);
    assert.ok(search.json().results.some((result: { type: string }) => result.type === 'lesson' || result.type === 'drill'));
  });
});

function assertNoPrivateLocation(body: unknown, snippets: string[]): void {
  const keys = collectKeys(body);
  for (const key of ['lat', 'lng', 'latitude', 'longitude', 'locationCell', 'email', 'birthYear']) {
    assert.equal(keys.has(key), false, key);
  }
  const json = JSON.stringify(body);
  for (const snippet of snippets) {
    assert.equal(json.includes(snippet), false, snippet);
  }
  const players = (body as { players?: Array<{ distanceBand?: string }> }).players ?? [];
  for (const player of players) assert.equal(typeof player.distanceBand, 'string');
}
