import 'package:baseline/logic/coach.dart';
import 'package:baseline/screens/lesson_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('forehand into the net uses the seed rule', () {
    final answer = answerCoachQuestion(
      'I keep hitting my forehand into the net.',
    );
    expect(answer.label, 'coaching_assistance');
    expect(
      answer.summary,
      'A forehand into the net usually means the contact or the swing path is too low.',
    );
    expect(answer.causes, contains('Contact point too low'));
    expect(answer.drillSlugs, ['wall-rally', 'forehand-consistency']);
    expect(answer.practiceNote, contains('15-minute'));
    expect(answer.stopForPain, isFalse);
  });

  testWidgets(
    'lesson reader shows the ready position title and a licensed clip',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LessonReaderScreen(slug: 'ready-position')),
        ),
      );

      expect(find.text('Ready position'), findsOneWidget);
      expect(find.text('Dropping into the ready position'), findsOneWidget);
      expect(find.text('Feet and the first step'), findsOneWidget);
      expect(find.textContaining('Pexels'), findsWidgets);
      expect(find.textContaining('Mixkit'), findsWidgets);
      expect(find.textContaining('Standing upright'), findsOneWidget);
      expect(find.textContaining('Feet wider than shoulders'), findsOneWidget);
    },
  );

  testWidgets('rally construction stays locked and the title still scales', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.4)),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const LessonReaderScreen(slug: 'rally-construction'),
        ),
      ),
    );

    expect(find.text('Rally construction'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.textContaining('is locked'), findsOneWidget);
    expect(find.textContaining('The cross-court shot is safer'), findsNothing);

    final title = tester.widget<Text>(find.text('Rally construction'));
    expect(title.textScaler, const TextScaler.linear(1.4));
  });
}
