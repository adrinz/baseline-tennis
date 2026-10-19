import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('level 4 has lessons and level 5 contains the advanced lesson set', () {
    expect(lessonsForLevel(4), isNotEmpty);

    final levelFive = lessonsForLevel(5);
    expect(levelFive.map((lesson) => lesson.slug).toSet(), const {
      'advanced-biomechanics',
      'opponent-scouting',
      'tournament-preparation',
    });
    expect(levelFive, hasLength(3));

    for (final lesson in levelFive) {
      expect(lesson.level, 5, reason: lesson.slug);
      expect(lesson.freeTier, isFalse, reason: lesson.slug);
      expect(lesson.summary, isNotEmpty, reason: lesson.slug);
      expect(lesson.blocks, isNotEmpty, reason: lesson.slug);
      expect(lesson.technique, isNull, reason: lesson.slug);
      expect(
        lesson.blocks.map((block) => block.kind),
        containsAll(const ['overview', 'steps', 'tips', 'mistakes']),
        reason: lesson.slug,
      );
      expect(
        lesson.blocks.every((block) => block.body.trim().isNotEmpty),
        isTrue,
        reason: lesson.slug,
      );
      expect(videosForLesson(lesson.slug), isNotEmpty, reason: lesson.slug);
    }

    const topicsBySlug = {
      'advanced-biomechanics': 'biomechanic',
      'opponent-scouting': 'scout',
      'tournament-preparation': 'tournament',
    };
    for (final lesson in levelFive) {
      final content = [
        lesson.title,
        lesson.summary,
        ...lesson.blocks.map((block) => block.body),
      ].join(' ').toLowerCase();
      expect(content, contains(topicsBySlug[lesson.slug]), reason: lesson.slug);
    }
  });
}
