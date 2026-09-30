import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/entrance.dart';
import 'package:baseline/widgets/hero_card.dart';
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
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [BaselineColors.nightGlow, BaselineColors.nightCourt],
                  stops: [0, 0.6],
                ),
              ),
            ),
          ),
          const Positioned(
            right: -60,
            top: 40,
            width: 230,
            height: 500,
            child: CourtLines(opacity: 0.08),
          ),
          SafeArea(
            child: Column(
              children: [
                const Expanded(child: _Story()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: FadeSlideIn(
                    index: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                            ref
                                .read(sessionProvider.notifier)
                                .signIn(AuthProvider.apple);
                            context.go('/age');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Story extends StatelessWidget {
  const _Story();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      children: [
        FadeSlideIn(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ScaledText(
                    'BASELINE',
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'Barlow Condensed',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: BaselineColors.ball,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        FadeSlideIn(
          index: 1,
          child: ScaledText(
            'Start from a solid base.',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: BaselineColors.line,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          index: 2,
          child: ScaledText(
            'Learn tennis step by step, find a place to practice, and see yourself improve.',
            style: TextStyle(
              fontSize: 17,
              height: 1.5,
              color: BaselineColors.line.withValues(alpha: 0.86),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const FadeSlideIn(
          index: 3,
          child: Column(
            children: [
              _Feature(
                icon: Icons.school_rounded,
                text: 'Short lessons with real demonstrations',
              ),
              _Feature(
                icon: Icons.sports_tennis_rounded,
                text: 'A weekly plan and drills you can do anywhere',
              ),
              _Feature(
                icon: Icons.place_rounded,
                text: 'Courts, coaches, and shops near you',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ScaledText(
          'Google and email are on the next step. Sign in with Apple is on this screen because Google is offered too.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: BaselineColors.line.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: BaselineColors.line.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: BaselineColors.ball, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ScaledText(
              text,
              style: BaselineType.cardBody.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: BaselineColors.line,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
