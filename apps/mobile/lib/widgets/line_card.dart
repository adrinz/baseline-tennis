import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/pressable.dart';
import 'package:flutter/material.dart';

enum LineCardTone { light, tint, night }

/// The standard surface: a soft card with a hairline border.
///
/// When [onTap] is set it shrinks under the finger, ticks, and ripples.
class LineCard extends StatelessWidget {
  const LineCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    this.padding = const EdgeInsets.all(16),
    this.tone = LineCardTone.light,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final EdgeInsets padding;
  final LineCardTone tone;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    final night = tone == LineCardTone.night;
    final background = switch (tone) {
      LineCardTone.light => BaselineColors.card,
      LineCardTone.tint => BaselineColors.fairwaySoft,
      LineCardTone.night => BaselineColors.nightCourt,
    };
    final border = night
        ? BaselineColors.line.withValues(alpha: 0.1)
        : BaselineColors.ink.withValues(alpha: 0.08);

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: tone == LineCardTone.light ? BaselineShadows.card : null,
      ),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? Padding(padding: padding, child: child)
            : InkWell(
                onTap: () {
                  tapFeedback();
                  onTap!();
                },
                child: Padding(padding: padding, child: child),
              ),
      ),
    );
    final card = SizedBox(width: double.infinity, child: surface);

    if (onTap == null) return card;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        child: PressScale(child: card),
      ),
    );
  }
}
