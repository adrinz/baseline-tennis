import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

type Block = { kind: string; body: string };
type Lesson = {
  slug: string;
  level: number;
  title: string;
  category: string;
  technique?: string;
  freeTier: boolean;
  estimatedMinutes: number;
  summary: string;
  blocks: Block[];
};
type Drill = {
  slug: string;
  name: string;
  levelMin: number;
  objective: string;
  equipment: string[];
  playersRequired: number;
  durationMinutes: number;
  repetitions: string;
  difficulty: number;
  freeTier: boolean;
  instructions: string;
  coachingTips: string;
  commonMistakes: string;
};
type Term = { term: string; definition: string };

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
  console.error('Set DATABASE_URL, apply migrations, then run this again.');
  process.exit(1);
}

const here = path.dirname(fileURLToPath(import.meta.url));
const catalogPath = path.join(here, '..', '..', '..', 'content', 'seed', 'catalog.json');
const catalog = JSON.parse(await readFile(catalogPath, 'utf8')) as {
  lessons: Lesson[];
  drills: Drill[];
  glossary: Term[];
};

const client = new pg.Client({ connectionString: databaseUrl });
await client.connect();

try {
  await client.query('BEGIN');
  for (const lesson of catalog.lessons) {
    const inserted = await client.query<{ id: string }>(
      `INSERT INTO lessons (level_id, slug, title, summary, category, estimated_minutes, difficulty, status, free_tier, published_at)
       VALUES ($1, $2, $3, $4, $5, $6, 2, 'published', $7, now())
       ON CONFLICT (slug) DO UPDATE
         SET title = EXCLUDED.title,
             summary = EXCLUDED.summary,
             category = EXCLUDED.category,
             estimated_minutes = EXCLUDED.estimated_minutes,
             free_tier = EXCLUDED.free_tier,
             status = 'published'
       RETURNING id`,
      [
        lesson.level,
        lesson.slug,
        lesson.title,
        lesson.summary,
        lesson.category,
        lesson.estimatedMinutes,
        lesson.freeTier,
      ],
    );
    const lessonId = inserted.rows[0]?.id;
    if (!lessonId) continue;
    await client.query('DELETE FROM lesson_blocks WHERE lesson_id = $1', [lessonId]);
    for (const [index, block] of lesson.blocks.entries()) {
      await client.query(
        `INSERT INTO lesson_blocks (lesson_id, sort_order, kind, body)
         VALUES ($1, $2, $3, $4::jsonb)`,
        [lessonId, index, block.kind, JSON.stringify({ text: block.body })],
      );
    }
  }

  for (const drill of catalog.drills) {
    await client.query(
      `INSERT INTO drills (
         slug, name, level_min, objective, equipment, players_required,
         instructions, duration_minutes, repetitions, difficulty,
         coaching_tips, common_mistakes, free_tier, status
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, $9, $10, $11, $12, $13, 'published')
       ON CONFLICT (slug) DO UPDATE
         SET name = EXCLUDED.name,
             objective = EXCLUDED.objective,
             free_tier = EXCLUDED.free_tier,
             status = 'published'`,
      [
        drill.slug,
        drill.name,
        drill.levelMin,
        drill.objective,
        drill.equipment,
        drill.playersRequired,
        JSON.stringify({ text: drill.instructions }),
        drill.durationMinutes,
        drill.repetitions,
        drill.difficulty,
        drill.coachingTips,
        drill.commonMistakes,
        drill.freeTier,
      ],
    );
  }

  for (const term of catalog.glossary) {
    const slug = term.term.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
    await client.query(
      `INSERT INTO glossary_terms (slug, term, definition, level_min)
       VALUES ($1, $2, $3, 1)
       ON CONFLICT (slug) DO UPDATE SET definition = EXCLUDED.definition`,
      [slug, term.term, term.definition],
    );
  }

  await client.query('COMMIT');
  console.log(
    `Seeded ${catalog.lessons.length} lessons, ${catalog.drills.length} drills, ${catalog.glossary.length} terms.`,
  );
} catch (error) {
  await client.query('ROLLBACK');
  throw error;
} finally {
  await client.end();
}
