import 'package:baseline/data/nearby_places.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/logic/plan.dart';
import 'package:baseline/logic/progress.dart';
import 'package:baseline/screens/shell_screen.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/clip_player.dart';
import 'package:baseline/widgets/coach_sheet.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveLiveLocation();
    });
  }

  Future<void> _resolveLiveLocation() async {
    final locality = await getCurrentLocality();
    if (locality != null && locality.isNotEmpty && mounted) {
      if (ref.read(sessionProvider).city != locality) {
        ref.read(sessionProvider.notifier).setCity(locality);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final lesson = continueLesson(session);
    final featured = videosForLesson(lesson.slug);
    final drill = recommendedDrill(session);
    final today = buildFirstWeek(session.daysPerWeek).first;
    final fresh = session.completedLessonSlugs.isEmpty;
    final levelName = session.level;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: ScaledText(
                    'BASELINE',
                    style: TextStyle(
                      fontFamily: 'Barlow Condensed',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: BaselineColors.muted,
                    ),
                  ),
                ),
                const SearchIconButton(),
                IconButton(
                  tooltip: 'Ask the pro',
                  constraints: const BoxConstraints(
                    minWidth: kMinTapTarget,
                    minHeight: kMinTapTarget,
                  ),
                  onPressed: () => showCoachSheet(context),
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
              ],
            ),
            ScaledText(
              timeGreeting(DateTime.now()),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            ScaledText(
              'Level $levelName · ${session.city}',
              style: const TextStyle(fontSize: 15, color: BaselineColors.muted),
            ),
            const SizedBox(height: 18),
            LineCard(
              semanticsLabel: fresh ? 'Start level 1' : 'Continue learning',
              onTap: () => context.go('/learn/lesson/${lesson.slug}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    fresh ? 'START LEVEL 1' : 'CONTINUE LEARNING',
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 6),
                  ScaledText(lesson.title, style: BaselineType.cardTitle),
                  const SizedBox(height: 4),
                  ScaledText(
                    '${lesson.estimatedMinutes} min · ${lesson.summary}',
                    style: BaselineType.cardBody,
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
                    "TODAY'S TRAINING",
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 6),
                  ScaledText(
                    '${today.title} · ${today.minutes} min',
                    style: BaselineType.cardTitle,
                  ),
                  const SizedBox(height: 8),
                  for (final block in today.blocks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _BlockLink(
                        title: block.title,
                        minutes: block.minutes,
                        lessonSlug: block.lessonSlug,
                        drillSlug: block.drillSlug,
                        done: session.todayPlanDone,
                      ),
                    ),
                  const SizedBox(height: 8),
                  BaselineButton(
                    label: session.todayPlanDone
                        ? 'Done for today'
                        : 'Mark done',
                    semanticsLabel: session.todayPlanDone
                        ? "Today's training is done"
                        : "Mark today's training done",
                    tone: BaselineButtonTone.fairway,
                    onPressed: session.todayPlanDone
                        ? null
                        : () => ref
                              .read(sessionProvider.notifier)
                              .markTodayDone(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LineCard(
              semanticsLabel: 'Recommended drill ${drill.name}',
              onTap: () => context.go('/train/drill/${drill.slug}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScaledText(
                    'RECOMMENDED DRILL',
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 6),
                  ScaledText(drill.name, style: BaselineType.cardTitle),
                  const SizedBox(height: 4),
                  ScaledText(
                    '${drill.durationMinutes} min · ${drill.objective}',
                    style: BaselineType.cardBody,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Stat(label: 'Level', value: '$levelName'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Stat(
                    label: 'Streak',
                    value: streakLabel(session.streak),
                  ),
                ),
              ],
            ),
            if (session.goal != null) ...[
              const SizedBox(height: 12),
              ScaledText(
                'Goal · ${session.goal}',
                style: const TextStyle(fontSize: 15, color: BaselineColors.ink),
              ),
            ],
            if (featured.isNotEmpty) ...[
              const SizedBox(height: 16),
              DemonstrationCard(video: featured.first),
              const SizedBox(height: 12),
              LineCard(
                semanticsLabel: 'Video credits',
                onTap: () => context.push('/credits'),
                child: const Row(
                  children: [
                    Expanded(
                      child: ScaledText(
                        'Video credits',
                        style: BaselineType.cardTitle,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: BaselineColors.ink),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              LineCard(
                semanticsLabel: 'All demonstrations',
                onTap: () => context.push('/videos'),
                child: Row(
                  children: [
                    Expanded(
                      child: ScaledText(
                        'All ${licensedVideos.length} demonstrations',
                        style: BaselineType.cardTitle,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: BaselineColors.ink),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlockLink extends StatelessWidget {
  const _BlockLink({
    required this.title,
    required this.minutes,
    required this.done,
    this.lessonSlug,
    this.drillSlug,
  });

  final String title;
  final int minutes;
  final bool done;
  final String? lessonSlug;
  final String? drillSlug;

  @override
  Widget build(BuildContext context) {
    final linked = lessonSlug != null || drillSlug != null;
    return Semantics(
      button: linked,
      label: '$title, $minutes minutes',
      child: InkWell(
        onTap: linked
            ? () {
                if (lessonSlug != null) context.go('/learn/lesson/$lessonSlug');
                if (drillSlug != null) context.go('/train/drill/$drillSlug');
              }
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTapTarget),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: done ? BaselineColors.fairway : BaselineColors.ink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ScaledText(
                  '$title · $minutes min',
                  style: BaselineType.cardBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BaselineColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BaselineColors.ink.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText(label.toUpperCase(), style: BaselineType.eyebrow),
          const SizedBox(height: 4),
          ScaledText(
            value,
            style: const TextStyle(
              color: BaselineColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
