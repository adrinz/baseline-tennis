import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: BaselineColors.nightCourt,
      appBar: AppBar(
        backgroundColor: BaselineColors.nightCourt,
        foregroundColor: BaselineColors.line,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText('INCLUDED', style: BaselineType.eyebrowFairway),
                SizedBox(height: 8),
                ScaledText(
                  'All published lessons and drills',
                  style: BaselineType.cardBody,
                ),
                ScaledText(
                  'Generated weekly plans',
                  style: BaselineType.cardBody,
                ),
                ScaledText('Virtual Tennis Pro', style: BaselineType.cardBody),
                ScaledText(
                  'Full progress history',
                  style: BaselineType.cardBody,
                ),
                ScaledText(
                  'Unlimited partner browsing',
                  style: BaselineType.cardBody,
                ),
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
