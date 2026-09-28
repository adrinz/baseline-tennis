import Fastify, { type FastifyInstance } from 'fastify';
import { ApiError } from './errors.ts';
import { loadStore, saveStore } from './file-store.ts';
import { loadCatalog } from './catalog.ts';
import { MemoryRepository } from './repository.ts';
import { registerRoutes } from './routes/register.ts';
import { SlidingWindowLimiter } from './rate-limit.ts';

export type BuildAppOptions = {
  logger?: boolean;
  /** Development-only premium header. Defaults to off when NODE_ENV is production. */
  allowDevPremium?: boolean;
  catalogPath?: string;
  /** When set, accounts and progress are written here after each response. */
  storePath?: string;
};

export async function buildApp(options: BuildAppOptions = {}): Promise<FastifyInstance> {
  const allowDevPremium = options.allowDevPremium ?? process.env.NODE_ENV !== 'production';
  const repo = new MemoryRepository(loadCatalog(options.catalogPath));
  if (options.storePath) await loadStore(repo, options.storePath);
  const app = Fastify({ logger: options.logger ?? false });
  if (options.storePath) {
    const storePath = options.storePath;
    app.addHook('onResponse', async () => {
      await saveStore(repo, storePath);
    });
  }

  app.setErrorHandler((error: unknown, request, reply) => {
    if (error instanceof ApiError) {
      return reply.status(error.statusCode).send({
        error: { code: error.code, message: error.message },
        ...error.details,
      });
    }
    const statusCode =
      typeof error === 'object' && error !== null && 'statusCode' in error && typeof error.statusCode === 'number'
        ? error.statusCode
        : 500;
    if (statusCode < 500) {
      return reply.status(statusCode).send({
        error: { code: 'validation', message: 'Request could not be read.' },
      });
    }
    request.log.error(error);
    return reply.status(500).send({
      error: { code: 'internal', message: 'Something went wrong.' },
    });
  });

  app.setNotFoundHandler((_request, reply) => {
    return reply.status(404).send({
      error: { code: 'not_found', message: 'Route not found' },
    });
  });

  await registerRoutes(app, {
    repo,
    allowDevPremium,
    authLimiter: new SlidingWindowLimiter(10, 60_000),
    messageLimiter: new SlidingWindowLimiter(30, 60_000),
    searchLimiter: new SlidingWindowLimiter(60, 60_000),
  });

  return app;
}
