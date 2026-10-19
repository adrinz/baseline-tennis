import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  testWidgets('Learn shows the published Level 5 advanced lessons', (
    tester,
  ) async {
    await pumpApp(tester, session: adultSession(), places: PlacesHarness());

    await tapTab(tester, 'Learn');
    await tester.scrollUntilVisible(find.text('Advanced'), 500);
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();

    expect(find.text('Advanced'), findsOneWidget);
    expect(
      find.text('Advanced biomechanics for efficient strokes'),
      findsOneWidget,
    );
    expect(find.text('Opponent scouting and match patterns'), findsOneWidget);
    expect(
      find.text('Tournament preparation and match routine'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Lessons for this level are on the way. The path stays visible so you can aim for it.',
      ),
      findsNothing,
    );
  });
}
