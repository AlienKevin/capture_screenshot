import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_projection_creator/media_projection_creator.dart';

import 'capture_screenshot_platform_interface.dart';

/// An implementation of [CaptureScreenshotPlatform] that uses method channels.
class MethodChannelCaptureScreenshot extends CaptureScreenshotPlatform {
  static bool _isGranted = false;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('li.kevinx.capture_screenshot/method');

  /// request permission
  /// return [int] errorCode
  /// 0: succeed
  /// 1: user canceled
  /// 2: system version too low
  Future<int> requestPermission() async {
    if (!_isGranted) {
      int errorCode = await MediaProjectionCreator.createMediaProjection();
      if (errorCode == MediaProjectionCreator.ERROR_CODE_SUCCEED) {
        _isGranted = true;
      }
      return errorCode;
    }
    return 0;
  }

  @override
  Future<Uint8List?> captureScreenshot({int? delayInMilliseconds}) async {
    await requestPermission();
    if (!_isGranted) {
      return null;
    }
    final Uint8List screenshot = await methodChannel.invokeMethod('captureScreenshot', {"delayInMilliseconds": delayInMilliseconds});
    return screenshot;
  }
}
