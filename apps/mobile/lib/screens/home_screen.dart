import 'package:baseline/data/catalog.dart';
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
import 'package:baseline/widgets/entrance.dart';
import 'package:baseline/widgets/hero_card.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/pressable.dart';
import 'package:baseline/widgets/progress.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:baseline/widgets/section_header.dart';
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
    final levelLessons = lessonsForLevel(session.level);
    final levelDone = levelLessons
        .where((item) => session.completedLessonSlugs.contains(item.slug))
        .length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const _Header(),
            const SizedBox(height: 14),
            FadeSlideIn(
              child: ScaledText(
                timeGreeting(DateTime.now()),
                style: BaselineType.screenTitle,
              ),
            ),
            const SizedBox(height: 6),
            FadeSlideIn(
              index: 1,
              child: Row(
                children: [
                  const Icon(
                    Icons.place_rounded,
                    size: 18,
                    color: BaselineColors.fairway,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: ScaledText(
                      'Level ${session.level} · ${session.city}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: BaselineColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              index: 2,
              child: _LessonHero(
                lesson: lesson,
                fresh: fresh,
                done: levelDone,
                total: levelLessons.length,
                level: session.level,
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              index: 3,
              child: Row(
                children: [
                  Expanded(
                    child: _Stat(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Streak',
                      value: '${session.streak}',
                      unit: session.streak == 1 ? 'day' : 'days',
                      semantics: streakLabel(session.streak),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Stat(
                      icon: Icons.timer_outlined,
                      label: 'Trained',
                      value: '${session.trainingMinutes}',
                      unit: 'min',
                      semantics: '${session.trainingMinutes} training minutes',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Stat(
                      icon: Icons.menu_book_rounded,
                      label: 'Lessons',
                      value: '${session.completedLessonSlugs.length}',
                      unit: 'done',
                      semantics:
                          '${session.completedLessonSlugs.length} lessons done',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FadeSlideIn(
              index: 4,
              child: _TodayCard(today: today, done: session.todayPlanDone),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              index: 5,
              child: LineCard(
                semanticsLabel: 'Recommended drill ${drill.name}',
                onTap: () => context.go('/train/drill/${drill.slug}'),
                child: Row(
                  children: [
                    const IconBadge(
                      Icons.sports_tennis_rounded,
                      tone: PillTone.ball,
                      size: 52,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScaledText(
                            'RECOMMENDED DRILL',
                            style: BaselineType.eyebrowFairway,
                          ),
                          const SizedBox(height: 2),
                          ScaledText(drill.name, style: BaselineType.cardTitle),
                          const SizedBox(height: 2),
                          ScaledText(
                            '${drill.durationMinutes} min · ${drill.objective}',
                            maxLines: 2,
                            style: BaselineType.cardMuted,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: BaselineColors.muted,
                    ),
                  ],
                ),
              ),
            ),
            if (featured.isNotEmpty) ...[
              SectionHeader(
                'WATCH AND LEARN',
                action: 'All ${licensedVideos.length}',
                onAction: () => context.push('/videos'),
                padding: const EdgeInsets.only(top: 22, bottom: 8),
              ),
              DemonstrationCard(video: featured.first),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.asset(
            'assets/images/app_logo.png',
            width: 38,
            height: 38,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: ScaledText(
            'BASELINE',
            style: TextStyle(
              fontFamily: 'Barlow Condensed',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: BaselineColors.ink,
            ),
          ),
        ),
        const SearchIconButton(),
      ],
    );
  }
}

class _LessonHero extends StatelessWidget {
  const _LessonHero({
    required this.lesson,
    required this.fresh,
    required this.done,
    required this.total,
    required this.level,
  });

  final Lesson lesson;
  final bool fresh;
  final int done;
  final int total;
  final int level;

  @override
  Widget build(BuildContext context) {
    return HeroCard(
      semanticsLabel: fresh ? 'Start level 1' : 'Continue learning',
      onTap: () => context.go('/learn/lesson/${lesson.slug}'),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaledText(
            fresh ? 'START LEVEL 1' : 'CONTINUE LEARNING',
            style: BaselineType.eyebrowOnNight,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 56),
            child: ScaledText(lesson.title, style: BaselineType.heroTitle),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: ScaledText(
              lesson.summary,
              maxLines: 3,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: BaselineColors.line.withValues(alpha: 0.82),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Pill(
                '${lesson.estimatedMinutes} min',
                icon: Icons.schedule_rounded,
                tone: PillTone.night,
              ),
              const Spacer(),
              const _GoButton(),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 18),
            SlimBar(
              value: total == 0 ? 0 : done / total,
              color: BaselineColors.ball,
              background: BaselineColors.line.withValues(alpha: 0.14),
            ),
            const SizedBox(height: 8),
            ScaledText(
              '$done of $total lessons in this level',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: BaselineColors.line.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoButton extends StatelessWidget {
  const _GoButton();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BaselineColors.ball,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.arrow_forward_rounded,
            color: BaselineColors.nightCourt,
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.today, required this.done});

  final PlanDay today;
  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LineCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScaledText(
                      "TODAY'S TRAINING",
                      style: BaselineType.eyebrowFairway,
                    ),
                    const SizedBox(height: 4),
                    ScaledText(
                      today.title,
                      style: BaselineType.cardTitle.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Pill(
                '${today.minutes} min',
                icon: Icons.schedule_rounded,
                tone: done ? PillTone.fairway : PillTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < today.blocks.length; i++)
            _BlockRow(index: i + 1, block: today.blocks[i], done: done),
          const SizedBox(height: 12),
          BaselineButton(
            label: done ? 'Done for today' : 'Mark done',
            semanticsLabel: done
                ? "Today's training is done"
                : "Mark today's training done",
            tone: done ? BaselineButtonTone.outline : BaselineButtonTone.fairway,
            icon: done ? Icons.check_circle_rounded : null,
            onPressed: done
                ? null
                : () {
                    successFeedback();
                    ref.read(sessionProvider.notifier).markTodayDone();
                  },
          ),
        ],
      ),
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({
    required this.index,
    required this.block,
    required this.done,
  });

  final int index;
  final PlanBlock block;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final linked = block.lessonSlug != null || block.drillSlug != null;
    return Semantics(
      button: linked,
      label: '${block.title}, ${block.minutes} minutes',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: linked
            ? () {
                if (block.lessonSlug != null) {
                  context.go('/learn/lesson/${block.lessonSlug}');
                }
                if (block.drillSlug != null) {
                  context.go('/train/drill/${block.drillSlug}');
                }
              }
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTapTarget),
          child: Row(
            children: [
              StepDot(number: index, done: done),
              const SizedBox(width: 12),
              Expanded(
                child: ScaledText(
                  block.title,
                  style: BaselineType.cardBody.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: done ? BaselineColors.muted : BaselineColors.ink,
                  ),
                ),
              ),
              ScaledText('${block.minutes} min', style: BaselineType.cardMuted),
              if (linked) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: BaselineColors.muted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.semantics,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label. $semantics',
      child: ExcludeSemantics(
        child: LineCard(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: BaselineColors.fairway),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: ScaledText(
                      value,
                      maxLines: 1,
                      style: BaselineType.stat,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ScaledText(
                    unit,
                    maxLines: 1,
                    style: BaselineType.cardMuted,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              ScaledText(
                label.toUpperCase(),
                maxLines: 1,
                style: BaselineType.eyebrow.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
