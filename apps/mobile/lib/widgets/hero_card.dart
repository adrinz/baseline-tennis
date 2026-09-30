import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/pressable.dart';
import 'package:flutter/material.dart';

/// A top-down tennis court drawn as thin lines. Decoration only.
class CourtLines extends StatelessWidget {
  const CourtLines({super.key, this.color = BaselineColors.line, this.opacity = 0.09});

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CourtPainter(color.withValues(alpha: opacity)),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _CourtPainter extends CustomPainter {
  _CourtPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    final sx = size.width / 36;
    final sy = size.height / 78;
    canvas.drawRect(Offset.zero & size, paint);
    for (final x in [4.5, 31.5]) {
      canvas.drawLine(Offset(x * sx, 0), Offset(x * sx, size.height), paint);
    }
    for (final y in [18.0, 60.0]) {
      canvas.drawLine(Offset(4.5 * sx, y * sy), Offset(31.5 * sx, y * sy), paint);
    }
    canvas.drawLine(Offset(18 * sx, 18 * sy), Offset(18 * sx, 60 * sy), paint);
    final net = Paint()
      ..color = color
      ..strokeWidth = 4;
    canvas.drawLine(Offset(-2 * sx, 39 * sy), Offset(38 * sx, 39 * sy), net);
  }

  @override
  bool shouldRepaint(_CourtPainter old) => old.color != color;
}

/// The dark, high-emphasis card that carries the one next action on a screen.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    this.padding = const EdgeInsets.all(20),
    this.showCourt = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final EdgeInsets padding;
  final bool showCourt;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);
    final body = DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: BaselineShadows.lift),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BaselineColors.nightGlow, BaselineColors.nightCourt],
                  ),
                ),
              ),
            ),
            if (showCourt)
              const Positioned(
                right: -36,
                top: -44,
                width: 180,
                height: 390,
                child: CourtLines(),
              ),
            Positioned(
              right: 22,
              bottom: 22,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: BaselineColors.ball.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 96, height: 96),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: onTap == null
                  ? Padding(padding: padding, child: child)
                  : InkWell(
                      onTap: () {
                        tapFeedback();
                        onTap!();
                      },
                      splashColor: BaselineColors.ball.withValues(alpha: 0.12),
                      highlightColor: BaselineColors.ball.withValues(alpha: 0.06),
                      child: Padding(padding: padding, child: child),
                    ),
            ),
          ],
        ),
      ),
    );
    final sized = SizedBox(width: double.infinity, child: body);
    if (onTap == null) return sized;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        child: PressScale(scale: 0.98, child: sized),
      ),
    );
  }
}
