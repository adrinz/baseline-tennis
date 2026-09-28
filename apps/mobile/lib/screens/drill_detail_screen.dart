import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/clip_player.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrillDetailScreen extends ConsumerWidget {
  const DrillDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drill = drillBySlug(slug);
    final session = ref.watch(sessionProvider);
    if (drill == null) {
      return Scaffold(
        appBar: AppBar(title: const ScaledText('Drill')),
        body: const Center(child: ScaledText('Drill not found.')),
      );
    }
    final done = session.completedDrillSlugs.contains(drill.slug);
    final players = drill.playersRequired == 1
        ? '1 player'
        : '${drill.playersRequired} players';

    return Scaffold(
      appBar: AppBar(title: const ScaledText('Drill')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ScaledText(
            drill.freeTier ? 'FREE' : 'PREMIUM',
            style: BaselineType.eyebrow,
          ),
          const SizedBox(height: 8),
          ScaledText(
            drill.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          ScaledText(
            'Level ${drill.levelMin} · ${drill.durationMinutes} min · $players · Difficulty ${drill.difficulty}',
            style: const TextStyle(
              color: BaselineColors.ink,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          for (final video in videosForDrill(drill.slug)) ...[
            DemonstrationCard(video: video),
            const SizedBox(height: 12),
          ],
          _section('Objective', drill.objective),
          _section('Equipment', drill.equipment.join(', ')),
          _section('Repetitions', drill.repetitions),
          _section('Setup', drill.instructions),
          _section('Coaching tips', drill.coachingTips),
          _section('Common mistakes', drill.commonMistakes),
          const SizedBox(height: 4),
          BaselineButton(
            label: done ? 'Marked done' : 'Mark done',
            semanticsLabel: done ? 'Drill marked done' : 'Mark drill done',
            onPressed: done
                ? null
                : () => ref
                      .read(sessionProvider.notifier)
                      .completeDrill(drill.slug),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LineCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText(title.toUpperCase(), style: BaselineType.eyebrowFairway),
            const SizedBox(height: 6),
            ScaledText(body, style: BaselineType.cardBody),
          ],
        ),
      ),
    );
  }
}
