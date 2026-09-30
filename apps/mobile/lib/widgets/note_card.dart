import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';

/// A high-contrast coaching note. Color is a border, never the only signal.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.title,
    required this.body,
    required this.borderColor,
  });

  final String title;
  final String body;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $body',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: BaselineColors.card,
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaledText(title, style: BaselineType.cardTitle),
              const SizedBox(height: 4),
              ScaledText(body, style: BaselineType.cardBody),
            ],
          ),
        ),
      ),
    );
  }
}
