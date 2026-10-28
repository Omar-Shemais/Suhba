import 'package:flutter/services.dart';

class NativeRadioService {
  static const MethodChannel _channel = MethodChannel('com.islamic_app/radio');

  // Callback for when iOS control center buttons are pressed
  Function(String action)? onControlCenterAction;

  NativeRadioService() {
    // Listen for callbacks from iOS
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPlay':
          onControlCenterAction?.call('play');
          break;
        case 'onPause':
          onControlCenterAction?.call('pause');
          break;
        case 'onStop':
          onControlCenterAction?.call('stop');
          break;
      }
    });
  }

  Future<void> play({
    required String url,
    required String title,
    String desc = "Islamic App",
  }) async {
    try {
      await _channel.invokeMethod('play', {
        'url': url,
        'title': title,
        'desc': desc,
      });
    } on PlatformException catch (e) {
      print("Error playing native audio: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _channel.invokeMethod('pause');
    } catch (e) {
      print("Error pausing native audio: $e");
    }
  }

  Future<void> resume() async {
    try {
      await _channel.invokeMethod('resume');
    } catch (e) {
      print("Error resuming native audio: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (e) {
      print("Error stopping native audio: $e");
    }
  }
}
