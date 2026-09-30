import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/entrance.dart';
import 'package:baseline/widgets/hero_card.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/progress.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:baseline/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final techniqueCount = techniqueGroups().fold<int>(
      0,
      (count, group) => count + group.skills.length,
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const ScaledText('Learn', style: BaselineType.screenTitle),
            const SizedBox(height: 6),
            const ScaledText(
              'Levels 1–3 are the full path. Levels 4 and 5 stay visible.',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: BaselineColors.muted,
              ),
            ),
            const SizedBox(height: 16),
            LineCard(
              semanticsLabel: 'Search lessons and drills',
              onTap: () => context.push('/search'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: BaselineColors.muted),
                  SizedBox(width: 10),
                  Expanded(
                    child: ScaledText(
                      'Search lessons and drills',
                      style: TextStyle(
                        fontSize: 16,
                        color: BaselineColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FadeSlideIn(
              child: HeroCard(
                semanticsLabel: 'Open stroke demonstrations',
                onTap: () => context.push('/videos'),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScaledText(
                            'WATCH',
                            style: BaselineType.eyebrowOnNight,
                          ),
                          const SizedBox(height: 4),
                          ScaledText(
                            '${licensedVideos.length} demonstrations',
                            style: BaselineType.heroTitle.copyWith(fontSize: 26),
                          ),
                          const SizedBox(height: 4),
                          ScaledText(
                            'Grips, footwork, scoring, and every main stroke.',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: BaselineColors.line.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const ExcludeSemantics(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: BaselineColors.ball,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 32,
                            color: BaselineColors.nightCourt,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ExploreTile(
                    label: 'Techniques',
                    detail: '$techniqueCount skills',
                    icon: Icons.auto_awesome_rounded,
                    semantics: 'Open techniques',
                    onTap: () => context.push('/learn/techniques'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExploreTile(
                    label: 'Glossary',
                    detail: '${baselineCatalog.glossary.length} terms',
                    icon: Icons.menu_book_rounded,
                    semantics: 'Open glossary',
                    onTap: () => context.push('/learn/glossary'),
                  ),
                ),
              ],
            ),
            const SectionHeader(
              'YOUR PATH',
              padding: EdgeInsets.only(top: 22, bottom: 10),
            ),
            for (final level in baselineCatalog.levels) ...[
              _LevelTile(
                level: level,
                current: level.id == session.level,
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
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push('/credits'),
                icon: const Icon(Icons.movie_outlined, size: 18),
                label: const ScaledText('Video credits'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.label,
    required this.detail,
    required this.icon,
    required this.semantics,
    required this.onTap,
  });

  final String label;
  final String detail;
  final IconData icon;
  final String semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      semanticsLabel: semantics,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon, size: 40),
          const SizedBox(height: 12),
          ScaledText(label, style: BaselineType.cardTitle),
          const SizedBox(height: 2),
          ScaledText(detail, style: BaselineType.cardMuted),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.current,
    required this.done,
    required this.total,
  });

  final LevelInfo level;
  final bool current;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final outline = total == 0;
    final complete = total > 0 && done == total;
    final count = outline ? 'Path outline' : '$done of $total lessons';
    return LineCard(
      semanticsLabel: 'Level ${level.id} ${level.name}',
      onTap: () => context.push('/learn/level/${level.id}'),
      tone: current ? LineCardTone.tint : LineCardTone.light,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LevelBadge(id: level.id, current: current, complete: complete),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ScaledText(
                      'LEVEL ${level.id}',
                      style: BaselineType.eyebrowFairway,
                    ),
                    if (current) const Pill('YOU ARE HERE', tone: PillTone.ball),
                  ],
                ),
                const SizedBox(height: 2),
                ScaledText(level.name, style: BaselineType.cardTitle),
                const SizedBox(height: 2),
                ScaledText(
                  level.summary,
                  maxLines: 2,
                  style: BaselineType.cardMuted.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 10),
                if (!outline) ...[
                  SlimBar(value: done / total, height: 6),
                  const SizedBox(height: 6),
                ],
                ScaledText(count, style: BaselineType.cardMuted),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Icon(
              outline ? Icons.lock_outline_rounded : Icons.chevron_right,
              color: BaselineColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({
    required this.id,
    required this.current,
    required this.complete,
  });

  final int id;
  final bool current;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final background = complete
        ? BaselineColors.fairway
        : current
        ? BaselineColors.nightCourt
        : BaselineColors.track;
    final foreground = complete || current
        ? BaselineColors.ball
        : BaselineColors.ink;
    return ExcludeSemantics(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: complete
            ? Icon(Icons.check_rounded, color: foreground, size: 28)
            : Text(
                '$id',
                style: TextStyle(
                  fontFamily: 'Barlow Condensed',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
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
    final done = lessons
        .where((item) => session.completedLessonSlugs.contains(item.slug))
        .length;
    return Scaffold(
      appBar: AppBar(title: ScaledText(level?.name ?? 'Level $levelId')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (level != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HeroCard(
                showCourt: false,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      'LEVEL $levelId',
                      style: BaselineType.eyebrowOnNight,
                    ),
                    const SizedBox(height: 6),
                    ScaledText(
                      level.summary,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: BaselineColors.line.withValues(alpha: 0.92),
                      ),
                    ),
                    if (lessons.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SlimBar(
                        value: done / lessons.length,
                        color: BaselineColors.ball,
                        background: BaselineColors.line.withValues(alpha: 0.14),
                      ),
                      const SizedBox(height: 8),
                      ScaledText(
                        '$done of ${lessons.length} lessons',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: BaselineColors.line.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (lessons.isEmpty)
            const LineCard(
              tone: LineCardTone.tint,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.hourglass_top_rounded, color: BaselineColors.fairway),
                  SizedBox(width: 12),
                  Expanded(
                    child: ScaledText(
                      'Lessons for this level are on the way. The path stays visible so you can aim for it.',
                      style: BaselineType.cardBody,
                    ),
                  ),
                ],
              ),
            ),
          for (var i = 0; i < lessons.length; i++) ...[
            _LessonTile(
              number: i + 1,
              lesson: lessons[i],
              completed: session.completedLessonSlugs.contains(lessons[i].slug),
              locked: !lessons[i].freeTier && !session.premium,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.number,
    required this.lesson,
    required this.completed,
    required this.locked,
  });

  final int number;
  final Lesson lesson;
  final bool completed;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      semanticsLabel: lesson.title,
      onTap: () => context.push('/learn/lesson/${lesson.slug}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepDot(number: number, done: completed, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(lesson.title, style: BaselineType.cardTitle),
                const SizedBox(height: 3),
                ScaledText(
                  lesson.summary,
                  maxLines: 2,
                  style: BaselineType.cardMuted.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Pill(
                      '${lesson.estimatedMinutes} min',
                      icon: Icons.schedule_rounded,
                    ),
                    if (lesson.freeTier)
                      const Pill('FREE', tone: PillTone.fairway)
                    else
                      Pill(
                        'PREMIUM',
                        icon: locked ? Icons.lock_rounded : Icons.star_rounded,
                        tone: PillTone.clay,
                      ),
                    if (completed)
                      const Pill('Completed', tone: PillTone.fairway),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.chevron_right, color: BaselineColors.muted),
          ),
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          for (final term in baselineCatalog.glossary) ...[
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    term.term,
                    style: BaselineType.cardTitle.copyWith(
                      color: BaselineColors.fairwayPressed,
                    ),
                  ),
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
