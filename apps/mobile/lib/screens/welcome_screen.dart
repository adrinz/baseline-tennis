import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: BaselineColors.nightCourt,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            const _Mark(),
            const SizedBox(height: 28),
            const ScaledText('BASELINE', style: BaselineType.eyebrowOnNight),
            const SizedBox(height: 12),
            ScaledText(
              'Start from a solid base.',
              style: Theme.of(context).textTheme.displayLarge
                  ?.copyWith(color: BaselineColors.line),
            ),
            const SizedBox(height: 16),
            const ScaledText(
              'Learn tennis step by step, find a place to practice, and see yourself improve.',
              style: TextStyle(
                fontSize: 17,
                height: 1.45,
                color: BaselineColors.line,
              ),
            ),
            const SizedBox(height: 32),
            BaselineButton(
              label: 'Get started',
              semanticsLabel: 'Get started',
              tone: BaselineButtonTone.ball,
              onPressed: () => context.push('/sign-in'),
            ),
            const SizedBox(height: 12),
            BaselineButton(
              label: 'Sign in with Apple',
              semanticsLabel: 'Sign in with Apple',
              tone: BaselineButtonTone.line,
              icon: Icons.apple,
              onPressed: () {
                ref.read(sessionProvider.notifier).signIn(AuthProvider.apple);
                context.go('/age');
              },
            ),
            const SizedBox(height: 28),
            const ScaledText(
              'Google and email are on the next step. Sign in with Apple is on this screen because Google is offered too.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: BaselineColors.line,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: BaselineColors.ball,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 16, height: 16),
        ),
        SizedBox(width: 10),
        DecoratedBox(
          decoration: BoxDecoration(color: BaselineColors.line),
          child: SizedBox(width: 42, height: 2),
        ),
      ],
    );
  }
}
