import { readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
  console.error('Set DATABASE_URL to a Postgres database with PostGIS, then run this again.');
  process.exit(1);
}

const here = path.dirname(fileURLToPath(import.meta.url));
const migrationsDir = path.join(here, '..', 'db', 'migrations');
const files = (await readdir(migrationsDir)).filter((name) => name.endsWith('.sql')).sort();

for (const file of files) {
  const full = path.join(migrationsDir, file);
  console.log(`Applying ${file}`);
  const result = spawnSync('psql', [databaseUrl, '-v', 'ON_ERROR_STOP=1', '-f', full], {
    stdio: 'inherit',
  });
  if (result.status !== 0) {
    console.error(`Migration failed: ${file}`);
    process.exit(result.status ?? 1);
  }
}

console.log('Migrations applied.');
