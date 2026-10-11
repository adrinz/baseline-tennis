import 'package:baseline/data/email_codes.dart';
import 'package:baseline/state/player_session.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignedInAccount {
  const SignedInAccount({
    required this.provider,
    required this.subject,
    this.email,
    this.givenName,
    this.identityToken,
  });

  final AuthProvider provider;
  final String subject;
  final String? email;
  final String? givenName;
  final String? identityToken;
}

sealed class AuthAttempt {
  const AuthAttempt();
}

final class AuthSucceeded extends AuthAttempt {
  const AuthSucceeded(this.account);

  final SignedInAccount account;
}

final class AuthCancelled extends AuthAttempt {
  const AuthCancelled();
}

final class AuthRejected extends AuthAttempt {
  const AuthRejected(this.message);

  final String message;
}

abstract class EmailCodeMailer {
  Future<String?> send({required String code});
}

abstract class AuthGateway {
  Future<AuthAttempt> signInWithApple();

  Future<AuthAttempt> signInWithGoogle();

  Future<String?> sendEmailCode(String email);

  String? checkEmailCode(String email, String code);

  void clearPending();
}

const _signInFailed = "That didn't sign you in. Try again or use email.";

class DeviceAuthGateway implements AuthGateway {
  DeviceAuthGateway({
    EmailCodeChallenge? codes,
    EmailCodeMailer? mailer,
    DateTime Function()? clock,
    Future<AuthAttempt> Function()? apple,
    Future<AuthAttempt> Function()? google,
  }) : _codes = codes ?? EmailCodeChallenge(),
       _mailer = mailer ?? NotificationEmailCodeMailer(),
       _clock = clock ?? DateTime.now,
       _apple = apple ?? _appleSignIn,
       _google = google ?? _googleSignIn;

  static const resendWait = Duration(seconds: 30);

  final EmailCodeChallenge _codes;
  final EmailCodeMailer _mailer;
  final DateTime Function() _clock;
  final Future<AuthAttempt> Function() _apple;
  final Future<AuthAttempt> Function() _google;
  DateTime? _nextSendAt;

  @override
  Future<AuthAttempt> signInWithApple() => _apple();

  @override
  Future<AuthAttempt> signInWithGoogle() => _google();

  @override
  Future<String?> sendEmailCode(String email) async {
    final now = _clock();
    final next = _nextSendAt;
    if (next != null && now.isBefore(next)) {
      final seconds = next.difference(now).inSeconds.clamp(1, 30);
      return 'Wait $seconds seconds, then request another code.';
    }
    final code = _codes.issue(email);
    final failure = await _mailer.send(code: code);
    if (failure != null) {
      _codes.revoke(email);
      return failure;
    }
    _nextSendAt = now.add(resendWait);
    return null;
  }

  @override
  String? checkEmailCode(String email, String code) {
    return _codes.rejectReason(email, code);
  }

  @override
  void clearPending() {
    _codes.clear();
    _nextSendAt = null;
  }
}

const _appleChannel = MethodChannel('baseline/apple_sign_in');
const _googleChannel = MethodChannel('baseline/google_sign_in');
const _emailChannel = MethodChannel('baseline/email_code');

Future<AuthAttempt> _appleSignIn() {
  return _providerSignIn(
    channel: _appleChannel,
    provider: AuthProvider.apple,
    fallback: 'Sign in with Apple could not start. Try again or use email.',
  );
}

Future<AuthAttempt> _googleSignIn() {
  return _providerSignIn(
    channel: _googleChannel,
    provider: AuthProvider.google,
    fallback: 'Google sign-in could not start. Try again or use email.',
  );
}

Future<AuthAttempt> _providerSignIn({
  required MethodChannel channel,
  required AuthProvider provider,
  required String fallback,
}) async {
  try {
    final raw = await channel.invokeMapMethod<String, dynamic>('signIn');
    if (raw == null) return const AuthRejected(_signInFailed);
    if (raw['cancelled'] == true) return const AuthCancelled();
    if (raw['ok'] != true) {
      final message = (raw['message'] as String?)?.trim();
      return AuthRejected(
        message == null || message.isEmpty ? _signInFailed : message,
      );
    }
    final subject = (raw['subject'] as String?)?.trim() ?? '';
    if (subject.isEmpty) return const AuthRejected(_signInFailed);
    return AuthSucceeded(
      SignedInAccount(
        provider: provider,
        subject: subject,
        email: _blank(raw['email'] as String?),
        givenName: _blank(raw['givenName'] as String?),
        identityToken: _blank(raw['identityToken'] as String?),
      ),
    );
  } on MissingPluginException {
    return AuthRejected(fallback);
  } on PlatformException catch (error) {
    final message = error.message?.trim();
    return AuthRejected(
      message == null || message.isEmpty ? _signInFailed : message,
    );
  }
}

class NotificationEmailCodeMailer implements EmailCodeMailer {
  @override
  Future<String?> send({required String code}) async {
    try {
      final raw = await _emailChannel.invokeMapMethod<String, dynamic>(
        'deliver',
        {'code': code},
      );
      if (raw?['ok'] == true) return null;
      final message = (raw?['message'] as String?)?.trim();
      return message == null || message.isEmpty
          ? 'Baseline could not deliver a code.'
          : message;
    } on MissingPluginException {
      return 'Baseline could not deliver a code on this device.';
    } on PlatformException catch (error) {
      return error.message ?? 'Baseline could not deliver a code.';
    }
  }
}

String? _blank(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

final authGatewayProvider = Provider<AuthGateway>(
  (ref) => DeviceAuthGateway(),
);
