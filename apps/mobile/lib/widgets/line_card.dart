import 'package:baseline/theme/baseline_colors.dart';
import 'package:flutter/material.dart';

class LineCard extends StatelessWidget {
  const LineCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final card = SizedBox(
      width: double.infinity,
      child: Material(
        color: BaselineColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: BaselineColors.ink.withValues(alpha: 0.16)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap == null) return card;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: card,
          ),
        ),
      ),
    );
  }
}
