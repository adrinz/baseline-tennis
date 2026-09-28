import 'package:baseline/logic/plan.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlanPreviewScreen extends ConsumerWidget {
  const PlanPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final days = buildFirstWeek(session.daysPerWeek);
    final goal = session.goal ?? 'Learn from scratch';
    final dayLabel = session.daysPerWeek >= 5 ? '5+' : '${session.daysPerWeek}';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const ScaledText('YOUR FIRST WEEK', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            ScaledText(
              'Your first week',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            ScaledText(
              '$dayLabel days · $goal. Courts in this preview use Austin.',
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 20),
            for (final day in days) ...[
              LineCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      day.label.toUpperCase(),
                      style: BaselineType.eyebrowFairway,
                    ),
                    const SizedBox(height: 4),
                    ScaledText(day.title, style: BaselineType.cardTitle),
                    const SizedBox(height: 4),
                    ScaledText(
                      '${day.minutes} min',
                      style: BaselineType.cardMuted,
                    ),
                    const SizedBox(height: 8),
                    for (final block in day.blocks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ScaledText(
                          '${block.title} · ${block.minutes} min',
                          style: BaselineType.cardBody,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            BaselineButton(
              label: 'Edit days',
              semanticsLabel: 'Edit training days',
              tone: BaselineButtonTone.outline,
              onPressed: () => context.go('/onboarding?step=days'),
            ),
            const SizedBox(height: 12),
            BaselineButton(
              label: 'Accept plan',
              semanticsLabel: 'Accept your first week',
              onPressed: () {
                ref.read(sessionProvider.notifier).finishOnboarding();
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
