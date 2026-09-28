# Baseline

Baseline is a tennis learning, training, and local-play app. A player can go from “I have never played” to a guided path: learn a technique, practice a drill, find a court, find a partner, and track progress.

The first client is iOS. The mobile app is Flutter so the same product can ship on Android later without a second backend. Maps, sign-in, and push notifications sit behind interfaces so iOS can use Apple services while Android uses the equivalents.

## Read this first

| Document | What it decides |
|---|---|
| [docs/architecture.md](docs/architecture.md) | System shape, modules, and technology |
| [docs/product-requirements.md](docs/product-requirements.md) | Who it is for, MVP scope, and acceptance |
| [docs/user-flows-and-navigation.md](docs/user-flows-and-navigation.md) | Flows and the five-tab navigation |
| [docs/data-model.md](docs/data-model.md) | Database tables and relationships |
| [docs/api.md](docs/api.md) | HTTP API the app and admin panel share |
| [docs/content-licensing.md](docs/content-licensing.md) | How lessons and videos are stored and licensed |
| [docs/security-privacy.md](docs/security-privacy.md) | Auth, location privacy, safety, and account deletion |
| [docs/mvp-roadmap.md](docs/mvp-roadmap.md) | Build order and later features |
| [docs/testing-release.md](docs/testing-release.md) | Test strategy and App Store release |

## Repository layout

```
baseline/
  apps/mobile/          Flutter app (iOS first, Android-ready)
  apps/admin/           Web CMS for lessons, drills, places, and reports
  services/api/         HTTP API and background jobs
  content/seed/         Original lesson, drill, and glossary seed data
  docs/                 Architecture and product source of truth
  infra/                CI and deployment notes
```

## Product name

**Baseline.** The name is a tennis term and the promise: start from a solid base and improve on purpose.
