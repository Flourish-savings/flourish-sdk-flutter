import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';

void main() {
  // `debugStaticToken` skips the auth backend, so these run without any network
  // mocking. They guard the scheme-selection fix: HTTP is driven by the debug
  // base URL's scheme, NOT by `Environment.development` alone.
  group('Flourish debug overrides (local dev)', () {
    test('static token + http base → local host loaded over http', () async {
      final flourish = await Flourish.create(
        uuid: 'u',
        secret: 's',
        env: Environment.development,
        language: Language.spanish,
        customerCode: 'c',
        debugBaseUrl: 'http://localhost:5173',
        debugStaticToken: 'local_dev_token',
      );

      expect(flourish.token, 'local_dev_token');
      expect(flourish.url, 'localhost:5173');
      expect(flourish.useHttp, isTrue);
    });

    test('https base is not downgraded to http (Issue 1 regression)', () async {
      final flourish = await Flourish.create(
        uuid: 'u',
        secret: 's',
        env: Environment.development,
        language: Language.spanish,
        customerCode: 'c',
        debugBaseUrl: 'https://platform-stg.flourishfi.com',
        debugStaticToken: 'tok',
      );

      expect(flourish.url, 'platform-stg.flourishfi.com');
      expect(flourish.useHttp, isFalse);
    });
  });
}
