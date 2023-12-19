# capture_screenshot

A Flutter plugin for capturing full screenshots on Android.

iOS is not supported because it is not possible to capture full screenshots on iOS.

# Usage

See the example app under `example/` for a complete demo.

```dart
try {
  // Adjust the delayInMilliseconds to suit your needs
  final imageBytes = await _captureScreenshotPlugin.captureScreenshot(
      delayInMilliseconds: 200);
  // imageBytes will be null if fails to take a screenshot
  // On success, imageBytes will contain the bytes of the screenshot image in PNG format
  if (imageBytes != null) {
    screenshot = Image.memory(imageBytes);
    print("Successfully taken a screenshot!");
  } else {
    print("Failed to take a screenshot!");
  }
} on PlatformException catch (e) {
  print("Failed to take a screenshot!");
  print(e);
  screenshot = null;
}
```

# Caveats
On Android 14 (API level 34), the user will be prompted to give consent before each taking screenshot.

See the following links for more information:
* https://developer.android.com/about/versions/14/behavior-changes-14#media-projection-consent
* https://stackoverflow.com/questions/76804553/reusing-media-projection-intent-on-android-14

# Inspiration
* media_projection_screenshot plugin by liasica: https://pub.dev/packages/media_projection_screenshot

# License
MIT License
