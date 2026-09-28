import 'dart:convert';

import 'package:baseline/state/player_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the player on this phone between launches. Version 1 does not
/// require an account server for the learning loop.
abstract final class SessionStore {
  static const _key = 'baseline.session.v1';

  static Future<PlayerSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) return null;
    return _fromJson(json);
  }

  static Future<void> save(PlayerSession session) async {
    final prefs = await SharedPreferences.getInstance();
    if (!session.signedIn) {
      await prefs.remove(_key);
      return;
    }
    await prefs.setString(_key, jsonEncode(_toJson(session)));
  }

  static Map<String, dynamic> _toJson(PlayerSession session) {
    return {
      'authProvider': session.authProvider?.name,
      'email': session.email,
      'birthYear': session.birthYear,
      'playedBefore': session.playedBefore,
      'level': session.level,
      'goal': session.goal,
      'daysPerWeek': session.daysPerWeek,
      'onboardingComplete': session.onboardingComplete,
      'completedLessonSlugs': session.completedLessonSlugs.toList(),
      'completedDrillSlugs': session.completedDrillSlugs.toList(),
      'streak': session.streak,
      'discoverable': session.discoverable,
      'notifications': session.notifications,
      'city': session.city,
      'premium': session.premium,
      'todayPlanDone': session.todayPlanDone,
      'savedCourtIds': session.savedCourtIds.toList(),
      'trainingMinutes': session.trainingMinutes,
      'matches': session.matches.map((match) => match.toJson()).toList(),
    };
  }

  static PlayerSession _fromJson(Map<String, dynamic> json) {
    AuthProvider? provider;
    final providerName = json['authProvider'] as String?;
    if (providerName != null) {
      provider = AuthProvider.values
          .where((value) => value.name == providerName)
          .firstOrNull;
    }
    final notifications = Map<String, bool>.from(defaultNotifications);
    final stored = json['notifications'];
    if (stored is Map) {
      for (final entry in stored.entries) {
        if (entry.value is bool) {
          notifications[entry.key.toString()] = entry.value as bool;
        }
      }
    }
    final matches = <MatchLog>[];
    final rawMatches = json['matches'];
    if (rawMatches is List) {
      for (final item in rawMatches) {
        if (item is Map<String, dynamic>) {
          matches.add(MatchLog.fromJson(item));
        } else if (item is Map) {
          matches.add(MatchLog.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return PlayerSession(
      authProvider: provider,
      email: json['email'] as String?,
      birthYear: json['birthYear'] as int?,
      playedBefore: json['playedBefore'] as String?,
      level: json['level'] as int? ?? 1,
      goal: json['goal'] as String?,
      daysPerWeek: json['daysPerWeek'] as int? ?? 3,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      completedLessonSlugs: _stringSet(json['completedLessonSlugs']),
      completedDrillSlugs: _stringSet(json['completedDrillSlugs']),
      streak: json['streak'] as int? ?? 0,
      discoverable: json['discoverable'] as bool? ?? false,
      notifications: notifications,
      city: json['city'] as String? ?? 'Austin',
      premium: json['premium'] as bool? ?? false,
      todayPlanDone: json['todayPlanDone'] as bool? ?? false,
      savedCourtIds: _stringSet(json['savedCourtIds']),
      trainingMinutes: json['trainingMinutes'] as int? ?? 0,
      matches: matches,
    );
  }

  static Set<String> _stringSet(Object? value) {
    if (value is! List) return {};
    return value.whereType<String>().toSet();
  }
}
