
import 'dart:typed_data';

import 'capture_screenshot_platform_interface.dart';

class CaptureScreenshot {
  Future<Uint8List?> captureScreenshot() {
    return CaptureScreenshotPlatform.instance.captureScreenshot();
  }
}
