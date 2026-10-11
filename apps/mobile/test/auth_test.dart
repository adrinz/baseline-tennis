import 'package:baseline/data/auth_gateway.dart';
import 'package:baseline/data/email_codes.dart';
import 'package:baseline/state/player_session.dart';
import 'package:baseline/state/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CapturingMailer implements EmailCodeMailer {
  String? lastCode;

  @override
  Future<String?> send({required String code}) async {
    lastCode = code;
    return null;
  }
}

class _ScriptedGateway implements AuthGateway {
  AuthAttempt next = const AuthCancelled();

  @override
  Future<AuthAttempt> signInWithApple() async => next;

  @override
  Future<AuthAttempt> signInWithGoogle() async => next;

  @override
  Future<String?> sendEmailCode(String email) async => null;

  @override
  String? checkEmailCode(String email, String code) => 'Request a new code.';

  @override
  void clearPending() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('a code is accepted once and any other code is rejected', () async {
    final mailer = _CapturingMailer();
    final container = ProviderContainer(
      overrides: [
        authGatewayProvider.overrideWith(
          (ref) => DeviceAuthGateway(
            mailer: mailer,
            codes: EmailCodeChallenge(nextCode: () => '482913'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final session = container.read(sessionProvider.notifier);

    expect(await session.startEmail('Ada@Example.com'), isNull);
    expect(container.read(sessionProvider).signedIn, isFalse);
    expect(mailer.lastCode, '482913');

    expect(await session.verifyEmailCode('000000'), isNotNull);
    expect(container.read(sessionProvider).signedIn, isFalse);
    expect(await session.verifyEmailCode('abcdef'), isNotNull);

    expect(await session.verifyEmailCode(mailer.lastCode!), isNull);
    final signedIn = container.read(sessionProvider);
    expect(signedIn.authProvider, AuthProvider.email);
    expect(signedIn.email, 'Ada@Example.com');
    expect(signedIn.givenName, 'Ada');
    expect(signedIn.subject, 'ada@example.com');

    expect(await session.verifyEmailCode(mailer.lastCode!), isNotNull);
  });

  test('an expired code is rejected', () {
    var now = DateTime(2026, 9, 30, 12);
    final codes = EmailCodeChallenge(
      clock: () => now,
      nextCode: () => '123456',
    );
    expect(codes.issue('player@example.com'), '123456');
    now = now.add(const Duration(minutes: 11));
    expect(
      codes.rejectReason('player@example.com', '123456'),
      'Request a new code.',
    );
  });

  test('five wrong attempts require a new code', () {
    final codes = EmailCodeChallenge(nextCode: () => '123456');
    codes.issue('player@example.com');
    for (var attempt = 0; attempt < 4; attempt++) {
      expect(codes.rejectReason('player@example.com', '000000'), contains("doesn't match"));
    }
    expect(
      codes.rejectReason('player@example.com', '000000'),
      "That code doesn't match. Request a new one.",
    );
    expect(codes.rejectReason('player@example.com', '123456'), 'Request a new code.');
  });

  test('cancelling Apple or Google does not start a session', () async {
    final gateway = _ScriptedGateway();
    final container = ProviderContainer(
      overrides: [
        authGatewayProvider.overrideWith((ref) => gateway),
      ],
    );
    addTearDown(container.dispose);
    final session = container.read(sessionProvider.notifier);

    expect(await session.signInWithProvider(AuthProvider.apple), isA<AuthCancelled>());
    expect(await session.signInWithProvider(AuthProvider.google), isA<AuthCancelled>());
    expect(container.read(sessionProvider).signedIn, isFalse);

    gateway.next = const AuthSucceeded(
      SignedInAccount(
        provider: AuthProvider.apple,
        subject: 'apple-user',
        email: 'ada@icloud.com',
        givenName: 'Ada',
      ),
    );
    expect(await session.signInWithProvider(AuthProvider.apple), isA<AuthSucceeded>());
    final signedIn = container.read(sessionProvider);
    expect(signedIn.authProvider, AuthProvider.apple);
    expect(signedIn.subject, 'apple-user');
    expect(signedIn.givenName, 'Ada');
    expect(signedIn.email, 'ada@icloud.com');
  });

  test('a second code request waits 30 seconds', () async {
    var now = DateTime(2026, 9, 30, 12);
    final container = ProviderContainer(
      overrides: [
        authGatewayProvider.overrideWith(
          (ref) => DeviceAuthGateway(
            mailer: _CapturingMailer(),
            clock: () => now,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final session = container.read(sessionProvider.notifier);

    expect(await session.startEmail('ada@example.com'), isNull);
    expect(await session.startEmail('ada@example.com'), contains('Wait'));
    now = now.add(const Duration(seconds: 30));
    expect(await session.startEmail('ada@example.com'), isNull);
  });
}
