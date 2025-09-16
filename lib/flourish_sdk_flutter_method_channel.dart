import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flourish_sdk_flutter_platform_interface.dart';

/// An implementation of [FlourishSdkFlutterPlatform] that uses method channels.
class MethodChannelFlourishSdkFlutter extends FlourishSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flourish_sdk_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
