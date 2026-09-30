import 'package:baseline/data/catalog.dart';
import 'package:baseline/logic/age.dart';
import 'package:baseline/logic/progress.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/hero_card.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/nav_row.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/pressable.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:baseline/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final level = levelById(session.level);
    final year = session.birthYear;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const ScaledText('Profile', style: BaselineType.screenTitle),
            const SizedBox(height: 16),
            HeroCard(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ExcludeSemantics(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: BaselineColors.ball,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Center(
                              child: Text(
                                '${session.level}',
                                style: const TextStyle(
                                  fontFamily: 'Barlow Condensed',
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: BaselineColors.nightCourt,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ScaledText(
                              'LEVEL',
                              style: BaselineType.eyebrowOnNight,
                            ),
                            const SizedBox(height: 2),
                            ScaledText(
                              level == null ? 'Level ${session.level}' : level.name,
                              style: BaselineType.heroTitle.copyWith(fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroStat(
                          value: '${session.streak}',
                          label: 'day streak',
                          semantics: streakLabel(session.streak),
                        ),
                      ),
                      Expanded(
                        child: _HeroStat(
                          value: '${session.trainingMinutes}',
                          label: 'training min',
                          semantics: '${session.trainingMinutes} training minutes',
                        ),
                      ),
                      Expanded(
                        child: _HeroStat(
                          value: '${session.matches.length}',
                          label: 'matches',
                          semantics: '${session.matches.length} matches logged',
                        ),
                      ),
                    ],
                  ),
                  if (year != null || session.goal != null) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (year != null)
                          Pill(
                            'Age band · ${ageBand(year)}',
                            tone: PillTone.night,
                          ),
                        if (session.goal != null)
                          Pill(
                            'Goal · ${session.goal}',
                            icon: Icons.flag_rounded,
                            tone: PillTone.night,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SectionHeader(
              'CHANGE LEVEL',
              padding: EdgeInsets.only(top: 22, bottom: 8),
            ),
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScaledText(
                    'Levels are guidelines. Changing this does not hide other lessons.',
                    style: BaselineType.cardMuted,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in baselineCatalog.levels)
                        _LevelChip(
                          id: item.id,
                          name: item.name,
                          selected: item.id == session.level,
                          onTap: () => ref
                              .read(sessionProvider.notifier)
                              .setLevel(item.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const ScaledText(
                    'A streak counts a day you log a drill, finish a lesson, or mark today’s training done.',
                    style: BaselineType.cardMuted,
                  ),
                ],
              ),
            ),
            const SectionHeader(
              'PRIVACY',
              padding: EdgeInsets.only(top: 22, bottom: 8),
            ),
            LineCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const ScaledText(
                  'Discoverable',
                  style: BaselineType.cardTitle,
                ),
                subtitle: ScaledText(
                  session.isAdult
                      ? 'Other players see a distance band, never an exact location.'
                      : 'Discovery stays off until you are 18. Learning, training, courts, coaches, and stores stay available.',
                  style: BaselineType.cardMuted,
                ),
                value: session.isAdult && session.discoverable,
                onChanged: session.isAdult
                    ? (value) {
                        tapFeedback();
                        ref
                            .read(sessionProvider.notifier)
                            .setDiscoverable(value);
                      }
                    : null,
              ),
            ),
            const SectionHeader(
              'NOTIFICATIONS',
              padding: EdgeInsets.only(top: 22, bottom: 8),
            ),
            LineCard(
              child: Column(
                children: [
                  for (final entry in NotificationPrefs.labels.entries)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: ScaledText(
                        entry.value,
                        style: BaselineType.cardBody,
                      ),
                      subtitle:
                          !session.isAdult &&
                              (entry.key == NotificationPrefs.partners ||
                                  entry.key == NotificationPrefs.messages)
                          ? const ScaledText(
                              'Available at 18.',
                              style: BaselineType.cardMuted,
                            )
                          : null,
                      value: session.notifications[entry.key] ?? false,
                      onChanged:
                          !session.isAdult &&
                              (entry.key == NotificationPrefs.partners ||
                                  entry.key == NotificationPrefs.messages)
                          ? null
                          : (value) {
                              tapFeedback();
                              ref
                                  .read(sessionProvider.notifier)
                                  .setNotification(entry.key, value);
                            },
                    ),
                ],
              ),
            ),
            const SectionHeader(
              'MORE',
              padding: EdgeInsets.only(top: 22, bottom: 8),
            ),
            NavRow(
              label: 'Privacy',
              icon: Icons.shield_outlined,
              onTap: () => context.push('/profile/privacy'),
            ),
            const SizedBox(height: 8),
            NavRow(
              label: 'Notification settings',
              icon: Icons.notifications_none_rounded,
              onTap: () => context.push('/profile/notifications'),
            ),
            const SizedBox(height: 8),
            NavRow(
              label: 'Techniques',
              icon: Icons.auto_awesome_rounded,
              onTap: () => context.push('/learn/techniques'),
            ),
            const SizedBox(height: 8),
            NavRow(
              label: 'Equipment guide',
              icon: Icons.sports_tennis_rounded,
              onTap: () => context.push('/profile/equipment'),
            ),
            const SizedBox(height: 8),
            NavRow(
              label: 'Match log',
              icon: Icons.emoji_events_outlined,
              onTap: () => context.push('/profile/matches'),
            ),
            const SizedBox(height: 8),
            NavRow(
              label: 'Inbox',
              icon: Icons.inbox_outlined,
              onTap: () => context.push('/profile/inbox'),
            ),
            const SizedBox(height: 8),
            NavRow(
              label: session.premium ? 'Premium is on' : 'Baseline Premium',
              icon: Icons.star_rounded,
              tone: PillTone.ball,
              onTap: () => context.push('/paywall'),
            ),
            const SizedBox(height: 8),
            NavRow(
              label: 'Video credits',
              icon: Icons.movie_outlined,
              onTap: () => context.push('/credits'),
            ),
            const SizedBox(height: 24),
            BaselineButton(
              label: 'Sign out',
              semanticsLabel: 'Sign out',
              tone: BaselineButtonTone.outline,
              onPressed: () {
                ref.read(sessionProvider.notifier).signOut();
                context.go('/welcome');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.semantics,
  });

  final String value;
  final String label;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText(
              value,
              maxLines: 1,
              style: BaselineType.heroTitle.copyWith(
                fontSize: 30,
                color: BaselineColors.ball,
              ),
            ),
            ScaledText(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: BaselineColors.line.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.id,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final int id;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Level $id $name',
      child: ExcludeSemantics(
        child: PressScale(
          scale: 0.92,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? BaselineColors.ball : BaselineColors.nightCourt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? BaselineColors.nightCourt : Colors.transparent,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  tapFeedback();
                  onTap();
                },
                child: Center(
                  child: ScaledText(
                    '$id',
                    style: TextStyle(
                      fontFamily: 'Barlow Condensed',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? BaselineColors.nightCourt
                          : BaselineColors.line,
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
