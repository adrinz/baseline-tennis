import Flutter
import UIKit
import UserNotifications

/// Shows the one-time code in a notification. The code is not written to the log.
final class EmailCodeChannel: NSObject, UNUserNotificationCenterDelegate {
  static let shared = EmailCodeChannel()

  static func register(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "BaselineEmailCode") else { return }
    let channel = FlutterMethodChannel(
      name: "baseline/email_code",
      binaryMessenger: registrar.messenger()
    )
    UNUserNotificationCenter.current().delegate = shared
    channel.setMethodCallHandler { call, result in
      guard call.method == "deliver" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let code = ((call.arguments as? [String: Any])?["code"] as? String) ?? ""
      guard code.count == 6, code.allSatisfy(\.isNumber) else {
        result(["ok": false, "message": "Baseline could not deliver a code."])
        return
      }
      shared.deliver(code: code, result: result)
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .list, .sound])
  }

  private func deliver(code: String, result: @escaping FlutterResult) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
      guard granted else {
        DispatchQueue.main.async {
          result([
            "ok": false,
            "message": "Allow notifications so Baseline can show your sign-in code.",
          ])
        }
        return
      }
      let content = UNMutableNotificationContent()
      content.title = "Baseline sign-in code"
      content.body = "Your code is \(code). It expires in 10 minutes."
      content.sound = .default
      let request = UNNotificationRequest(
        identifier: "baseline.email-code",
        content: content,
        trigger: nil
      )
      center.add(request) { error in
        DispatchQueue.main.async {
          if error == nil {
            result(["ok": true])
          } else {
            result(["ok": false, "message": "Baseline could not deliver a code."])
          }
        }
      }
    }
  }
}
