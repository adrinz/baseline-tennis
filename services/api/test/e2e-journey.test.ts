import assert from 'node:assert/strict';
import test from 'node:test';
import { buildApp } from '../src/app.ts';
import { coarseCell } from '../src/geo.ts';
import { collectKeys } from '../src/player-card.ts';
import type { FastifyInstance } from 'fastify';

const rileyCell = coarseCell(40.731, -73.991);
const near = `lat=${rileyCell.lat}&lng=${rileyCell.lng}`;

async function withApp(run: (app: FastifyInstance) => Promise<void>): Promise<void> {
  const app = await buildApp({ allowDevPremium: true });
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
): Promise<{ accessToken: string; refreshToken: string; user: { id: string } }> {
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

function auth(accessToken: string, extra?: Record<string, string>): Record<string, string> {
  return { authorization: `Bearer ${accessToken}`, ...extra };
}

function names(body: { courts?: Array<{ name: string }>; coaches?: Array<{ name: string }>; stores?: Array<{ name: string }>; players?: Array<{ displayName: string }> }, key: 'courts' | 'coaches' | 'stores' | 'players'): string[] {
  const rows = body[key] ?? [];
  return rows.map((row) => ('name' in row ? row.name : row.displayName));
}

function assertNoPlayerCoordinates(body: unknown): void {
  const keys = collectKeys(body);
  for (const key of ['lat', 'lng', 'latitude', 'longitude', 'locationCell', 'email', 'birthYear']) {
    assert.equal(keys.has(key), false, key);
  }
}

test('E2E-API player journey covers auth, learning, discovery, partners, and deletion', async () => {
  await withApp(async (app) => {
    const unsigned = await app.inject({ method: 'GET', url: '/v1/me' });
    assert.equal(unsigned.statusCode, 401);
    assert.equal(unsigned.json().error.code, 'unauthorized');

    const email = 'journey@example.com';
    const started = await app.inject({
      method: 'POST',
      url: '/v1/auth/email/start',
      payload: { email },
    });
    assert.equal(started.json().delivery, 'dev');
    const wrong = await app.inject({
      method: 'POST',
      url: '/v1/auth/email/finish',
      payload: { email, code: '111111', birthYear: 1990, displayName: 'Journey' },
    });
    assert.equal(wrong.statusCode, 401);
    assert.equal(wrong.json().error.code, 'unauthorized');

    const session = await signIn(app, email, { birthYear: 1990, displayName: 'Journey' });
    const headers = auth(session.accessToken);

    const me = await app.inject({ method: 'GET', url: '/v1/me', headers });
    assert.equal(me.statusCode, 200, me.body);
    assert.equal(me.json().entitlement, 'free');
    assert.equal(me.json().profile.discoverable, false);

    const halfLocation = await app.inject({
      method: 'PUT',
      url: '/v1/me',
      headers,
      payload: { latitude: 40.73 },
    });
    assert.equal(halfLocation.statusCode, 400);
    assert.equal(halfLocation.json().error.code, 'validation');

    const onboard = await app.inject({
      method: 'POST',
      url: '/v1/me/onboarding',
      headers,
      payload: {
        playedBefore: true,
        level: 1,
        playFrequency: 'weekly',
        primaryGoal: 'Rally with consistency',
        format: 'singles',
        daysPerWeek: 3,
        focusSkills: ['forehand'],
        homeCity: 'Dix Hills',
        setting: 'outdoor',
        availability: { summary: 'Weeknights' },
      },
    });
    assert.equal(onboard.statusCode, 200, onboard.body);
    const plan = onboard.json().plan;
    assert.equal(plan.daysPerWeek, 3);
    assert.equal(plan.items.length, 12);
    assert.equal(plan.goal, 'Rally with consistency');
    const firstItem = plan.items[0];
    assert.equal(firstItem.completed, false);

    const completedItem = await app.inject({
      method: 'POST',
      url: `/v1/plans/items/${firstItem.id}/complete`,
      headers,
    });
    assert.equal(completedItem.statusCode, 200, completedItem.body);
    assert.equal(completedItem.json().item.completed, true);
    const again = await app.inject({
      method: 'POST',
      url: `/v1/plans/items/${firstItem.id}/complete`,
      headers,
    });
    assert.equal(again.statusCode, 409);

    const lesson = await app.inject({
      method: 'GET',
      url: '/v1/lessons/welcome-to-tennis',
      headers,
    });
    assert.equal(lesson.statusCode, 200, lesson.body);
    assert.ok(lesson.json().blocks.length > 0);
    const progress = await app.inject({
      method: 'POST',
      url: '/v1/lessons/welcome-to-tennis/progress',
      headers,
      payload: { status: 'completed' },
    });
    assert.equal(progress.statusCode, 200, progress.body);
    assert.equal(progress.json().status, 'completed');

    const locked = await app.inject({
      method: 'GET',
      url: '/v1/lessons/rally-construction',
      headers,
    });
    assert.equal(locked.statusCode, 403);
    assert.equal(locked.json().error.code, 'premium_required');
    assert.equal(locked.json().title, 'Rally construction');
    assert.equal(locked.json().blocks, undefined);

    const coachLocked = await app.inject({
      method: 'POST',
      url: '/v1/coach/ask',
      headers,
      payload: { question: 'I keep hitting my forehand into the net.' },
    });
    assert.equal(coachLocked.statusCode, 403);
    assert.equal(coachLocked.json().error.code, 'premium_required');

    const drills = await app.inject({ method: 'GET', url: '/v1/drills', headers });
    assert.equal(drills.statusCode, 200, drills.body);
    assert.ok(drills.json().drills.some((drill: { slug: string }) => drill.slug === 'wall-rally'));
    const drillDone = await app.inject({
      method: 'POST',
      url: '/v1/drills/wall-rally/completions',
      headers,
      payload: { minutes: 12 },
    });
    assert.equal(drillDone.statusCode, 200, drillDone.body);

    const levels = await app.inject({ method: 'GET', url: '/v1/levels', headers });
    assert.deepEqual(
      levels.json().levels.map((level: { name: string }) => level.name),
      ['Complete Beginner', 'Beginner', 'Advanced Beginner', 'Intermediate', 'Advanced'],
    );
    const glossary = await app.inject({ method: 'GET', url: '/v1/glossary?q=let', headers });
    assert.equal(glossary.statusCode, 200, glossary.body);
    assert.ok(glossary.json().terms.length > 0);
    const scoring = await app.inject({ method: 'GET', url: '/v1/rules/scoring', headers });
    assert.equal(scoring.statusCode, 200, scoring.body);
    const techniques = await app.inject({ method: 'GET', url: '/v1/techniques', headers });
    assert.equal(techniques.statusCode, 200, techniques.body);
    const techniqueRows = techniques.json().techniques as Array<{ slug: string; name: string; family: string }>;
    const bySlug = new Map(techniqueRows.map((row) => [row.slug, row]));
    for (const slug of ['slice', 'drop', 'lob', 'smash', 'return', 'contact-point', 'topspin', 'second-serve']) {
      assert.ok(bySlug.has(slug), slug);
    }
    assert.equal(bySlug.get('contact-point')?.name, 'Contact point');
    assert.equal(bySlug.get('contact-point')?.family, 'groundstroke');
    assert.equal(bySlug.get('drop')?.name, 'Drop shot');
    assert.equal(bySlug.get('drop')?.family, 'specialty');
    assert.equal(bySlug.get('smash')?.family, 'net');

    const missingVideo = await app.inject({ method: 'GET', url: '/v1/videos/missing', headers });
    assert.equal(missingVideo.statusCode, 404);

    const closeCourts = await app.inject({
      method: 'GET',
      url: '/v1/courts?lat=40.73&lng=-73.99&radiusKm=1',
      headers,
    });
    const wideCourts = await app.inject({
      method: 'GET',
      url: '/v1/courts?lat=40.73&lng=-73.99&radiusKm=15',
      headers,
    });
    const closeCourtNames = names(closeCourts.json(), 'courts');
    const wideCourtNames = names(wideCourts.json(), 'courts');
    assert.deepEqual(closeCourtNames.sort(), ['North Loop Indoor Tennis', 'Riverton Municipal Courts']);
    for (const name of closeCourtNames) assert.ok(wideCourtNames.includes(name), name);
    assert.ok(wideCourtNames.includes('Cedar Park Public Courts'));
    const court = await app.inject({
      method: 'GET',
      url: '/v1/courts/court-riverton-municipal',
      headers,
    });
    assert.equal(court.statusCode, 200, court.body);
    assert.equal(court.json().name, 'Riverton Municipal Courts');

    const closeCoaches = names(
      (await app.inject({ method: 'GET', url: '/v1/coaches?lat=40.73&lng=-73.99&radiusKm=1', headers })).json(),
      'coaches',
    );
    const wideCoaches = names(
      (await app.inject({ method: 'GET', url: '/v1/coaches?lat=40.73&lng=-73.99&radiusKm=15', headers })).json(),
      'coaches',
    );
    assert.ok(closeCoaches.includes('Avery Lane'));
    for (const name of closeCoaches) assert.ok(wideCoaches.includes(name), name);

    const closeStores = names(
      (await app.inject({ method: 'GET', url: '/v1/stores?lat=40.73&lng=-73.99&radiusKm=1', headers })).json(),
      'stores',
    );
    const wideStores = names(
      (await app.inject({ method: 'GET', url: '/v1/stores?lat=40.73&lng=-73.99&radiusKm=15', headers })).json(),
      'stores',
    );
    assert.deepEqual(closeStores, ['String and Grip Shop']);
    for (const name of closeStores) assert.ok(wideStores.includes(name), name);
    assert.ok(wideStores.includes('Baseline Outfitters'));

    const favorite = await app.inject({
      method: 'POST',
      url: '/v1/favorites',
      headers,
      payload: { placeType: 'court', placeId: 'court-riverton-municipal' },
    });
    assert.equal(favorite.statusCode, 200, favorite.body);
    const duplicate = await app.inject({
      method: 'POST',
      url: '/v1/favorites',
      headers,
      payload: { placeType: 'court', placeId: 'court-riverton-municipal' },
    });
    assert.equal(duplicate.statusCode, 409);

    const located = await app.inject({
      method: 'PUT',
      url: '/v1/me',
      headers,
      payload: {
        discoverable: true,
        homeCity: 'Riverton',
        latitude: 40.731,
        longitude: -73.991,
        searchRadiusKm: 15,
      },
    });
    assert.equal(located.statusCode, 200, located.body);
    assert.equal(located.json().profile.hasLocationCell, true);
    assert.equal(located.json().profile.searchRadiusKm, 15);
    assertNoPlayerCoordinates(located.json().profile);
    assert.equal(JSON.stringify(located.json().profile).includes('40.731'), false);

    const playersNear = await app.inject({
      method: 'GET',
      url: `/v1/players?${near}&radiusKm=3`,
      headers,
    });
    const playersWide = await app.inject({
      method: 'GET',
      url: `/v1/players?${near}&radiusKm=15`,
      headers,
    });
    const nearNames = names(playersNear.json(), 'players');
    const wideNames = names(playersWide.json(), 'players');
    assert.deepEqual(nearNames, ['Riley M.']);
    for (const name of nearNames) assert.ok(wideNames.includes(name), name);
    assert.ok(wideNames.includes('Casey D.'));
    assert.equal(playersWide.json().players[0].distanceBand.length > 0, true);
    assertNoPlayerCoordinates(playersWide.json());
    assert.equal(JSON.stringify(playersWide.json()).includes('40.75'), false);
    assert.equal(JSON.stringify(playersWide.json()).includes('riley.m@'), false);

    const riley = playersWide.json().players.find((player: { displayName: string }) => player.displayName === 'Riley M.');
    const casey = playersWide.json().players.find((player: { displayName: string }) => player.displayName === 'Casey D.');
    const blocked = await app.inject({
      method: 'POST',
      url: '/v1/blocks',
      headers,
      payload: { userId: riley.id },
    });
    assert.equal(blocked.statusCode, 200, blocked.body);
    const afterBlock = names(
      (await app.inject({ method: 'GET', url: `/v1/players?${near}&radiusKm=15`, headers })).json(),
      'players',
    );
    assert.equal(afterBlock.includes('Riley M.'), false);
    assert.equal(afterBlock.includes('Casey D.'), true);

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
      headers: auth(caseySession.accessToken),
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
    const inbox = await app.inject({ method: 'GET', url: '/v1/conversations', headers });
    assert.equal(inbox.statusCode, 200, inbox.body);
    const report = await app.inject({
      method: 'POST',
      url: '/v1/reports',
      headers,
      payload: { targetType: 'user', targetId: casey.id, reason: 'Unwanted messages' },
    });
    assert.equal(report.json().message, 'Thanks, we received this.');

    const notes = await app.inject({
      method: 'PUT',
      url: '/v1/me/notifications',
      headers,
      payload: { practiceReminders: false, messages: true },
    });
    assert.equal(notes.statusCode, 200, notes.body);
    assert.equal(notes.json().practiceReminders, false);
    assert.equal(notes.json().messages, true);

    const equipment = await app.inject({ method: 'GET', url: '/v1/equipment', headers });
    assert.equal(
      equipment.json().products.filter((product: { sponsored: boolean }) => product.sponsored).length,
      1,
    );
    const search = await app.inject({ method: 'GET', url: '/v1/search', headers });
    assert.equal(search.statusCode, 400);
    const found = await app.inject({ method: 'GET', url: '/v1/search?q=forehand', headers });
    assert.equal(found.statusCode, 200, found.body);
    assert.ok(found.json().results.length > 0);

    const opened = await app.inject({
      method: 'GET',
      url: '/v1/lessons/rally-construction',
      headers: auth(session.accessToken, { 'x-dev-premium': 'true' }),
    });
    assert.equal(opened.statusCode, 200, opened.body);
    assert.ok(opened.json().blocks.length > 0);
    const coach = await app.inject({
      method: 'POST',
      url: '/v1/coach/ask',
      headers,
      payload: { question: 'I keep hitting my forehand into the net.' },
    });
    assert.equal(coach.statusCode, 200, coach.body);
    assert.equal(coach.json().label, 'coaching_assistance');
    assert.ok(coach.json().drillSlugs.includes('wall-rally'));
    const pain = await app.inject({
      method: 'POST',
      url: '/v1/coach/ask',
      headers,
      payload: { question: 'My forehand causes pain in my wrist.' },
    });
    assert.match(pain.json().summary, /clinician/i);
    assert.deepEqual(pain.json().drillSlugs, []);

    const exported = await app.inject({ method: 'GET', url: '/v1/me/export', headers });
    assert.equal(exported.statusCode, 200, exported.body);
    assert.equal(exported.json().favorites.length, 1);
    assert.equal(exported.json().messagesSent.length, 1);
    assertNoPlayerCoordinates(exported.json().profile);
    assert.equal(JSON.stringify(exported.json()).includes('40.731'), false);

    const removed = await app.inject({
      method: 'DELETE',
      url: `/v1/favorites/${favorite.json().id}`,
      headers,
    });
    assert.equal(removed.statusCode, 204);

    const loggedOut = await app.inject({
      method: 'POST',
      url: '/v1/auth/logout',
      payload: { refreshToken: session.refreshToken },
    });
    assert.equal(loggedOut.statusCode, 204);
    const refresh = await app.inject({
      method: 'POST',
      url: '/v1/auth/refresh',
      payload: { refreshToken: session.refreshToken },
    });
    assert.equal(refresh.statusCode, 401);

    const deleted = await app.inject({
      method: 'DELETE',
      url: '/v1/me',
      headers,
      payload: { confirm: 'DELETE' },
    });
    assert.equal(deleted.statusCode, 200, deleted.body);
    const afterDelete = await app.inject({ method: 'GET', url: '/v1/me', headers });
    assert.equal(afterDelete.statusCode, 401);
  });
});
