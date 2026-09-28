import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Sign in')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const ScaledText(
              'Use Apple, Google, or a one-time email code.',
              style: TextStyle(
                fontSize: 17,
                height: 1.45,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 28),
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
            const SizedBox(height: 12),
            BaselineButton(
              label: 'Continue with Google',
              semanticsLabel: 'Continue with Google',
              tone: BaselineButtonTone.outline,
              onPressed: () {
                ref.read(sessionProvider.notifier).signIn(AuthProvider.google);
                context.go('/age');
              },
            ),
            const SizedBox(height: 12),
            BaselineButton(
              label: 'Use email code',
              semanticsLabel: 'Continue with email',
              tone: BaselineButtonTone.outline,
              onPressed: () => context.push('/email'),
            ),
          ],
        ),
      ),
    );
  }
}
