import 'package:baseline/screens/discover_screen.dart';
import 'package:baseline/theme/baseline_colors.dart';
import 'package:baseline/widgets/baseline_button.dart';
import 'package:baseline/widgets/line_card.dart';
import 'package:baseline/widgets/scaled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  testWidgets('E2E-U01 welcome offers Apple because Google is offered', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Start from a solid base.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Sign in with Apple'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Use email code'), findsOneWidget);
    expect(find.text('Sign in with Apple'), findsOneWidget);
  });

  testWidgets('E2E-U02 text scale is kept and primary controls are 48pt', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester);

    final title = tester.widget<Text>(find.text('Start from a solid base.'));
    expect(title.textScaler!.scale(16), 32);

    final button = tester.getSize(find.byType(BaselineButton).first);
    expect(button.height, greaterThanOrEqualTo(kMinTapTarget));
    expect(button.width, greaterThanOrEqualTo(kMinTapTarget));
  });

  testWidgets('E2E-U03 shared controls meet the tap target', (tester) async {
    usePhoneSurface(tester);
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              BaselineButton(label: 'Continue', onPressed: () => tapped = true),
              LineCard(
                semanticsLabel: 'Open lesson',
                onTap: () {},
                child: const ScaledText('Ready position'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(BaselineButton)).height,
      greaterThanOrEqualTo(kMinTapTarget),
    );
    expect(
      tester.getSize(find.byType(LineCard)).height,
      greaterThanOrEqualTo(kMinTapTarget),
    );
    final text = tester.widget<Text>(find.text('Continue'));
    expect(text.textScaler!.scale(16), 16);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('E2E-A01 onboarding builds a week and lands on Home', (
    tester,
  ) async {
    final places = PlacesHarness();
    await pumpApp(
      tester,
      session: adultSession(onboardingComplete: false),
      places: places,
    );

    expect(find.text('Have you played before?'), findsOneWidget);
    expect(find.bySemanticsLabel('Question 1 of 4'), findsOneWidget);
    await tester.tap(find.text('A little'));
    await tester.pumpAndSettle();

    expect(find.text('What level fits you now?'), findsOneWidget);
    await tester.tap(find.text('1. Complete Beginner'));
    await tester.pumpAndSettle();

    expect(find.text('What is your main goal?'), findsOneWidget);
    await tester.tap(find.text('Rally with consistency'));
    await tester.pumpAndSettle();

    expect(find.text('How many days can you train?'), findsOneWidget);
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(find.text('Your first week'), findsOneWidget);
    expect(
      find.textContaining('3 days · Rally with consistency'),
      findsOneWidget,
    );
    await tester.tap(find.text('Accept plan'));
    await tester.pumpAndSettle();

    expect(find.text('START LEVEL 1'), findsOneWidget);
    expect(find.text('Introduction to tennis'), findsOneWidget);
    expect(find.textContaining('Level 1 ·'), findsOneWidget);
  });

  testWidgets('E2E-A02 a free lesson can be marked complete', (tester) async {
    await pumpApp(tester, session: adultSession(), places: PlacesHarness());

    expect(find.text('START LEVEL 1'), findsOneWidget);
    await tester.tap(find.text('Introduction to tennis'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Mark complete'), 400);
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('E2E-A03 a premium lesson stays locked', (tester) async {
    await pumpApp(tester, session: adultSession(), places: PlacesHarness());

    await tapTab(tester, 'Learn');
    expect(
      find.text('Levels 1–3 are the full path. Levels 4 and 5 stay visible.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Advanced Beginner'), 400);
    await tester.tap(find.text('Advanced Beginner'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Rally construction'), 400);
    await tester.tap(find.text('Rally construction'));
    await tester.pumpAndSettle();
    expect(find.text('See Premium'), findsOneWidget);
    expect(find.textContaining('is locked'), findsOneWidget);
  });

  testWidgets('E2E-A04 search, training, and the pro answer a question', (
    tester,
  ) async {
    await pumpApp(tester, session: adultSession(), places: PlacesHarness());

    await tester.tap(find.byTooltip('Search lessons and drills'));
    await tester.pump();
    expect(find.text('Search'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search-field')), 'forehand');
    await tester.pump();
    expect(find.text('Forehand consistency'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapTab(tester, 'Train');
    expect(find.text('THIS WEEK'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Wall rally'), 500);
    expect(find.text('Wall rally'), findsOneWidget);

    await tapTab(tester, 'Home');
    await tester.tap(find.byTooltip('Ask the pro'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('coach-question')),
      'My forehand causes pain in my wrist.',
    );
    await tester.tap(find.text('Ask'));
    await tester.pump();
    expect(find.text('Coaching assistance'), findsOneWidget);
    expect(find.textContaining('clinician'), findsOneWidget);
  });

  testWidgets(
    'E2E-A05 profile covers privacy, equipment, premium, and sign out',
    (tester) async {
      final places = PlacesHarness();
      await pumpApp(tester, session: adultSession(), places: places);

      await tapTab(tester, 'Profile');
      expect(find.text('Complete Beginner'), findsOneWidget);
      expect(find.textContaining('Age band'), findsOneWidget);
      expect(
        find.textContaining('Goal · Rally with consistency'),
        findsOneWidget,
      );

      await tester.tap(find.text('Discoverable'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Other players see a distance band, never an exact location.',
        ),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(find.text('Equipment guide'), 400);
      await tester.tap(find.text('Equipment guide'));
      await tester.pumpAndSettle();
      expect(find.text('BASELINE PICK'), findsOneWidget);
      expect(find.text('Harborline Learn 27'), findsOneWidget);
      expect(find.text('FROM OUR PARTNERS'), findsOneWidget);
      expect(find.text('Sponsored'), findsOneWidget);
      expect(find.text('Launchline Match 100'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Match log'), 400);
      await tester.tap(find.text('Match log'));
      await tester.pumpAndSettle();
      expect(find.text('Match log'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Inbox'), 400);
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();
      expect(find.text('No requests yet.'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Privacy'), 400);
      await tester.tap(find.text('Privacy'));
      await tester.pumpAndSettle();
      expect(find.text('Privacy'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Baseline Premium'), 400);
      await tester.tap(find.text('Baseline Premium'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'The price is set in the App Store. This preview does not charge you.',
        ),
        findsOneWidget,
      );
      expect(find.text('Virtual Tennis Pro'), findsOneWidget);
      await tester.ensureVisible(find.text('Unlock on this phone'));
      await tester.tap(find.text('Unlock on this phone'));
      await tester.pumpAndSettle();
      expect(find.text('Premium is on'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Sign out'), 400);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
    },
  );

  testWidgets('E2E-A06 Discover sits in the tab shell', (tester) async {
    final places = PlacesHarness();
    await pumpApp(tester, session: adultSession(), places: places);

    await tapTab(tester, 'Discover');
    expect(find.byType(DiscoverScreen), findsOneWidget);
    expect(find.text('Terry Farrell Park'), findsOneWidget);
    expect(find.textContaining('km'), findsNothing);

    await tapTab(tester, 'Home');
    expect(find.text('START LEVEL 1'), findsOneWidget);
  });
}
