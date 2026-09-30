import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/clip_player.dart';
import 'package:baseline/widgets/entrance.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/pressable.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LessonReaderScreen extends ConsumerWidget {
  const LessonReaderScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = lessonBySlug(slug);
    final session = ref.watch(sessionProvider);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const ScaledText('Lesson')),
        body: const Center(child: ScaledText('Lesson not found.')),
      );
    }

    final locked = !lesson.freeTier && !session.premium;
    final completed = session.completedLessonSlugs.contains(lesson.slug);
    final videos = videosForLesson(lesson.slug);

    return Scaffold(
      appBar: AppBar(title: const ScaledText('Lesson')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    lesson.category.toUpperCase(),
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 6),
                  ScaledText(lesson.title, style: BaselineType.screenTitle),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Pill(
                        'Level ${lesson.level}',
                        icon: Icons.stairs_rounded,
                      ),
                      Pill(
                        '${lesson.estimatedMinutes} min',
                        icon: Icons.schedule_rounded,
                      ),
                      if (lesson.freeTier)
                        const Pill('FREE', tone: PillTone.fairway)
                      else
                        const Pill(
                          'PREMIUM',
                          icon: Icons.star_rounded,
                          tone: PillTone.clay,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ScaledText(lesson.summary, style: BaselineType.lead),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (final video in videos) ...[
              DemonstrationCard(video: video),
              const SizedBox(height: 14),
            ],
            if (locked) ...[
              _LockCard(title: lesson.title),
              const SizedBox(height: 14),
              BaselineButton(
                label: 'See Premium',
                semanticsLabel: 'See Premium',
                tone: BaselineButtonTone.ink,
                icon: Icons.star_rounded,
                onPressed: () => context.push('/paywall'),
              ),
            ] else ...[
              for (final block in lesson.blocks) ...[
                _BlockCard(kind: block.kind, body: block.body),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              BaselineButton(
                label: completed ? 'Completed' : 'Mark complete',
                semanticsLabel: completed
                    ? 'Lesson completed'
                    : 'Mark lesson complete',
                tone: BaselineButtonTone.fairway,
                icon: completed ? Icons.check_circle_rounded : null,
                onPressed: completed
                    ? null
                    : () {
                        successFeedback();
                        ref
                            .read(sessionProvider.notifier)
                            .completeLesson(lesson.slug);
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

({IconData icon, PillTone tone}) _kindStyle(String kind) {
  switch (kind) {
    case 'overview':
      return (icon: Icons.menu_book_rounded, tone: PillTone.fairway);
    case 'why':
      return (icon: Icons.lightbulb_outline_rounded, tone: PillTone.ball);
    case 'steps':
      return (icon: Icons.format_list_numbered_rounded, tone: PillTone.fairway);
    case 'tips':
      return (icon: Icons.tips_and_updates_outlined, tone: PillTone.ball);
    case 'mistakes':
    case 'beginner_mistakes':
      return (icon: Icons.warning_amber_rounded, tone: PillTone.clay);
    case 'checklist':
      return (icon: Icons.checklist_rounded, tone: PillTone.fairway);
    default:
      return (icon: Icons.notes_rounded, tone: PillTone.neutral);
  }
}

final _numbered = RegExp(r'^\s*(\d+)\.\s+(.*)$');

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.kind, required this.body});

  final String kind;
  final String body;

  @override
  Widget build(BuildContext context) {
    final style = _kindStyle(kind);
    final lines = formatBlockBody(
      body,
    ).split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty);
    final rows = lines.toList();
    final numberedCount = rows.where(_numbered.hasMatch).length;
    final asSteps = numberedCount >= 2;
    final asBullets =
        !asSteps &&
        rows.length > 1 &&
        (kind == 'tips' ||
            kind == 'checklist' ||
            kind == 'mistakes' ||
            kind == 'beginner_mistakes');

    return LineCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(style.icon, tone: style.tone, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: ScaledText(
                  blockHeading(kind).toUpperCase(),
                  style: BaselineType.section.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (asSteps)
            for (final row in rows)
              if (_numbered.firstMatch(row) case final match?)
                _StepLine(
                  number: int.tryParse(match.group(1) ?? ''),
                  text: match.group(2) ?? row,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ScaledText(row, style: BaselineType.cardBody),
                )
          else if (asBullets)
            for (final row in rows) _BulletLine(text: row, kind: kind)
          else
            ScaledText(body, style: BaselineType.cardBody),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.number, required this.text});

  final int? number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepDot(number: number, size: 26),
          const SizedBox(width: 12),
          Expanded(child: ScaledText(text, style: BaselineType.cardBody)),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text, required this.kind});

  final String text;
  final String kind;

  @override
  Widget build(BuildContext context) {
    final mistake = kind == 'mistakes' || kind == 'beginner_mistakes';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              mistake ? Icons.close_rounded : Icons.check_rounded,
              size: 20,
              color: mistake ? BaselineColors.clay : BaselineColors.fairway,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: ScaledText(text, style: BaselineType.cardBody)),
        ],
      ),
    );
  }
}

class _LockCard extends StatelessWidget {
  const _LockCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Locked Premium lesson',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: BaselineColors.claySoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: BaselineColors.clay.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBadge(
              Icons.lock_outline_rounded,
              tone: PillTone.clay,
              size: 44,
            ),
            const SizedBox(height: 12),
            const ScaledText('Premium', style: BaselineType.cardTitle),
            const SizedBox(height: 6),
            ScaledText(
              'You can read the overview. The rest of $title is locked.',
              style: BaselineType.cardBody,
            ),
            const SizedBox(height: 6),
            const ScaledText(
              'With Premium you get the full lesson: cross-court patterns, and when to change direction.',
              style: BaselineType.cardBody,
            ),
          ],
        ),
      ),
    );
  }
}
