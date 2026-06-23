import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  group('resolveJsMessageRoute', () {
    test('routes known eventNames to their handler', () {
      expect(resolveJsMessageRoute('REFERRAL_COPY'),
          JsMessageRoute.referralCopy);
      expect(resolveJsMessageRoute('OPEN_EXTERNAL_URL'),
          JsMessageRoute.openExternalUrl);
      expect(resolveJsMessageRoute('INVALID_TOKEN'),
          JsMessageRoute.invalidToken);
      expect(resolveJsMessageRoute('ERROR'), JsMessageRoute.error);
    });

    test('routes unknown and null eventNames to generic', () {
      expect(resolveJsMessageRoute('SOMETHING_ELSE'), JsMessageRoute.generic);
      expect(resolveJsMessageRoute(null), JsMessageRoute.generic);
    });
  });

  group('resolveWebViewLoadError', () {
    test('403 maps to the token error page', () {
      expect(
        resolveWebViewLoadError(
            errorCode: 403, errorType: null, hasCallback: true),
        WebViewLoadAction.tokenErrorPage,
      );
    });

    test('connectivity error types invoke the callback when present', () {
      for (final type in [
        WebResourceErrorType.connect,
        WebResourceErrorType.timeout,
        WebResourceErrorType.hostLookup,
      ]) {
        expect(
          resolveWebViewLoadError(
              errorCode: 0, errorType: type, hasCallback: true),
          WebViewLoadAction.invokeLoadErrorCallback,
        );
      }
    });

    test('connectivity error falls back to the load-error page without a callback',
        () {
      expect(
        resolveWebViewLoadError(
            errorCode: 0,
            errorType: WebResourceErrorType.connect,
            hasCallback: false),
        WebViewLoadAction.loadErrorPage,
      );
    });

    test('the iOS offline code -1009 is treated as a connectivity error', () {
      expect(
        resolveWebViewLoadError(
            errorCode: -1009, errorType: null, hasCallback: false),
        WebViewLoadAction.loadErrorPage,
      );
    });

    test('any other error is ignored', () {
      expect(
        resolveWebViewLoadError(
            errorCode: 500,
            errorType: WebResourceErrorType.unknown,
            hasCallback: true),
        WebViewLoadAction.ignore,
      );
    });
  });
}
