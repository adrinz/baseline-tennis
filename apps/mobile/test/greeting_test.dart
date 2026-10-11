import 'package:baseline/logic/plan.dart';
import 'package:baseline/state/player_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a morning greeting includes the first name from sign-in', () {
    final morning = DateTime(2026, 9, 30, 8);
    expect(greetingLine(morning, null), 'Good morning');
    expect(greetingLine(morning, 'John'), 'Good morning John');
    expect(firstNameFromEmail('john.smith@club.com'), 'John');
    expect(firstNameFromEmail('ADA@example.com'), 'Ada');
    expect(
      const PlayerSession(email: 'john.smith@club.com').greetingName,
      'John',
    );
  });
}