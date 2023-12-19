import 'package:flutter_test/flutter_test.dart';
import 'package:capture_screenshot/capture_screenshot.dart';
import 'package:capture_screenshot/capture_screenshot_platform_interface.dart';
import 'package:capture_screenshot/capture_screenshot_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCaptureScreenshotPlatform
    with MockPlatformInterfaceMixin
    implements CaptureScreenshotPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CaptureScreenshotPlatform initialPlatform = CaptureScreenshotPlatform.instance;

  test('$MethodChannelCaptureScreenshot is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCaptureScreenshot>());
  });

  test('getPlatformVersion', () async {
    CaptureScreenshot captureScreenshotPlugin = CaptureScreenshot();
    MockCaptureScreenshotPlatform fakePlatform = MockCaptureScreenshotPlatform();
    CaptureScreenshotPlatform.instance = fakePlatform;

    expect(await captureScreenshotPlugin.getPlatformVersion(), '42');
  });
}
