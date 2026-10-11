import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// One-time email codes. The plaintext code is returned only to the mailer.
class EmailCodeChallenge {
  EmailCodeChallenge({DateTime Function()? clock, String Function()? nextCode})
    : _clock = clock ?? DateTime.now,
      _nextCode = nextCode ?? secureSixDigitCode;

  static const lifetime = Duration(minutes: 10);
  static const maxAttempts = 5;

  final DateTime Function() _clock;
  final String Function() _nextCode;
  final Map<String, _PendingCode> _pending = {};

  String issue(String email) {
    final normalized = _normalize(email);
    final code = _nextCode();
    _pending[normalized] = _PendingCode(
      hash: _hash(normalized, code),
      expiresAt: _clock().add(lifetime),
    );
    return code;
  }

  void revoke(String email) {
    _pending.remove(_normalize(email));
  }

  void clear() {
    _pending.clear();
  }

  /// Null when the code matches. The match can be used once.
  String? rejectReason(String email, String code) {
    final normalized = _normalize(email);
    final pending = _pending[normalized];
    if (pending == null || !pending.expiresAt.isAfter(_clock())) {
      _pending.remove(normalized);
      return 'Request a new code.';
    }
    final digits = code.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(digits)) {
      return 'Enter the 6-digit code.';
    }
    pending.attempts += 1;
    if (!_matches(_hash(normalized, digits), pending.hash)) {
      if (pending.attempts >= maxAttempts) {
        _pending.remove(normalized);
        return "That code doesn't match. Request a new one.";
      }
      return "That code doesn't match.";
    }
    _pending.remove(normalized);
    return null;
  }

  static String _normalize(String email) => email.trim().toLowerCase();

  static String _hash(String email, String code) {
    return sha256.convert(utf8.encode('$email:$code')).toString();
  }

  static bool _matches(String presented, String expected) {
    if (presented.length != expected.length) return false;
    var difference = 0;
    for (var index = 0; index < presented.length; index++) {
      difference |= presented.codeUnitAt(index) ^ expected.codeUnitAt(index);
    }
    return difference == 0;
  }
}

String secureSixDigitCode() {
  final random = Random.secure();
  final digits = StringBuffer();
  for (var index = 0; index < 6; index++) {
    digits.write(random.nextInt(10));
  }
  return digits.toString();
}

class _PendingCode {
  _PendingCode({required this.hash, required this.expiresAt});

  final String hash;
  final DateTime expiresAt;
  int attempts = 0;
}
