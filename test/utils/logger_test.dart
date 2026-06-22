import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/utils/logger.dart';

void main() {
  group('FlourishLog.redactUri', () {
    test('redacts the token query param', () {
      final uri = Uri.https('example.com', '/dashboard', {
        'token': 'super-secret',
        'lang': 'en',
      });
      final result = FlourishLog.redactUri(uri);
      expect(result, contains('token=%5BREDACTED%5D'));
      expect(result, isNot(contains('super-secret')));
      expect(result, contains('lang=en'));
    });

    test('redacts the apiToken query param', () {
      final uri = Uri.https('example.com', '/x', {'apiToken': 'abc123'});
      final result = FlourishLog.redactUri(uri);
      expect(result, isNot(contains('abc123')));
    });

    test('returns the URI unchanged when there are no query params', () {
      final uri = Uri.https('example.com', '/dashboard');
      expect(FlourishLog.redactUri(uri), uri.toString());
    });

    test('leaves non-sensitive params intact', () {
      final uri = Uri.https('example.com', '/x', {'lang': 'pt', 'foo': 'bar'});
      final result = FlourishLog.redactUri(uri);
      expect(result, contains('lang=pt'));
      expect(result, contains('foo=bar'));
      expect(result, isNot(contains('REDACTED')));
    });
  });
}
