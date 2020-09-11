import 'dart:async';

import 'package:flutter/services.dart';

class FlourishFlutterSdk {
  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
