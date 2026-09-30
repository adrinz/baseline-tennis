import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';

/// A tappable row with an icon, a label, and a chevron.
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.detail,
    this.tone = PillTone.fairway,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? detail;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      semanticsLabel: label,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconBadge(icon, tone: tone, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(label, style: BaselineType.cardTitle),
                if (detail != null) ...[
                  const SizedBox(height: 1),
                  ScaledText(detail!, style: BaselineType.cardMuted),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: BaselineColors.muted),
        ],
      ),
    );
  }
}
