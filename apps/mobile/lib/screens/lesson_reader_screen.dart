import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/clip_player.dart';
import 'package:baseline/widgets/coach_sheet.dart';
import 'package:baseline/widgets/line_card.dart';
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
      appBar: AppBar(
        title: const ScaledText('Lesson'),
        actions: [
          IconButton(
            tooltip: 'Ask the pro',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            onPressed: () => showCoachSheet(context),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText(
              lesson.category.toUpperCase(),
              style: BaselineType.eyebrow,
            ),
            const SizedBox(height: 8),
            ScaledText(
              lesson.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            ScaledText(
              'Level ${lesson.level} · ${lesson.estimatedMinutes} min',
              style: const TextStyle(color: BaselineColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 16),
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScaledText(
                    'OVERVIEW',
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 6),
                  ScaledText(lesson.summary, style: BaselineType.cardBody),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final video in videos) ...[
              DemonstrationCard(video: video),
              const SizedBox(height: 12),
            ],
            if (locked) ...[
              _LockCard(title: lesson.title),
              const SizedBox(height: 12),
              BaselineButton(
                label: 'See Premium',
                semanticsLabel: 'See Premium',
                onPressed: () => context.push('/paywall'),
              ),
            ] else ...[
              for (final block in lesson.blocks) ...[
                LineCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScaledText(
                        blockHeading(block.kind).toUpperCase(),
                        style: BaselineType.eyebrowFairway,
                      ),
                      const SizedBox(height: 6),
                      ScaledText(
                        formatBlockBody(block.body),
                        style: BaselineType.cardBody,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              BaselineButton(
                label: completed ? 'Completed' : 'Mark complete',
                semanticsLabel: completed
                    ? 'Lesson completed'
                    : 'Mark lesson complete',
                tone: BaselineButtonTone.fairway,
                onPressed: completed
                    ? null
                    : () => ref
                          .read(sessionProvider.notifier)
                          .completeLesson(lesson.slug),
              ),
            ],
          ],
        ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BaselineColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BaselineColors.clay, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lock_outline,
              color: BaselineColors.clay,
              size: 28,
            ),
            const SizedBox(height: 8),
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
