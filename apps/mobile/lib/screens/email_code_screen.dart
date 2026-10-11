import 'dart:async';

import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _controller.text;
    if (!looksLikeEmail(email)) {
      setState(() => _error = 'Enter an email address.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final failure = await ref.read(sessionProvider.notifier).startEmail(email);
    if (!mounted) return;
    setState(() => _sending = false);
    if (failure != null) {
      setState(() => _error = failure);
      return;
    }
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
              'Enter the email for this account. There is no password. Baseline shows a 6-digit code in a notification on this phone.',
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 20),
            const ScaledText(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('email-field'),
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enabled: !_sending,
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
              label: _sending ? 'Sending code…' : 'Send code',
              semanticsLabel: 'Send code',
              onPressed: _sending ? null : _send,
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
  bool _checking = false;
  int _wait = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_wait <= 1) {
        timer.cancel();
        setState(() => _wait = 0);
      } else {
        setState(() => _wait -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startWait() {
    _timer?.cancel();
    setState(() => _wait = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_wait <= 1) {
        timer.cancel();
        setState(() => _wait = 0);
      } else {
        setState(() => _wait -= 1);
      }
    });
  }

  Future<void> _verify() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final failure = await ref
        .read(sessionProvider.notifier)
        .verifyEmailCode(_controller.text);
    if (!mounted) return;
    if (failure != null) {
      _controller.clear();
      setState(() {
        _checking = false;
        _error = failure;
      });
      return;
    }
    context.go('/age');
  }

  Future<void> _resend() async {
    if (_wait > 0 || _checking) return;
    final email = ref.read(sessionProvider.notifier).pendingEmail;
    if (email == null) {
      setState(() => _error = 'Request a new code.');
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
    });
    final failure = await ref.read(sessionProvider.notifier).startEmail(email);
    if (!mounted) return;
    setState(() => _checking = false);
    if (failure != null) {
      setState(() => _error = failure);
      return;
    }
    _controller.clear();
    _startWait();
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.read(sessionProvider.notifier).pendingEmail;
    final waitLabel = _wait == 0
        ? 'Resend code'
        : 'Resend code in 0:${_wait.toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Enter the code')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            ScaledText(
              email == null
                  ? 'Enter the 6-digit code from the Baseline notification.'
                  : 'Enter the 6-digit code sent for $email. It is in the Baseline notification and expires in 10 minutes.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('email-code-field'),
              controller: _controller,
              keyboardType: TextInputType.number,
              enabled: !_checking,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: BaselineColors.ink,
                letterSpacing: 2,
              ),
              decoration: const InputDecoration(
                hintText: '6-digit code',
                counterText: '',
              ),
              onChanged: (value) {
                if (value.length == 6) _verify();
              },
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
              label: _checking ? 'Checking…' : 'Continue',
              semanticsLabel: 'Verify email code',
              onPressed: _checking ? null : _verify,
            ),
            const SizedBox(height: 12),
            BaselineButton(
              label: waitLabel,
              semanticsLabel: 'Resend code',
              tone: BaselineButtonTone.outline,
              onPressed: _wait == 0 && !_checking ? _resend : null,
            ),
            const SizedBox(height: 12),
            BaselineButton(
              label: 'Use a different email',
              semanticsLabel: 'Use a different email',
              tone: BaselineButtonTone.outline,
              onPressed: _checking ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
