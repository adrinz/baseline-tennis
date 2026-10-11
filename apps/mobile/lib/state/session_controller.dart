import 'dart:async';

import 'package:baseline/data/auth_gateway.dart';
import 'package:baseline/data/baseline_api.dart';
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
  String? signupToken;
  bool _remoteEmail = false;

  @override
  PlayerSession build() => initial ?? const PlayerSession();

  void _commit(PlayerSession next) {
    state = next;
    refresh.value++;
    SessionStore.save(next);
  }

  Future<AuthAttempt> signInWithProvider(AuthProvider provider) async {
    final gateway = ref.read(authGatewayProvider);
    final attempt = switch (provider) {
      AuthProvider.apple => await gateway.signInWithApple(),
      AuthProvider.google => await gateway.signInWithGoogle(),
      AuthProvider.email => const AuthRejected('Use the email code.'),
    };
    if (attempt case AuthSucceeded(:final account)) {
      _completeSignIn(
        account.provider,
        email: account.email,
        givenName: account.givenName,
        subject: account.subject,
      );
      final token = account.identityToken;
      final api = ref.read(baselineApiProvider);
      if (api != null && token != null && account.provider != AuthProvider.email) {
        final remote = await api.signIn(
          provider: account.provider,
          identityToken: token,
          givenName: account.givenName,
        );
        _keepRemote(remote);
      }
    }
    return attempt;
  }

  /// Sends a one-time code. Returns an error message, or null after it is delivered.
  Future<String?> startEmail(String email) async {
    final trimmed = email.trim();
    final api = ref.read(baselineApiProvider);
    if (api != null) {
      final preview = await api.startEmail(trimmed);
      if (preview != null) {
        final failure = await NotificationEmailCodeMailer().send(code: preview);
        if (failure != null) return failure;
        pendingEmail = trimmed;
        _remoteEmail = true;
        return null;
      }
    }
    _remoteEmail = false;
    final failure = await ref.read(authGatewayProvider).sendEmailCode(trimmed);
    if (failure != null) return failure;
    pendingEmail = trimmed;
    return null;
  }

  /// Returns an error message, or null when the code matches and the session starts.
  Future<String?> verifyEmailCode(String code) async {
    final email = pendingEmail?.trim();
    if (email == null || email.isEmpty) return 'Request a new code.';
    if (_remoteEmail) {
      final remote = await ref.read(baselineApiProvider)?.finishEmail(email, code.trim());
      if (remote == null) return "That code doesn't match.";
      _keepRemote(remote);
      _completeSignIn(
        AuthProvider.email,
        email: email,
        subject: email.toLowerCase(),
      );
      pendingEmail = null;
      _remoteEmail = false;
      return null;
    }
    final failure = ref.read(authGatewayProvider).checkEmailCode(email, code);
    if (failure != null) return failure;
    _completeSignIn(
      AuthProvider.email,
      email: email,
      subject: email.toLowerCase(),
    );
    pendingEmail = null;
    return null;
  }

  void _completeSignIn(
    AuthProvider provider, {
    String? email,
    String? givenName,
    String? subject,
  }) {
    final nextEmail = email ?? state.email;
    _commit(
      state.copyWith(
        authProvider: provider,
        email: nextEmail,
        givenName: _nameFromSignIn(givenName, nextEmail),
        subject: subject,
      ),
    );
  }

  void acceptAge(int birthYear) {
    final adult = DateTime.now().year - birthYear >= 18;
    _commit(
      state.copyWith(
        birthYear: birthYear,
        discoverable: adult ? state.discoverable : false,
      ),
    );
    final token = signupToken;
    final api = ref.read(baselineApiProvider);
    if (token == null || api == null) return;
    unawaited(() async {
      final remote = await api.complete(
        signupToken: token,
        birthYear: birthYear,
        displayName: state.givenName,
      );
      signupToken = null;
      _keepRemote(remote);
    }());
  }

  void setPlayedBefore(String value) =>
      _commit(state.copyWith(playedBefore: value));

  void setLevel(int level) => _commit(state.copyWith(level: level));

  void setSkillRating(String? code) {
    _commit(state.copyWith(skillRating: code));
    final token = state.accessToken;
    final api = ref.read(baselineApiProvider);
    if (token == null || api == null) return;
    unawaited(api.updateNtrp(token, code));
  }

  void setCity(String city) {
    final trimmed = city.trim();
    if (trimmed.isEmpty || trimmed == state.city) return;
    _commit(state.copyWith(city: trimmed));
  }

  void setGoal(String goal) => _commit(state.copyWith(goal: goal));

  void setDaysPerWeek(int days) => _commit(state.copyWith(daysPerWeek: days));

  void finishOnboarding() => _commit(state.copyWith(onboardingComplete: true));

  void setGivenName(String name) {
    final first = name.trim().split(RegExp(r'\s+')).first;
    if (first.isEmpty) return;
    _commit(state.copyWith(givenName: first));
  }

  String? _nameFromSignIn(String? givenName, String? email) {
    final typed = givenName?.trim();
    if (typed != null && typed.isNotEmpty) return typed;
    if (email == null) return state.givenName;
    return firstNameFromEmail(email) ?? state.givenName;
  }

  void signOut() {
    pendingEmail = null;
    signupToken = null;
    _remoteEmail = false;
    ref.read(authGatewayProvider).clearPending();
    _commit(const PlayerSession());
  }

  void deleteAccount() {
    final token = state.accessToken;
    final api = ref.read(baselineApiProvider);
    if (token != null && api != null) unawaited(api.deleteAccount(token));
    pendingEmail = null;
    signupToken = null;
    _remoteEmail = false;
    ref.read(authGatewayProvider).clearPending();
    _commit(const PlayerSession());
  }

  void _keepRemote(RemoteAuth? remote) {
    if (remote == null) return;
    if (remote.signupToken != null) signupToken = remote.signupToken;
    if (remote.accessToken == null || remote.refreshToken == null) return;
    _commit(
      state.copyWith(
        accessToken: remote.accessToken,
        refreshToken: remote.refreshToken,
      ),
    );
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
