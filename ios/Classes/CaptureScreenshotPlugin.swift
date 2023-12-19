import Flutter
import UIKit

public class CaptureScreenshotPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "capture_screenshot", binaryMessenger: registrar.messenger())
    let instance = CaptureScreenshotPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "captureScreenshot":
      var screenshotData: Data?
      UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
      if let context = UIGraphicsGetCurrentContext() {
        UIApplication.shared.windows.first?.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        screenshotData = image?.pngData()
      }
      UIGraphicsEndImageContext()
      result(screenshotData)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
