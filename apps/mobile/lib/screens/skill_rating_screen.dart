import 'package:baseline/data/ntrp.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:baseline/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SkillRatingScreen extends ConsumerWidget {
  const SkillRatingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(sessionProvider).skillRating;
    final selectedNtrp = code != null && !code.startsWith('rough:') ? code : null;
    final selectedRough = code != null && code.startsWith('rough:')
        ? code.substring('rough:'.length)
        : null;
    final implied = selectedNtrp == null ? null : roughLevelForNtrp(selectedNtrp);

    return Scaffold(
      appBar: AppBar(title: const ScaledText('Skill rating')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const ScaledText(
            'Pick a USTA NTRP number if you have one, or a rough level if you only know the broader band. This is your own estimate, not an official USTA rating.',
            style: TextStyle(fontSize: 16, height: 1.45, color: BaselineColors.ink),
          ),
          if (implied != null) ...[
            const SizedBox(height: 12),
            ScaledText(
              '${selectedNtrp!} sits in ${implied.name}.',
              style: BaselineType.cardMuted,
            ),
          ],
          const SectionHeader(
            'USTA NTRP',
            padding: EdgeInsets.only(top: 22, bottom: 8),
          ),
          for (final rating in ntrpRatings) ...[
            _Choice(
              title: rating.value,
              body: rating.summary,
              selected: selectedNtrp == rating.value,
              semantics: 'NTRP ${rating.value}. ${rating.summary}',
              onTap: () => ref.read(sessionProvider.notifier).setSkillRating(rating.value),
            ),
            const SizedBox(height: 8),
          ],
          const SectionHeader(
            'ROUGH LEVELS',
            padding: EdgeInsets.only(top: 16, bottom: 8),
          ),
          for (final level in roughLevels) ...[
            _Choice(
              title: level.name,
              detail: 'About ${level.about}',
              body: level.summary,
              selected: selectedRough == level.id,
              semantics: '${level.name}, about ${level.about}. ${level.summary}',
              onTap: () => ref
                  .read(sessionProvider.notifier)
                  .setSkillRating('rough:${level.id}'),
            ),
            const SizedBox(height: 8),
          ],
          if (code != null) ...[
            const SizedBox(height: 8),
            BaselineButton(
              label: 'Clear rating',
              semanticsLabel: 'Clear skill rating',
              tone: BaselineButtonTone.outline,
              onPressed: () => ref.read(sessionProvider.notifier).setSkillRating(null),
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.body,
    required this.selected,
    required this.semantics,
    required this.onTap,
    this.detail,
  });

  final String title;
  final String? detail;
  final String body;
  final bool selected;
  final String semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      tone: selected ? LineCardTone.tint : LineCardTone.light,
      semanticsLabel: selected ? '$semantics Selected.' : semantics,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(title, style: BaselineType.cardTitle),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  ScaledText(detail!, style: BaselineType.cardMuted),
                ],
                const SizedBox(height: 4),
                ScaledText(body, style: BaselineType.cardBody),
              ],
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_rounded, color: BaselineColors.fairway),
          ],
        ],
      ),
    );
  }
}
