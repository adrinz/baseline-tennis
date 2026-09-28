import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/logic/coach.dart';
import 'package:baseline/logic/progress.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/theme/baseline_theme.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> showCoachSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BaselineColors.line,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const CoachSheet(),
  );
}

class CoachSheet extends ConsumerStatefulWidget {
  const CoachSheet({super.key});

  @override
  ConsumerState<CoachSheet> createState() => _CoachSheetState();
}

class _CoachSheetState extends ConsumerState<CoachSheet> {
  final _controller = TextEditingController();
  CoachAnswer? _answer;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask() {
    final question = _controller.text.trim();
    if (question.isEmpty) {
      setState(() {
        _error = 'Type a question first.';
        _answer = null;
      });
      return;
    }
    final session = ref.read(sessionProvider);
    final unfinished = continueLesson(session);
    setState(() {
      _error = null;
      _answer = answerCoachQuestion(
        question,
        unfinishedLessonSlug: unfinished.slug,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final answer = _answer;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: BaselineColors.ink.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const ScaledText('Ask the pro', style: BaselineType.cardTitle),
              const SizedBox(height: 12),
              TextField(
                key: const Key('coach-question'),
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                style: const TextStyle(color: BaselineColors.line),
                cursorColor: BaselineColors.ball,
                decoration: InputDecoration(
                  hintText: 'I keep hitting my forehand into the net',
                  hintStyle: TextStyle(
                    color: BaselineColors.line.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: BaselineColors.nightCourt,
                ),
              ),
              const SizedBox(height: 12),
              BaselineButton(
                label: 'Ask',
                semanticsLabel: 'Ask the pro',
                onPressed: _ask,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                ScaledText(
                  _error!,
                  style: const TextStyle(color: BaselineColors.ink),
                ),
              ],
              if (answer != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: BaselineColors.fairway,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const ScaledText(
                    'Coaching assistance',
                    style: TextStyle(
                      color: BaselineColors.line,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ScaledText(answer.summary, style: BaselineType.cardBody),
                if (answer.causes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const ScaledText(
                    'POSSIBLE CAUSES',
                    style: BaselineType.eyebrowFairway,
                  ),
                  const SizedBox(height: 6),
                  for (final cause in answer.causes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ScaledText(
                        '· $cause',
                        style: BaselineType.cardBody,
                      ),
                    ),
                ],
                if (answer.nextTechniqueSlug != null) ...[
                  const SizedBox(height: 8),
                  ScaledText(
                    'Next technique · ${techniqueTitle(answer.nextTechniqueSlug!)}',
                    style: BaselineType.cardBody,
                  ),
                ],
                if (answer.lessonSlug != null &&
                    lessonBySlug(answer.lessonSlug!) != null) ...[
                  const SizedBox(height: 8),
                  BaselineButton(
                    label: lessonBySlug(answer.lessonSlug!)!.title,
                    semanticsLabel:
                        'Open ${lessonBySlug(answer.lessonSlug!)!.title}',
                    tone: BaselineButtonTone.fairway,
                    onPressed: () {
                      final slug = answer.lessonSlug!;
                      Navigator.of(context).pop();
                      context.go('/learn/lesson/$slug');
                    },
                  ),
                ],
                for (final video in videosForDrills(
                  answer.drillSlugs,
                ).take(2)) ...[
                  const SizedBox(height: 8),
                  BaselineButton(
                    label: 'Watch ${video.title}',
                    semanticsLabel: 'Watch ${video.title}',
                    tone: BaselineButtonTone.fairway,
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/video/${video.id}');
                    },
                  ),
                ],
                for (final slug in answer.drillSlugs)
                  if (drillBySlug(slug) != null) ...[
                    const SizedBox(height: 8),
                    BaselineButton(
                      label: drillBySlug(slug)!.name,
                      semanticsLabel: 'Open drill ${drillBySlug(slug)!.name}',
                      tone: BaselineButtonTone.fairway,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/train/drill/$slug');
                      },
                    ),
                  ],
                if (answer.practiceNote.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ScaledText(answer.practiceNote, style: BaselineType.cardBody),
                ],
              ],
              const SizedBox(height: 16),
              const ScaledText(
                'Coaching help, not medical advice.',
                style: TextStyle(
                  color: BaselineColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
