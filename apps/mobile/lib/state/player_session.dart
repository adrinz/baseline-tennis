enum AuthProvider { apple, google, email }

abstract final class NotificationPrefs {
  static const practice = 'practice_reminders';
  static const plan = 'plan_reminders';
  static const tips = 'lesson_tips';
  static const weekly = 'weekly_progress';
  static const partners = 'partner_requests';
  static const messages = 'messages';
  static const milestones = 'milestones';

  static const labels = <String, String>{
    practice: 'Practice reminders',
    plan: 'Plan reminders',
    tips: 'Lesson tips',
    weekly: 'Weekly progress',
    partners: 'Partner requests',
    messages: 'Messages',
    milestones: 'Milestones',
  };
}

const defaultNotifications = <String, bool>{
  NotificationPrefs.practice: true,
  NotificationPrefs.plan: false,
  NotificationPrefs.tips: false,
  NotificationPrefs.weekly: false,
  NotificationPrefs.partners: true,
  NotificationPrefs.messages: false,
  NotificationPrefs.milestones: false,
};

class MatchLog {
  const MatchLog({
    required this.playedOn,
    required this.format,
    required this.result,
    this.score = '',
    this.wentWell = '',
    this.toImprove = '',
  });

  final String playedOn;
  final String format;
  final String result;
  final String score;
  final String wentWell;
  final String toImprove;

  Map<String, String> toJson() => {
    'playedOn': playedOn,
    'format': format,
    'result': result,
    'score': score,
    'wentWell': wentWell,
    'toImprove': toImprove,
  };

  factory MatchLog.fromJson(Map<String, dynamic> json) {
    return MatchLog(
      playedOn: json['playedOn'] as String? ?? '',
      format: json['format'] as String? ?? 'singles',
      result: json['result'] as String? ?? 'unfinished',
      score: json['score'] as String? ?? '',
      wentWell: json['wentWell'] as String? ?? '',
      toImprove: json['toImprove'] as String? ?? '',
    );
  }
}

const _keep = Object();

class PlayerSession {
  const PlayerSession({
    this.authProvider,
    this.email,
    this.givenName,
    this.subject,
    this.birthYear,
    this.playedBefore,
    this.level = 1,
    this.skillRating,
    this.accessToken,
    this.refreshToken,
    this.goal,
    this.daysPerWeek = 3,
    this.onboardingComplete = false,
    this.completedLessonSlugs = const {},
    this.completedDrillSlugs = const {},
    this.streak = 0,
    this.discoverable = false,
    this.notifications = defaultNotifications,
    this.city = 'Melville',
    this.premium = false,
    this.todayPlanDone = false,
    this.savedCourtIds = const {},
    this.trainingMinutes = 0,
    this.matches = const [],
  });

  final AuthProvider? authProvider;
  final String? email;
  final String? givenName;
  final String? subject;
  final int? birthYear;
  final String? playedBefore;
  final int level;

  /// An NTRP value such as `3.5`, or `rough:<id>` for a band without a number.
  final String? skillRating;
  final String? accessToken;
  final String? refreshToken;
  final String? goal;
  final int daysPerWeek;
  final bool onboardingComplete;
  final Set<String> completedLessonSlugs;
  final Set<String> completedDrillSlugs;
  final int streak;
  final bool discoverable;
  final Map<String, bool> notifications;
  final String city;
  final bool premium;
  final bool todayPlanDone;
  final Set<String> savedCourtIds;
  final int trainingMinutes;
  final List<MatchLog> matches;

  bool get signedIn => authProvider != null;

  /// First name for the home greeting. Uses the saved sign-in name, then the email.
  String? get greetingName {
    final saved = givenName?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    final mail = email;
    if (mail == null) return null;
    return firstNameFromEmail(mail);
  }

  int? get ageYears {
    final year = birthYear;
    if (year == null) return null;
    return DateTime.now().year - year;
  }

  bool get isAdult => (ageYears ?? 0) >= 18;

  PlayerSession copyWith({
    AuthProvider? authProvider,
    String? email,
    String? givenName,
    String? subject,
    int? birthYear,
    String? playedBefore,
    int? level,
    Object? skillRating = _keep,
    String? accessToken,
    String? refreshToken,
    String? goal,
    int? daysPerWeek,
    bool? onboardingComplete,
    Set<String>? completedLessonSlugs,
    Set<String>? completedDrillSlugs,
    int? streak,
    bool? discoverable,
    Map<String, bool>? notifications,
    String? city,
    bool? premium,
    bool? todayPlanDone,
    Set<String>? savedCourtIds,
    int? trainingMinutes,
    List<MatchLog>? matches,
  }) {
    return PlayerSession(
      authProvider: authProvider ?? this.authProvider,
      email: email ?? this.email,
      givenName: givenName ?? this.givenName,
      subject: subject ?? this.subject,
      birthYear: birthYear ?? this.birthYear,
      playedBefore: playedBefore ?? this.playedBefore,
      level: level ?? this.level,
      skillRating: identical(skillRating, _keep)
          ? this.skillRating
          : skillRating as String?,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      goal: goal ?? this.goal,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      completedLessonSlugs: completedLessonSlugs ?? this.completedLessonSlugs,
      completedDrillSlugs: completedDrillSlugs ?? this.completedDrillSlugs,
      streak: streak ?? this.streak,
      discoverable: discoverable ?? this.discoverable,
      notifications: notifications ?? this.notifications,
      city: city ?? this.city,
      premium: premium ?? this.premium,
      todayPlanDone: todayPlanDone ?? this.todayPlanDone,
      savedCourtIds: savedCourtIds ?? this.savedCourtIds,
      trainingMinutes: trainingMinutes ?? this.trainingMinutes,
      matches: matches ?? this.matches,
    );
  }
}

const _authPaths = {'/welcome', '/sign-in', '/email', '/code'};

/// First name from an email, such as john.smith@club.com → John.
String? firstNameFromEmail(String email) {
  final local = email.split('@').first.trim();
  if (local.isEmpty) return null;
  final token = local.split(RegExp(r'[^A-Za-z]+')).firstWhere(
    (part) => part.isNotEmpty,
    orElse: () => '',
  );
  if (token.length < 2) return null;
  return '${token[0].toUpperCase()}${token.substring(1).toLowerCase()}';
}

String? sessionRedirect(PlayerSession session, String path) {
  if (path == '/') return '/welcome';

  if (!session.signedIn) {
    if (_authPaths.contains(path)) return null;
    return '/welcome';
  }

  final age = session.ageYears;
  if (age == null || age < 16) {
    return path == '/age' ? null : '/age';
  }

  if (!session.onboardingComplete) {
    if (path == '/onboarding' || path == '/plan') return null;
    return '/onboarding';
  }

  if (_authPaths.contains(path) ||
      path == '/age' ||
      path == '/onboarding' ||
      path == '/plan') {
    return '/home';
  }
  return null;
}
