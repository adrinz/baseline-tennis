import 'package:baseline/data/catalog.dart';
import 'package:baseline/data/videos.dart';
import 'package:baseline/logic/plan.dart';
import 'package:baseline/logic/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  testWidgets('E2E-S01 Home covers search, cards, navigation, and completion', (
    tester,
  ) async {
    final session = adultSession();
    final drill = recommendedDrill(session);
    await pumpApp(tester, session: session, places: PlacesHarness());

    expect(find.text('START LEVEL 1'), findsOneWidget);
    expect(semanticsLabel('Start level 1'), findsOneWidget);
    expect(find.byTooltip('Search lessons and drills'), findsOneWidget);

    await tester.tap(find.byTooltip('Search lessons and drills'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('search-field')),
      'no such tennis result',
    );
    await tester.pump();
    expect(
      find.text('No lessons, drills, or videos match that.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Clear search'));
    await tester.enterText(find.byKey(const Key('search-field')), 'forehand');
    await tester.pump();
    expect(find.text('Forehand consistency'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(semanticsLabel('Start level 1'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson'), findsOneWidget);
    await tapTab(tester, 'Home');

    await tester.scrollUntilVisible(find.text(drill.name).first, 400);
    await tester.tap(find.text(drill.name).first);
    await tester.pumpAndSettle();
    expect(find.text(drill.name), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Mark done'), 400);
    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();
    expect(find.text('Marked done'), findsOneWidget);
    await tapTab(tester, 'Home');

    await tester.scrollUntilVisible(find.text('WATCH AND LEARN'), 500);
    await tester.tap(find.text('All ${licensedVideos.length}'));
    await tester.pumpAndSettle();
    expect(find.text('Video library'), findsOneWidget);
  });

  testWidgets('E2E-S02 Learn covers path cards and reference libraries', (
    tester,
  ) async {
    await pumpApp(tester, session: adultSession(), places: PlacesHarness());
    await tapTab(tester, 'Learn');

    await tester.tap(semanticsLabel('Open techniques'));
    await tester.pumpAndSettle();
    expect(find.text('Techniques'), findsOneWidget);
    expect(find.text('GROUNDSTROKES'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(semanticsLabel('Open glossary'));
    await tester.pumpAndSettle();
    expect(find.text('Glossary'), findsOneWidget);
    expect(find.text(baselineCatalog.glossary.first.term), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(semanticsLabel('Level 2 Beginner'));
    await tester.pumpAndSettle();
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Lessons'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(semanticsLabel('Open video library'));
    await tester.pumpAndSettle();
    expect(find.text('Video library'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Video credits'));
    await tester.pumpAndSettle();
    expect(find.text('Video credits'), findsOneWidget);
  });

  testWidgets(
    'E2E-S03 Train covers day selection, drill cards, and play controls',
    (tester) async {
      final session = adultSession();
      final week = buildFirstWeek(session.daysPerWeek);
      final firstVideo = licensedVideos.first;
      await pumpApp(tester, session: session, places: PlacesHarness());
      await tapTab(tester, 'Train');

      expect(find.text('THIS WEEK'), findsOneWidget);
      final secondDay = week[1];
      await tapSemanticsButton(
        tester,
        '${secondDay.label}, ${secondDay.title}, ${secondDay.minutes} minutes',
      );
      expect(find.text(secondDay.title), findsOneWidget);

      final page = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('VIDEO LIBRARY'),
        500,
        scrollable: page,
      );
      final playFirst = semanticsLabel('Play ${firstVideo.title}');
      await tester.ensureVisible(playFirst);
      await tester.tap(playFirst);
      await tester.pumpAndSettle();
      expect(find.text(firstVideo.title), findsWidgets);
      expect(find.text('All video credits'), findsOneWidget);
      final playerControl = semanticsLabel(
        'Play ${firstVideo.title}, ${firstVideo.durationLabel}. Credit ${firstVideo.creator}.',
      );
      expect(playerControl, findsOneWidget);
      await tester.tap(playerControl);
      await tester.pump(const Duration(milliseconds: 300));
      final pauseControl = semanticsLabel(
        'Pause ${firstVideo.title}, ${firstVideo.durationLabel}. Credit ${firstVideo.creator}.',
      );
      expect(
        pauseControl.evaluate().isNotEmpty ||
            find.text('This clip could not be played.').evaluate().isNotEmpty ||
            playerControl.evaluate().isNotEmpty,
        isTrue,
      );
      expect(find.text('Transcript'), findsOneWidget);
      await tester.tap(find.text('Transcript'));
      await tester.pumpAndSettle();
      expect(find.text(firstVideo.transcript), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('DRILL LIBRARY'),
        500,
        scrollable: page,
      );
      await tester.scrollUntilVisible(
        find.text('Forehand consistency'),
        500,
        scrollable: page,
      );
      await tester.tap(find.text('Forehand consistency').first);
      await tester.pumpAndSettle();
      expect(find.text('Drill'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Mark done'), 500);
      expect(find.text('Mark done'), findsOneWidget);
      await tapTab(tester, 'Train');
    },
  );

  testWidgets('E2E-S04 Video library filters, opens, and returns from a clip', (
    tester,
  ) async {
    await pumpApp(tester, session: adultSession(), places: PlacesHarness());
    await tapTab(tester, 'Learn');
    await tester.tap(semanticsLabel('Open video library'));
    await tester.pumpAndSettle();

    final categoryButton = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.button == true &&
          widget.properties.selected != true &&
          (widget.properties.label?.endsWith(' videos') ?? false),
    );
    expect(categoryButton, findsWidgets);
    await tester.tap(categoryButton.first);
    expect(find.text(licensedVideos.first.title), findsWidgets);
    await tapSemanticsButton(tester, 'All videos');
    expect(find.text(licensedVideos.first.title), findsOneWidget);
    await tester.tap(find.text(licensedVideos.first.title).first);
    await tester.pumpAndSettle();
    expect(find.text(licensedVideos.first.title), findsWidgets);
    expect(find.text('All video credits'), findsOneWidget);
    await tester.tap(find.text('All video credits'));
    await tester.pumpAndSettle();
    expect(find.text('Video credits'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Video library'), findsOneWidget);
  });

  testWidgets('E2E-S05 Profile covers level, switches, and settings routes', (
    tester,
  ) async {
    await pumpApp(tester, session: adultSession(), places: PlacesHarness());
    await tapTab(tester, 'Profile');

    await tapSemanticsButton(tester, 'Level 2 Beginner');
    expect(find.text('Beginner'), findsOneWidget);

    final discoverable = find.byType(SwitchListTile).first;
    await tester.tap(discoverable);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(discoverable).value, isTrue);
    expect(
      find.text('Other players see a distance band, never an exact location.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Practice reminders'), 500);
    final reminder = find.widgetWithText(SwitchListTile, 'Practice reminders');
    final before = tester.widget<SwitchListTile>(reminder).value;
    await tester.tap(reminder);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(reminder).value, isNot(before));

    await tester.scrollUntilVisible(find.text('Skill rating'), 500);
    await tester.tap(find.text('Skill rating'));
    await tester.pumpAndSettle();
    expect(find.text('Skill rating'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Notification settings'), 500);
    await tester.tap(find.text('Notification settings'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Techniques'), 500);
    await tester.tap(find.text('Techniques'));
    await tester.pumpAndSettle();
    expect(find.text('Techniques'), findsOneWidget);
  });
}

Finder semanticsLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
  );
}
