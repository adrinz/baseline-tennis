import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildApp } from './app.ts';

const port = Number(process.env.PORT ?? 8787);
const host = process.env.HOST ?? '0.0.0.0';
const here = path.dirname(fileURLToPath(import.meta.url));
const storePath = process.env.BASELINE_STORE_PATH ?? path.join(here, '..', 'data', 'store.json');
const app = await buildApp({ logger: true, storePath });

try {
  await app.listen({ port, host });
} catch (error) {
  app.log.error(error);
  process.exit(1);
}
