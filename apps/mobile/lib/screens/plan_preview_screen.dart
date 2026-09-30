import 'package:baseline/logic/plan.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/entrance.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/pill.dart';
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
    final total = days.fold<int>(0, (sum, day) => sum + day.minutes);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            const ScaledText('YOUR FIRST WEEK', style: BaselineType.eyebrowFairway),
            const SizedBox(height: 8),
            const ScaledText('Your first week', style: BaselineType.screenTitle),
            const SizedBox(height: 8),
            ScaledText(
              '$dayLabel days · $goal',
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: BaselineColors.muted,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Pill('${days.length} sessions', icon: Icons.event_available_rounded),
                Pill('$total min total', icon: Icons.schedule_rounded),
              ],
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < days.length; i++) ...[
              FadeSlideIn(
                index: i,
                child: LineCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ScaledText(
                                  days[i].label.toUpperCase(),
                                  style: BaselineType.eyebrowFairway,
                                ),
                                const SizedBox(height: 2),
                                ScaledText(
                                  days[i].title,
                                  style: BaselineType.cardTitle.copyWith(
                                    fontSize: 19,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Pill('${days[i].minutes} min'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (var b = 0; b < days[i].blocks.length; b++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              StepDot(number: b + 1, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ScaledText(
                                  '${days[i].blocks[b].title} · ${days[i].blocks[b].minutes} min',
                                  style: BaselineType.cardBody.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
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
              icon: Icons.check_rounded,
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
