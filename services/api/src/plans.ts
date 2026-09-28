import { randomUUID } from 'node:crypto';

export type PlanBlockKind = 'warmup' | 'footwork' | 'focus' | 'rally';

export type PlanItemDraft = {
  id: string;
  dayIndex: number;
  sortOrder: number;
  kind: PlanBlockKind;
  title: string;
  minutes: number;
  lessonSlug: string | null;
  drillSlug: string | null;
};

export function weekStartMonday(now = new Date()): string {
  const date = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const weekday = date.getUTCDay();
  const daysSinceMonday = weekday === 0 ? 6 : weekday - 1;
  date.setUTCDate(date.getUTCDate() - daysSinceMonday);
  return date.toISOString().slice(0, 10);
}

export function addDays(isoDate: string, days: number): string {
  const [year, month, day] = isoDate.split('-').map(Number);
  const date = new Date(Date.UTC(year!, month! - 1, day!));
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}

type LessonHint = { slug: string; level: number; technique?: string; freeTier: boolean };

/**
 * One training day is four blocks: warm-up, footwork, a focus technique, and rallying.
 * Days per week must already be 2, 3, 4, or 5.
 */
export function buildWeekItems(input: {
  daysPerWeek: number;
  focusSkills: string[];
  level: number;
  lessons: LessonHint[];
  drillSlugs: ReadonlySet<string>;
}): PlanItemDraft[] {
  const focusLesson = pickFocusLesson(input.focusSkills, input.level, input.lessons);
  const focusTitle = focusLesson
    ? `Focus: ${titleFromSlug(focusLesson.technique ?? focusLesson.slug)}`
    : `Focus: ${titleFromSlug(input.focusSkills[0] ?? 'rally')}`;
  const footworkSlug = input.drillSlugs.has('split-step') ? 'split-step' : null;
  const rallySlug = input.drillSlugs.has('wall-rally')
    ? 'wall-rally'
    : input.drillSlugs.has('forehand-consistency')
      ? 'forehand-consistency'
      : null;

  const items: PlanItemDraft[] = [];
  for (let day = 0; day < input.daysPerWeek; day += 1) {
    const blocks: Array<Omit<PlanItemDraft, 'id' | 'dayIndex'>> = [
      { sortOrder: 0, kind: 'warmup', title: 'Warm-up', minutes: 10, lessonSlug: null, drillSlug: null },
      {
        sortOrder: 1,
        kind: 'footwork',
        title: 'Footwork',
        minutes: 10,
        lessonSlug: null,
        drillSlug: footworkSlug,
      },
      {
        sortOrder: 2,
        kind: 'focus',
        title: focusTitle,
        minutes: 25,
        lessonSlug: focusLesson?.slug ?? null,
        drillSlug: null,
      },
      {
        sortOrder: 3,
        kind: 'rally',
        title: 'Rally',
        minutes: 15,
        lessonSlug: null,
        drillSlug: rallySlug,
      },
    ];
    for (const block of blocks) {
      items.push({ id: randomUUID(), dayIndex: day, ...block });
    }
  }
  return items;
}

function pickFocusLesson(skills: string[], level: number, lessons: LessonHint[]): LessonHint | null {
  const blob = skills.join(' ').toLowerCase();
  const atLevel = lessons.filter((lesson) => lesson.level === level);
  const pool = atLevel.length > 0 ? atLevel : lessons;
  if (blob.includes('forehand')) {
    return pool.find((lesson) => lesson.technique === 'forehand') ?? lessons.find((lesson) => lesson.technique === 'forehand') ?? null;
  }
  if (blob.includes('serve')) {
    return pool.find((lesson) => lesson.technique === 'serve') ?? null;
  }
  if (blob.includes('ready')) {
    return pool.find((lesson) => lesson.technique === 'ready-position') ?? null;
  }
  if (blob.includes('rally')) {
    return (
      pool.find((lesson) => lesson.technique === 'rally' && lesson.freeTier) ??
      pool.find((lesson) => lesson.technique === 'rally') ??
      null
    );
  }
  return pool.find((lesson) => lesson.freeTier) ?? pool[0] ?? null;
}

function titleFromSlug(slug: string): string {
  if (slug === 'rally') return 'rallying fundamentals';
  return slug.replace(/[-_]+/g, ' ');
}
