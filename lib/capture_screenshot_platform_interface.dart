import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'capture_screenshot_method_channel.dart';

abstract class CaptureScreenshotPlatform extends PlatformInterface {
  /// Constructs a CaptureScreenshotPlatform.
  CaptureScreenshotPlatform() : super(token: _token);

  static final Object _token = Object();

  static CaptureScreenshotPlatform _instance = MethodChannelCaptureScreenshot();

  /// The default instance of [CaptureScreenshotPlatform] to use.
  ///
  /// Defaults to [MethodChannelCaptureScreenshot].
  static CaptureScreenshotPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CaptureScreenshotPlatform] when
  /// they register themselves.
  static set instance(CaptureScreenshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List?> captureScreenshot({int? delayInMilliseconds});
}
