import 'package:baseline/data/catalog.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (_index + 1) / 4,
                    minHeight: 8,
                    backgroundColor: BaselineColors.track,
                    color: BaselineColors.fairway,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const ScaledText(
                'Levels are guidelines. You can change yours later in Profile.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: BaselineColors.ink,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _question(session)),
              if (_index > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(kMinTapTarget, kMinTapTarget),
                      foregroundColor: BaselineColors.ink,
                    ),
                    onPressed: () => setState(() => _index -= 1),
                    child: const ScaledText('Back'),
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
        ScaledText(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          ScaledText(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: BaselineColors.ink,
            ),
          ),
        ],
        const SizedBox(height: 20),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTapTarget),
          child: Material(
            color: BaselineColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: selected
                    ? BaselineColors.ink
                    : BaselineColors.ink.withValues(alpha: 0.16),
                width: selected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: ScaledText(
                  label,
                  style: BaselineType.cardTitle.copyWith(fontSize: 17),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
