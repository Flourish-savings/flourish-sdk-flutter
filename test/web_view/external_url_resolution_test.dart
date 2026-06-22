import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/web_view/external_url_resolution.dart';

void main() {
  group('resolveExternalUrl', () {
    test('launches http and https URLs', () {
      expect(
        resolveExternalUrl('http://store.example.com'),
        ExternalUrlDecision.launch,
      );
      expect(
        resolveExternalUrl('https://store.example.com/track?id=1'),
        ExternalUrlDecision.launch,
      );
    });

    test('treats an empty URL as empty', () {
      expect(resolveExternalUrl(''), ExternalUrlDecision.empty);
    });

    test('rejects non-http(s) schemes', () {
      expect(
        resolveExternalUrl('tel:+15551234567'),
        ExternalUrlDecision.disallowedScheme,
      );
      expect(
        resolveExternalUrl('mailto:someone@example.com'),
        ExternalUrlDecision.disallowedScheme,
      );
      expect(
        resolveExternalUrl('javascript:alert(1)'),
        ExternalUrlDecision.disallowedScheme,
      );
      expect(
        resolveExternalUrl('market://details?id=com.example'),
        ExternalUrlDecision.disallowedScheme,
      );
    });

    test('rejects a URL with no scheme', () {
      expect(
        resolveExternalUrl('store.example.com/path'),
        ExternalUrlDecision.disallowedScheme,
      );
    });

    test('is case-insensitive about the scheme', () {
      expect(
        resolveExternalUrl('HTTPS://store.example.com'),
        ExternalUrlDecision.launch,
      );
    });
  });
}
