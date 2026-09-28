import 'package:baseline/logic/age.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AgeGateScreen extends ConsumerStatefulWidget {
  const AgeGateScreen({super.key});

  @override
  ConsumerState<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends ConsumerState<AgeGateScreen> {
  final _controller = TextEditingController();
  String? _message;
  bool _blocked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final check = evaluateBirthYear(_controller.text);
    switch (check.decision) {
      case AgeDecision.invalid:
        setState(() {
          _blocked = false;
          _message = 'Enter the year you were born.';
        });
      case AgeDecision.blocked:
        setState(() {
          _blocked = true;
          _message = 'Baseline is for players 16 and older. You cannot create an account yet.';
        });
      case AgeDecision.minor:
        ref.read(sessionProvider.notifier).acceptAge(check.birthYear!);
        context.go('/onboarding');
      case AgeDecision.adult:
        ref.read(sessionProvider.notifier).acceptAge(check.birthYear!);
        context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScaledText('Birth year'),
        leading: IconButton(
          tooltip: 'Use a different sign-in',
          constraints: const BoxConstraints(
            minWidth: kMinTapTarget,
            minHeight: kMinTapTarget,
          ),
          onPressed: () {
            ref.read(sessionProvider.notifier).signOut();
            context.go('/welcome');
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const ScaledText(
              'Baseline is for players 16 and older.',
              style: TextStyle(
                fontSize: 22,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const ScaledText(
              'Ages 16 and 17 can learn, train, and look up courts. Finding other players waits until 18.',
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: BaselineColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              key: const Key('birth-year-field'),
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: const TextStyle(color: BaselineColors.ink, fontSize: 18),
              decoration: const InputDecoration(hintText: 'Birth year'),
              onSubmitted: (_) => _submit(),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                label: _message,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: BaselineColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _blocked
                          ? BaselineColors.clay
                          : BaselineColors.fairway,
                    ),
                  ),
                  child: ScaledText(
                    _message!,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: BaselineColors.ink,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            BaselineButton(
              label: 'Continue',
              semanticsLabel: 'Continue',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
