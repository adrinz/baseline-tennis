import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:baseline/state/player_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The practice server on this Mac. The phone must be on the same Wi-Fi.
const macApiBase = 'http://Adrians-Mac-Mini.local:8787';

class RemoteAuth {
  const RemoteAuth({this.accessToken, this.refreshToken, this.signupToken});

  final String? accessToken;
  final String? refreshToken;
  final String? signupToken;
}

class BaselineApi {
  BaselineApi({this.baseUrl = macApiBase});

  final String baseUrl;

  Future<String?> startEmail(String email) async {
    final body = await _post('/v1/auth/email/start', {'email': email});
    final code = body?['previewCode'];
    if (code is String && code.length == 6) return code;
    return null;
  }

  Future<RemoteAuth?> finishEmail(String email, String code) async {
    final body = await _post('/v1/auth/email/finish', {'email': email, 'code': code});
    return _auth(body);
  }

  Future<RemoteAuth?> signIn({
    required AuthProvider provider,
    required String identityToken,
    String? givenName,
  }) async {
    final path = provider == AuthProvider.apple ? '/v1/auth/apple' : '/v1/auth/google';
    final payload = provider == AuthProvider.apple
        ? {'identityToken': identityToken, 'givenName': givenName}
        : {'idToken': identityToken, 'givenName': givenName};
    return _auth(await _post(path, payload));
  }

  Future<RemoteAuth?> complete({
    required String signupToken,
    required int birthYear,
    String? displayName,
  }) async {
    return _auth(
      await _post('/v1/auth/complete', {
        'signupToken': signupToken,
        'birthYear': birthYear,
        'displayName': displayName,
      }),
    );
  }

  Future<void> updateNtrp(String accessToken, String? code) async {
    await _send(
      'PUT',
      '/v1/me/profile',
      {'ntrpCode': code},
      accessToken,
    );
  }

  Future<void> deleteAccount(String accessToken) async {
    await _send('DELETE', '/v1/me', {'confirm': 'DELETE'}, accessToken);
  }

  RemoteAuth? _auth(Map<String, dynamic>? body) {
    if (body == null) return null;
    final signup = body['signupToken'];
    if (signup is String && signup.isNotEmpty) {
      return RemoteAuth(signupToken: signup);
    }
    final access = body['accessToken'];
    final refresh = body['refreshToken'];
    if (access is String && refresh is String) {
      return RemoteAuth(accessToken: access, refreshToken: refresh);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _post(String path, Map<String, Object?> payload) {
    return _send('POST', path, payload, null);
  }

  Future<Map<String, dynamic>?> _send(
    String method,
    String path,
    Map<String, Object?> payload,
    String? accessToken,
  ) async {
    final client = HttpClient();
    try {
      final request = await client
          .openUrl(method, Uri.parse('$baseUrl$path'))
          .timeout(const Duration(seconds: 4));
      request.headers.contentType = ContentType.json;
      if (accessToken != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      }
      request.write(jsonEncode(payload));
      final response = await request.close().timeout(const Duration(seconds: 6));
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}

final baselineApiProvider = Provider<BaselineApi?>((ref) => null);
