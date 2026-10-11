import AuthenticationServices
import CryptoKit
import Flutter
import Security
import UIKit

/// Opens Google's account screen and accepts the sign-in only after Google
/// returns an ID token for this app.
final class GoogleSignInChannel: NSObject, ASWebAuthenticationPresentationContextProviding {
  static let shared = GoogleSignInChannel()

  private var pending: FlutterResult?
  private var session: ASWebAuthenticationSession?

  static func register(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "BaselineGoogleSignIn") else { return }
    let channel = FlutterMethodChannel(
      name: "baseline/google_sign_in",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "signIn" else {
        result(FlutterMethodNotImplemented)
        return
      }
      DispatchQueue.main.async {
        shared.start(result: result)
      }
    }
  }

  private func start(result: @escaping FlutterResult) {
    if pending != nil {
      result(["ok": false, "cancelled": true])
      return
    }
    let clientID = (Bundle.main.object(forInfoDictionaryKey: "BaselineGoogleClientID") as? String)?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    guard let scheme = reversedScheme(clientID), bundleHasScheme(scheme) else {
      result([
        "ok": false,
        "cancelled": false,
        "message": "Google sign-in is not set up on this build yet. Use Apple or an email code.",
      ])
      return
    }

    let verifier = randomVerifier()
    var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")
    components?.queryItems = [
      URLQueryItem(name: "client_id", value: clientID),
      URLQueryItem(name: "redirect_uri", value: "\(scheme):/oauth2redirect"),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: "openid email profile"),
      URLQueryItem(name: "code_challenge", value: codeChallenge(verifier)),
      URLQueryItem(name: "code_challenge_method", value: "S256"),
      URLQueryItem(name: "prompt", value: "select_account"),
    ]
    guard let url = components?.url else {
      result(["ok": false, "cancelled": false, "message": "Google sign-in could not start. Try again or use email."])
      return
    }

    pending = result
    let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme) { callback, error in
      if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
        self.finish(["ok": false, "cancelled": true])
        return
      }
      guard let code = callback.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "code" }?.value }),
            !code.isEmpty else {
        self.finish(["ok": false, "cancelled": false, "message": "That didn't sign you in. Try again or use email."])
        return
      }
      self.exchange(
        code: code,
        verifier: verifier,
        clientID: clientID,
        redirectURI: "\(scheme):/oauth2redirect"
      )
    }
    session.presentationContextProvider = self
    session.prefersEphemeralWebBrowserSession = false
    self.session = session
    if !session.start() {
      finish(["ok": false, "cancelled": false, "message": "Google sign-in could not start. Try again or use email."])
    }
  }

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first { $0.isKeyWindow }
    return window ?? ASPresentationAnchor()
  }

  private func exchange(code: String, verifier: String, clientID: String, redirectURI: String) {
    var request = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    let body = [
      "code": code,
      "client_id": clientID,
      "code_verifier": verifier,
      "redirect_uri": redirectURI,
      "grant_type": "authorization_code",
    ]
    request.httpBody = formEncode(body).data(using: .utf8)
    URLSession.shared.dataTask(with: request) { data, _, _ in
      let account = data.flatMap { self.account(from: $0, clientID: clientID) }
      if let account {
        self.finish(account)
      } else {
        self.finish(["ok": false, "cancelled": false, "message": "That didn't sign you in. Try again or use email."])
      }
    }.resume()
  }

  private func account(from data: Data, clientID: String) -> [String: Any]? {
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let idToken = json["id_token"] as? String,
          let payload = jwtPayload(idToken) else {
      return nil
    }
    let subject = (payload["sub"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let issuer = payload["iss"] as? String
    let expiry = (payload["exp"] as? NSNumber)?.doubleValue ?? 0
    let audience = payload["aud"]
    let audienceMatches = (audience as? String) == clientID || (audience as? [String])?.contains(clientID) == true
    let issuerMatches = issuer == "https://accounts.google.com" || issuer == "accounts.google.com"
    guard !subject.isEmpty, audienceMatches, issuerMatches, expiry > Date().timeIntervalSince1970 else {
      return nil
    }
    return [
      "ok": true,
      "cancelled": false,
      "subject": subject,
      "email": payload["email"] as? String ?? "",
      "givenName": payload["given_name"] as? String ?? "",
      "identityToken": idToken,
    ]
  }

  private func finish(_ value: [String: Any]) {
    let result = pending
    pending = nil
    session = nil
    DispatchQueue.main.async {
      result?(value)
    }
  }
}

private func reversedScheme(_ clientID: String) -> String? {
  let suffix = ".apps.googleusercontent.com"
  guard clientID.hasSuffix(suffix), clientID.count > suffix.count else { return nil }
  let prefix = clientID.dropLast(suffix.count)
  guard !prefix.isEmpty else { return nil }
  return "com.googleusercontent.apps.\(prefix)"
}

private func bundleHasScheme(_ scheme: String) -> Bool {
  let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] ?? []
  return types.contains { type in
    let schemes = type["CFBundleURLSchemes"] as? [String] ?? []
    return schemes.contains(scheme)
  }
}

private func randomVerifier() -> String {
  var bytes = [UInt8](repeating: 0, count: 32)
  let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
  if status != errSecSuccess {
    bytes = (0..<32).map { _ in UInt8.random(in: 0...255) }
  }
  return Data(bytes).base64EncodedString()
    .replacingOccurrences(of: "+", with: "-")
    .replacingOccurrences(of: "/", with: "_")
    .replacingOccurrences(of: "=", with: "")
}

private func codeChallenge(_ verifier: String) -> String {
  let digest = SHA256.hash(data: Data(verifier.utf8))
  return Data(digest).base64EncodedString()
    .replacingOccurrences(of: "+", with: "-")
    .replacingOccurrences(of: "/", with: "_")
    .replacingOccurrences(of: "=", with: "")
}

private func formEncode(_ items: [String: String]) -> String {
  let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
  return items.map { key, value in
    let encoded = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    return "\(key)=\(encoded)"
  }.joined(separator: "&")
}

private func jwtPayload(_ token: String) -> [String: Any]? {
  let parts = token.split(separator: ".")
  guard parts.count >= 2 else { return nil }
  var payload = String(parts[1])
    .replacingOccurrences(of: "-", with: "+")
    .replacingOccurrences(of: "_", with: "/")
  let remainder = payload.count % 4
  if remainder > 0 {
    payload += String(repeating: "=", count: 4 - remainder)
  }
  guard let data = Data(base64Encoded: payload),
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
    return nil
  }
  return json
}
