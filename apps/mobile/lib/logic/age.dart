enum AgeDecision { invalid, blocked, minor, adult }

class AgeCheck {
  const AgeCheck(this.decision, this.age, this.birthYear);

  final AgeDecision decision;
  final int? age;
  final int? birthYear;
}

/// Birth year is the only age signal in the MVP. Under 16 cannot continue.
AgeCheck evaluateBirthYear(String raw, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final year = int.tryParse(raw.trim());
  if (year == null || year < 1900 || year > clock.year) {
    return const AgeCheck(AgeDecision.invalid, null, null);
  }
  final age = clock.year - year;
  if (age < 16) return AgeCheck(AgeDecision.blocked, age, year);
  if (age < 18) return AgeCheck(AgeDecision.minor, age, year);
  return AgeCheck(AgeDecision.adult, age, year);
}

String ageBand(int birthYear, {DateTime? now}) {
  final age = (now ?? DateTime.now()).year - birthYear;
  if (age < 18) return '16–17';
  if (age < 25) return '18–24';
  if (age < 35) return '25–34';
  if (age < 50) return '35–49';
  return '50+';
}
