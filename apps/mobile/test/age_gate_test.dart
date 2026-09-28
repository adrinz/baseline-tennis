import 'package:baseline/app.dart';
import 'package:baseline/logic/age.dart';
import 'package:baseline/screens/age_gate_screen.dart';
import 'package:baseline/state/player_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('birth year under 16 is blocked and 16 to 17 stays off discovery', () {
    final now = DateTime(2026, 9, 27);
    expect(evaluateBirthYear('2011', now: now).decision, AgeDecision.blocked);
    expect(evaluateBirthYear('2010', now: now).decision, AgeDecision.minor);
    expect(evaluateBirthYear('2008', now: now).decision, AgeDecision.adult);
    expect(evaluateBirthYear('nope', now: now).decision, AgeDecision.invalid);
  });

  test('a signed-in player without a birth year stays on the age gate', () {
    const session = PlayerSession(authProvider: AuthProvider.apple);
    expect(sessionRedirect(session, '/home'), '/age');
    expect(sessionRedirect(session, '/age'), isNull);
    expect(sessionRedirect(const PlayerSession(), '/home'), '/welcome');
  });

  testWidgets('age gate blocks a player under 16', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AgeGateScreen())),
    );

    final tooYoung = (DateTime.now().year - 10).toString();
    await tester.enterText(find.byKey(const Key('birth-year-field')), tooYoung);
    await tester.tap(find.bySemanticsLabel('Continue'));
    await tester.pump();

    expect(find.textContaining('cannot create an account'), findsOneWidget);
  });

  testWidgets('welcome shows get started and sign in with Apple', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: BaselineApp()));
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Sign in with Apple'), findsOneWidget);
  });
}
