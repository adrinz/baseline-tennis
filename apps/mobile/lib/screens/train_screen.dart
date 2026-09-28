import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/logic/plan.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TrainScreen extends ConsumerWidget {
  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final week = buildFirstWeek(session.daysPerWeek);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            ScaledText(
              'Train',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const ScaledText('THIS WEEK', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            for (final day in week) ...[
              LineCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      '${day.label} · ${day.minutes} min',
                      style: BaselineType.eyebrowFairway,
                    ),
                    const SizedBox(height: 4),
                    ScaledText(day.title, style: BaselineType.cardTitle),
                    const SizedBox(height: 6),
                    for (final block in day.blocks)
                      ScaledText(
                        '· ${block.title}',
                        style: BaselineType.cardBody,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            const ScaledText('WATCH A STROKE', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            for (final video in licensedVideos) ...[
              LineCard(
                semanticsLabel: 'Play ${video.title}',
                onTap: () => context.push('/video/${video.id}'),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_fill,
                      color: BaselineColors.fairway,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScaledText(
                            video.title,
                            style: BaselineType.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          ScaledText(
                            '${video.durationLabel} · ${video.creator}',
                            style: BaselineType.cardBody,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
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
            const ScaledText('DRILL LIBRARY', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            for (final drill in baselineCatalog.drills) ...[
              LineCard(
                semanticsLabel: drill.name,
                onTap: () => context.push('/train/drill/${drill.slug}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      drill.freeTier
                          ? 'FREE · LEVEL ${drill.levelMin}'
                          : 'PREMIUM · LEVEL ${drill.levelMin}',
                      style: BaselineType.eyebrowFairway,
                    ),
                    const SizedBox(height: 4),
                    ScaledText(drill.name, style: BaselineType.cardTitle),
                    const SizedBox(height: 4),
                    ScaledText(
                      '${drill.durationMinutes} min · ${drill.objective}',
                      style: BaselineType.cardBody,
                    ),
                    if (session.completedDrillSlugs.contains(drill.slug)) ...[
                      const SizedBox(height: 6),
                      const ScaledText('Done', style: BaselineType.cardMuted),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
