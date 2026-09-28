# Architecture

Baseline is one product with three deployable parts:

1. **Mobile app** (`apps/mobile`) — Flutter. iOS is the launch target. Android uses the same UI and the same API.
2. **API** (`services/api`) — TypeScript, Fastify, PostgreSQL with PostGIS. The app never talks to the database directly.
3. **Admin** (`apps/admin`) — Next.js. Editors publish lessons, drills, videos, courts, coaches, and stores. They also review reports.

```
┌─────────────────┐     ┌─────────────────┐
│  iOS / Android  │     │  Admin web      │
│  Flutter        │     │  Next.js        │
└────────┬────────┘     └────────┬────────┘
         │ HTTPS                 │ HTTPS
         └──────────┬────────────┘
                    ▼
         ┌──────────────────────┐
         │  API  /v1            │
         │  Auth, content,      │
         │  training, discovery,│
         │  social, billing     │
         └──────────┬───────────┘
                    │
     ┌──────────────┼───────────────┐
     ▼              ▼               ▼
 PostgreSQL     Object storage    Push provider
 + PostGIS      images only       APNs now, FCM later
                    │
                    ▼
              Video embeds
              (never re-hosted
               third-party files)
```

## Why this shape

- **One API for iOS, Android, and admin.** Feature work happens once. A phone release does not require a schema change hidden inside the app.
- **Flutter for the client.** Lists, video layouts, charts, and forms are shared. Sign in with Apple, maps, and notifications stay behind small interfaces (`AuthGateway`, `MapGateway`, `PushGateway`) so iOS can feel native.
- **PostgreSQL + PostGIS.** Courts, coaches, stores, and player discovery are “near me” queries. Full-text search on lessons and drills is enough until the catalog is large. A separate search engine can be added behind `SearchService` later.
- **Videos are references, not copies.** Each video row stores source, creator, license, attribution, and a URL. The player embeds an allowed URL or streams a file Baseline owns. The API refuses to store a third-party download URL.

## Modules

Each module owns its tables and exposes a service. HTTP routes call services. Services do not reach into another module’s tables except through that module’s service.

| Module | Owns | MVP |
|---|---|---|
| Identity | Accounts, Apple/Google/email login, sessions, deletion | Yes |
| Profile | Onboarding answers, level, goals, availability, privacy | Yes |
| Learning | Levels 1–5, lessons, techniques, glossary, rules articles | Yes, depth on levels 1–3 |
| Media | Video records and license metadata | Yes |
| Training | Drills, generated plans, logged sessions | Yes |
| Progress | Completions, minutes, streaks, skill ratings, badges | Yes |
| Discovery | Courts, coaches, academies, stores | Yes, seeded + admin-managed |
| Equipment | Guides and recommendations by level, style, and budget | Yes, editorial |
| Partners | Player cards, requests, messaging, block, report | Yes |
| Notifications | Preferences and scheduled reminders | Yes |
| Billing | Free vs Premium entitlement | Interface yes, store product wired at launch |
| Coaching | “Virtual Tennis Pro” suggestions | Rules engine in MVP, model later |
| Community | Posts, groups, events | Tables reserved, UI after MVP |
| Match desk | Pre/during/post match checklists and match logs | Checklist in MVP, stats later |
| Moderation | Reports, audit log | Yes |
| Analysis | Uploaded swing video | Interface only |

## Skill levels

Levels are guidelines. Onboarding sets a starting level. The player can change it at any time. Completing lessons never locks them out of another level.

| Level | Name | MVP content |
|---|---|---|
| 1 | Complete Beginner | Full path |
| 2 | Beginner | Full path |
| 3 | Advanced Beginner | Full path. This is the deepest course. |
| 4 | Intermediate | Outline, key techniques, and drills |
| 5 | Advanced | Outline, key techniques, and drills |

“Rally technique” in the product is **rallying fundamentals**: keeping a ball in play, height, depth, direction, and recovery. It is a technique family, not a typo.

## Virtual Tennis Pro

The app talks to `CoachingService`. The MVP implementation is a **rules coach**:

- Input: current level, goal, days per week, completed lessons, self-reported weakness, and a free-text question.
- A catalog maps symptoms (“forehand into the net”) to likely causes, the technique to open next, and drill ids.
- Output is labeled **coaching assistance**, not a medical or injury diagnosis.
- A later `LlmCoachingService` and `VideoAnalysisService` implement the same interface. The mobile app does not change its request shape.

The pro does not invent drill ids. It only returns ids that exist in the catalog.

## Personalized plans

`PlanBuilder` builds a week from:

- days per week (2, 3, 4, or 5+)
- primary goal (learn from scratch, a stroke, consistency, first match, singles, doubles, fitness, tournament)
- session length budget (default 60 minutes)

A day is an ordered list of blocks: warm-up, footwork, focus technique, second stroke, serve or rally, and a short close. Completing a block writes a `practice_sessions` row and updates the streak.

## Discovery and location

Location permission is requested only when the player opens Discover or chooses “use my location.” They can type a city instead.

- Courts, coaches, and stores store a real point because they are public places.
- Player discovery stores a **coarse cell** (geohash length 5, roughly a few kilometers) plus a radius preference. Responses return a distance band (“within 5 km”), never a lat/long and never a home address.
- Directions open the system maps app with the place’s address.

Court data starts as admin-entered records and OpenStreetMap tennis courts (with OSM attribution). Booking availability is a text field until a venue partner exists. The schema includes `booking_url` so deep links can be added later.

## Payments

`GET /v1/me` includes `entitlement: free | premium`. Premium unlocks the full lesson path past the free set, the full drill library, generated multi-day plans, the rules coach, and progress charts beyond 14 days. RevenueCat (or StoreKit 2 directly) is the source of truth on device. The API trusts a verified store notification, not a flag sent by the app.

Paid placements (a featured coach or a sponsored racket) use `placement: sponsored` and are rendered apart from editorial recommendations.

## Cross-platform seams

| Concern | iOS | Android later |
|---|---|---|
| Sign-in | Sign in with Apple, Google, email | Same API, Google + email |
| Maps | Apple MapKit via `MapGateway` | Google Maps via the same gateway |
| Push | APNs | FCM |
| Subscriptions | App Store | Play Billing, same entitlement names |
| Health / watch | Not in MVP | Same future module |

## Future seams (interfaces now, product later)

- `BookingService` for court and coach booking
- `MatchScoringService` for live score and a rating
- `VideoAnalysisService` for uploaded swings
- `CommunityService` for posts and groups
- `TournamentService` for events and leagues
- Wearables and ball-machine integrations sit behind `TrainingSignalService` so they only add session facts

## Environments

`local`, `staging`, `production`. Secrets live in the host’s secret store, not in the app binary. The mobile app ships with a public API base URL and a RevenueCat public key only.

## Suggested stack

| Layer | Choice |
|---|---|
| Mobile | Flutter 3, Dart 3, `go_router`, Riverpod |
| Admin | Next.js, TypeScript, server-side calls to the API |
| API | Node 22, Fastify, Zod, Drizzle ORM |
| Database | PostgreSQL 16, PostGIS |
| Images | S3-compatible bucket, private by default, signed URLs |
| Auth tokens | Short-lived JWT access token, rotating refresh token |
| Jobs | Postgres-backed queue table in MVP, worker process later |
