# Baseline database

PostgreSQL 16 with PostGIS. Migrations live in `migrations/` and run in lexical order.

`001_init.sql` creates the schema and `search_all(query, near_point)`. It also runs `CREATE EXTENSION IF NOT EXISTS postgis`. `002_seed_reference.sql` inserts the five levels, badge definitions, and three sample public courts in Austin. Those courts are `source = 'admin'` and are marked as sample data. Coordinates are approximate.

## Enable PostGIS

The database role must be allowed to create extensions. On managed Postgres, enable PostGIS in the provider console first if the role cannot run `CREATE EXTENSION`.

Local Docker, same image as `infra/README.md`:

```bash
docker run --name baseline-postgres \
  --restart unless-stopped \
  -e POSTGRES_USER=baseline \
  -e POSTGRES_PASSWORD=local-dev-only \
  -e POSTGRES_DB=baseline \
  -p 5432:5432 \
  -d postgis/postgis:16-3.4
```

That image includes PostGIS. Create the extension in the `baseline` database:

```bash
export DATABASE_URL="postgres://baseline:local-dev-only@127.0.0.1:5432/baseline"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "CREATE EXTENSION IF NOT EXISTS postgis;"
psql "$DATABASE_URL" -c "SELECT PostGIS_Version();"
```

On a host install, install the PostGIS build that matches PostgreSQL 16, then run the same `CREATE EXTENSION`.

- Debian or Ubuntu: `postgresql-16-postgis-3`
- macOS Homebrew: `brew install postgis`

`local-dev-only` is a machine-local password. Staging and production use a different password from the host secret store.

## Apply migrations

From the repository root, against an empty `baseline` database:

```bash
export DATABASE_URL="postgres://baseline:local-dev-only@127.0.0.1:5432/baseline"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f services/api/db/migrations/001_init.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f services/api/db/migrations/002_seed_reference.sql
```

Or apply every file in order:

```bash
for f in services/api/db/migrations/*.sql; do
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$f"
done
```

`002_seed_reference.sql` expects the tables from `001_init.sql`. Run them once per database.

Check the seed:

```bash
psql "$DATABASE_URL" -c "SELECT id, name FROM levels ORDER BY sort_order;"
psql "$DATABASE_URL" -c "SELECT code, name FROM badges ORDER BY code;"
psql "$DATABASE_URL" -c "SELECT name, source, notes FROM courts ORDER BY name;"
```

Place search can take a point. Longitude comes first:

```bash
psql "$DATABASE_URL" -c \
  "SELECT kind, title, round(distance_meters::numeric, 0) AS meters
   FROM search_all('austin', ST_SetSRID(ST_MakePoint(-97.74, 30.27), 4326)::geography);"
```

`search_all` does not return players. Partner browse applies the coarse-location rules.
