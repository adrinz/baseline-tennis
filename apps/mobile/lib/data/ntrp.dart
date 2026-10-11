/// USTA NTRP self-rating guide. Descriptions are Baseline's, not official
/// USTA copy. A saved choice is the player's own estimate.
class NtrpRating {
  const NtrpRating({required this.value, required this.summary});

  final String value;
  final String summary;

  double get number => double.parse(value);
}

class RoughLevel {
  const RoughLevel({
    required this.id,
    required this.name,
    required this.low,
    required this.high,
    required this.about,
    required this.summary,
  });

  final String id;
  final String name;
  final double low;
  final double high;
  final String about;
  final String summary;

  bool contains(double rating) => rating >= low && rating <= high;
}

const ntrpRatings = <NtrpRating>[
  NtrpRating(
    value: '1.5',
    summary: 'Just starting. The aim is to make contact and get the ball in play.',
  ),
  NtrpRating(
    value: '2.0',
    summary: 'Easy shots go over the net. You are still learning where the ball will land.',
  ),
  NtrpRating(
    value: '2.5',
    summary: 'You can keep a slow rally going when the ball comes back softly.',
  ),
  NtrpRating(
    value: '3.0',
    summary: 'Medium-pace shots are fairly consistent. Direction and depth still vary.',
  ),
  NtrpRating(
    value: '3.5',
    summary: 'Moderate groundstrokes hold up, and you can aim with some purpose. Doubles positions are starting to click.',
  ),
  NtrpRating(
    value: '4.0',
    summary: 'Strokes are reliable in a point. You can use pace and place the ball, including lobs, overheads, and approaches.',
  ),
  NtrpRating(
    value: '4.5',
    summary: 'You add spin, change pace, and adjust the plan during a point. Footwork is sound.',
  ),
  NtrpRating(
    value: '5.0',
    summary: 'You anticipate well and have at least one shot that puts opponents under pressure.',
  ),
  NtrpRating(
    value: '5.5',
    summary: 'Power or consistency is a weapon, and you can change style from one match to the next.',
  ),
  NtrpRating(
    value: '6.0',
    summary: 'You handle pace in stressful points and have serious practice and match experience.',
  ),
  NtrpRating(
    value: '6.5',
    summary: 'Regular high-level tournament play, with few holes in the game.',
  ),
  NtrpRating(
    value: '7.0',
    summary: 'World-class match play.',
  ),
];

const roughLevels = <RoughLevel>[
  RoughLevel(
    id: 'new',
    name: 'New to tennis',
    low: 1.5,
    high: 2.0,
    about: '1.5–2.0',
    summary: 'Learning contact, the swing, and how to start a point.',
  ),
  RoughLevel(
    id: 'advanced-beginner',
    name: 'Advanced beginner',
    low: 2.5,
    high: 3.0,
    about: '2.5–3.0',
    summary: 'You can keep a slow rally going and are starting to aim.',
  ),
  RoughLevel(
    id: 'intermediate',
    name: 'Intermediate',
    low: 3.5,
    high: 3.5,
    about: '3.5',
    summary: 'Moderate shots are consistent and direction is becoming reliable.',
  ),
  RoughLevel(
    id: 'high-intermediate',
    name: 'High intermediate',
    low: 4.0,
    high: 4.0,
    about: '4.0',
    summary: 'Strokes hold up in a real point and you place the ball on purpose.',
  ),
  RoughLevel(
    id: 'advanced',
    name: 'Advanced',
    low: 4.5,
    high: 5.0,
    about: '4.5–5.0',
    summary: 'You use spin and pace, and you change the plan during a point.',
  ),
  RoughLevel(
    id: 'tournament',
    name: 'Tournament',
    low: 5.5,
    high: 6.0,
    about: '5.5–6.0',
    summary: 'You have a weapon and can play your game under pressure.',
  ),
  RoughLevel(
    id: 'elite',
    name: 'Elite',
    low: 6.5,
    high: 7.0,
    about: '6.5–7.0',
    summary: 'National-level and world-class play.',
  ),
];

NtrpRating? ntrpByValue(String? value) {
  if (value == null) return null;
  for (final rating in ntrpRatings) {
    if (rating.value == value) return rating;
  }
  return null;
}

RoughLevel? roughById(String? id) {
  if (id == null) return null;
  for (final level in roughLevels) {
    if (level.id == id) return level;
  }
  return null;
}

RoughLevel? roughLevelForNtrp(String value) {
  final rating = ntrpByValue(value);
  if (rating == null) return null;
  for (final level in roughLevels) {
    if (level.contains(rating.number)) return level;
  }
  return null;
}

/// Saved as an NTRP value such as `3.5`, or `rough:<id>` when only a band is chosen.
String? skillRatingDetail(String? code) {
  if (code == null || code.isEmpty) return null;
  if (code.startsWith('rough:')) {
    final level = roughById(code.substring('rough:'.length));
    if (level == null) return null;
    return '${level.name} · about ${level.about}';
  }
  final rating = ntrpByValue(code);
  final level = roughLevelForNtrp(code);
  if (rating == null || level == null) return null;
  return '${rating.value} NTRP · ${level.name}';
}
