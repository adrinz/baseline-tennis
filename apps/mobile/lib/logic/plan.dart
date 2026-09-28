class PlanBlock {
  const PlanBlock({
    required this.title,
    required this.minutes,
    this.lessonSlug,
    this.drillSlug,
  });

  final String title;
  final int minutes;
  final String? lessonSlug;
  final String? drillSlug;
}

class PlanDay {
  const PlanDay({
    required this.label,
    required this.title,
    required this.blocks,
  });

  final String label;
  final String title;
  final List<PlanBlock> blocks;

  int get minutes => blocks.fold(0, (sum, block) => sum + block.minutes);
}

const _week = <PlanDay>[
  PlanDay(
    label: 'Day 1',
    title: 'Find your stance',
    blocks: [
      PlanBlock(title: 'Warm-up', minutes: 5),
      PlanBlock(
        title: 'Ready position',
        minutes: 10,
        lessonSlug: 'ready-position',
      ),
      PlanBlock(title: 'Wall rally', minutes: 10, drillSlug: 'wall-rally'),
    ],
  ),
  PlanDay(
    label: 'Day 2',
    title: 'Learn the lines',
    blocks: [
      PlanBlock(
        title: 'Understanding the court',
        minutes: 8,
        lessonSlug: 'the-court',
      ),
      PlanBlock(title: 'Scoring', minutes: 10, lessonSlug: 'scoring'),
      PlanBlock(title: 'Easy shadow swings', minutes: 7),
    ],
  ),
  PlanDay(
    label: 'Day 3',
    title: 'First forehand',
    blocks: [
      PlanBlock(title: 'Warm-up', minutes: 5),
      PlanBlock(
        title: 'Basic forehand',
        minutes: 15,
        lessonSlug: 'basic-forehand',
      ),
      PlanBlock(title: 'Wall rally', minutes: 10, drillSlug: 'wall-rally'),
    ],
  ),
  PlanDay(
    label: 'Day 4',
    title: 'Repeat and recover',
    blocks: [
      PlanBlock(title: 'Split-step drill', minutes: 8, drillSlug: 'split-step'),
      PlanBlock(
        title: 'Forehand consistency',
        minutes: 15,
        drillSlug: 'forehand-consistency',
      ),
      PlanBlock(title: 'Cool down', minutes: 5),
    ],
  ),
  PlanDay(
    label: 'Day 5',
    title: 'Put a rally together',
    blocks: [
      PlanBlock(
        title: 'Introduction to tennis',
        minutes: 8,
        lessonSlug: 'welcome-to-tennis',
      ),
      PlanBlock(
        title: 'Basic rallying',
        minutes: 12,
        lessonSlug: 'basic-rally',
      ),
      PlanBlock(title: 'Wall rally', minutes: 10, drillSlug: 'wall-rally'),
    ],
  ),
];

List<PlanDay> buildFirstWeek(int daysPerWeek) {
  final count = daysPerWeek.clamp(2, 5);
  return _week.take(count).toList();
}

String timeGreeting(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
