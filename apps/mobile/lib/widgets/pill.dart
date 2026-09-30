import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';

enum PillTone { neutral, fairway, ball, clay, night }

({Color background, Color foreground}) _pillColors(PillTone tone) {
  switch (tone) {
    case PillTone.neutral:
      return (background: BaselineColors.track, foreground: BaselineColors.ink);
    case PillTone.fairway:
      return (
        background: BaselineColors.fairwaySoft,
        foreground: BaselineColors.fairwayPressed,
      );
    case PillTone.ball:
      return (background: BaselineColors.ball, foreground: BaselineColors.ink);
    case PillTone.clay:
      return (
        background: BaselineColors.claySoft,
        foreground: BaselineColors.clayDeep,
      );
    case PillTone.night:
      return (
        background: BaselineColors.nightRaised,
        foreground: BaselineColors.ball,
      );
  }
}

/// A small rounded label for facts such as FREE, 10 min, or Level 2.
class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.icon, this.tone = PillTone.neutral});

  final String label;
  final IconData? icon;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _pillColors(tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: colors.foreground),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: ScaledText(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: colors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded square that holds an icon.
class IconBadge extends StatelessWidget {
  const IconBadge(
    this.icon, {
    super.key,
    this.tone = PillTone.fairway,
    this.size = 44,
  });

  final IconData icon;
  final PillTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = _pillColors(tone);
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(size * 0.32),
          ),
          child: Icon(icon, size: size * 0.52, color: colors.foreground),
        ),
      ),
    );
  }
}

/// A numbered or checked circle for steps and lists.
class StepDot extends StatelessWidget {
  const StepDot({
    super.key,
    this.number,
    this.done = false,
    this.size = 28,
    this.onDark = false,
  });

  final int? number;
  final bool done;
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final background = done
        ? BaselineColors.fairway
        : onDark
        ? BaselineColors.nightRaised
        : BaselineColors.track;
    final foreground = done
        ? BaselineColors.line
        : onDark
        ? BaselineColors.ball
        : BaselineColors.ink;
    return ExcludeSemantics(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: done
            ? Icon(Icons.check, size: size * 0.6, color: foreground)
            : Text(
                '${number ?? ''}',
                style: TextStyle(
                  fontSize: size * 0.46,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
      ),
    );
  }
}
