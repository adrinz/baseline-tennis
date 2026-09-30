import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';

/// A section title with an optional action on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.only(top: 8, bottom: 10),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: ScaledText(title, style: BaselineType.section),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: BaselineColors.fairwayPressed,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaledText(
                    action!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
