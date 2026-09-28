import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { z } from 'zod';

const blockSchema = z.object({
  kind: z.string(),
  body: z.string(),
});

const catalogSchema = z.object({
  levels: z.array(
    z.object({
      id: z.number().int(),
      name: z.string(),
      summary: z.string(),
    }),
  ),
  lessons: z.array(
    z.object({
      slug: z.string(),
      level: z.number().int(),
      title: z.string(),
      category: z.string(),
      technique: z.string().optional(),
      freeTier: z.boolean(),
      estimatedMinutes: z.number(),
      summary: z.string(),
      blocks: z.array(blockSchema),
    }),
  ),
  drills: z.array(
    z.object({
      slug: z.string(),
      name: z.string(),
      levelMin: z.number().int(),
      objective: z.string(),
      equipment: z.array(z.string()),
      playersRequired: z.number().int(),
      durationMinutes: z.number(),
      repetitions: z.string(),
      difficulty: z.number().int(),
      freeTier: z.boolean(),
      instructions: z.string(),
      coachingTips: z.string(),
      commonMistakes: z.string(),
    }),
  ),
  glossary: z.array(
    z.object({
      term: z.string(),
      definition: z.string(),
    }),
  ),
  coachRules: z.array(
    z.object({
      id: z.string(),
      match: z.array(z.string()),
      summary: z.string(),
      causes: z.array(z.string()),
      nextTechniqueSlug: z.string(),
      drillSlugs: z.array(z.string()),
      practiceNote: z.string(),
    }),
  ),
});

export type Catalog = z.infer<typeof catalogSchema>;
export type CatalogLesson = Catalog['lessons'][number];
export type CatalogDrill = Catalog['drills'][number];

/**
 * Seed file lives at baseline/content/seed/catalog.json.
 * From this service (`services/api`) that is `../../content/seed/catalog.json`,
 * resolved from the service directory so `npm run dev` does not depend on cwd.
 */
export function resolveCatalogPath(): string {
  const serviceRoot = fileURLToPath(new URL('..', import.meta.url));
  return path.resolve(serviceRoot, '../../content/seed/catalog.json');
}

export function loadCatalog(catalogPath = resolveCatalogPath()): Catalog {
  const raw = readFileSync(catalogPath, 'utf8');
  return catalogSchema.parse(JSON.parse(raw));
}

export function glossarySlug(term: string): string {
  return term
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}
