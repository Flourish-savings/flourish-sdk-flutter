import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/flourish_flutter_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('flourish_flutter_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlourishFlutterSdk.platformVersion, '42');
  });
}
