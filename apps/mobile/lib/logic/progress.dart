import 'package:baseline/data/catalog.dart';
import 'package:baseline/state/player_session.dart';

Lesson continueLesson(PlayerSession session) {
  for (final lesson in baselineCatalog.lessons) {
    if (lesson.level == session.level &&
        !session.completedLessonSlugs.contains(lesson.slug)) {
      return lesson;
    }
  }
  for (final lesson in baselineCatalog.lessons) {
    if (!session.completedLessonSlugs.contains(lesson.slug)) return lesson;
  }
  return baselineCatalog.lessons.first;
}

Drill recommendedDrill(PlayerSession session) {
  const order = [
    'wall-rally',
    'forehand-consistency',
    'split-step',
    'serve-target',
  ];
  for (final slug in order) {
    if (!session.completedDrillSlugs.contains(slug)) {
      return drillBySlug(slug)!;
    }
  }
  return baselineCatalog.drills.first;
}

String streakLabel(int streak) {
  if (streak == 1) return '1-day streak';
  return '$streak-day streak';
}
