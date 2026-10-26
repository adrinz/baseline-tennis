import assert from 'node:assert/strict';
import test from 'node:test';
import { buildApp } from '../src/app.ts';
import type { FastifyInstance } from 'fastify';

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
): Promise<{ accessToken: string; refreshToken: string }> {
  const started = await app.inject({
    method: 'POST',
    url: '/v1/auth/email/start',
    payload: { email },
  });
  assert.equal(started.statusCode, 200, started.body);
  const finished = await app.inject({
    method: 'POST',
    url: '/v1/auth/email/finish',
    payload: { email, code: '000000', birthYear: 1990, displayName: 'Surface tester' },
  });
  assert.equal(finished.statusCode, 200, finished.body);
  return finished.json();
}

function auth(accessToken: string): Record<string, string> {
  return { authorization: `Bearer ${accessToken}` };
}

test('API client surface returns contracts for learning, training, discovery, and profile', async () => {
  await withApp(async (app) => {
    const session = await signIn(app, 'client-surface@example.com');
    const headers = auth(session.accessToken);

    const onboarding = await app.inject({
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
    assert.equal(onboarding.statusCode, 200, onboarding.body);

    const me = await app.inject({ method: 'GET', url: '/v1/me', headers });
    assert.equal(me.statusCode, 200, me.body);
    assert.equal(typeof me.json().id, 'string');

    const levels = await app.inject({ method: 'GET', url: '/v1/levels', headers });
    assert.equal(levels.statusCode, 200, levels.body);
    assert.equal(levels.json().levels.length, 5);

    const lessons = await app.inject({
      method: 'GET',
      url: '/v1/lessons?level=1',
      headers,
    });
    assert.equal(lessons.statusCode, 200, lessons.body);
    assert.ok(Array.isArray(lessons.json().lessons));
    assert.ok(lessons.json().lessons.length > 0);

    const lesson = await app.inject({
      method: 'GET',
      url: '/v1/lessons/welcome-to-tennis',
      headers,
    });
    assert.equal(lesson.statusCode, 200, lesson.body);
    assert.ok(Array.isArray(lesson.json().blocks));
    const progress = await app.inject({
      method: 'POST',
      url: '/v1/lessons/welcome-to-tennis/progress',
      headers,
      payload: { status: 'started' },
    });
    assert.equal(progress.statusCode, 200, progress.body);
    assert.equal(progress.json().status, 'started');

    const techniques = await app.inject({ method: 'GET', url: '/v1/techniques?family=groundstroke', headers });
    assert.equal(techniques.statusCode, 200, techniques.body);
    assert.ok(techniques.json().techniques.length > 0);
    const technique = await app.inject({ method: 'GET', url: '/v1/techniques/forehand', headers });
    assert.equal(technique.statusCode, 200, technique.body);

    const glossary = await app.inject({ method: 'GET', url: '/v1/glossary?q=let', headers });
    assert.equal(glossary.statusCode, 200, glossary.body);
    assert.ok(glossary.json().terms.length > 0);
    const rules = await app.inject({ method: 'GET', url: '/v1/rules/scoring', headers });
    assert.equal(rules.statusCode, 200, rules.body);

    const drills = await app.inject({ method: 'GET', url: '/v1/drills?level=1&technique=forehand', headers });
    assert.equal(drills.statusCode, 200, drills.body);
    assert.ok(drills.json().drills.length > 0);
    const drill = await app.inject({ method: 'GET', url: '/v1/drills/wall-rally', headers });
    assert.equal(drill.statusCode, 200, drill.body);
    const completion = await app.inject({
      method: 'POST',
      url: '/v1/drills/wall-rally/completions',
      headers,
      payload: { minutes: 10 },
    });
    assert.equal(completion.statusCode, 200, completion.body);

    const plan = await app.inject({ method: 'GET', url: '/v1/plans/current', headers });
    assert.equal(plan.statusCode, 200, plan.body);
    assert.ok(Array.isArray(plan.json().items));
    const rebuilt = await app.inject({ method: 'POST', url: '/v1/plans/rebuild', headers });
    assert.equal(rebuilt.statusCode, 200, rebuilt.body);
    const progressSummary = await app.inject({ method: 'GET', url: '/v1/progress', headers });
    assert.equal(progressSummary.statusCode, 200, progressSummary.body);

    for (const [path, key] of [
      ['/v1/courts?lat=40.73&lng=-73.99&radiusKm=5', 'courts'],
      ['/v1/coaches?lat=40.73&lng=-73.99&radiusKm=5', 'coaches'],
      ['/v1/stores?lat=40.73&lng=-73.99&radiusKm=5', 'stores'],
      ['/v1/players?lat=40.73&lng=-73.99&radiusKm=5', 'players'],
    ] as const) {
      const response = await app.inject({ method: 'GET', url: path, headers });
      assert.equal(response.statusCode, 200, response.body);
      assert.ok(Array.isArray(response.json()[key]));
    }

    const equipment = await app.inject({ method: 'GET', url: '/v1/equipment?level=1&budget=mid', headers });
    assert.equal(equipment.statusCode, 200, equipment.body);
    assert.ok(Array.isArray(equipment.json().products));
    const search = await app.inject({ method: 'GET', url: '/v1/search?q=forehand', headers });
    assert.equal(search.statusCode, 200, search.body);
    assert.ok(Array.isArray(search.json().results));
    const unavailableVideo = await app.inject({ method: 'GET', url: '/v1/videos/mobile-local', headers });
    assert.equal(unavailableVideo.statusCode, 404);

    const updatedProfile = await app.inject({
      method: 'PUT',
      url: '/v1/me/profile',
      headers,
      payload: { level: 2, discoverable: true, homeCity: 'Riverton' },
    });
    assert.equal(updatedProfile.statusCode, 200, updatedProfile.body);
    assert.equal(updatedProfile.json().profile.level, 2);
    const notifications = await app.inject({
      method: 'PUT',
      url: '/v1/me/notifications',
      headers,
      payload: { practiceReminders: false, weeklyProgress: true },
    });
    assert.equal(notifications.statusCode, 200, notifications.body);
    assert.equal(notifications.json().practiceReminders, false);
    assert.equal(notifications.json().weeklyProgress, true);
    const exported = await app.inject({ method: 'GET', url: '/v1/me/export', headers });
    assert.equal(exported.statusCode, 200, exported.body);
    assert.ok(exported.json().profile);
  });
});

test('API client surface rejects protected requests without a session', async () => {
  await withApp(async (app) => {
    for (const url of [
      '/v1/me',
      '/v1/levels',
      '/v1/lessons',
      '/v1/drills',
      '/v1/plans/current',
      '/v1/progress',
      '/v1/techniques',
      '/v1/glossary',
      '/v1/rules',
      '/v1/courts?lat=40.73&lng=-73.99&radiusKm=5',
      '/v1/players?lat=40.73&lng=-73.99&radiusKm=5',
      '/v1/equipment',
      '/v1/search?q=forehand',
    ]) {
      const response = await app.inject({ method: 'GET', url });
      assert.equal(response.statusCode, 401, url);
      assert.equal(response.json().error.code, 'unauthorized', url);
    }
  });
});
