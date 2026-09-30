import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _Perk extends StatelessWidget {
  const _Perk(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: BaselineColors.fairway,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(child: ScaledText(label, style: BaselineType.cardBody)),
        ],
      ),
    );
  }
}

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: BaselineColors.nightCourt,
      appBar: AppBar(
        backgroundColor: BaselineColors.nightCourt,
        foregroundColor: BaselineColors.line,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const ScaledText(
          'Premium',
          style: TextStyle(color: BaselineColors.line),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ScaledText(
            'Baseline Premium',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: BaselineColors.line),
          ),
          const SizedBox(height: 8),
          const ScaledText(
            'The price is set in the App Store. This preview does not charge you.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: BaselineColors.line,
            ),
          ),
          const SizedBox(height: 16),
          const LineCard(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText('INCLUDED', style: BaselineType.eyebrowFairway),
                SizedBox(height: 12),
                _Perk('All published lessons and drills'),
                _Perk('Generated weekly plans'),
                _Perk('Virtual Tennis Pro'),
                _Perk('Full progress history'),
                _Perk('Unlimited partner browsing'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BaselineButton(
            label: 'Unlock on this phone',
            semanticsLabel: 'Unlock Premium on this phone',
            onDark: true,
            tone: BaselineButtonTone.ball,
            onPressed: () {
              context.pop();
              ref.read(sessionProvider.notifier).unlockPremium();
            },
          ),
          const SizedBox(height: 8),
          const ScaledText(
            'App Store billing is not connected in this build. Unlocking here does not charge you.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: BaselineColors.mist,
            ),
          ),
          const SizedBox(height: 16),
          BaselineButton(
            label: 'Not now',
            semanticsLabel: 'Dismiss Premium offer',
            tone: BaselineButtonTone.outline,
            onDark: true,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
