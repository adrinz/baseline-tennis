import 'package:baseline/data/catalog.dart';

class CoachAnswer {
  const CoachAnswer({
    required this.label,
    required this.summary,
    required this.causes,
    required this.drillSlugs,
    required this.practiceNote,
    this.nextTechniqueSlug,
    this.lessonSlug,
    this.isFallback = false,
    this.stopForPain = false,
  });

  /// Always coaching assistance. Never a medical diagnosis.
  final String label;
  final String summary;
  final List<String> causes;
  final String? nextTechniqueSlug;
  final String? lessonSlug;
  final List<String> drillSlugs;
  final String practiceNote;
  final bool isFallback;
  final bool stopForPain;
}

bool _mentionsPain(String question) {
  const words = ['pain', 'hurt', 'hurts', 'injury', 'injured', 'sore', 'ache'];
  return words.any(question.contains);
}

CoachAnswer answerCoachQuestion(
  String question, {
  String? unfinishedLessonSlug,
}) {
  final normalized = question.toLowerCase();
  if (_mentionsPain(normalized)) {
    return const CoachAnswer(
      label: 'coaching_assistance',
      summary: 'Stop and talk with a clinician or a coach in person. Baseline does not diagnose pain or injury.',
      causes: [],
      drillSlugs: [],
      practiceNote: '',
      stopForPain: true,
    );
  }

  for (final rule in baselineCatalog.coachRules) {
    final matched = rule.match.every(normalized.contains);
    if (!matched) continue;
    return CoachAnswer(
      label: 'coaching_assistance',
      summary: rule.summary,
      causes: rule.causes,
      nextTechniqueSlug: rule.nextTechniqueSlug,
      drillSlugs: rule.drillSlugs,
      practiceNote: rule.practiceNote,
    );
  }

  return CoachAnswer(
    label: 'coaching_assistance',
    summary: 'Review the last lesson you have not finished, then run one consistency drill.',
    causes: const [],
    lessonSlug: unfinishedLessonSlug,
    drillSlugs: const ['forehand-consistency'],
    practiceNote: 'Three short sessions this week beat one long one.',
    isFallback: true,
  );
}
