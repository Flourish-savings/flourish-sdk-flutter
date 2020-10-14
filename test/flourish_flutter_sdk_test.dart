import 'package:flutter_test/flutter_test.dart';

void main() {
  // Flourish flourish;

  // setUp(() {
  //   flourish = Flourish.initialize(
  //     apiKey: 'key',
  //     env: Environment.development,
  //   );
  // });

  // tearDown(() {
  //   flourish = null;
  // });

  test('certify that the webview is not initialized before auth', () async {
    // expect(
    //   flourish.webviewContainer(),
    //   isNull,
    // );
  });

  // test('authenticate the client', () async {
  //   expect(
  //     await flourish.authenticate(
  //       userId: 'id',
  //       secretKey: 'random_string',
  //     ),
  //     'key',
  //   );
  // });

  // test('authenticate the client and open the dasboard', () async {
  //   await flourish.authenticateAndOpenDashboard(
  //     userId: 'id',
  //     secretKey: 'random_string',
  //   );
  //   expect(flourish.webviewContainer(), isNotNull);
  // });

  // test('assert that only one instance can be created', () async {
  //   Flourish instance2 = Flourish.initialize(
  //     apiKey: 'key1',
  //     env: Environment.development,
  //   );
  //   expect(
  //     identical(
  //       instance2,
  //       flourish,
  //     ),
  //     true,
  //   );
  // });

  // test('assert that the instance is assigning the correct env', () async {
  //   expect(
  //     flourish.webviewContainer().url,
  //     equals("https://flourish-engine.herokuapp.com/webviews/dashboard/50"),
  //   );
  // });
}
