import Flutter
import UIKit
import NidThirdPartyLogin

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // MARK - Naver SDK 초기화
    let naverClientId = "RRsdQ2Zd8sI2E6X8MZTJ"
    let naverClientSecret = "_iEJqJh0EU"
    let naverServiceAppName = "청약계산소"
    let naverUrlScheme = "com.jaystar.chungyakbox"

    // 초기화
    NidOAuth.shared.initialize(
      appName: naverServiceAppName,      
      clientId: naverClientId,
      clientSecret: naverClientSecret,
      urlScheme: naverUrlScheme
    )
    // 로그인 시 동작 설정
    NidOAuth.shared.setLoginBehavior(.appPreferredWithInAppBrowserFallback)


    // MARK - Method Channel 설정
    guard let contoller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }

    let channel = FlutterMethodChannel(name: "com.chungyakbox/auth", binaryMessenger: contoller.binaryMessenger)

    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "signInWithNaver" else {
        result(FlutterMethodNotImplemented)
        return
      }

      NidOAuth.shared.requestLogin { loginResult in
        switch loginResult {
        case .success(let accessToken):
          result(accessToken.accessToken.tokenString)
        case .failure(let error):
          result(FlutterError(
            code: "NAVER_LOGIN_FAILURE", 
            message: error.description, details: nil
            )
          )
        }
      }
    })


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - URL Scheme을 통한 콜백 처리
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if NidOAuth.shared.handleURL(url) {
      return true
    }

    return super.application(app, open: url, options: options)
  }

}
