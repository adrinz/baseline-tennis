import 'package:baseline/data/auth_gateway.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  AuthProvider? _busy;
  String? _error;

  Future<void> _provider(AuthProvider provider) async {
    setState(() {
      _busy = provider;
      _error = null;
    });
    final attempt = await ref
        .read(sessionProvider.notifier)
        .signInWithProvider(provider);
    if (!mounted) return;
    setState(() => _busy = null);
    switch (attempt) {
      case AuthSucceeded():
        context.go('/age');
      case AuthCancelled():
        break;
      case AuthRejected(:final message):
        setState(() => _error = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _busy != null;
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Sign in')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const IconBadge(Icons.lock_open_rounded, size: 56),
            const SizedBox(height: 18),
            const ScaledText(
              'Use Apple, Google, or a one-time email code.',
              style: BaselineType.lead,
            ),
            const SizedBox(height: 8),
            const ScaledText(
              'Baseline is for ages 16 and up.',
              style: TextStyle(fontSize: 14, height: 1.4, color: BaselineColors.muted),
            ),
            const SizedBox(height: 28),
            BaselineButton(
              label: _busy == AuthProvider.apple ? 'Signing in…' : 'Sign in with Apple',
              semanticsLabel: 'Sign in with Apple',
              tone: BaselineButtonTone.ink,
              icon: Icons.apple,
              onPressed: busy ? null : () => _provider(AuthProvider.apple),
            ),
            const SizedBox(height: 12),
            BaselineButton(
              label: _busy == AuthProvider.google
                  ? 'Signing in…'
                  : 'Continue with Google',
              semanticsLabel: 'Continue with Google',
              tone: BaselineButtonTone.outline,
              icon: Icons.g_mobiledata_rounded,
              onPressed: busy ? null : () => _provider(AuthProvider.google),
            ),
            const SizedBox(height: 12),
            BaselineButton(
              label: 'Use email code',
              semanticsLabel: 'Continue with email',
              tone: BaselineButtonTone.outline,
              icon: Icons.mail_outline_rounded,
              onPressed: busy ? null : () => context.push('/email'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              ScaledText(
                _error!,
                style: const TextStyle(
                  color: BaselineColors.clay,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
