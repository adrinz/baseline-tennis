import 'package:baseline/data/catalog.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/note_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Privacy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          LineCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const ScaledText(
                'Let players find me',
                style: BaselineType.cardTitle,
              ),
              subtitle: ScaledText(
                session.isAdult
                    ? 'They see your name, level, city, and a distance band. Not your address.'
                    : 'Finding players starts at 18. Lessons, drills, and courts stay available.',
                style: BaselineType.cardMuted,
              ),
              value: session.isAdult && session.discoverable,
              onChanged: session.isAdult
                  ? (value) => ref
                        .read(sessionProvider.notifier)
                        .setDiscoverable(value)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          const NoteCard(
            title: 'Location',
            body: 'Courts and shops can be shown on a map. Other players never get a pin.',
            borderColor: BaselineColors.nightCourt,
          ),
          const SizedBox(height: 24),
          BaselineButton(
            label: 'Delete account',
            semanticsLabel: 'Delete account',
            tone: BaselineButtonTone.outline,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const ScaledText('Delete account?'),
                  content: const ScaledText(
                    'This removes your progress from this phone. It cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const ScaledText('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const ScaledText('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;
              ref.read(sessionProvider.notifier).deleteAccount();
              context.go('/welcome');
            },
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Notifications')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const ScaledText(
            'Choose what Baseline can remind you about. You can turn every one off.',
            style: BaselineType.cardBody,
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }
}

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Equipment')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const ScaledText('BASELINE PICK', style: BaselineType.eyebrow),
          const SizedBox(height: 8),
          const _ProductCard(
            name: 'Harborline Learn 27',
            detail: 'Level 1–2 · Starter racket · \$79',
            body: 'A light racket with a large face so early contact still finds the strings.',
            sponsored: false,
          ),
          const SizedBox(height: 10),
          const _ProductCard(
            name: 'Quiet Court Shoe',
            detail: 'Hard courts · \$110',
            body: 'A court shoe with a stable heel. Running shoes slip on a hard court.',
            sponsored: false,
          ),
          const SizedBox(height: 18),
          const ScaledText('FROM OUR PARTNERS', style: BaselineType.eyebrow),
          const SizedBox(height: 8),
          const _ProductCard(
            name: 'Launchline Match 100',
            detail: 'Sponsored · Level 3+',
            body: 'A sample partner listing. It is not a Baseline pick.',
            sponsored: true,
          ),
          const SizedBox(height: 16),
          const NoteCard(
            title: 'Not medical advice',
            body: 'A shop or coach should check grip size and shoes if you have pain.',
            borderColor: BaselineColors.clay,
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.detail,
    required this.body,
    required this.sponsored,
  });

  final String name;
  final String detail;
  final String body;
  final bool sponsored;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sponsored)
            const ScaledText('Sponsored', style: BaselineType.cardMuted),
          ScaledText(name, style: BaselineType.cardTitle),
          const SizedBox(height: 4),
          ScaledText(detail, style: BaselineType.cardMuted),
          const SizedBox(height: 8),
          ScaledText(body, style: BaselineType.cardBody),
        ],
      ),
    );
  }
}

class MatchLogScreen extends ConsumerStatefulWidget {
  const MatchLogScreen({super.key});

  @override
  ConsumerState<MatchLogScreen> createState() => _MatchLogScreenState();
}

class _MatchLogScreenState extends ConsumerState<MatchLogScreen> {
  String format = 'singles';
  String result = 'unfinished';
  final score = TextEditingController();
  final wentWell = TextEditingController();
  final toImprove = TextEditingController();

  @override
  void dispose() {
    score.dispose();
    wentWell.dispose();
    toImprove.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(sessionProvider).matches;
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Match log')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const ScaledText(
            'A simple note after you play. This is not live scoring.',
            style: BaselineType.cardBody,
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'singles', label: Text('Singles')),
              ButtonSegment(value: 'doubles', label: Text('Doubles')),
            ],
            selected: {format},
            onSelectionChanged: (value) => setState(() => format = value.first),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'win', label: Text('Win')),
              ButtonSegment(value: 'loss', label: Text('Loss')),
              ButtonSegment(value: 'unfinished', label: Text('Unfinished')),
            ],
            selected: {result},
            onSelectionChanged: (value) => setState(() => result = value.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: score,
            decoration: const InputDecoration(
              labelText: 'Score',
              hintText: '6–4, 3–6',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: wentWell,
            decoration: const InputDecoration(labelText: 'What went well'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: toImprove,
            decoration: const InputDecoration(labelText: 'What to practice'),
          ),
          const SizedBox(height: 16),
          BaselineButton(
            label: 'Save match',
            semanticsLabel: 'Save match',
            onPressed: () {
              final today = DateTime.now();
              ref
                  .read(sessionProvider.notifier)
                  .addMatch(
                    MatchLog(
                      playedOn:
                          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
                      format: format,
                      result: result,
                      score: score.text.trim(),
                      wentWell: wentWell.text.trim(),
                      toImprove: toImprove.text.trim(),
                    ),
                  );
              score.clear();
              wentWell.clear();
              toImprove.clear();
            },
          ),
          const SizedBox(height: 24),
          const ScaledText('SAVED', style: BaselineType.eyebrow),
          const SizedBox(height: 8),
          if (matches.isEmpty)
            const ScaledText(
              'No matches logged yet.',
              style: BaselineType.cardMuted,
            ),
          for (final match in matches) ...[
            LineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    '${match.playedOn} · ${match.format} · ${match.result}',
                    style: BaselineType.cardTitle,
                  ),
                  if (match.score.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ScaledText(match.score, style: BaselineType.cardBody),
                  ],
                  if (match.toImprove.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ScaledText(
                      'Practice · ${match.toImprove}',
                      style: BaselineType.cardMuted,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Inbox')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText('No requests yet.', style: BaselineType.cardTitle),
            SizedBox(height: 8),
            ScaledText(
              'When someone nearby asks to hit, the request shows up here. You can accept, decline, block, or report.',
              style: BaselineType.cardBody,
            ),
          ],
        ),
      ),
    );
  }
}

class TechniqueListScreen extends StatelessWidget {
  const TechniqueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = techniqueGroups();
    return Scaffold(
      appBar: AppBar(title: const ScaledText('Techniques')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const ScaledText(
            'Skills from the course. Open one to read the lesson.',
            style: BaselineType.cardBody,
          ),
          const SizedBox(height: 16),
          for (final group in groups) ...[
            ScaledText(group.title.toUpperCase(), style: BaselineType.eyebrow),
            const SizedBox(height: 8),
            for (final skill in group.skills) ...[
              LineCard(
                semanticsLabel: 'Open ${skill.title}',
                onTap: () => context.push('/learn/lesson/${skill.lessonSlug}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScaledText(
                            skill.title,
                            style: BaselineType.cardTitle,
                          ),
                          const SizedBox(height: 4),
                          ScaledText(
                            skill.summary,
                            style: BaselineType.cardBody,
                          ),
                          const SizedBox(height: 4),
                          ScaledText(
                            'Level ${skill.level}',
                            style: BaselineType.cardMuted,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: BaselineColors.ink),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
