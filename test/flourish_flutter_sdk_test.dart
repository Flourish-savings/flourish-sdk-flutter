import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/flourish.dart';

void main() {
  Flourish flourish;

  setUp(() {
    flourish = Flourish.initialize(Environment.development);
  });

  tearDown(() {
    flourish = null;
  });

  test('authenticate the client', () async {
    expect(flourish.authenticate('id', 'random_string'), 'key');
  });

  test('authenticate the client and open the dasboard', () async {
    flourish.authenticateAndOpenDashboard('id', 'random_string');
    expect(flourish.webviewContainer(), isNotNull);
  });

  test('certify that the webview is not initialized before auth', () async {
    expect(flourish.webviewContainer(), isNull);
  });

  test('assert that only one instance can be created', () async {
    Flourish instance2 = Flourish.initialize(Environment.development);
    expect(identical(instance2, flourish), true);
  });
  test('assert that the instance is changing the environment attribute',
      () async {
    Flourish instance2 = Flourish.initialize(Environment.development);
    expect(instance2.environment, Environment.development);
  });
}
