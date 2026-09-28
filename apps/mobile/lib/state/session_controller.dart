import 'package:baseline/data/catalog.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionController extends Notifier<PlayerSession> {
  SessionController({this.initial});

  final PlayerSession? initial;
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  String? pendingEmail;

  @override
  PlayerSession build() => initial ?? const PlayerSession();

  void _commit(PlayerSession next) {
    state = next;
    refresh.value++;
    SessionStore.save(next);
  }

  void signIn(AuthProvider provider, {String? email}) {
    _commit(state.copyWith(authProvider: provider, email: email));
  }

  void startEmail(String email) {
    pendingEmail = email.trim();
  }

  bool verifyEmailCode(String code) {
    if (code.trim().isEmpty) return false;
    _commit(
      state.copyWith(authProvider: AuthProvider.email, email: pendingEmail),
    );
    return true;
  }

  void acceptAge(int birthYear) {
    final adult = DateTime.now().year - birthYear >= 18;
    _commit(
      state.copyWith(
        birthYear: birthYear,
        discoverable: adult ? state.discoverable : false,
      ),
    );
  }

  void setPlayedBefore(String value) =>
      _commit(state.copyWith(playedBefore: value));

  void setLevel(int level) => _commit(state.copyWith(level: level));

  void setCity(String city) {
    final trimmed = city.trim();
    if (trimmed.isEmpty || trimmed == state.city) return;
    _commit(state.copyWith(city: trimmed));
  }

  void setGoal(String goal) => _commit(state.copyWith(goal: goal));

  void setDaysPerWeek(int days) => _commit(state.copyWith(daysPerWeek: days));

  void finishOnboarding() => _commit(state.copyWith(onboardingComplete: true));

  void signOut() {
    pendingEmail = null;
    _commit(const PlayerSession());
  }

  void deleteAccount() {
    pendingEmail = null;
    _commit(const PlayerSession());
  }

  void unlockPremium() => _commit(state.copyWith(premium: true));

  void addMatch(MatchLog log) {
    _commit(state.copyWith(matches: [log, ...state.matches]));
  }

  void setDiscoverable(bool value) {
    if (!state.isAdult) {
      _commit(state.copyWith(discoverable: false));
      return;
    }
    _commit(state.copyWith(discoverable: value));
  }

  void setNotification(String key, bool value) {
    if (!state.isAdult &&
        (key == NotificationPrefs.partners ||
            key == NotificationPrefs.messages)) {
      return;
    }
    _commit(
      state.copyWith(notifications: {...state.notifications, key: value}),
    );
  }

  void completeLesson(String slug) {
    if (state.completedLessonSlugs.contains(slug)) return;
    _commit(
      state.copyWith(
        completedLessonSlugs: {...state.completedLessonSlugs, slug},
        streak: state.streak == 0 ? 1 : state.streak,
      ),
    );
  }

  void completeDrill(String slug) {
    if (state.completedDrillSlugs.contains(slug)) return;
    final minutes = drillBySlug(slug)?.durationMinutes ?? 0;
    _commit(
      state.copyWith(
        completedDrillSlugs: {...state.completedDrillSlugs, slug},
        streak: state.streak == 0 ? 1 : state.streak,
        trainingMinutes: state.trainingMinutes + minutes,
      ),
    );
  }

  void markTodayDone() {
    if (state.todayPlanDone) return;
    _commit(
      state.copyWith(
        todayPlanDone: true,
        streak: state.streak == 0 ? 1 : state.streak,
      ),
    );
  }

  void toggleSavedCourt(String id) {
    final next = {...state.savedCourtIds};
    if (!next.add(id)) next.remove(id);
    _commit(state.copyWith(savedCourtIds: next));
  }
}

final sessionProvider = NotifierProvider<SessionController, PlayerSession>(
  SessionController.new,
);
