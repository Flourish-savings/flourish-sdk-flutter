import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/web_view/error_presentation.dart';

void main() {
  group('resolveErrorPresentation', () {
    test('returns none when the widget is not mounted', () {
      expect(
        resolveErrorPresentation(isMounted: false, hasCallback: true),
        ErrorPresentation.none,
      );
      expect(
        resolveErrorPresentation(isMounted: false, hasCallback: false),
        ErrorPresentation.none,
      );
    });

    test('invokes the callback when mounted and a callback is provided', () {
      expect(
        resolveErrorPresentation(isMounted: true, hasCallback: true),
        ErrorPresentation.invokeCallback,
      );
    });

    test('navigates to fallback when mounted and no callback is provided', () {
      expect(
        resolveErrorPresentation(isMounted: true, hasCallback: false),
        ErrorPresentation.navigateToFallback,
      );
    });
  });
}
