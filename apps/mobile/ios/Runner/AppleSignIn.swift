import AuthenticationServices
import Flutter
import UIKit

/// Presents Sign in with Apple and returns the Apple user id, name, and email.
final class AppleSignInChannel: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  static let shared = AppleSignInChannel()

  private var pending: FlutterResult?
  private var controller: ASAuthorizationController?

  static func register(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "BaselineAppleSignIn") else { return }
    let channel = FlutterMethodChannel(
      name: "baseline/apple_sign_in",
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
    pending = result
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName, .email]
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    self.controller = controller
    controller.performRequests()
  }

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
          !credential.user.isEmpty else {
      finish(["ok": false, "cancelled": false, "message": "That didn't sign you in. Try again or use email."])
      return
    }
    finish([
      "ok": true,
      "cancelled": false,
      "subject": credential.user,
      "givenName": credential.fullName?.givenName ?? "",
      "email": credential.email ?? "",
      "identityToken": credential.identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? "",
    ])
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    let code = (error as NSError).code
    if code == ASAuthorizationError.canceled.rawValue {
      finish(["ok": false, "cancelled": true])
      return
    }
    let message: String
    if code == ASAuthorizationError.unknown.rawValue || code == ASAuthorizationError.notHandled.rawValue {
      message = "Sign in with Apple could not start. Enable it for this app in the Apple developer account, then install the app again."
    } else {
      message = "That didn't sign you in. Try again or use email."
    }
    finish(["ok": false, "cancelled": false, "message": message])
  }

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window = scenes.flatMap(\.windows).first { $0.isKeyWindow }
    return window ?? ASPresentationAnchor()
  }

  private func finish(_ value: [String: Any]) {
    let result = pending
    pending = nil
    controller = nil
    DispatchQueue.main.async {
      result?(value)
    }
  }
}
