import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';

enum BaselineButtonTone { ball, fairway, line, outline }

class BaselineButton extends StatelessWidget {
  const BaselineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticsLabel,
    this.tone = BaselineButtonTone.fairway,
    this.onDark = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final BaselineButtonTone tone;
  final bool onDark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final colors = _colorsFor(tone, onDark);
    final foreground = enabled
        ? colors.foreground
        : colors.foreground.withValues(alpha: 0.55);

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel ?? label,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMinTapTarget,
            minHeight: kMinTapTarget,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: colors.background,
              foregroundColor: colors.foreground,
              disabledBackgroundColor: colors.background.withValues(
                alpha: 0.45,
              ),
              disabledForegroundColor: colors.foreground.withValues(
                alpha: 0.55,
              ),
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: StadiumBorder(
                side: tone == BaselineButtonTone.outline
                    ? BorderSide(
                        color: onDark
                            ? BaselineColors.line
                            : BaselineColors.fairway,
                        width: 1.5,
                      )
                    : BorderSide.none,
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: foreground),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: ScaledText(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _colorsFor(BaselineButtonTone tone, bool onDark) {
    switch (tone) {
      case BaselineButtonTone.ball:
        return const _ButtonColors(BaselineColors.ball, BaselineColors.ink);
      case BaselineButtonTone.fairway:
        return const _ButtonColors(BaselineColors.fairway, BaselineColors.line);
      case BaselineButtonTone.line:
        return const _ButtonColors(BaselineColors.line, BaselineColors.ink);
      case BaselineButtonTone.outline:
        return onDark
            ? const _ButtonColors(Colors.transparent, BaselineColors.line)
            : const _ButtonColors(Colors.transparent, BaselineColors.fairway);
    }
  }
}

class _ButtonColors {
  const _ButtonColors(this.background, this.foreground);
  final Color background;
  final Color foreground;
}
