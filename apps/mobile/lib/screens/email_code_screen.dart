import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

bool looksLikeEmail(String value) {
  final trimmed = value.trim();
  final at = trimmed.indexOf('@');
  return at > 0 && trimmed.contains('.', at);
}

class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final email = _controller.text;
    if (!looksLikeEmail(email)) {
      setState(() => _error = 'Enter an email address.');
      return;
    }
    ref.read(sessionProvider.notifier).startEmail(email);
    context.push('/code');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Email')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const ScaledText(
              'We will send a one-time code. There is no password in this version.',
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('email-field'),
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              style: const TextStyle(color: BaselineColors.ink),
              decoration: const InputDecoration(hintText: 'you@email.com'),
              onSubmitted: (_) => _send(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              ScaledText(
                _error!,
                style: const TextStyle(
                  color: BaselineColors.clay,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 20),
            BaselineButton(
              label: 'Send code',
              semanticsLabel: 'Send code',
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class EmailCodeScreen extends ConsumerStatefulWidget {
  const EmailCodeScreen({super.key});

  @override
  ConsumerState<EmailCodeScreen> createState() => _EmailCodeScreenState();
}

class _EmailCodeScreenState extends ConsumerState<EmailCodeScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    final ok = ref
        .read(sessionProvider.notifier)
        .verifyEmailCode(_controller.text);
    if (!ok) {
      setState(() => _error = 'Enter the code.');
      return;
    }
    context.go('/age');
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.read(sessionProvider.notifier).pendingEmail;
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Enter the code')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            ScaledText(
              email == null
                  ? 'Enter the code from your email.'
                  : 'Enter the code sent to $email.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const ScaledText(
              'Any code works in this preview.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: BaselineColors.fairway,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('email-code-field'),
              controller: _controller,
              keyboardType: TextInputType.text,
              style: const TextStyle(
                color: BaselineColors.ink,
                letterSpacing: 2,
              ),
              decoration: const InputDecoration(hintText: 'Code'),
              onSubmitted: (_) => _verify(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              ScaledText(
                _error!,
                style: const TextStyle(
                  color: BaselineColors.clay,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 20),
            BaselineButton(
              label: 'Continue',
              semanticsLabel: 'Verify email code',
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }
}
