import 'package:baseline/data/catalog.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/pressable.dart';
import 'package:baseline/widgets/progress.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _played = ['Not yet', 'A little', 'Yes'];
  static const _goals = [
    'Learn from scratch',
    'A reliable forehand',
    'Rally with consistency',
    'Play a first match',
  ];
  static const _days = [2, 3, 4, 5];

  int _index = 0;
  var _appliedQuery = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedQuery) return;
    final step = GoRouterState.of(context).uri.queryParameters['step'];
    if (step == 'days') _index = 3;
    _appliedQuery = true;
  }

  void _next() {
    if (_index < 3) {
      setState(() => _index += 1);
      return;
    }
    context.go('/plan');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Question ${_index + 1} of 4',
                child: SlimBar(value: (_index + 1) / 4, height: 8),
              ),
              const SizedBox(height: 10),
              const ScaledText(
                'Levels are guidelines. You can change yours later in Profile.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: BaselineColors.muted,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_index),
                    child: _question(session),
                  ),
                ),
              ),
              if (_index > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                      foregroundColor: BaselineColors.ink,
                    ),
                    onPressed: () => setState(() => _index -= 1),
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    label: const ScaledText('Back'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question(PlayerSession session) {
    switch (_index) {
      case 0:
        return _choices(
          title: 'Have you played before?',
          options: _played,
          selected: session.playedBefore,
          onSelect: (value) {
            ref.read(sessionProvider.notifier).setPlayedBefore(value);
            _next();
          },
        );
      case 1:
        return _choices(
          title: 'What level fits you now?',
          subtitle: 'Pick the closest description. It does not lock you out of other lessons.',
          options: [
            for (final level in baselineCatalog.levels)
              '${level.id}. ${level.name}',
          ],
          selected: '${session.level}. ${levelById(session.level)?.name ?? ''}',
          onSelect: (value) {
            final level = int.parse(value.split('.').first);
            ref.read(sessionProvider.notifier).setLevel(level);
            _next();
          },
        );
      case 2:
        return _choices(
          title: 'What is your main goal?',
          options: _goals,
          selected: session.goal,
          onSelect: (value) {
            ref.read(sessionProvider.notifier).setGoal(value);
            _next();
          },
        );
      default:
        return _choices(
          title: 'How many days can you train?',
          subtitle: 'The first week uses 2, 3, 4, or 5 days.',
          options: [for (final day in _days) day == 5 ? '5+' : '$day'],
          selected: session.daysPerWeek >= 5 ? '5+' : '${session.daysPerWeek}',
          onSelect: (value) {
            final days = value == '5+' ? 5 : int.parse(value);
            ref.read(sessionProvider.notifier).setDaysPerWeek(days);
            _next();
          },
        );
    }
  }

  Widget _choices({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
    String? subtitle,
  }) {
    return ListView(
      children: [
        ScaledText(title, style: BaselineType.screenTitle),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          ScaledText(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: BaselineColors.muted,
            ),
          ),
        ],
        const SizedBox(height: 22),
        for (final option in options) ...[
          _OptionButton(
            label: option,
            selected: option == selected,
            onPressed: () => onSelect(option),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: PressScale(
          scale: 0.98,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTapTarget + 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected ? BaselineColors.fairwaySoft : BaselineColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? BaselineColors.fairway
                      : BaselineColors.ink.withValues(alpha: 0.1),
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected ? null : BaselineShadows.card,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    tapFeedback();
                    onPressed();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ScaledText(
                            label,
                            style: BaselineType.cardTitle.copyWith(fontSize: 17),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? BaselineColors.fairway
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? BaselineColors.fairway
                                  : BaselineColors.mist,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: BaselineColors.line,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
