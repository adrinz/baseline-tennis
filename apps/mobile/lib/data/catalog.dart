/// Offline copy of the lesson, drill, glossary, and coach seed catalog.
/// The app reads this instead of the network so the shell runs without the API.
library;

import 'package:baseline/data/catalog_more.dart';

class LevelInfo {
  const LevelInfo({
    required this.id,
    required this.name,
    required this.summary,
  });

  final int id;
  final String name;
  final String summary;
}

class LessonBlock {
  const LessonBlock({required this.kind, required this.body});

  final String kind;
  final String body;
}

class Lesson {
  const Lesson({
    required this.slug,
    required this.level,
    required this.title,
    required this.category,
    required this.freeTier,
    required this.estimatedMinutes,
    required this.summary,
    required this.blocks,
    this.technique,
  });

  final String slug;
  final int level;
  final String title;
  final String category;
  final bool freeTier;
  final int estimatedMinutes;
  final String summary;
  final String? technique;
  final List<LessonBlock> blocks;
}

class Drill {
  const Drill({
    required this.slug,
    required this.name,
    required this.levelMin,
    required this.objective,
    required this.equipment,
    required this.playersRequired,
    required this.durationMinutes,
    required this.repetitions,
    required this.difficulty,
    required this.freeTier,
    required this.instructions,
    required this.coachingTips,
    required this.commonMistakes,
  });

  final String slug;
  final String name;
  final int levelMin;
  final String objective;
  final List<String> equipment;
  final int playersRequired;
  final int durationMinutes;
  final String repetitions;
  final int difficulty;
  final bool freeTier;
  final String instructions;
  final String coachingTips;
  final String commonMistakes;
}

class GlossaryTerm {
  const GlossaryTerm({required this.term, required this.definition});

  final String term;
  final String definition;
}

class CoachRule {
  const CoachRule({
    required this.id,
    required this.match,
    required this.summary,
    required this.causes,
    required this.nextTechniqueSlug,
    required this.drillSlugs,
    required this.practiceNote,
  });

  final String id;
  final List<String> match;
  final String summary;
  final List<String> causes;
  final String nextTechniqueSlug;
  final List<String> drillSlugs;
  final String practiceNote;
}

const baselineCatalog = (
  levels: <LevelInfo>[
    LevelInfo(
      id: 1,
      name: 'Complete Beginner',
      summary:
          'First time on a court: gear, rules, grips, and the first swings.',
    ),
    LevelInfo(
      id: 2,
      name: 'Beginner',
      summary: 'Build a rally you can repeat: strokes, footwork, and simple patterns.',
    ),
    LevelInfo(
      id: 3,
      name: 'Advanced Beginner',
      summary: 'Consistency, placement, spin, and building a point.',
    ),
    LevelInfo(
      id: 4,
      name: 'Intermediate',
      summary: 'Patterns, serve plus one, and match decisions.',
    ),
    LevelInfo(
      id: 5,
      name: 'Advanced',
      summary: 'Biomechanics, scouting, and tournament preparation.',
    ),
  ],
  lessons: <Lesson>[
    Lesson(
      slug: 'welcome-to-tennis',
      level: 1,
      title: 'Introduction to tennis',
      category: 'etiquette',
      freeTier: true,
      estimatedMinutes: 8,
      summary:
          'What a match looks like and how a practice session is organized.',
      blocks: [
        LessonBlock(
          kind: 'overview',
          body: 'Tennis is a game of keeping the ball in play inside the lines, then learning to place it where your opponent is not. You can start on a wall, a public court, or with one other person.',
        ),
        LessonBlock(
          kind: 'steps',
          body: '1. Learn the lines and the scoring words. 2. Get a racket that fits and a can of balls. 3. Practice a short rally before you worry about winning points.',
        ),
      ],
    ),
    Lesson(
      slug: 'the-court',
      level: 1,
      title: 'Understanding the court',
      category: 'rules',
      freeTier: true,
      estimatedMinutes: 8,
      summary: 'Baselines, service boxes, alleys, and the net.',
      blocks: [
        LessonBlock(
          kind: 'overview',
          body: 'The baseline is the back line. The service boxes are the two rectangles on the far side of the net where a serve must land. The alleys count in doubles and are out in singles.',
        ),
      ],
    ),
    Lesson(
      slug: 'scoring',
      level: 1,
      title: 'Scoring',
      category: 'rules',
      freeTier: true,
      estimatedMinutes: 10,
      summary: 'Love, 15, 30, 40, deuce, games, and sets in plain language.',
      blocks: [
        LessonBlock(
          kind: 'overview',
          body: 'Points inside a game are called love, 15, 30, 40, then game. If both players reach 40, the score is deuce. The next point is advantage. Win the following point and you win the game. A set is usually first to 6 games, by 2.',
        ),
      ],
    ),
    Lesson(
      slug: 'ready-position',
      level: 1,
      title: 'Ready position',
      category: 'technique',
      technique: 'ready-position',
      freeTier: true,
      estimatedMinutes: 10,
      summary: 'The athletic stance you return to between shots.',
      blocks: [
        LessonBlock(
          kind: 'why',
          body: 'Most late swings start from standing tall. A low, balanced ready position lets you move to either side.',
        ),
        LessonBlock(
          kind: 'steps',
          body: 'Feet wider than shoulders, knees soft, weight on the balls of the feet, racket up in front of the body, other hand on the throat of the racket.',
        ),
        LessonBlock(
          kind: 'mistakes',
          body:
              'Standing upright, racket pointed at the ground, heels planted.',
        ),
      ],
    ),
    Lesson(
      slug: 'basic-forehand',
      level: 1,
      title: 'Basic forehand',
      category: 'technique',
      technique: 'forehand',
      freeTier: true,
      estimatedMinutes: 15,
      summary: 'A simple forehand path for the first rallies.',
      blocks: [
        LessonBlock(
          kind: 'steps',
          body: 'Turn your shoulders as the ball arrives. Racket back early. Meet the ball in front of the front hip. Finish up over the other shoulder.',
        ),
        LessonBlock(
          kind: 'beginner_mistakes',
          body: 'Arm-only swing, contact beside the body, no recovery back to the middle.',
        ),
      ],
    ),
    Lesson(
      slug: 'basic-rally',
      level: 2,
      title: 'Basic rallying',
      category: 'technique',
      technique: 'rally',
      freeTier: true,
      estimatedMinutes: 12,
      summary:
          'Keep the ball going with height, a target, and a recovery step.',
      blocks: [
        LessonBlock(
          kind: 'overview',
          body: 'A rally is cooperative practice before it is a contest. Aim higher over the net than you think, land near the opposite baseline, then return to the middle.',
        ),
      ],
    ),
    Lesson(
      slug: 'rally-construction',
      level: 3,
      title: 'Rally construction',
      category: 'strategy',
      technique: 'rally',
      freeTier: false,
      estimatedMinutes: 12,
      summary:
          'Cross-court until you have a shorter ball, then change direction.',
      blocks: [
        LessonBlock(
          kind: 'tips',
          body: 'The cross-court shot is safer because the net is lower in the middle and the court is longer on the diagonal. Change direction only when the ball sits up.',
        ),
      ],
    ),
    ...moreLessons,
  ],
  drills: <Drill>[
    Drill(
      slug: 'wall-rally',
      name: 'Wall rally',
      levelMin: 1,
      objective: 'Learn contact and a repeatable swing without a partner.',
      equipment: ['racket', 'balls', 'wall'],
      playersRequired: 1,
      durationMinutes: 10,
      repetitions: '5 sets of 20 contacts',
      difficulty: 1,
      freeTier: true,
      instructions: 'Stand about 8 meters from a wall. Drop and hit forehands that bounce once before returning. Reset if you miss twice in a row.',
      coachingTips: 'Keep the racket prepared before the bounce, not after it.',
      commonMistakes: 'Standing so close that the swing is rushed.',
    ),
    Drill(
      slug: 'warmup',
      name: 'Court warm-up',
      levelMin: 1,
      objective: 'Loosen the feet, split step, and shadow a few swings before you hit.',
      equipment: ['racket'],
      playersRequired: 1,
      durationMinutes: 5,
      repetitions: '3 easy rounds',
      difficulty: 1,
      freeTier: true,
      instructions: 'Start in the ready position. Split step, shuffle a few steps each way, then shadow five forehands and five backhands. Stay light on your feet.',
      coachingTips: 'The warm-up is movement, not pace. Finish each shadow swing and return to the middle.',
      commonMistakes: 'Standing still and only moving the arm.',
    ),
    Drill(
      slug: 'forehand-consistency',
      name: 'Forehand consistency',
      levelMin: 2,
      objective: 'Land ten forehands in a row past the service line.',
      equipment: ['racket', 'balls', 'court or wall'],
      playersRequired: 1,
      durationMinutes: 15,
      repetitions: '10 in a row, 3 times',
      difficulty: 2,
      freeTier: true,
      instructions: 'Feed yourself or hit against a wall. Count only balls that clear the net by a racket length and land deep.',
      coachingTips: 'A higher, slower ball counts. Speed comes later.',
      commonMistakes: 'Swinging harder after a miss.',
    ),
    Drill(
      slug: 'split-step',
      name: 'Split-step drill',
      levelMin: 2,
      objective: 'Land a small hop as the opponent hits.',
      equipment: ['racket'],
      playersRequired: 1,
      durationMinutes: 8,
      repetitions: '3 sets of 30 seconds',
      difficulty: 2,
      freeTier: true,
      instructions: 'Shadow a rally. As you imagine the other player making contact, hop and land balanced, then move one step and recover.',
      coachingTips: 'The hop is small. It is a timing tool, not a jump.',
      commonMistakes:
          'Hopping late, after the ball has already crossed the net.',
    ),
    Drill(
      slug: 'serve-target',
      name: 'Serve target drill',
      levelMin: 2,
      objective: 'Start the serve in a chosen service box.',
      equipment: ['racket', 'balls', 'cones or towels'],
      playersRequired: 1,
      durationMinutes: 15,
      repetitions: '2 sets of 10 serves each box',
      difficulty: 2,
      freeTier: false,
      instructions: 'Place a target in the deuce box and one in the ad box. Toss in front of the hitting shoulder and aim for one target at a time.',
      coachingTips:
          'Hold the finish. A falling toss should be caught, not swatted.',
      commonMistakes: 'Tossing behind the head or too far to the side.',
    ),
    ...moreDrills,
  ],
  glossary: <GlossaryTerm>[
    GlossaryTerm(
      term: 'Ace',
      definition: 'A serve the receiver does not touch.',
    ),
    GlossaryTerm(term: 'Love', definition: 'Zero, used in the score.'),
    GlossaryTerm(
      term: 'Deuce',
      definition:
          '40–40. Someone must win two points in a row to take the game.',
    ),
    GlossaryTerm(
      term: 'Advantage',
      definition:
          'The point after deuce. Win the next point and the game is yours.',
    ),
    GlossaryTerm(
      term: 'Let',
      definition: 'A point that is replayed, often because the serve clipped the net and still landed in.',
    ),
    GlossaryTerm(
      term: 'Fault',
      definition:
          'A missed serve. Two in a row is a double fault and loses the point.',
    ),
    GlossaryTerm(
      term: 'Rally',
      definition: 'The exchange of shots after the serve.',
    ),
    GlossaryTerm(
      term: 'Volley',
      definition: 'A shot hit before the ball bounces, usually near the net.',
    ),
    GlossaryTerm(
      term: 'Unforced error',
      definition: 'A miss on a ball you had time to play.',
    ),
    GlossaryTerm(
      term: 'Winner',
      definition: 'A shot that lands in and is not touched by the opponent.',
    ),
    GlossaryTerm(
      term: 'Topspin',
      definition: 'Forward spin that helps the ball dip into the court.',
    ),
    GlossaryTerm(
      term: 'Slice',
      definition: 'Backspin that keeps the ball low.',
    ),
    GlossaryTerm(
      term: 'Baseline',
      definition: 'The line at the back of each end of the court.',
    ),
    GlossaryTerm(
      term: 'Tiebreak',
      definition: 'A special game used when a set reaches 6–6.',
    ),
  ],
  coachRules: <CoachRule>[
    CoachRule(
      id: 'forehand-net',
      match: ['forehand', 'net'],
      summary: 'A forehand into the net usually means the contact or the swing path is too low.',
      causes: [
        'Contact point too low',
        'Racket prepared late',
        'Too close to the ball',
        'Swing path downward',
        'Follow-through stopped at the waist',
        'Wrist flipping the racket face open and shut',
      ],
      nextTechniqueSlug: 'contact-point',
      drillSlugs: ['wall-rally', 'forehand-consistency'],
      practiceNote: 'Use three 15-minute sessions this week. Count deep balls, not winners.',
    ),
  ],
);

LevelInfo? levelById(int id) {
  for (final level in baselineCatalog.levels) {
    if (level.id == id) return level;
  }
  return null;
}

Lesson? lessonBySlug(String slug) {
  for (final lesson in baselineCatalog.lessons) {
    if (lesson.slug == slug) return lesson;
  }
  return null;
}

List<Lesson> lessonsForLevel(int level) {
  return baselineCatalog.lessons
      .where((lesson) => lesson.level == level)
      .toList();
}

Drill? drillBySlug(String slug) {
  for (final drill in baselineCatalog.drills) {
    if (drill.slug == slug) return drill;
  }
  return null;
}

String blockHeading(String kind) {
  switch (kind) {
    case 'overview':
      return 'Overview';
    case 'why':
      return 'Why it matters';
    case 'steps':
      return 'Steps';
    case 'tips':
      return 'Tips';
    case 'mistakes':
    case 'beginner_mistakes':
      return 'Mistakes';
    case 'checklist':
      return 'Checklist';
    default:
      return 'Notes';
  }
}

String formatBlockBody(String body) {
  return body.replaceAllMapped(RegExp(r'\s+(?=\d+\.\s)'), (_) => '\n');
}

String humanizeSlug(String slug) {
  return slug
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class TechniqueSkill {
  const TechniqueSkill({
    required this.slug,
    required this.title,
    required this.family,
    required this.summary,
    required this.level,
    required this.lessonSlug,
  });

  final String slug;
  final String title;
  final String family;
  final String summary;
  final int level;
  final String lessonSlug;
}

class TechniqueGroup {
  const TechniqueGroup({
    required this.id,
    required this.title,
    required this.skills,
  });

  final String id;
  final String title;
  final List<TechniqueSkill> skills;
}

const _techniqueTitles = <String, String>{
  'ready-position': 'Ready position',
  'rally': 'Rallying fundamentals',
  'contact-point': 'Contact point',
  'one-handed-backhand': 'One-handed backhand',
  'return': 'Return of serve',
  'smash': 'Overhead smash',
  'recovery': 'Court recovery',
  'drop': 'Drop shot',
  'approach': 'Approach shot',
  'passing-shot': 'Passing shot',
  'second-serve': 'Second serve',
};

const _techniqueFamilies = <String, String>{
  'ready-position': 'ready',
  'grip': 'grip',
  'footwork': 'footwork',
  'split-step': 'footwork',
  'recovery': 'footwork',
  'forehand': 'groundstroke',
  'backhand': 'groundstroke',
  'slice': 'groundstroke',
  'topspin': 'groundstroke',
  'one-handed-backhand': 'groundstroke',
  'contact-point': 'groundstroke',
  'volley': 'net',
  'smash': 'net',
  'serve': 'serve',
  'second-serve': 'serve',
  'return': 'return',
  'rally': 'rally',
  'drop': 'specialty',
  'lob': 'specialty',
  'approach': 'specialty',
  'passing-shot': 'specialty',
};

const _familyOrder = <String>[
  'ready',
  'grip',
  'footwork',
  'groundstroke',
  'net',
  'serve',
  'return',
  'rally',
  'specialty',
];

const _familyTitles = <String, String>{
  'ready': 'Ready',
  'grip': 'Grip',
  'footwork': 'Footwork',
  'groundstroke': 'Groundstrokes',
  'net': 'Net',
  'serve': 'Serve',
  'return': 'Return',
  'rally': 'Rally',
  'specialty': 'Point play',
};

String techniqueTitle(String slug) {
  return _techniqueTitles[slug] ?? humanizeSlug(slug);
}

String techniqueFamily(String slug) {
  return _techniqueFamilies[slug] ?? 'specialty';
}

List<TechniqueGroup> techniqueGroups() {
  final firstLesson = <String, Lesson>{};
  for (final lesson in baselineCatalog.lessons) {
    final technique = lesson.technique;
    if (technique == null) continue;
    firstLesson.putIfAbsent(technique, () => lesson);
  }
  final grouped = <String, List<TechniqueSkill>>{};
  for (final entry in firstLesson.entries) {
    final family = techniqueFamily(entry.key);
    final lesson = entry.value;
    grouped
        .putIfAbsent(family, () => [])
        .add(
          TechniqueSkill(
            slug: entry.key,
            title: techniqueTitle(entry.key),
            family: family,
            summary: lesson.summary,
            level: lesson.level,
            lessonSlug: lesson.slug,
          ),
        );
  }
  for (final skills in grouped.values) {
    skills.sort((a, b) {
      final byLevel = a.level.compareTo(b.level);
      if (byLevel != 0) return byLevel;
      return a.title.compareTo(b.title);
    });
  }
  return [
    for (final id in _familyOrder)
      if (grouped[id] != null)
        TechniqueGroup(
          id: id,
          title: _familyTitles[id] ?? humanizeSlug(id),
          skills: grouped[id]!,
        ),
  ];
}
