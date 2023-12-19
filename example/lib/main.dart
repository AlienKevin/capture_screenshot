import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:capture_screenshot/capture_screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Image? _screenshot;
  final _captureScreenshotPlugin = CaptureScreenshot();

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> captureScreenshot() async {
    Image? screenshot;

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      // Adjust the delayInMilliseconds to suit your needs
      final imageBytes = await _captureScreenshotPlugin.captureScreenshot(
          delayInMilliseconds: 200);
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

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _screenshot = screenshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('capture_screenshot example app'),
        ),
        body: Center(
            child: Column(
          children: [
            TextButton(
              child: const Text('Capture Screenshot'),
              onPressed: () {
                print("Capturing screenshot...");
                captureScreenshot();
              },
            ),
            _screenshot != null ? Expanded(child: _screenshot!) : Container(),
          ],
        )),
      ),
    );
  }
}
