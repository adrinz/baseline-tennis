import 'package:baseline/data/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('techniques list the course skills by family', () {
    final groups = techniqueGroups();
    final skills = groups.expand((group) => group.skills).toList();
    final slugs = skills.map((skill) => skill.slug).toSet();

    expect(skills, hasLength(38));
    expect(
      slugs,
      containsAll(const [
        'ready-position',
        'grip',
        'forehand',
        'backhand',
        'rally',
        'serve',
        'volley',
        'footwork',
        'slice',
        'topspin',
        'contact-point',
        'one-handed-backhand',
        'return',
        'smash',
        'recovery',
        'lob',
        'drop',
        'approach',
        'passing-shot',
        'second-serve',
        'serve-plus-one',
        'inside-out-forehand',
        'crossover-step',
        'kick-serve',
        'angle-shot',
        'neutral-ball',
        'flat-serve',
        'slice-serve',
        'return-positioning',
        'backhand-slice',
        'forehand-down-the-line',
        'cross-court-forehand',
        'swing-volley',
        'drop-volley',
        'serve-and-volley',
        'doubles-formation',
        'poaching',
        'tiebreak-strategy',
      ]),
    );
    expect(groups.map((group) => group.id), const [
      'ready',
      'grip',
      'footwork',
      'groundstroke',
      'net',
      'serve',
      'return',
      'rally',
      'specialty',
    ]);

    final drop = skills.firstWhere((skill) => skill.slug == 'drop');
    expect(drop.title, 'Drop shot');
    expect(drop.lessonSlug, 'drop-shot');
    expect(drop.level, 3);

    final contact = skills.firstWhere((skill) => skill.slug == 'contact-point');
    expect(contact.title, 'Contact point');
    expect(contact.family, 'groundstroke');

    expect(
      groups
          .firstWhere((group) => group.id == 'specialty')
          .skills
          .map((skill) => skill.slug),
      [
        'angle-shot',
        'approach',
        'doubles-formation',
        'drop',
        'lob',
        'passing-shot',
        'poaching',
        'tiebreak-strategy',
        'serve-and-volley',
        'serve-plus-one',
      ],
    );

    final servePlusOne = skills.firstWhere(
      (skill) => skill.slug == 'serve-plus-one',
    );
    expect(servePlusOne.title, 'Serve plus one');
    expect(servePlusOne.family, 'specialty');
    expect(servePlusOne.level, 4);

    final crossover = skills.firstWhere(
      (skill) => skill.slug == 'crossover-step',
    );
    expect(crossover.family, 'footwork');

    final kickServe = skills.firstWhere((skill) => skill.slug == 'kick-serve');
    expect(kickServe.family, 'serve');

    const expectedTechniqueInfo = <String, (String, String)>{
      'flat-serve': ('Flat serve', 'serve'),
      'slice-serve': ('Slice serve', 'serve'),
      'return-positioning': ('Return positioning', 'return'),
      'backhand-slice': ('Backhand slice', 'groundstroke'),
      'forehand-down-the-line': ('Forehand down the line', 'groundstroke'),
      'cross-court-forehand': ('Cross-court forehand', 'groundstroke'),
      'swing-volley': ('Swing volley', 'net'),
      'drop-volley': ('Drop volley', 'net'),
      'serve-and-volley': ('Serve and volley', 'specialty'),
      'doubles-formation': ('Doubles formation', 'specialty'),
      'poaching': ('Poaching', 'specialty'),
      'tiebreak-strategy': ('Tiebreak strategy', 'specialty'),
    };
    for (final entry in expectedTechniqueInfo.entries) {
      final skill = skills.firstWhere((skill) => skill.slug == entry.key);
      expect(skill.title, entry.value.$1, reason: entry.key);
      expect(skill.family, entry.value.$2, reason: entry.key);
      expect(skill.lessonSlug, entry.key, reason: entry.key);
    }
  });

  test('glossary includes distinct beginner and intermediate terms', () {
    final terms = baselineCatalog.glossary.map((entry) => entry.term).toList();
    final normalizedTerms = terms.map((term) => term.toLowerCase()).toSet();

    expect(terms.length, 26);
    expect(normalizedTerms.length, terms.length);
    expect(
      normalizedTerms,
      containsAll(const [
        'break point',
        'deuce court',
        'ad court',
        'continental grip',
        'eastern grip',
        'sweet spot',
        'split step',
        'recovery position',
        'approach shot',
        'passing shot',
        'kick serve',
        'serve plus one',
      ]),
    );
  });

  test('next technique batch has complete lesson content', () {
    const expected = <String, (int, String, bool)>{
      'flat-serve': (2, 'technique', true),
      'slice-serve': (3, 'technique', true),
      'return-positioning': (2, 'technique', true),
      'backhand-slice': (2, 'technique', true),
      'forehand-down-the-line': (3, 'technique', true),
      'cross-court-forehand': (2, 'technique', true),
      'swing-volley': (3, 'technique', true),
      'drop-volley': (3, 'technique', true),
      'serve-and-volley': (4, 'strategy', false),
      'doubles-formation': (3, 'strategy', true),
      'poaching': (3, 'strategy', true),
      'tiebreak-strategy': (3, 'strategy', true),
    };
    final lessons = baselineCatalog.lessons
        .where((lesson) => expected.containsKey(lesson.slug))
        .toList();

    expect(lessons, hasLength(12));
    for (final lesson in lessons) {
      final details = expected[lesson.slug]!;
      expect(lesson.technique, lesson.slug, reason: lesson.slug);
      expect(lesson.level, details.$1, reason: lesson.slug);
      expect(lesson.category, details.$2, reason: lesson.slug);
      expect(lesson.freeTier, details.$3, reason: lesson.slug);
      expect(lesson.summary, isNotEmpty, reason: lesson.slug);
      expect(
        lesson.blocks.map((block) => block.kind),
        containsAll(const ['overview', 'steps', 'tips', 'mistakes']),
        reason: lesson.slug,
      );
    }
  });
}
