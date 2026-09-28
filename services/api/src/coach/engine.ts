export type CoachRule = {
  id: string;
  match: string[];
  summary: string;
  causes: string[];
  nextTechniqueSlug: string;
  drillSlugs: string[];
  practiceNote: string;
};

export type CoachAnswer = {
  label: 'coaching_assistance';
  summary: string;
  causes: string[];
  nextTechniqueSlug: string | null;
  drillSlugs: string[];
  practiceNote: string;
};

export type UnfinishedLesson = {
  slug: string;
  title: string;
  techniqueSlug: string | null;
};

function questionHas(question: string, term: string): boolean {
  const escaped = term.trim().toLowerCase().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  if (!escaped) return false;
  return new RegExp(`(?:^|[^a-z0-9])${escaped}(?:[^a-z0-9]|$)`, 'i').test(question);
}

function existingDrills(slugs: string[], known: ReadonlySet<string>): string[] {
  return slugs.filter((slug) => known.has(slug));
}

/**
 * Rules coach. Pain questions stop with a clinician note and no drill.
 * Every other answer may only name drill slugs that exist in the catalog.
 */
export function answerCoachQuestion(input: {
  question: string;
  rules: CoachRule[];
  knownDrillSlugs: ReadonlySet<string>;
  unfinishedLesson: UnfinishedLesson | null;
}): CoachAnswer {
  const question = input.question.trim();

  if (/\bpain/i.test(question)) {
    return {
      label: 'coaching_assistance',
      summary:
        'Stop and talk with a clinician or a qualified coach before you keep practicing. Pain needs a person, not a drill.',
      causes: [],
      nextTechniqueSlug: null,
      drillSlugs: [],
      practiceNote:
        'This is coaching assistance, not a medical opinion. Do not use a drill as treatment for pain.',
    };
  }

  const rule = input.rules.find(
    (candidate) => candidate.match.length > 0 && candidate.match.every((term) => questionHas(question, term)),
  );

  if (!rule) {
    const consistency = existingDrills(['forehand-consistency', 'wall-rally'], input.knownDrillSlugs);
    const lesson = input.unfinishedLesson;
    const summary = lesson
      ? `Review “${lesson.title}”, the lesson you have not finished, then practice one consistency drill.`
      : 'Review the last lesson you have not finished, then practice one consistency drill.';
    return {
      label: 'coaching_assistance',
      summary,
      causes: [],
      nextTechniqueSlug: lesson?.techniqueSlug ?? null,
      drillSlugs: consistency.slice(0, 1),
      practiceNote: 'A short repeatable session beats guessing at a new fix.',
    };
  }

  return {
    label: 'coaching_assistance',
    summary: rule.summary,
    causes: [...rule.causes],
    nextTechniqueSlug: rule.nextTechniqueSlug,
    drillSlugs: existingDrills(rule.drillSlugs, input.knownDrillSlugs),
    practiceNote: rule.practiceNote,
  };
}
