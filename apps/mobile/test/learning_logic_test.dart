import 'package:baseline/data/catalog.dart';
import 'package:baseline/logic/progress.dart';
import 'package:baseline/state/player_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('continue lesson stays in the player level before falling back', () {
    final levelOne = baselineCatalog.lessons
        .where((lesson) => lesson.level == 1)
        .toList();
    final completed = levelOne.first.slug;
    final session = PlayerSession(level: 1, completedLessonSlugs: {completed});

    expect(continueLesson(session).level, 1);
    expect(continueLesson(session).slug, isNot(completed));
  });

  test('recommended drill advances through the unfinished practice order', () {
    expect(recommendedDrill(const PlayerSession()).slug, 'wall-rally');
    expect(
      recommendedDrill(const PlayerSession(completedDrillSlugs: {'wall-rally'}))
          .slug,
      'forehand-consistency',
    );
    expect(
      recommendedDrill(
        const PlayerSession(
          completedDrillSlugs: {
            'wall-rally',
            'forehand-consistency',
            'split-step',
            'serve-target',
          },
        ),
      ),
      isNotNull,
    );
  });

  test('streak labels are readable for singular and plural days', () {
    expect(streakLabel(1), '1-day streak');
    expect(streakLabel(4), '4-day streak');
  });
}
