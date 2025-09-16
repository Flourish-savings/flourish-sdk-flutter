import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flourish_sdk_flutter_method_channel.dart';

abstract class FlourishSdkFlutterPlatform extends PlatformInterface {
  /// Constructs a FlourishSdkFlutterPlatform.
  FlourishSdkFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlourishSdkFlutterPlatform _instance = MethodChannelFlourishSdkFlutter();

  /// The default instance of [FlourishSdkFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlourishSdkFlutter].
  static FlourishSdkFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlourishSdkFlutterPlatform] when
  /// they register themselves.
  static set instance(FlourishSdkFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
