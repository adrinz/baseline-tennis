# Baseline API

In-memory HTTP API for the Baseline tennis app. It serves the MVP routes from `docs/api.md` without PostgreSQL. Content is loaded from `content/seed/catalog.json`.

## Run

From this directory:

```bash
npm install
npm test
npm run dev
```

The server listens on port **8787**.

`npm run dev` resolves the seed catalog from the service directory (`../../content/seed/catalog.json`), so the working directory should be `services/api`.

## Auth

Email login uses a one-time code. In this MVP the code is always `000000`. No message is sent.

Sign in with Apple and Sign in with Google respond with HTTP 501 and `not_configured` until credentials exist.

Access tokens last 15 minutes. Send `Authorization: Bearer <accessToken>`. Refresh tokens rotate.

Accounts require a birth year. Under 16 is rejected. Under 18 can learn and browse courts, coaches, and stores, and cannot turn on player discovery or message.

Users start on the free plan. In development, `X-Dev-Premium: true` on an authenticated request upgrades that user. The header is ignored when the process is built with premium disabled (`NODE_ENV=production`).

## Examples

```bash
curl -s http://127.0.0.1:8787/health
```

```bash
curl -s -X POST http://127.0.0.1:8787/v1/auth/email/start \
  -H 'content-type: application/json' \
  -d '{"email":"ada@example.com"}'
```

```bash
curl -s -X POST http://127.0.0.1:8787/v1/auth/email/finish \
  -H 'content-type: application/json' \
  -d '{"email":"ada@example.com","code":"000000","birthYear":1998,"displayName":"Ada"}'
```

Use the `accessToken` from that response as `TOKEN` below.

```bash
curl -s http://127.0.0.1:8787/v1/me \
  -H "authorization: Bearer $TOKEN"
```

```bash
curl -s -X POST http://127.0.0.1:8787/v1/me/onboarding \
  -H "authorization: Bearer $TOKEN" \
  -H 'content-type: application/json' \
  -d '{"playedBefore":false,"level":1,"playFrequency":"new","primaryGoal":"learn from scratch","format":"singles","daysPerWeek":3,"focusSkills":["forehand"],"homeCity":"Riverton","setting":"outdoor"}'
```

```bash
curl -s http://127.0.0.1:8787/v1/plans/current \
  -H "authorization: Bearer $TOKEN"
```

```bash
curl -s http://127.0.0.1:8787/v1/lessons/rally-construction \
  -H "authorization: Bearer $TOKEN"
```

That lesson is premium. The response is `premium_required` and still includes the title and summary. Retry with `-H 'x-dev-premium: true'` to open the blocks.

```bash
curl -s -X POST http://127.0.0.1:8787/v1/coach/ask \
  -H "authorization: Bearer $TOKEN" \
  -H 'x-dev-premium: true' \
  -H 'content-type: application/json' \
  -d '{"question":"I keep hitting my forehand into the net."}'
```

```bash
curl -s 'http://127.0.0.1:8787/v1/courts?lat=40.73&lng=-73.99&radiusKm=5' \
  -H "authorization: Bearer $TOKEN"
```

```bash
curl -s 'http://127.0.0.1:8787/v1/players?lat=40.75&lng=-74&radiusKm=15' \
  -H "authorization: Bearer $TOKEN"
```

Player results include `distanceBand` only. They do not include coordinates, email, or birth year.

```bash
curl -s -X POST http://127.0.0.1:8787/v1/auth/refresh \
  -H 'content-type: application/json' \
  -d '{"refreshToken":"'"$REFRESH"'"}'
```

```bash
curl -s -X POST http://127.0.0.1:8787/v1/auth/logout \
  -H 'content-type: application/json' \
  -d '{"refreshToken":"'"$REFRESH"'"}'
```

```bash
curl -s -X DELETE http://127.0.0.1:8787/v1/me \
  -H "authorization: Bearer $TOKEN" \
  -H 'content-type: application/json' \
  -d '{"confirm":"DELETE"}'
```

## Routes

| Method | Path |
|---|---|
| GET | `/health` |
| POST | `/v1/auth/email/start` |
| POST | `/v1/auth/email/finish` |
| POST | `/v1/auth/refresh` |
| POST | `/v1/auth/logout` |
| POST | `/v1/auth/apple` |
| POST | `/v1/auth/google` |
| GET | `/v1/me` |
| PUT | `/v1/me` |
| PUT | `/v1/me/profile` |
| POST | `/v1/me/onboarding` |
| PUT | `/v1/me/notifications` |
| GET | `/v1/me/export` |
| DELETE | `/v1/me` |
| GET | `/v1/levels` |
| GET | `/v1/lessons` |
| GET | `/v1/lessons/:slug` |
| POST | `/v1/lessons/:slug/progress` |
| GET | `/v1/techniques` |
| GET | `/v1/techniques/:slug` |
| GET | `/v1/glossary` |
| GET | `/v1/rules` |
| GET | `/v1/rules/:slug` |
| GET | `/v1/videos/:id` |
| GET | `/v1/drills` |
| GET | `/v1/drills/:slug` |
| POST | `/v1/drills/:slug/completions` |
| GET | `/v1/plans/current` |
| POST | `/v1/plans/rebuild` |
| POST | `/v1/plans/items/:id/complete` |
| GET | `/v1/progress` |
| POST | `/v1/coach/ask` |
| GET | `/v1/courts` |
| GET | `/v1/courts/:id` |
| GET | `/v1/coaches` |
| GET | `/v1/coaches/:id` |
| GET | `/v1/stores` |
| GET | `/v1/players` |
| POST | `/v1/favorites` |
| DELETE | `/v1/favorites/:id` |
| GET | `/v1/equipment` |
| GET | `/v1/search` |
| POST | `/v1/connections` |
| POST | `/v1/connections/:id/accept` |
| POST | `/v1/connections/:id/decline` |
| GET | `/v1/conversations` |
| GET | `/v1/conversations/:id/messages` |
| POST | `/v1/conversations/:id/messages` |
| POST | `/v1/blocks` |
| POST | `/v1/reports` |

Discovery data is fictional and in memory: three courts, two coaches, two stores, and two discoverable players (`Riley M.`, `Casey D.`). Rules articles for scoring, the serve, and the let are original text in `src/content/rules.ts`. Videos are references only. `GET /v1/videos/:id` does not return a third-party mp4.
