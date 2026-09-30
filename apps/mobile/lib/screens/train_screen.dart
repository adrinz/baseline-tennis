import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/logic/plan.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/hero_card.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/pill.dart';
import 'package:baseline/widgets/pressable.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:baseline/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TrainScreen extends ConsumerStatefulWidget {
  const TrainScreen({super.key});

  @override
  ConsumerState<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends ConsumerState<TrainScreen> {
  int _day = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final week = buildFirstWeek(session.daysPerWeek);
    final selected = week[_day.clamp(0, week.length - 1)];
    final totalMinutes = week.fold<int>(0, (sum, day) => sum + day.minutes);
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.8);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const ScaledText('Train', style: BaselineType.screenTitle),
            const SizedBox(height: 6),
            ScaledText(
              '${week.length} sessions · $totalMinutes minutes this week',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: BaselineColors.muted,
              ),
            ),
            const SectionHeader(
              'THIS WEEK',
              padding: EdgeInsets.only(top: 18, bottom: 10),
            ),
            SizedBox(
              height: 92 * textScale,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: week.length,
                clipBehavior: Clip.none,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) => _DayChip(
                  day: week[index],
                  selected: index == _day,
                  today: index == 0,
                  onTap: () => setState(() => _day = index),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              child: _DayPlan(
                key: ValueKey(_day),
                day: selected,
                today: _day == 0,
              ),
            ),
            SectionHeader(
              'WATCH A STROKE',
              action: 'See all',
              onAction: () => context.push('/videos'),
              padding: const EdgeInsets.only(top: 24, bottom: 10),
            ),
            SizedBox(
              height: 172 * textScale,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: licensedVideos.length,
                clipBehavior: Clip.none,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _ClipTile(video: licensedVideos[index]),
              ),
            ),
            const SectionHeader(
              'DRILL LIBRARY',
              padding: EdgeInsets.only(top: 24, bottom: 10),
            ),
            for (final drill in baselineCatalog.drills) ...[
              _DrillTile(
                drill: drill,
                done: session.completedDrillSlugs.contains(drill.slug),
                locked: !drill.freeTier && !session.premium,
              ),
              const SizedBox(height: 10),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push('/credits'),
                icon: const Icon(Icons.movie_outlined, size: 18),
                label: const ScaledText('Video credits'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final PlanDay day;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${day.label}, ${day.title}, ${day.minutes} minutes',
      child: ExcludeSemantics(
        child: PressScale(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 92,
            decoration: BoxDecoration(
              color: selected ? BaselineColors.nightCourt : BaselineColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? BaselineColors.nightCourt
                    : BaselineColors.ink.withValues(alpha: 0.1),
              ),
              boxShadow: selected ? BaselineShadows.lift : BaselineShadows.card,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  tapFeedback();
                  onTap();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaledText(
                        day.label.toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Barlow Condensed',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: selected
                              ? BaselineColors.ball
                              : BaselineColors.fairwayPressed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ScaledText(
                        '${day.minutes} min',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? BaselineColors.line
                              : BaselineColors.ink,
                        ),
                      ),
                      if (today)
                        ScaledText(
                          'Today',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? BaselineColors.line.withValues(alpha: 0.7)
                                : BaselineColors.muted,
                          ),
                        ),
                    ],
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

class _DayPlan extends StatelessWidget {
  const _DayPlan({super.key, required this.day, required this.today});

  final PlanDay day;
  final bool today;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      '${day.label} · ${day.minutes} min',
                      style: BaselineType.eyebrowFairway,
                    ),
                    const SizedBox(height: 4),
                    ScaledText(
                      day.title,
                      style: BaselineType.cardTitle.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              if (today) const Pill('TODAY', tone: PillTone.ball),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < day.blocks.length; i++)
            _PlanBlockRow(index: i + 1, block: day.blocks[i]),
        ],
      ),
    );
  }
}

class _PlanBlockRow extends StatelessWidget {
  const _PlanBlockRow({required this.index, required this.block});

  final int index;
  final PlanBlock block;

  @override
  Widget build(BuildContext context) {
    final linked = block.lessonSlug != null || block.drillSlug != null;
    final icon = block.lessonSlug != null
        ? Icons.menu_book_rounded
        : block.drillSlug != null
        ? Icons.sports_tennis_rounded
        : Icons.self_improvement_rounded;
    return Semantics(
      button: linked,
      label: '${block.title}, ${block.minutes} minutes',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: linked
            ? () {
                if (block.lessonSlug != null) {
                  context.push('/learn/lesson/${block.lessonSlug}');
                }
                if (block.drillSlug != null) {
                  context.push('/train/drill/${block.drillSlug}');
                }
              }
            : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Row(
            children: [
              IconBadge(
                icon,
                size: 34,
                tone: block.lessonSlug != null
                    ? PillTone.fairway
                    : block.drillSlug != null
                    ? PillTone.ball
                    : PillTone.neutral,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ScaledText(
                  block.title,
                  style: BaselineType.cardBody.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _ClipTile extends StatelessWidget {
  const _ClipTile({required this.video});

  final LicensedVideo video;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 232,
      child: HeroCard(
        semanticsLabel: 'Play ${video.title}',
        onTap: () => context.push('/video/${video.id}'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill(
                  video.category.toUpperCase(),
                  tone: PillTone.night,
                ),
                const Spacer(),
                const ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: BaselineColors.ball,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 26,
                        color: BaselineColors.nightCourt,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ScaledText(
              video.title,
              maxLines: 2,
              style: BaselineType.heroTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            ScaledText(
              video.durationLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: BaselineColors.line.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrillTile extends StatelessWidget {
  const _DrillTile({
    required this.drill,
    required this.done,
    required this.locked,
  });

  final Drill drill;
  final bool done;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return LineCard(
      semanticsLabel: drill.name,
      onTap: () => context.push('/train/drill/${drill.slug}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          done
              ? const StepDot(done: true, size: 44)
              : IconBadge(
                  Icons.sports_tennis_rounded,
                  tone: drill.freeTier ? PillTone.ball : PillTone.clay,
                  size: 44,
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaledText(drill.name, style: BaselineType.cardTitle),
                const SizedBox(height: 2),
                ScaledText(
                  drill.objective,
                  maxLines: 2,
                  style: BaselineType.cardMuted.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Pill(
                      '${drill.durationMinutes} min',
                      icon: Icons.schedule_rounded,
                    ),
                    Pill('Level ${drill.levelMin}', icon: Icons.stairs_rounded),
                    if (drill.freeTier)
                      const Pill('FREE', tone: PillTone.fairway)
                    else
                      Pill(
                        'PREMIUM',
                        icon: locked ? Icons.lock_rounded : Icons.star_rounded,
                        tone: PillTone.clay,
                      ),
                    if (done) const Pill('Done', tone: PillTone.fairway),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Icon(Icons.chevron_right, color: BaselineColors.muted),
          ),
        ],
      ),
    );
  }
}
