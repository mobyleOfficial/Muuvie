import Flutter
import UIKit
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WebviewCookies") {
      registerWebviewCookiesChannel(messenger: registrar.messenger())
    }
  }

  /// The WKWebView cookie jar, including HttpOnly cookies that `document.cookie` cannot see.
  private func registerWebviewCookiesChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "muuvie/webview_cookies", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "getCookies" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any],
            let url = args["url"] as? String,
            let host = URL(string: url)?.host else {
        result(FlutterError(code: "missing_url", message: "url is required", details: nil))
        return
      }
      WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
        let header = cookies
          .filter { cookie in
            let domain = cookie.domain.hasPrefix(".") ? String(cookie.domain.dropFirst()) : cookie.domain
            return host == domain || host.hasSuffix("." + domain)
          }
          .map { "\($0.name)=\($0.value)" }
          .joined(separator: "; ")
        result(header)
      }
    }
  }
}
