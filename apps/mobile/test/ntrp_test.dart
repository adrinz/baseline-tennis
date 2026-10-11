import 'package:baseline/data/ntrp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every NTRP rating sits in one rough level', () {
    expect(roughLevelForNtrp('1.5')?.name, 'New to tennis');
    expect(roughLevelForNtrp('2.0')?.name, 'New to tennis');
    expect(roughLevelForNtrp('2.5')?.name, 'Advanced beginner');
    expect(roughLevelForNtrp('3.0')?.name, 'Advanced beginner');
    expect(roughLevelForNtrp('3.5')?.name, 'Intermediate');
    expect(roughLevelForNtrp('4.0')?.name, 'High intermediate');
    expect(roughLevelForNtrp('4.5')?.name, 'Advanced');
    expect(roughLevelForNtrp('5.0')?.name, 'Advanced');
    expect(roughLevelForNtrp('5.5')?.name, 'Tournament');
    expect(roughLevelForNtrp('6.0')?.name, 'Tournament');
    expect(roughLevelForNtrp('6.5')?.name, 'Elite');
    expect(roughLevelForNtrp('7.0')?.name, 'Elite');
    expect(ntrpRatings, hasLength(12));
    expect(roughLevels, hasLength(7));
  });

  test('the profile line names the number or the rough band', () {
    expect(skillRatingDetail('3.5'), '3.5 NTRP · Intermediate');
    expect(skillRatingDetail('rough:advanced'), 'Advanced · about 4.5–5.0');
    expect(skillRatingDetail(null), isNull);
    expect(skillRatingDetail('rough:missing'), isNull);
  });
}
