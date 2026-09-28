import 'package:baseline/data/catalog.dart';
import 'package:baseline/logic/age.dart';
import 'package:baseline/logic/progress.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
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
            ScaledText(
              'Profile',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScaledText('LEVEL', style: BaselineType.eyebrowFairway),
                  const SizedBox(height: 4),
                  ScaledText(
                    level == null ? 'Level ${session.level}' : level.name,
                    style: BaselineType.cardTitle,
                  ),
                  const SizedBox(height: 4),
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
                        Semantics(
                          button: true,
                          selected: item.id == session.level,
                          label: 'Level ${item.id} ${item.name}',
                          child: ExcludeSemantics(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: kMinTapTarget,
                                minWidth: kMinTapTarget,
                              ),
                              child: ChoiceChip(
                                label: ScaledText(
                                  '${item.id}',
                                  style: TextStyle(
                                    color: item.id == session.level
                                        ? BaselineColors.ink
                                        : BaselineColors.line,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                selected: item.id == session.level,
                                showCheckmark: false,
                                selectedColor: BaselineColors.ball,
                                backgroundColor: BaselineColors.nightCourt,
                                onSelected: (_) => ref
                                    .read(sessionProvider.notifier)
                                    .setLevel(item.id),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScaledText(
                    'STREAK',
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 4),
                  ScaledText(
                    streakLabel(session.streak),
                    style: BaselineType.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  const ScaledText(
                    'A streak counts a day you log a drill, finish a lesson, or mark today’s training done.',
                    style: BaselineType.cardMuted,
                  ),
                  if (year != null) ...[
                    const SizedBox(height: 12),
                    ScaledText(
                      'Age band · ${ageBand(year)}',
                      style: BaselineType.cardBody,
                    ),
                  ],
                  if (session.goal != null) ...[
                    const SizedBox(height: 4),
                    ScaledText(
                      'Goal · ${session.goal}',
                      style: BaselineType.cardBody,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            ScaledText(
              '${session.trainingMinutes} training minutes · ${session.matches.length} matches logged',
              style: BaselineType.cardMuted,
            ),
            const SizedBox(height: 18),
            const ScaledText('PRIVACY', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
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
                        ? (value) => ref
                              .read(sessionProvider.notifier)
                              .setDiscoverable(value)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const ScaledText('NOTIFICATIONS', style: BaselineType.eyebrow),
            const SizedBox(height: 8),
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
                          : (value) => ref
                                .read(sessionProvider.notifier)
                                .setNotification(entry.key, value),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ProfileLink(
              label: 'Privacy',
              onTap: () => context.push('/profile/privacy'),
            ),
            _ProfileLink(
              label: 'Notification settings',
              onTap: () => context.push('/profile/notifications'),
            ),
            _ProfileLink(
              label: 'Techniques',
              onTap: () => context.push('/learn/techniques'),
            ),
            _ProfileLink(
              label: 'Equipment guide',
              onTap: () => context.push('/profile/equipment'),
            ),
            _ProfileLink(
              label: 'Match log',
              onTap: () => context.push('/profile/matches'),
            ),
            _ProfileLink(
              label: 'Inbox',
              onTap: () => context.push('/profile/inbox'),
            ),
            _ProfileLink(
              label: session.premium ? 'Premium is on' : 'Baseline Premium',
              onTap: () => context.push('/paywall'),
            ),
            _ProfileLink(
              label: 'Video credits',
              onTap: () => context.push('/credits'),
            ),
            const SizedBox(height: 20),
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

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LineCard(
        semanticsLabel: label,
        onTap: onTap,
        child: Row(
          children: [
            Expanded(child: ScaledText(label, style: BaselineType.cardTitle)),
            const Icon(Icons.chevron_right, color: BaselineColors.ink),
          ],
        ),
      ),
    );
  }
}
