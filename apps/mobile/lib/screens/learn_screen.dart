import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/screens/shell_screen.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: ScaledText(
                    'Learn',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SearchIconButton(),
              ],
            ),
            const SizedBox(height: 8),
            const ScaledText(
              'Levels 1–3 are the full path. Levels 4 and 5 stay visible.',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            LineCard(
              semanticsLabel: 'Open stroke demonstrations',
              onTap: () => context.push('/videos'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScaledText('WATCH', style: BaselineType.eyebrowFairway),
                  const SizedBox(height: 4),
                  ScaledText(
                    '${licensedVideos.length} demonstrations',
                    style: BaselineType.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  const ScaledText(
                    'Grips, ready position, court lines, scoring, equipment, etiquette, and every main stroke.',
                    style: BaselineType.cardBody,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LineCard(
              semanticsLabel: 'Video credits',
              onTap: () => context.push('/credits'),
              child: const Row(
                children: [
                  Expanded(
                    child: ScaledText(
                      'Video credits',
                      style: BaselineType.cardTitle,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: BaselineColors.ink),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LineCard(
              semanticsLabel: 'Search lessons and drills',
              onTap: () => context.push('/search'),
              child: const Row(
                children: [
                  Icon(Icons.search, color: BaselineColors.ink),
                  SizedBox(width: 10),
                  Expanded(
                    child: ScaledText(
                      'Search lessons and drills',
                      style: BaselineType.cardBody,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final level in baselineCatalog.levels) ...[
              _LevelTile(
                level: level,
                done: lessonsForLevel(level.id)
                    .where(
                      (lesson) =>
                          session.completedLessonSlugs.contains(lesson.slug),
                    )
                    .length,
                total: lessonsForLevel(level.id).length,
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            LineCard(
              semanticsLabel: 'Open techniques',
              onTap: () => context.push('/learn/techniques'),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScaledText(
                          'Techniques',
                          style: BaselineType.cardTitle,
                        ),
                        const SizedBox(height: 4),
                        ScaledText(
                          '${techniqueGroups().fold<int>(0, (count, group) => count + group.skills.length)} skills',
                          style: BaselineType.cardMuted,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: BaselineColors.ink),
                ],
              ),
            ),
            const SizedBox(height: 8),
            LineCard(
              semanticsLabel: 'Open glossary',
              onTap: () => context.push('/learn/glossary'),
              child: const Row(
                children: [
                  Expanded(
                    child: ScaledText(
                      'Glossary',
                      style: BaselineType.cardTitle,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: BaselineColors.ink),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.done,
    required this.total,
  });

  final LevelInfo level;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final count = total == 0 ? 'Path outline' : '$done of $total lessons';
    return LineCard(
      semanticsLabel: 'Level ${level.id} ${level.name}',
      onTap: () => context.push('/learn/level/${level.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText('LEVEL ${level.id}', style: BaselineType.eyebrowFairway),
          const SizedBox(height: 4),
          ScaledText(level.name, style: BaselineType.cardTitle),
          const SizedBox(height: 4),
          ScaledText(level.summary, style: BaselineType.cardBody),
          const SizedBox(height: 6),
          ScaledText(count, style: BaselineType.cardMuted),
        ],
      ),
    );
  }
}

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key, required this.levelId});

  final int levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = levelById(levelId);
    final lessons = lessonsForLevel(levelId);
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: ScaledText(level?.name ?? 'Level $levelId')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (level != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ScaledText(
                level.summary,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: BaselineColors.ink,
                ),
              ),
            ),
          if (lessons.isEmpty)
            const ScaledText(
              'Lessons for this level are on the way. The path stays visible so you can aim for it.',
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: BaselineColors.ink,
              ),
            ),
          for (final lesson in lessons) ...[
            LineCard(
              semanticsLabel: lesson.title,
              onTap: () => context.push('/learn/lesson/${lesson.slug}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    lesson.freeTier ? 'FREE' : 'PREMIUM',
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 4),
                  ScaledText(lesson.title, style: BaselineType.cardTitle),
                  const SizedBox(height: 4),
                  ScaledText(
                    '${lesson.estimatedMinutes} min · ${lesson.summary}',
                    style: BaselineType.cardBody,
                  ),
                  if (session.completedLessonSlugs.contains(lesson.slug)) ...[
                    const SizedBox(height: 6),
                    const ScaledText(
                      'Completed',
                      style: BaselineType.cardMuted,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Glossary')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final term in baselineCatalog.glossary) ...[
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(term.term, style: BaselineType.cardTitle),
                  const SizedBox(height: 4),
                  ScaledText(term.definition, style: BaselineType.cardBody),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
