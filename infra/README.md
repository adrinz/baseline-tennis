# Infrastructure

Baseline has three environments: `local`, `staging`, and `production`. Secrets live in the host secret store. The mobile app ships with a public API base URL and a RevenueCat public key only. This file lists environment variable names and contains no secret values.

CI is [`.github/workflows/ci.yml`](../.github/workflows/ci.yml). On every push and pull request it runs API lint, typecheck, and `npm test` when `services/api` defines those scripts, Flutter analyze (and `flutter test` when `apps/mobile/test` exists), and admin `typecheck` when `apps/admin` is present. It does not read signing secrets. A manual run can set the `testflight` input; that job only reports that signing secrets are not configured.

## Local

Use Node.js 22 and the Flutter stable channel, matching CI.

### Postgres 16 with PostGIS

Start a disposable database with the PostGIS image. `local-dev-only` is a machine-local database password. Use a different password in staging and production, and keep those values in the host secret store.

```bash
docker run --name baseline-postgres \
  --restart unless-stopped \
  -e POSTGRES_USER=baseline \
  -e POSTGRES_PASSWORD=local-dev-only \
  -e POSTGRES_DB=baseline \
  -p 5432:5432 \
  -d postgis/postgis:16-3.4

until docker exec baseline-postgres pg_isready -U baseline -d baseline; do sleep 1; done

export DATABASE_URL="postgres://baseline:local-dev-only@127.0.0.1:5432/baseline"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

### Apply migrations

From `services/api`, apply every SQL file in `services/api/db/migrations` in lexical order. Drizzle’s generated names sort in apply order.

```bash
cd services/api
export DATABASE_URL="postgres://baseline:local-dev-only@127.0.0.1:5432/baseline"

if [ ! -d db/migrations ]; then
  echo "services/api/db/migrations is not present yet."
else
  found=0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    found=1
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$f" || exit 1
  done < <(find db/migrations -maxdepth 1 -type f -name '*.sql' | sort)
  if [ "$found" -eq 0 ]; then
    echo "No SQL files in services/api/db/migrations yet."
  fi
fi
```

When the API package defines a `db:migrate` script, run that instead so Drizzle’s journal stays in charge:

```bash
npm run db:migrate
```

### Run the API on port 8787

```bash
cd services/api
if [ -f package-lock.json ]; then npm ci; else npm install; fi
export DATABASE_URL="postgres://baseline:local-dev-only@127.0.0.1:5432/baseline"
export PORT=8787
npm run dev
```

The process listens on port 8787. The iOS Simulator reaches it at `http://127.0.0.1:8787`. Authenticated routes use `/v1`.

### Run Flutter

Point the app’s public API base URL at `http://127.0.0.1:8787`, then:

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter run
```

Run `flutter test` when `apps/mobile/test` exists.

## Staging

1. Provision managed PostgreSQL 16 and enable PostGIS (`CREATE EXTENSION postgis`).
2. Apply `services/api/db/migrations` to that database before the new API revision serves traffic. Use the same order as local.
3. Create a private S3-compatible bucket for images. The API issues signed URLs. Objects stay private.
4. Build a container image from `services/api` and run it behind HTTPS. The process listens on 8787 inside the container.
5. Pass these names in from the host secret store when the container starts. Names only:

   - `DATABASE_URL`
   - `TOKEN_SECRET`
   - `APPLE_CLIENT_ID`
   - `GOOGLE_CLIENT_ID`
   - `REVENUECAT_WEBHOOK_SECRET`
   - `S3_BUCKET` (S3 bucket)

6. Point the staging mobile build’s public API base URL at the staging API. The RevenueCat public key may ship in the app binary. `REVENUECAT_WEBHOOK_SECRET` stays on the server and verifies `POST /billing/revenuecat` (base path `/v1`).

## Production release order

Ship in this order, from the release checklist in `docs/testing-release.md`:

1. Apply migrations on staging, then on production.
2. Publish seed content so lessons and related records are published.
3. Run the license report and confirm every published video has a license.
4. Match paywall products to the RevenueCat offerings.
5. Complete a crash-free smoke test of the version-1 success path.
6. Record the rollback note: the API is backward compatible with the live app version.

TestFlight still needs a small phone and a current phone before App Store review. The `testflight` workflow input does not sign or upload a build.

## Rollback

The API stays backward compatible with the app version already on TestFlight or the App Store.

- Keep `/v1` working for that live build. Place breaking HTTP changes on `/v2`. The app sends `X-Client` and `X-App-Version`.
- Ship additive schema changes (new tables and new columns) so the previous API image still starts on the current database.
- Roll back a bad API deploy by running the previous container image again. Leave the migrated schema in place.
- Deploy the API revision that the store build calls before you release a mobile build that depends on new routes.
