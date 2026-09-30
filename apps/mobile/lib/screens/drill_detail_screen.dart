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
          FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(
                  drill.freeTier ? 'FREE' : 'PREMIUM',
                  style: BaselineType.eyebrowFairway,
                ),
                const SizedBox(height: 6),
                ScaledText(drill.name, style: BaselineType.screenTitle),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Fact(
                        icon: Icons.schedule_rounded,
                        value: '${drill.durationMinutes} min',
                        label: 'Duration',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Fact(
                        icon: Icons.group_outlined,
                        value: players,
                        label: 'Players',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Fact(
                        icon: Icons.stairs_rounded,
                        value: 'Level ${drill.levelMin}',
                        label: 'Start at',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Difficulty(level: drill.difficulty),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final video in videosForDrill(drill.slug)) ...[
            DemonstrationCard(video: video),
            const SizedBox(height: 14),
          ],
          _section(
            Icons.flag_rounded,
            PillTone.ball,
            'Objective',
            drill.objective,
          ),
          _section(
            Icons.backpack_outlined,
            PillTone.fairway,
            'Equipment',
            drill.equipment.join(', '),
          ),
          _section(
            Icons.repeat_rounded,
            PillTone.fairway,
            'Repetitions',
            drill.repetitions,
          ),
          _section(
            Icons.format_list_numbered_rounded,
            PillTone.fairway,
            'Setup',
            drill.instructions,
          ),
          _section(
            Icons.tips_and_updates_outlined,
            PillTone.ball,
            'Coaching tips',
            drill.coachingTips,
          ),
          _section(
            Icons.warning_amber_rounded,
            PillTone.clay,
            'Common mistakes',
            drill.commonMistakes,
          ),
          const SizedBox(height: 4),
          BaselineButton(
            label: done ? 'Marked done' : 'Mark done',
            semanticsLabel: done ? 'Drill marked done' : 'Mark drill done',
            icon: done ? Icons.check_circle_rounded : null,
            onPressed: done
                ? null
                : () {
                    successFeedback();
                    ref
                        .read(sessionProvider.notifier)
                        .completeDrill(drill.slug);
                  },
          ),
        ],
      ),
    );
  }

  Widget _section(IconData icon, PillTone tone, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LineCard(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(icon, tone: tone, size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: ScaledText(
                    title.toUpperCase(),
                    style: BaselineType.section.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ScaledText(body, style: BaselineType.cardBody),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label. $value',
      child: ExcludeSemantics(
        child: LineCard(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: BaselineColors.fairway),
              const SizedBox(height: 8),
              ScaledText(
                value,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: BaselineColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              ScaledText(label.toUpperCase(), style: BaselineType.eyebrow.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Difficulty extends StatelessWidget {
  const _Difficulty({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final total = level < 3 ? 3 : level;
    return Semantics(
      label: 'Difficulty $level of $total',
      child: ExcludeSemantics(
        child: Row(
          children: [
            const ScaledText('DIFFICULTY', style: BaselineType.eyebrow),
            const SizedBox(width: 12),
            for (var i = 1; i <= total; i++) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 8,
                decoration: BoxDecoration(
                  color: i <= level ? BaselineColors.clay : BaselineColors.track,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 6),
            ],
            ScaledText('$level', style: BaselineType.cardMuted),
          ],
        ),
      ),
    );
  }
}
