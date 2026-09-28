# API

Base path `/v1`. JSON. Authenticated routes expect `Authorization: Bearer <access_token>`. Errors use:

```json
{ "error": { "code": "not_found", "message": "Lesson not found" } }
```

Codes: `unauthorized`, `forbidden`, `not_found`, `validation`, `conflict`, `rate_limited`, `premium_required`.

## Auth

| Method | Path | Purpose |
|---|---|---|
| POST | /auth/apple | Identity token in, session out |
| POST | /auth/google | ID token in, session out |
| POST | /auth/email/start | Send a one-time code |
| POST | /auth/email/finish | Code in, session out |
| POST | /auth/refresh | Rotate refresh token |
| POST | /auth/logout | Revoke refresh token |
| DELETE | /me | Delete account and personal content |

Session response: `accessToken`, `refreshToken`, `expiresIn`, `user`.

Email accounts store a one-time code hash, not a password, in the MVP. Password can be added later on `auth_identities`.

## Profile and onboarding

| Method | Path | Purpose |
|---|---|---|
| GET | /me | Profile, entitlement, streak, notification flags |
| PUT | /me/profile | Update level, goals, privacy, availability |
| POST | /me/onboarding | Save the 10 answers and build week 1 |
| PUT | /me/notifications | Toggle each notification class |
| GET | /me/export | JSON export of personal data |

`PUT /me/profile` with `discoverable: true` is rejected when birth year shows the player is under 18.

## Learning

| Method | Path | Purpose |
|---|---|---|
| GET | /levels | Five levels and progress counts |
| GET | /lessons?level=&category= | Published lessons the user may see |
| GET | /lessons/:slug | Blocks, videos, drills, checklist |
| POST | /lessons/:slug/progress | started or completed |
| GET | /techniques?family= | Technique index |
| GET | /techniques/:slug | Full coaching page |
| GET | /glossary?q= | Terms |
| GET | /rules | Rules articles |
| GET | /rules/:slug | One article |

Premium lessons return `premium_required` with the lesson title and summary still visible so the paywall can explain what is locked.

## Video

| Method | Path | Purpose |
|---|---|---|
| GET | /videos/:id | Playback descriptor |

Response is either `{ "mode": "embed", "url", "attribution" }` or `{ "mode": "owned", "url" }` where `url` is a short-lived signed URL. The API never returns a third-party mp4.

## Training and progress

| Method | Path | Purpose |
|---|---|---|
| GET | /drills?level=&technique= | Drill cards |
| GET | /drills/:slug | Full drill |
| POST | /drills/:slug/completions | Log a completion |
| GET | /plans/current | This week |
| POST | /plans/rebuild | Rebuild from current goal and days |
| POST | /plans/items/:id/complete | Mark a block done |
| GET | /progress | Dashboard numbers and 8-week minutes |
| POST | /matches | Add a match log |
| GET | /matches | History |
| GET | /badges | Earned and locked |

## Coaching

| Method | Path | Purpose |
|---|---|---|
| POST | /coach/ask | `{ "question": "I keep hitting my forehand into the net." }` |

Response:

```json
{
  "label": "coaching_assistance",
  "summary": "Several common causes fit a forehand into the net.",
  "causes": ["Contact point too low", "Swing path down through the ball"],
  "nextTechniqueSlug": "contact-point",
  "drillSlugs": ["wall-rally", "forehand-consistency"],
  "practiceNote": "Three short sessions this week beat one long one."
}
```

Premium route. The rules catalog lives in `content/seed/coach_rules.json`. Unknown questions return a safe fallback: review the last unfinished lesson and one consistency drill.

## Discovery

All list routes accept `lat`, `lng`, and `radiusKm`, or `city` when the player did not share GPS. The client may send the device location as a query. It is not stored on the user unless they save a city.

| Method | Path | Purpose |
|---|---|---|
| GET | /courts | Filters: indoor, lights, access, surface |
| GET | /courts/:id | Detail |
| POST | /favorites | `{ placeType, placeId }` |
| DELETE | /favorites/:id | Remove |
| GET | /coaches | Filters: audience, format, price band |
| GET | /coaches/:id | Profile |
| GET | /stores | Filter by service, including stringing |
| GET | /equipment?level=&budget=&category= | Guide |
| GET | /search?q= | Mixed results |

## Partners

| Method | Path | Purpose |
|---|---|---|
| GET | /players | Coarse cards. Query by level, format, setting |
| POST | /connections | Send a request |
| POST | /connections/:id/accept | Accept |
| POST | /connections/:id/decline | Decline |
| GET | /conversations | Inbox |
| GET | /conversations/:id/messages | History |
| POST | /conversations/:id/messages | Send |
| POST | /blocks | Block |
| POST | /reports | Report a user or message |

Player card fields: display name, level label, format, city, distance band, goals, availability summary. No email, no coordinates, no birth year (optional age band only).

## Admin

Prefix `/admin`. Requires `admin_users` role.

- CRUD for lessons, blocks, techniques, drills, videos, courts, coaches, academies, stores, products, glossary, rules
- `POST /admin/videos` rejects publish when license metadata is incomplete
- GET/POST `/admin/reports`
- GET `/admin/users` (no secrets), POST suspend
- GET `/admin/audit`

Editors can draft. Admins publish and suspend.

## Webhooks

`POST /billing/revenuecat` verifies the signature and upserts `entitlements`.

## Rate limits

Auth routes: 10 per minute per IP. Messages: 30 per minute per user. Search: 60 per minute per user.

## Versioning

Breaking changes increment `/v1` to `/v2`. The mobile app sends `X-Client: ios|android` and `X-App-Version`.
