/** Age is the calendar year minus birth year. Baseline stores a year, not a birthday. */

export function ageInYears(birthYear: number, now = new Date()): number {
  return now.getFullYear() - birthYear;
}

export function canCreateAccount(birthYear: number, now = new Date()): boolean {
  return ageInYears(birthYear, now) >= 16;
}

export function canUsePartnerFeatures(birthYear: number, now = new Date()): boolean {
  return ageInYears(birthYear, now) >= 18;
}

export function ageBand(birthYear: number, now = new Date()): string {
  const age = ageInYears(birthYear, now);
  if (age < 18) return '16–17';
  if (age < 25) return '18–24';
  if (age < 35) return '25–34';
  if (age < 50) return '35–49';
  return '50+';
}
