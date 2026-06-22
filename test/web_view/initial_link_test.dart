import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';

void main() {
  group('buildInitialLink', () {
    test('always includes token and lang', () {
      final uri = buildInitialLink(
        platformUrl: 'app.flourish.test',
        token: 'abc123',
        langCode: 'es',
      );
      expect(uri.scheme, 'https');
      expect(uri.host, 'app.flourish.test');
      expect(uri.queryParameters['token'], 'abc123');
      expect(uri.queryParameters['lang'], 'es');
    });

    test('omits redirectTo and resourceId when not provided', () {
      final uri = buildInitialLink(
        platformUrl: 'app.flourish.test',
        token: 'abc123',
        langCode: 'es',
      );
      expect(uri.queryParameters.containsKey('redirectTo'), isFalse);
      expect(uri.queryParameters.containsKey('resourceId'), isFalse);
    });

    test('appends redirectTo and resourceId when provided', () {
      final uri = buildInitialLink(
        platformUrl: 'app.flourish.test',
        token: 'abc123',
        langCode: 'es',
        redirectTo: 'PARTNER_STORE_DETAIL',
        resourceId: '123',
      );
      expect(uri.queryParameters['redirectTo'], 'PARTNER_STORE_DETAIL');
      expect(uri.queryParameters['resourceId'], '123');
    });

    test('appends redirectTo alone (static route, no resourceId)', () {
      final uri = buildInitialLink(
        platformUrl: 'app.flourish.test',
        token: 'abc123',
        langCode: 'es',
        redirectTo: 'CASHBACK',
      );
      expect(uri.queryParameters['redirectTo'], 'CASHBACK');
      expect(uri.queryParameters.containsKey('resourceId'), isFalse);
    });

    test('treats empty strings as absent', () {
      final uri = buildInitialLink(
        platformUrl: 'app.flourish.test',
        token: 'abc123',
        langCode: 'es',
        redirectTo: '',
        resourceId: '',
      );
      expect(uri.queryParameters.containsKey('redirectTo'), isFalse);
      expect(uri.queryParameters.containsKey('resourceId'), isFalse);
    });

    test('defaults to https', () {
      final uri = buildInitialLink(
        platformUrl: 'app.flourish.test',
        token: 'abc123',
        langCode: 'es',
      );
      expect(uri.scheme, 'https');
    });

    test('uses http when useHttp is true', () {
      final uri = buildInitialLink(
        platformUrl: 'localhost:5173',
        token: 'abc123',
        langCode: 'es',
        useHttp: true,
      );
      expect(uri.scheme, 'http');
      expect(uri.host, 'localhost');
      expect(uri.port, 5173);
    });
  });
}
